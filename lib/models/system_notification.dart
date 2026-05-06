import 'dart:convert';

// WebSocket 推送的系统通知
enum NotificationType {
  friendApply,
  friendAccept,
  friendReject;

  static NotificationType fromString(String value) {
    return switch (value) {
      'friend_apply' => NotificationType.friendApply,
      'friend_accept' => NotificationType.friendAccept,
      'friend_reject' => NotificationType.friendReject,
      _ => throw ArgumentError('Unknown notification type: $value'),
    };
  }
}

class SystemNotification {
  final NotificationType type;
  final String content;
  final Map<String, dynamic> data;
  final DateTime time;

  SystemNotification({
    required this.type,
    required this.content,
    required this.data,
    required this.time,
  });

  factory SystemNotification.fromJson(Map<String, dynamic> json) {
    return SystemNotification(
      type: NotificationType.fromString(json['type'] as String),
      content: json['content'] ?? '',
      data: json['data'] as Map<String, dynamic>? ?? {},
      time: DateTime.parse(json['time'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'content': content,
    'data': data,
    'time': time.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());

  static SystemNotification fromJsonString(String s) =>
      SystemNotification.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
