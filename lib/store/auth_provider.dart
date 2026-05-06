import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../utils/token.dart';
import 'ws_provider.dart';

// 登录状态，token 有值就是已登录
final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<String?> {
  final Ref _ref;
  bool loading = true;

  AuthNotifier(this._ref) : super(null) {
    _init();
  }

  // 启动时看本地有没有 token，有的话自动连 WebSocket
  Future<void> _init() async {
    state = await TokenStorage.get();
    loading = false;
    if (state != null) {
      _ref.read(wsProvider).connect();
    }
  }

  Future<void> login(String token) async {
    await TokenStorage.save(token);
    state = token;
    _ref.read(wsProvider).connect();
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    _ref.read(wsProvider).disconnect();
    state = null;
  }

  // token 过期时调用，清状态让路由守卫跳登录页
  void onTokenExpired() {
    state = null;
  }
}
