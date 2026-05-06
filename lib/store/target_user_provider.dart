import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/friend_request.dart';
import 'conversation_provider.dart';
import 'friend_provider.dart';

// 根据 targetId 找对方的 UserBrief，先查好友列表再查会话列表
final targetUserProvider = FutureProvider.family<UserBrief?, int>((
  ref,
  targetId,
) async {
  UserBrief? result;

  // 优先从好友列表找，信息更全
  final friendsAsync = ref.watch(friendListProvider);
  friendsAsync.whenData((friends) {
    for (final f in friends) {
      if (f.friendId == targetId) result = f.friendUser;
    }
  });
  if (result != null) return result;

  // 好友列表没找到，从会话列表的 targetUser 取
  final convsAsync = ref.watch(conversationListProvider);
  convsAsync.whenData((convs) {
    for (final c in convs) {
      if (c.targetId == targetId) result = c.targetUser;
    }
  });
  return result;
});
