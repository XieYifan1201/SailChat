import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'http_client.dart';

final friendServiceProvider = Provider<FriendService>((ref) {
  return FriendService(ref.watch(httpClientProvider));
});

// 好友相关接口：列表、申请、同意/拒绝
class FriendService {
  final Dio _http;

  FriendService(this._http);

  Future<List<Map<String, dynamic>>> getFriendList() async {
    final res = await _http.get('/friend/list');
    return (res.data['data'] as List).cast<Map<String, dynamic>>();
  }

  // 按用户名搜人，走的是 /user/search 不是 /friend/search
  Future<List<Map<String, dynamic>>> searchFriends(String username) async {
    final res = await _http.get(
      '/user/search',
      queryParameters: {'username': username},
    );
    return (res.data['data'] as List).cast<Map<String, dynamic>>();
  }

  // 发好友申请，toUsername 是对方用户名
  Future<void> apply({required String toUsername, String? message}) async {
    await _http.post(
      '/friend/apply',
      data: {'toUsername': toUsername, if (message != null) 'message': message},
      options: Options(contentType: 'application/json'),
    );
  }

  // 同意申请，路径参数
  Future<void> accept({required int requestId}) async {
    await _http.post('/friend/accept/$requestId');
  }

  // 拒绝申请
  Future<void> reject({required int requestId}) async {
    await _http.post('/friend/reject/$requestId');
  }

  // 收到的好友申请列表
  Future<List<Map<String, dynamic>>> getRequests() async {
    final res = await _http.get('/friend/requests');
    return (res.data['data'] as List).cast<Map<String, dynamic>>();
  }

  // 删好友
  Future<void> delete({required int friendId}) async {
    await _http.delete('/friend/delete/$friendId');
  }
}
