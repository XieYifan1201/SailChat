import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../models/system_notification.dart';
import '../socket/chat_websocket.dart';

// WebSocket 单例，生命周期跟 app 一样长
final wsProvider = Provider<ChatWebSocket>((ref) {
  final ws = ChatWebSocket('10.0.2.2:8080');
  ref.onDispose(() => ws.dispose());
  return ws;
});

// 下面三个 provider 把 WebSocket 的 stream 桥接到 Riverpod
final wsStatusProvider = StreamProvider<WsStatus>((ref) {
  return ref.watch(wsProvider).onStatusChange;
});

final realtimeMessageProvider = StreamProvider<Message>((ref) {
  return ref.watch(wsProvider).onMessage;
});

final realtimeNotificationProvider = StreamProvider<SystemNotification>((ref) {
  return ref.watch(wsProvider).onNotification;
});
