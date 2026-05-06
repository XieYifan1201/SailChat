import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/user.dart';
import '../services/user_service.dart';
import '../utils/user_storage.dart';

// 当前登录用户信息，全局共享
final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User>>((
  ref,
) {
  return UserNotifier(ref.watch(userServiceProvider));
});

class UserNotifier extends StateNotifier<AsyncValue<User>> {
  final UserService _userService;

  UserNotifier(this._userService) : super(const AsyncValue.loading()) {
    _init();
  }

  // 先读缓存再拉接口，跟聊天记录一个套路
  Future<void> _init() async {
    final cached = await UserStorage.get();
    if (cached != null) {
      state = AsyncValue.data(cached);
    }
    await fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    try {
      final json = await _userService.getProfile();
      final user = User.fromJson(json);
      await UserStorage.save(user);
      state = AsyncValue.data(user);
    } catch (e, st) {
      // 已经有数据就不报错了，下次再拉
      if (state.hasValue) return;
      state = AsyncValue.error(e, st);
    }
  }

  // 退出登录时清掉
  Future<void> clearUser() async {
    await UserStorage.clear();
    state = const AsyncValue.loading();
  }
}
