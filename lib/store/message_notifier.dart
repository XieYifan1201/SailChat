import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/message.dart';
import '../models/system_notification.dart';
import '../services/message_service.dart';
import '../utils/cache_storage.dart';
import 'chat_history_provider.dart';
import 'conversation_provider.dart';
import 'friend_provider.dart';

// 消息收发中枢，发消息、收消息、标记已读都走这里
final messageNotifierProvider =
    StateNotifierProvider<MessageNotifier, AsyncValue<void>>((ref) {
      return MessageNotifier(ref.watch(messageServiceProvider), ref);
    });

class MessageNotifier extends StateNotifier<AsyncValue<void>> {
  final MessageService _service;
  final Ref _ref;

  MessageNotifier(this._service, this._ref)
    : super(const AsyncValue.data(null));

  // 发消息：调接口 → 存本地 → 追加到状态 → 刷新会话列表
  Future<Message> send({
    required int toId,
    required String msgType,
    required String content,
  }) async {
    try {
      final data = await _service.send(
        toId: toId,
        msgType: msgType,
        content: content,
      );
      final msg = Message.fromJson(data);
      await CacheStorage.appendSingleMessage(toId, msg);
      // 直接追加到状态，不走 invalidate
      _ref.read(chatHistoryProvider(toId).notifier).addMessage(msg);
      _ref.invalidate(conversationListProvider);
      return msg;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> markRead({required int fromId}) async {
    try {
      await _service.markRead(fromId: fromId);
      await CacheStorage.markLocalMessagesAsRead(fromId);
      _ref
          .read(chatHistoryProvider(fromId).notifier)
          .markMessagesAsRead(fromId);
      _ref.invalidate(conversationListProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // WebSocket 收到消息时调用，判断属于哪个会话然后追加
  Future<void> onReceiveMessage(Message msg, int currentUserId) async {
    final targetId = msg.fromId == currentUserId ? msg.toId : msg.fromId;
    await CacheStorage.appendSingleMessage(targetId, msg);
    _ref.read(chatHistoryProvider(targetId).notifier).addMessage(msg);
    _ref.invalidate(conversationListProvider);
  }

  // 系统通知：好友申请/同意/拒绝，刷新对应列表就行
  void handleNotification(SystemNotification notification) {
    switch (notification.type) {
      case NotificationType.friendApply:
        _ref.invalidate(friendRequestListProvider);
        break;
      case NotificationType.friendAccept:
        _ref.invalidate(friendListProvider);
        _ref.invalidate(friendRequestListProvider);
        break;
      case NotificationType.friendReject:
        _ref.invalidate(friendRequestListProvider);
        break;
    }
  }
}
