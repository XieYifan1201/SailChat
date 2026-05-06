import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../store/auth_provider.dart';
import '../utils/token.dart';

// 全局 Dio 实例，自动带 token 和错误处理
final httpClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      // 登录注册接口要 form-urlencoded，其他接口默认 json
      contentType: 'application/x-www-form-urlencoded',
    ),
  );

  // 不需要鉴权的路径，登录/注册/验证码
  const noAuthPaths = ['/user/login', '/user/register', '/captcha'];

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 不需要 token 的接口就不带，避免过期 token 干扰
        if (!noAuthPaths.contains(options.path)) {
          final token = await TokenStorage.get();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // 401 清 token + 通知 authProvider，路由守卫会自动跳登录页
        if (error.response?.statusCode == 401) {
          await TokenStorage.clear();
          ref.read(authProvider.notifier).onTokenExpired();
        }
        handler.next(error);
      },
    ),
  );

  return dio;
});
