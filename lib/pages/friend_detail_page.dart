import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/friend.dart';
import '../utils/app_colors.dart';
import '../utils/user_avatar.dart';

// 好友详情页，展示头像昵称，可以发消息或删除好友
class FriendDetailPage extends StatelessWidget {
  final Friend friend;

  const FriendDetailPage({super.key, required this.friend});

  @override
  Widget build(BuildContext context) {
    final colors = c(context);
    final l10n = AppLocalizations.of(context)!;
    final name = friend.remark.isNotEmpty
        ? friend.remark
        : (friend.friendUser?.nickname.isNotEmpty == true
              ? friend.friendUser!.nickname
              : friend.friendUser?.username ?? '');
    final displayName = name.isNotEmpty
        ? name
        : l10n.userPrefix(friend.friendId.toString());

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        title: Text(
          l10n.friendDetail,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 30),
          Center(
            child: UserAvatar(
              avatarUrl: friend.friendUser?.avatar,
              name: displayName,
              size: 80,
              radius: 20,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ),
          if (friend.friendUser?.username.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Center(
              child: Text(
                l10n.sailId(friend.friendUser!.username),
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: 30),
          _buildGroup(colors, [
            if (friend.remark.isNotEmpty)
              _buildInfoRow(colors, l10n.remark, friend.remark),
            _buildGenderRow(colors, l10n),
          ]),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/chat/${friend.friendId}'),
                icon: const Icon(Icons.chat_bubble_outline, size: 20),
                label: Text(
                  l10n.goChat,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGroup(AppColors colors, List<Widget> children) {
    if (children.isEmpty) return const SizedBox.shrink();
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

  Widget _buildInfoRow(AppColors colors, String label, String value) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: colors.textPrimary),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: colors.textPrimary),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderRow(AppColors colors, AppLocalizations l10n) {
    final gender = friend.friendUser?.gender ?? 0;
    final genderText = switch (gender) {
      1 => l10n.male,
      2 => l10n.female,
      _ => l10n.unknown,
    };
    return _buildInfoRow(colors, l10n.gender, genderText);
  }
}
