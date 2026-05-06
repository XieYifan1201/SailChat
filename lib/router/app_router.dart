import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sail_chat/pages/chats_page.dart';
import 'package:sail_chat/pages/contacts_page.dart';
import 'package:sail_chat/pages/main_layout.dart';
import 'package:sail_chat/pages/mine_page.dart';

import '../models/friend.dart';
import '../pages/add_friend_page.dart';
import '../pages/chat_page.dart';
import '../pages/data_page.dart';
import '../pages/friend_detail_page.dart';
import '../pages/friend_requests_page.dart';
import '../pages/login_page.dart';
import '../pages/profile_page.dart';
import '../pages/settings_page.dart';
import '../store/auth_provider.dart';

// 路由配置，用 go_router 管理页面跳转
final router = Provider<GoRouter>((ref) {
  // 监听 authProvider 变化，token 没了自动跳登录页
  ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/chats',

    // 登录态拦截：没 token 跳登录页，已登录不让再进登录页
    redirect: (context, state) {
      if (ref.read(authProvider.notifier).loading) return null;
      final token = ref.read(authProvider);
      final loggingIn = state.matchedLocation == '/login';
      if (token == null && !loggingIn) {
        return '/login';
      }
      if (token != null && loggingIn) {
        return '/chats';
      }
      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

      // 底部导航三个 tab，用 StatefulShellRoute 保持各 tab 状态
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatsPage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contacts',
                builder: (context, state) => const ContactsPage(),
              ),
            ],
          ),

          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mine',
                builder: (context, state) => const MinePage(),
              ),
            ],
          ),
        ],
      ),

      // 聊天页，targetId 从路径参数取
      GoRoute(
        path: '/chat/:targetId',
        builder: (context, state) {
          final targetId = int.parse(state.pathParameters['targetId']!);
          return ChatPage(targetId: targetId);
        },
      ),

      GoRoute(
        path: '/friend-requests',
        builder: (context, state) => const FriendRequestsPage(),
      ),

      GoRoute(
        path: '/add-friend',
        builder: (context, state) => const AddFriendPage(),
      ),

      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),

      GoRoute(path: '/data', builder: (context, state) => const DataPage()),

      // 好友详情，Friend 对象通过 extra 传进来
      GoRoute(
        path: '/friend-detail',
        builder: (context, state) {
          final friend = state.extra as Friend;
          return FriendDetailPage(friend: friend);
        },
      ),

      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
