import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/user.dart';
import '../store/user_provider.dart';
import '../utils/app_colors.dart';
import '../utils/user_avatar.dart';

// "我的"页面，展示当前用户信息和操作入口
class MinePage extends ConsumerStatefulWidget {
  const MinePage({super.key});

  @override
  ConsumerState<MinePage> createState() => _MinePageState();
}

class _MinePageState extends ConsumerState<MinePage> {
  @override
  Widget build(BuildContext context) {
    final colors = c(context);
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorView(colors, error),
        data: (user) => _buildContent(colors, user),
      ),
    );
  }

  Widget _buildErrorView(AppColors colors, Object error) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: colors.textSecondary),
          const SizedBox(height: 12),
          Text(
            l10n.loadFailed,
            style: TextStyle(fontSize: 16, color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(userProvider.notifier).fetchUserInfo(),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppColors colors, User user) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildProfileHeader(colors, l10n, user),
        const SizedBox(height: 10),
        _buildGroup(colors, [
          _buildItem(
            colors,
            l10n,
            title: l10n.favorites,
            iconColor: colors.warning,
          ),
          _buildItem(colors, l10n, title: l10n.album, iconColor: colors.info),
          _buildItem(
            colors,
            l10n,
            title: l10n.cardPack,
            iconColor: const Color(0xFF5856D6),
          ),
          _buildItem(
            colors,
            l10n,
            title: l10n.data,
            iconColor: const Color(0xFFFFCC00),
            onTap: () => context.push('/data'),
          ),
        ]),
        const SizedBox(height: 10),
        _buildGroup(colors, [
          _buildItem(
            colors,
            l10n,
            title: l10n.settings,
            iconColor: colors.success,
            onTap: () => context.push('/settings'),
          ),
        ]),
      ],
    );
  }

  Widget _buildProfileHeader(
    AppColors colors,
    AppLocalizations l10n,
    User user,
  ) {
    final displayName = user.nickname.isNotEmpty
        ? user.nickname
        : user.username;

    return InkWell(
      onTap: () => context.push('/profile'),
      child: Container(
        color: colors.card,
        padding: const EdgeInsets.only(
          top: 80,
          bottom: 30,
          left: 20,
          right: 20,
        ),
        child: Row(
          children: [
            UserAvatar(
              avatarUrl: user.avatar,
              name: displayName,
              size: 72,
              radius: 16,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.nickname.isNotEmpty ? user.nickname : user.username,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.sailId(user.username),
                    style: TextStyle(fontSize: 14, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '>',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 16,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(AppColors colors, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        border: Border.symmetric(
          horizontal: BorderSide(color: colors.border, width: 0.5),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildItem(
    AppColors colors,
    AppLocalizations l10n, {
    required String title,
    required Color iconColor,
    bool showBadge = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Center(
                child: Icon(Icons.circle, size: 22, color: iconColor),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, color: colors.textPrimary),
              ),
            ),
            if (showBadge)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: colors.error,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              '>',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 16,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
