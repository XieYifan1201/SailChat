import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/system_notification.dart';
import '../store/friend_provider.dart';
import '../store/message_provider.dart';
import '../store/user_provider.dart';
import '../utils/app_colors.dart';

// 主布局，底部导航 + 三个 tab（会话、通讯录、我的）
class MainLayout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = c(context);
    final pendingCount = ref.watch(pendingRequestCountProvider);

    final currentUserId = ref.watch(userProvider).value?.id;

    final messageAsync = ref.watch(realtimeMessageProvider);
    messageAsync.whenData((msg) {
      if (currentUserId != null) {
        ref
            .read(messageNotifierProvider.notifier)
            .onReceiveMessage(msg, currentUserId);
      }
    });

    final notificationAsync = ref.watch(realtimeNotificationProvider);
    notificationAsync.whenData((notification) {
      final notifier = ref.read(messageNotifierProvider.notifier);
      notifier.handleNotification(notification);
      _showNotificationSnackBar(context, colors, l10n, notification);
    });

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.chat_outlined),
            selectedIcon: const Icon(Icons.chat),
            label: l10n.chats,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pendingCount > 0,
              child: const Icon(Icons.contacts_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: pendingCount > 0,
              child: const Icon(Icons.contacts),
            ),
            label: l10n.contacts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.me,
          ),
        ],
      ),
    );
  }

  void _showNotificationSnackBar(
    BuildContext context,
    AppColors colors,
    AppLocalizations l10n,
    SystemNotification notification,
  ) {
    final icon = switch (notification.type) {
      NotificationType.friendApply => Icons.person_add,
      NotificationType.friendAccept => Icons.check_circle,
      NotificationType.friendReject => Icons.cancel,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(notification.content)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
