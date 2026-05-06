import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/conversation.dart';
import '../models/friend_request.dart';
import '../socket/chat_websocket.dart';
import '../store/conversation_provider.dart';
import '../store/friend_provider.dart';
import '../store/ws_provider.dart';
import '../utils/app_colors.dart';
import '../utils/user_avatar.dart';

// 会话列表页
class ChatsPage extends ConsumerWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = c(context);
    final l10n = AppLocalizations.of(context)!;
    final conversationsAsync = ref.watch(conversationListProvider);
    final friendsAsync = ref.watch(friendListProvider);
    final wsStatusAsync = ref.watch(wsStatusProvider);

    // 从好友列表构建 id -> UserBrief 映射，用于显示昵称
    final Map<int, UserBrief> friendMap = {};
    friendsAsync.whenData((friends) {
      for (final f in friends) {
        if (f.friendUser != null) {
          friendMap[f.friendId] = f.friendUser!;
        }
      }
    });

    final wsStatus = wsStatusAsync.value ?? WsStatus.disconnected;
    final statusSuffix = switch (wsStatus) {
      WsStatus.connected => '',
      WsStatus.connecting => '（${l10n.connecting}）',
      WsStatus.failed => '（${l10n.connectionFailed}）',
      WsStatus.disconnected => '',
    };

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, colors, l10n, statusSuffix),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: conversationsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Text(
                      '${l10n.loadFailed}: $e',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                ),
              ),
              data: (conversations) {
                if (conversations.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Text(
                          l10n.noConversations,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildChatCard(
                      context,
                      colors,
                      l10n,
                      conversations[index],
                      friendMap,
                    ),
                    childCount: conversations.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 会话列表顶栏
  Widget _buildHeader(
    BuildContext context,
    AppColors colors,
    AppLocalizations l10n,
    String statusSuffix,
  ) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        colors.primary,
                        colors.primaryLight,
                        colors.primaryGradientEnd,
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'SailChat',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (statusSuffix.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      statusSuffix,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.push('/add-friend'),
                    child: _buildHeaderIcon(colors, Icons.add),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.inputFill,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 18, color: colors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  l10n.searchRoutes,
                  style: TextStyle(color: colors.textSecondary, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(AppColors colors, IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: colors.iconBg, shape: BoxShape.circle),
      child: Center(child: Icon(icon, size: 18, color: colors.textPrimary)),
    );
  }

  // 单个会话卡片，显示头像、昵称、最后一条消息、未读数
  Widget _buildChatCard(
    BuildContext context,
    AppColors colors,
    AppLocalizations l10n,
    Conversation conv,
    Map<int, UserBrief> friendMap,
  ) {
    // 优先用好友列表的昵称，其次会话中的 targetUser，最后兜底
    final friendUser = friendMap[conv.targetId];
    final name =
        conv.targetUser?.nickname ??
        friendUser?.nickname ??
        conv.targetUser?.username ??
        friendUser?.username ??
        l10n.userPrefix(conv.targetId.toString());
    final avatarUrl = conv.targetUser?.avatar ?? friendUser?.avatar;
    final timeStr = _formatTime(conv.lastMsgTime, l10n);

    return GestureDetector(
      onTap: () => context.push('/chat/${conv.targetId}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            UserAvatar(avatarUrl: avatarUrl, name: name, size: 56, radius: 16),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conv.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (conv.unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.badge,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${conv.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    if (target == today) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (target == today.subtract(const Duration(days: 1))) {
      return l10n.yesterday;
    } else {
      return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}';
    }
  }
}
