import 'dart:convert';

import 'friend_request.dart';

// 好友关系，friendUser 从后端的 friendInfo 字段解析
class Friend {
  final int id;
  final int userId;
  final int friendId;
  final int status;
  final String remark;
  final DateTime? applyTime;
  final DateTime? acceptTime;
  final DateTime createTime;
  final DateTime updateTime;

  UserBrief? friendUser;

  Friend({
    required this.id,
    required this.userId,
    required this.friendId,
    required this.status,
    required this.remark,
    this.applyTime,
    this.acceptTime,
    required this.createTime,
    required this.updateTime,
    this.friendUser,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      friendId: json['friendId'] ?? 0,
      status: json['status'] ?? 1,
      remark: json['remark'] ?? '',
      applyTime: json['applyTime'] != null
          ? DateTime.parse(json['applyTime'])
          : null,
      acceptTime: json['acceptTime'] != null
          ? DateTime.parse(json['acceptTime'])
          : null,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      friendUser: json['friendInfo'] != null
          ? UserBrief.fromJson(json['friendInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'friendId': friendId,
    'status': status,
    'remark': remark,
    'applyTime': applyTime?.toIso8601String(),
    'acceptTime': acceptTime?.toIso8601String(),
    'createTime': createTime.toIso8601String(),
    'updateTime': updateTime.toIso8601String(),
    'friendInfo': friendUser?.toJson(),
  };

  String toJsonString() => jsonEncode(toJson());

  static Friend fromJsonString(String s) =>
      Friend.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
