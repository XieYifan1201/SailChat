import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/conversation.dart';
import '../services/message_service.dart';
import '../utils/cache_storage.dart';
import 'riverpod.dart';

// 会话列表，先读缓存再拉接口
final conversationListProvider = FutureProvider<List<Conversation>>((
  ref,
) async {
  final cached = await CacheStorage.getConversations();
  try {
    final service = ref.watch(messageServiceProvider);
    final data = await service.getConversations();
    final conversations = data.map((e) => Conversation.fromJson(e)).toList();
    await CacheStorage.saveConversations(conversations);
    return conversations;
  } catch (e) {
    // 接口挂了就用缓存顶一下
    if (cached != null) return cached;
    rethrow;
  }
});
