import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/friend.dart';
import '../models/friend_request.dart';
import '../services/friend_service.dart';
import '../utils/cache_storage.dart';

// 好友申请列表，带缓存兜底
final friendRequestListProvider = FutureProvider<List<FriendRequest>>((
  ref,
) async {
  final cached = await CacheStorage.getFriendRequests();
  try {
    final service = ref.watch(friendServiceProvider);
    final data = await service.getRequests();
    final requests = data.map((e) => FriendRequest.fromJson(e)).toList();
    await CacheStorage.saveFriendRequests(requests);
    return requests;
  } catch (e) {
    if (cached != null) return cached;
    rethrow;
  }
});

// 好友列表
final friendListProvider = FutureProvider<List<Friend>>((ref) async {
  final cached = await CacheStorage.getFriendList();
  try {
    final service = ref.watch(friendServiceProvider);
    final data = await service.getFriendList();
    final friends = data.map((e) => Friend.fromJson(e)).toList();
    await CacheStorage.saveFriendList(friends);
    return friends;
  } catch (e) {
    if (cached != null) return cached;
    rethrow;
  }
});

// 待处理的申请数，给底部导航小红点用
final pendingRequestCountProvider = Provider<int>((ref) {
  final requestsAsync = ref.watch(friendRequestListProvider);
  return requestsAsync.whenOrNull<int>(
        data: (list) => list.where((r) => r.status == 0).length,
      ) ??
      0;
});

// 好友操作：申请、同意、拒绝
class FriendNotifier extends StateNotifier<AsyncValue<void>> {
  final FriendService _friendService;
  final Ref _ref;

  FriendNotifier(this._friendService, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> apply({required String toUsername, String? message}) async {
    try {
      await _friendService.apply(toUsername: toUsername, message: message);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> accept({required int requestId}) async {
    try {
      await _friendService.accept(requestId: requestId);
      _ref.invalidate(friendRequestListProvider);
      _ref.invalidate(friendListProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> reject({required int requestId}) async {
    try {
      await _friendService.reject(requestId: requestId);
      _ref.invalidate(friendRequestListProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final friendNotifierProvider =
    StateNotifierProvider<FriendNotifier, AsyncValue<void>>((ref) {
      return FriendNotifier(ref.watch(friendServiceProvider), ref);
    });
