import 'dart:convert';

// 当前登录用户的完整信息
class User {
  final int id;
  final String username;
  final String email;
  final String avatar;
  final String nickname;
  final int gender; // 0未知 1男 2女
  final int onlineStatus; // 0离线 1在线
  final int status;
  final String region;
  final String signature;
  final DateTime createTime;
  final DateTime updateTime;
  final DateTime? lastActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.nickname,
    required this.gender,
    required this.onlineStatus,
    required this.status,
    required this.region,
    required this.signature,
    required this.createTime,
    required this.updateTime,
    this.lastActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '',
      nickname: json['nickname'] ?? '',
      gender: json['gender'] ?? 0,
      onlineStatus: json['onlineStatus'] ?? 0,
      status: json['status'] ?? 0,
      region: json['region'] ?? '',
      signature: json['signature'] ?? '',
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'avatar': avatar,
    'nickname': nickname,
    'gender': gender,
    'onlineStatus': onlineStatus,
    'status': status,
    'region': region,
    'signature': signature,
    'createTime': createTime.toIso8601String(),
    'updateTime': updateTime.toIso8601String(),
    'lastActive': lastActive?.toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());

  static User fromJsonString(String s) =>
      User.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
