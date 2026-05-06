import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/message.dart';
import '../services/message_service.dart';
import '../utils/cache_storage.dart';

// 每个聊天对象一个 notifier，family 参数是 targetId
final chatHistoryProvider =
    StateNotifierProvider.family<
      ChatHistoryNotifier,
      AsyncValue<List<Message>>,
      int
    >((ref, targetId) {
      return ChatHistoryNotifier(targetId, ref.watch(messageServiceProvider));
    });

// 用 StateNotifier 而不是 FutureProvider，这样发消息可以直接 addMessage，不用 invalidate
class ChatHistoryNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final int targetId;
  final MessageService _service;

  ChatHistoryNotifier(this.targetId, this._service)
    : super(const AsyncValue.loading()) {
    _load();
  }

  // 先展示缓存，再拉未读合并
  Future<void> _load() async {
    final cached = await CacheStorage.getChatHistory(targetId);
    if (cached != null && cached.isNotEmpty) {
      state = AsyncValue.data(cached);
    }
    try {
      final data = await _service.getUnreadHistory(targetId: targetId);
      final unread = data.map((e) => Message.fromJson(e)).toList();
      await CacheStorage.appendChatHistory(targetId, unread);
      final all = await CacheStorage.getChatHistory(targetId);
      state = AsyncValue.data(all ?? unread);
    } catch (e, st) {
      // 有缓存就先用着，不报错
      if (cached == null || cached.isEmpty) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  // 发消息/收消息时直接追加，避免 invalidate 导致列表闪一下
  void addMessage(Message msg) {
    final current = state.value ?? [];
    if (current.any((m) => m.id == msg.id)) return;
    state = AsyncValue.data([...current, msg]);
  }

  // 把对方发的未读消息标成已读
  void markMessagesAsRead(int fromId) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      current.map((m) {
        if (m.fromId == fromId && m.status == 0) {
          return Message(
            id: m.id,
            fromId: m.fromId,
            toId: m.toId,
            msgType: m.msgType,
            content: m.content,
            status: 1,
            createTime: m.createTime,
            readTime: DateTime.now(),
          );
        }
        return m;
      }).toList(),
    );
  }

  Future<void> refresh() async {
    await _load();
  }
}
