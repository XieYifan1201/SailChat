import 'dart:convert';

// 聊天消息，status: 0未读 1已读，msgType: text/image/video
class Message {
  final int id;
  final int fromId;
  final int toId;
  final String msgType;
  final String content;
  final int status;
  final DateTime createTime;
  final DateTime? readTime;

  Message({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.msgType,
    required this.content,
    required this.status,
    required this.createTime,
    this.readTime,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      fromId: json['fromId'],
      toId: json['toId'],
      msgType: json['msgType'] ?? 'text',
      content: json['content'] ?? '',
      status: json['status'] ?? 0,
      createTime: DateTime.parse(json['createTime']),
      readTime: json['readTime'] != null
          ? DateTime.parse(json['readTime'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromId': fromId,
    'toId': toId,
    'msgType': msgType,
    'content': content,
    'status': status,
    'createTime': createTime.toIso8601String(),
    'readTime': readTime?.toIso8601String(),
  };

  // 这俩方法给本地缓存用的，SharedPreferences 只能存字符串
  String toJsonString() => jsonEncode(toJson());

  static Message fromJsonString(String s) =>
      Message.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
