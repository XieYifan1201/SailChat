import 'dart:convert';

import 'friend_request.dart';

// 会话列表项，targetUser 可能没值，得从好友列表补
class Conversation {
  final int id;
  final int userId;
  final int targetId;
  final String lastMessage;
  final DateTime lastMsgTime;
  final int unreadCount;
  final DateTime createTime;
  final DateTime updateTime;

  UserBrief? targetUser;

  Conversation({
    required this.id,
    required this.userId,
    required this.targetId,
    required this.lastMessage,
    required this.lastMsgTime,
    required this.unreadCount,
    required this.createTime,
    required this.updateTime,
    this.targetUser,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      userId: json['userId'],
      targetId: json['targetId'],
      lastMessage: json['lastMessage'] ?? '',
      lastMsgTime: DateTime.parse(json['lastMsgTime']),
      unreadCount: json['unreadCount'] ?? 0,
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime']),
      targetUser: json['targetUser'] != null
          ? UserBrief.fromJson(json['targetUser'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'targetId': targetId,
    'lastMessage': lastMessage,
    'lastMsgTime': lastMsgTime.toIso8601String(),
    'unreadCount': unreadCount,
    'createTime': createTime.toIso8601String(),
    'updateTime': updateTime.toIso8601String(),
    'targetUser': targetUser?.toJson(),
  };

  String toJsonString() => jsonEncode(toJson());

  static Conversation fromJsonString(String s) =>
      Conversation.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
