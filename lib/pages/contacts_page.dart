import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/friend.dart';
import '../store/friend_provider.dart';
import '../utils/app_colors.dart';
import '../utils/user_avatar.dart';

// 通讯录页，展示好友列表，点击进详情
class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = c(context);
    final l10n = AppLocalizations.of(context)!;
    final friendsAsync = ref.watch(friendListProvider);
    final pendingCount = ref.watch(pendingRequestCountProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(colors, l10n)),
          SliverToBoxAdapter(
            child: _buildFixedItems(context, colors, l10n, pendingCount),
          ),
          friendsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${l10n.loadFailed}: $e',
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ref.invalidate(friendListProvider),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (friends) {
              if (friends.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        l10n.noFriends,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildFriendItem(context, colors, l10n, friends[index]),
                  childCount: friends.length,
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColors colors, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.crewList,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: colors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 18, color: colors.textHint),
                const SizedBox(width: 8),
                Text(
                  l10n.searchTeammates,
                  style: TextStyle(color: colors.textHint, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedItems(
    BuildContext context,
    AppColors colors,
    AppLocalizations l10n,
    int pendingCount,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider, width: 8)),
      ),
      child: Column(
        children: [
          _buildFixedItem(
            context,
            l10n.newCrew,
            colors.warning,
            Icons.person_add,
            showBadge: pendingCount > 0,
            onTap: () => context.push('/friend-requests'),
          ),
          _buildFixedItem(
            context,
            l10n.groupChat,
            colors.success,
            Icons.anchor,
          ),
          _buildFixedItem(context, l10n.tags, colors.info, Icons.local_offer),
        ],
      ),
    );
  }

  Widget _buildFixedItem(
    BuildContext context,
    String title,
    Color bgColor,
    IconData icon, {
    bool showBadge = false,
    VoidCallback? onTap,
  }) {
    final colors = c(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, color: Colors.white, size: 20)),
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: colors.textPrimary),
            ),
            const Spacer(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildFriendItem(
    BuildContext context,
    AppColors colors,
    AppLocalizations l10n,
    Friend friend,
  ) {
    final name = friend.remark.isNotEmpty
        ? friend.remark
        : (friend.friendUser?.nickname ??
              friend.friendUser?.username ??
              l10n.userPrefix(friend.friendId.toString()));
    final avatarUrl = friend.friendUser?.avatar;

    return InkWell(
      onTap: () => context.push('/friend-detail', extra: friend),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            UserAvatar(avatarUrl: avatarUrl, name: name, size: 44, radius: 12),
            const SizedBox(width: 15),
            Text(
              name,
              style: TextStyle(fontSize: 16, color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
