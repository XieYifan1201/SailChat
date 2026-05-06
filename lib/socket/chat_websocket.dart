import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/message.dart';
import '../models/system_notification.dart';
import '../utils/token.dart';

enum WsStatus { disconnected, connecting, connected, failed }

// WebSocket 封装，连上后通过 stream 分发消息和通知
class ChatWebSocket {
  final String _host;
  WebSocketChannel? _channel;
  WsStatus _status = WsStatus.disconnected;

  final _msgCtrl = StreamController<Message>.broadcast();
  final _notifCtrl = StreamController<SystemNotification>.broadcast();
  final _statusCtrl = StreamController<WsStatus>.broadcast();

  ChatWebSocket(this._host);

  WsStatus get status => _status;
  Stream<Message> get onMessage => _msgCtrl.stream;
  Stream<SystemNotification> get onNotification => _notifCtrl.stream;
  Stream<WsStatus> get onStatusChange => _statusCtrl.stream;

  void _setStatus(WsStatus s) {
    _status = s;
    _statusCtrl.add(s);
  }

  // 连接 WebSocket，token 通过 query 参数传
  Future<void> connect() async {
    if (_status == WsStatus.connected || _status == WsStatus.connecting) return;

    final token = await TokenStorage.get();
    if (token == null) {
      _setStatus(WsStatus.failed);
      return;
    }

    _setStatus(WsStatus.connecting);
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$_host/ws/chat?token=$token'),
      );
      _channel!.stream.listen(
        (data) {
          if (_status != WsStatus.connected) _setStatus(WsStatus.connected);
          try {
            final json = jsonDecode(data as String) as Map<String, dynamic>;
            // 有 type 字段的是系统通知，有 msgType 的是聊天消息
            if (json.containsKey('type')) {
              _notifCtrl.add(SystemNotification.fromJson(json));
            } else if (json.containsKey('msgType')) {
              _msgCtrl.add(Message.fromJson(json));
            }
          } catch (_) {}
        },
        onDone: () => _setStatus(WsStatus.disconnected),
        onError: (_) => _setStatus(WsStatus.failed),
      );
      await _channel!.ready;
      _setStatus(WsStatus.connected);
    } catch (_) {
      _setStatus(WsStatus.failed);
    }
  }

  // 发消息走 WebSocket，不用等 REST 接口返回
  void send({
    required int toId,
    required String msgType,
    required String content,
  }) {
    if (_status != WsStatus.connected || _channel == null) return;
    _channel!.sink.add(
      jsonEncode({'toId': toId, 'msgType': msgType, 'content': content}),
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _setStatus(WsStatus.disconnected);
  }

  void dispose() {
    disconnect();
    _msgCtrl.close();
    _notifCtrl.close();
    _statusCtrl.close();
  }
}
