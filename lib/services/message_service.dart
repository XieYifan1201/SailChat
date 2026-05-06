import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'http_client.dart';

final messageServiceProvider = Provider<MessageService>((ref) {
  return MessageService(ref.watch(httpClientProvider));
});

// 消息相关接口：发消息、历史记录、上传文件
class MessageService {
  final Dio _http;

  MessageService(this._http);

  // 发消息，返回完整消息体（含 id、createTime 等）
  Future<Map<String, dynamic>> send({
    required int toId,
    required String msgType,
    required String content,
  }) async {
    final res = await _http.post(
      '/message/send',
      data: {'toId': toId, 'msgType': msgType, 'content': content},
      options: Options(contentType: 'application/json'),
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  // 拉未读历史，后端只返回对方发的未读消息
  Future<List<Map<String, dynamic>>> getUnreadHistory({required int targetId}) async {
    final res = await _http.get('/message/history/$targetId');
    return (res.data['data'] as List).cast<Map<String, dynamic>>();
  }

  // 标记已读
  Future<void> markRead({required int fromId}) async {
    await _http.post('/message/read/$fromId');
  }

  // 会话列表
  Future<List<Map<String, dynamic>>> getConversations() async {
    final res = await _http.get('/message/conversations');
    return (res.data['data'] as List).cast<Map<String, dynamic>>();
  }

  // 上传图片/视频，返回文件 URL
  Future<String> uploadFile({required String filePath, required String type}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'type': type,
    });
    final res = await _http.post('/message/upload', data: formData);
    return res.data['data'] as String;
  }
}
