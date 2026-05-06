import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

// 当前用户信息缓存，登录后存一份，启动时先读缓存
class UserStorage {
  static const _key = 'cached_user';

  static Future<void> save(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, user.toJsonString());
  }

  static Future<User?> get() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return User.fromJsonString(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
