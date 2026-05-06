import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'http_client.dart';

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(httpClientProvider));
});

// 用户相关接口：登录注册、个人信息、搜索
class UserService {
  final Dio _http;

  UserService(this._http);

  // 登录，拿到 token
  Future<String> login({
    required String username,
    required String password,
    String? captchaCode,
  }) async {
    final data = {'username': username, 'password': password};
    if (captchaCode != null) data['captchaCode'] = captchaCode;
    final res = await _http.post('/user/login', data: data);
    return res.data['data'] as String;
  }

  Future<void> register({
    required String username,
    required String password,
    required String email,
    String? captchaCode,
  }) async {
    final data = {'username': username, 'password': password, 'email': email};
    if (captchaCode != null) data['captchaCode'] = captchaCode;
    await _http.post('/user/register', data: data);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await _http.get('/user/userInfo');
    return res.data['data'] as Map<String, dynamic>;
  }

  // 改资料，只传需要改的字段
  Future<void> updateProfile({
    String? nickname,
    String? avatar,
    int? gender,
    String? region,
    String? signature,
  }) async {
    final data = <String, dynamic>{};
    if (nickname != null) data['nickname'] = nickname;
    if (avatar != null) data['avatar'] = avatar;
    if (gender != null) data['gender'] = gender;
    if (region != null) data['region'] = region;
    if (signature != null) data['signature'] = signature;
    await _http.put(
      '/user/update',
      data: data,
      options: Options(contentType: 'application/json'),
    );
  }

  // 上传头像，返回新头像 URL
  Future<String> uploadAvatar({required String filePath}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final res = await _http.post('/user/avatar', data: formData);
    return res.data['data'] as String;
  }

  // 按用户名搜人
  Future<List<Map<String, dynamic>>> searchUsers(String username) async {
    final res = await _http.get(
      '/user/search',
      queryParameters: {'username': username},
    );
    return (res.data['data'] as List).cast<Map<String, dynamic>>();
  }
}
