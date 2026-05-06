import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import '../models/friend_request.dart';
import '../models/message.dart';
import '../store/chat_history_provider.dart';
import '../store/friend_provider.dart';
import '../store/message_notifier.dart';
import '../store/riverpod.dart';
import '../store/target_user_provider.dart';
import '../store/user_provider.dart';
import '../store/ws_provider.dart';
import '../utils/app_colors.dart';
import '../utils/user_avatar.dart';

// 聊天页，targetId 是对方的用户 ID
class ChatPage extends ConsumerStatefulWidget {
  final int targetId;

  const ChatPage({super.key, required this.targetId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  bool _hasAutoMarkedRead = false;
  bool _isSendingMedia = false;

  static const _baseUrl = 'http://10.0.2.2:8080';

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // 发文字消息
  void _sendTextMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    ref
        .read(messageNotifierProvider.notifier)
        .send(toId: widget.targetId, msgType: 'text', content: text);
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image == null) return;
    await _sendMediaFile(image.path, 'image');
  }

  Future<void> _pickAndSendVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video == null) return;
    await _sendMediaFile(video.path, 'video');
  }

  // 发图片/视频：先上传文件拿到 URL，再发消息
  Future<void> _sendMediaFile(String filePath, String type) async {
    setState(() => _isSendingMedia = true);
    try {
      final service = ref.read(messageServiceProvider);
      final url = await service.uploadFile(filePath: filePath, type: type);
      await ref
          .read(messageNotifierProvider.notifier)
          .send(toId: widget.targetId, msgType: type, content: url);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.uploadFailed)));
      }
    } finally {
      if (mounted) setState(() => _isSendingMedia = false);
    }
  }

  // 当前登录用户 ID，用来判断消息是发的还是收的
  int? get _currentUserId {
    final userState = ref.read(userProvider);
    return userState.value?.id;
  }

  @override
  Widget build(BuildContext context) {
    final colors = c(context);
    final l10n = AppLocalizations.of(context)!;
    final historyAsync = ref.watch(chatHistoryProvider(widget.targetId));
    final targetUserAsync = ref.watch(targetUserProvider(widget.targetId));
    final friendsAsync = ref.watch(friendListProvider);

    // 收到实时消息后自动标记已读
    ref.listen<AsyncValue<Message>>(realtimeMessageProvider, (_, next) {
      next.whenData((msg) {
        if (msg.fromId == widget.targetId) {
          ref
              .read(messageNotifierProvider.notifier)
              .markRead(fromId: widget.targetId);
        }
      });
    });

    // 进入聊天页自动标记已读
    historyAsync.whenData((_) {
      if (!_hasAutoMarkedRead) {
        _hasAutoMarkedRead = true;
        ref
            .read(messageNotifierProvider.notifier)
            .markRead(fromId: widget.targetId);
      }
    });

    // 名字优先取 nickname，没有再取 username，两边都查（会话 + 好友列表）
    final targetUser = targetUserAsync.whenOrNull<UserBrief?>(data: (u) => u);
    final friendUser = friendsAsync.whenOrNull<UserBrief?>(
      data: (list) {
        for (final f in list) {
          if (f.friendId == widget.targetId) return f.friendUser;
        }
        return null;
      },
    );

    final String targetName = targetUser?.nickname.isNotEmpty == true
        ? targetUser!.nickname
        : friendUser?.nickname.isNotEmpty == true
        ? friendUser!.nickname
        : targetUser?.username ?? friendUser?.username ?? l10n.chat;

    final String? targetAvatar = targetUser?.avatar ?? friendUser?.avatar;

    final List<Message> messages = [];
    historyAsync.whenData((list) => messages.addAll(list));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(
              avatarUrl: targetAvatar,
              name: targetName,
              size: 32,
              radius: 8,
            ),
            const SizedBox(width: 10),
            Text(
              targetName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l10n.loadFailed}: $e')),
              data: (_) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noMessages,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                // 新消息来了自动滚到底
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(colors, messages[index]),
                );
              },
            ),
          ),
          if (_isSendingMedia)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: colors.card,
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.uploading,
                    style: TextStyle(color: colors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          _buildInputBar(colors, l10n),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AppColors colors, Message msg) {
    final isMe = msg.fromId == _currentUserId;
    final timeStr =
        '${msg.createTime.hour.toString().padLeft(2, '0')}:${msg.createTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[_buildTargetAvatar(), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageContent(colors, msg, isMe),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: TextStyle(fontSize: 11, color: colors.textTertiary),
                ),
              ],
            ),
          ),
          if (isMe) ...[const SizedBox(width: 8), _buildMyAvatar(colors)],
        ],
      ),
    );
  }

  Widget _buildTargetAvatar() {
    final targetUser = ref
        .watch(targetUserProvider(widget.targetId))
        .whenOrNull<UserBrief?>(data: (u) => u);
    final friendUser = ref
        .watch(friendListProvider)
        .whenOrNull<UserBrief?>(
          data: (list) {
            for (final f in list) {
              if (f.friendId == widget.targetId) return f.friendUser;
            }
            return null;
          },
        );
    final name = targetUser?.nickname.isNotEmpty == true
        ? targetUser!.nickname
        : friendUser?.nickname.isNotEmpty == true
        ? friendUser!.nickname
        : targetUser?.username ?? friendUser?.username ?? '?';
    final avatar = targetUser?.avatar ?? friendUser?.avatar;
    return UserAvatar(avatarUrl: avatar, name: name, size: 36, radius: 10);
  }

  Widget _buildMyAvatar(AppColors colors) {
    final userAsync = ref.watch(userProvider);
    final name = userAsync.value?.nickname.isNotEmpty == true
        ? userAsync.value!.nickname
        : userAsync.value?.username ?? '?';
    final avatar = userAsync.value?.avatar;
    return UserAvatar(avatarUrl: avatar, name: name, size: 36, radius: 10);
  }

  Widget _buildMessageContent(AppColors colors, Message msg, bool isMe) {
    final bgColor = isMe ? colors.chatBubbleMe : colors.chatBubbleOther;
    final textColor = isMe ? Colors.white : colors.textPrimary;

    switch (msg.msgType) {
      case 'image':
        return _buildImageBubble(msg.content, isMe);
      case 'video':
        return _buildVideoBubble(colors, msg.content, isMe);
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.content,
            style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
          ),
        );
    }
  }

  Widget _buildImageBubble(String content, bool isMe) {
    final url = content.startsWith('http') ? content : '$_baseUrl$content';
    return GestureDetector(
      onTap: () => _showImagePreview(url),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isMe ? 16 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 16),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.55,
            maxHeight: 300,
          ),
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
              width: 200,
              height: 150,
              color: Colors.grey[200],
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            errorWidget: (_, _, _) => Container(
              width: 200,
              height: 150,
              color: Colors.grey[200],
              child: const Icon(Icons.broken_image, size: 40),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBubble(AppColors colors, String content, bool isMe) {
    final url = content.startsWith('http') ? content : '$_baseUrl$content';
    return GestureDetector(
      onTap: () => _showVideoPreview(url),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.55,
        ),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 220,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                color: Colors.black54,
              ),
              child: const Icon(
                Icons.videocam,
                color: Colors.white54,
                size: 40,
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow, color: colors.primary, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  void _showVideoPreview(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: Text(
              'Video: $url',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(AppColors colors, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(top: BorderSide(color: colors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: _isSendingMedia ? null : _pickAndSendImage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.image_outlined,
                  size: 20,
                  color: _isSendingMedia
                      ? colors.textTertiary
                      : colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: _isSendingMedia ? null : _pickAndSendVideo,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videocam_outlined,
                  size: 20,
                  color: _isSendingMedia
                      ? colors.textTertiary
                      : colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: colors.inputFill,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: l10n.inputMessage,
                    hintStyle: TextStyle(
                      color: colors.textTertiary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  style: TextStyle(fontSize: 15, color: colors.textPrimary),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendTextMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendTextMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.primaryGradientEnd],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
