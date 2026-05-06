import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/conversation.dart';
import '../models/friend.dart';
import '../models/friend_request.dart';
import '../models/message.dart';

// 本地缓存，全走 SharedPreferences，存 JSON 字符串
class CacheStorage {
  static const _conversationsKey = 'cached_conversations';
  static const _friendListKey = 'cached_friend_list';
  static const _friendRequestsKey = 'cached_friend_requests';
  static const _chatHistoryPrefix = 'cached_chat_history_';

  // ---- 会话列表 ----

  static Future<void> saveConversations(List<Conversation> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _conversationsKey,
      jsonEncode(list.map((e) => e.toJsonString()).toList()),
    );
  }

  static Future<List<Conversation>?> getConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_conversationsKey);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Conversation.fromJsonString(e as String))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ---- 好友列表 ----

  static Future<void> saveFriendList(List<Friend> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _friendListKey,
      jsonEncode(list.map((e) => e.toJsonString()).toList()),
    );
  }

  static Future<List<Friend>?> getFriendList() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_friendListKey);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Friend.fromJsonString(e as String))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ---- 好友申请 ----

  static Future<void> saveFriendRequests(List<FriendRequest> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _friendRequestsKey,
      jsonEncode(list.map((e) => e.toJsonString()).toList()),
    );
  }

  static Future<List<FriendRequest>?> getFriendRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_friendRequestsKey);
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => FriendRequest.fromJsonString(e as String))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ---- 聊天记录（按 targetId 分开存） ----

  static Future<void> saveChatHistory(int targetId, List<Message> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_chatHistoryPrefix$targetId',
      jsonEncode(list.map((e) => e.toJsonString()).toList()),
    );
  }

  static Future<List<Message>?> getChatHistory(int targetId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_chatHistoryPrefix$targetId');
    if (raw == null) return null;
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Message.fromJsonString(e as String))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // 追加一批消息，自动去重
  static Future<void> appendChatHistory(
    int targetId,
    List<Message> msgs,
  ) async {
    final existing = await getChatHistory(targetId);
    if (existing == null || existing.isEmpty) {
      await saveChatHistory(targetId, msgs);
      return;
    }
    final ids = existing.map((m) => m.id).toSet();
    final toAdd = msgs.where((m) => !ids.contains(m.id)).toList();
    if (toAdd.isEmpty) return;
    await saveChatHistory(targetId, [...existing, ...toAdd]);
  }

  // 追加单条消息
  static Future<void> appendSingleMessage(int targetId, Message msg) async {
    final existing = await getChatHistory(targetId);
    if (existing == null) {
      await saveChatHistory(targetId, [msg]);
      return;
    }
    if (existing.any((m) => m.id == msg.id)) return;
    await saveChatHistory(targetId, [...existing, msg]);
  }

  // 把本地缓存中 fromId 发来的未读消息标成已读
  static Future<void> markLocalMessagesAsRead(int fromId) async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (!key.startsWith(_chatHistoryPrefix)) continue;
      final raw = prefs.getString(key);
      if (raw == null) continue;
      try {
        final list = (jsonDecode(raw) as List)
            .map((e) => Message.fromJsonString(e as String))
            .toList();
        var changed = false;
        for (var i = 0; i < list.length; i++) {
          if (list[i].fromId == fromId && list[i].status == 0) {
            list[i] = Message(
              id: list[i].id,
              fromId: list[i].fromId,
              toId: list[i].toId,
              msgType: list[i].msgType,
              content: list[i].content,
              status: 1,
              createTime: list[i].createTime,
              readTime: DateTime.now(),
            );
            changed = true;
          }
        }
        if (changed) {
          final targetId = int.parse(key.substring(_chatHistoryPrefix.length));
          await saveChatHistory(targetId, list);
        }
      } catch (_) {}
    }
  }

  // ---- 清理 ----

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (key.startsWith('cached_')) await prefs.remove(key);
    }
  }

  // 只清聊天记录
  static Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_chatHistoryPrefix)) await prefs.remove(key);
    }
  }

  // 算一下聊天记录占了多少字节，设置页展示用
  static Future<int> getChatHistorySize() async {
    final prefs = await SharedPreferences.getInstance();
    var total = 0;
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_chatHistoryPrefix)) {
        final raw = prefs.getString(key);
        if (raw != null) total += raw.length * 2;
      }
    }
    return total;
  }
}
