import 'dart:convert';

// 好友申请，status: 0待处理 1已同意 2已拒绝
class FriendRequest {
  final int id;
  final int fromId;
  final int toId;
  final int status;
  final String message;
  final DateTime createTime;
  final DateTime? handleTime;

  UserBrief? fromUser;

  FriendRequest({
    required this.id,
    required this.fromId,
    required this.toId,
    required this.status,
    required this.message,
    required this.createTime,
    this.handleTime,
    this.fromUser,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      fromId: json['fromId'],
      toId: json['toId'],
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      createTime: DateTime.parse(json['createTime']),
      handleTime: json['handleTime'] != null
          ? DateTime.parse(json['handleTime'])
          : null,
      fromUser: json['fromUser'] != null
          ? UserBrief.fromJson(json['fromUser'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromId': fromId,
        'toId': toId,
        'status': status,
        'message': message,
        'createTime': createTime.toIso8601String(),
        'handleTime': handleTime?.toIso8601String(),
        'fromUser': fromUser?.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());

  static FriendRequest fromJsonString(String s) =>
      FriendRequest.fromJson(jsonDecode(s) as Map<String, dynamic>);
}

// 用户简要信息，嵌套在好友列表、申请列表、会话里用
class UserBrief {
  final int id;
  final String username;
  final String nickname;
  final String avatar;
  final int gender;

  UserBrief({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatar,
    required this.gender,
  });

  factory UserBrief.fromJson(Map<String, dynamic> json) {
    return UserBrief(
      id: json['id'],
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? '',
      avatar: json['avatar'] ?? '',
      gender: json['gender'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'nickname': nickname,
        'avatar': avatar,
        'gender': gender,
      };

  String toJsonString() => jsonEncode(toJson());

  static UserBrief fromJsonString(String s) =>
      UserBrief.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
