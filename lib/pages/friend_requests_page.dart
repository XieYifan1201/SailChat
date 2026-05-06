import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../models/friend_request.dart';
import '../store/friend_provider.dart';
import '../utils/app_colors.dart';

// 好友申请列表页，显示收到和发出的申请
class FriendRequestsPage extends ConsumerWidget {
  const FriendRequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = c(context);
    final l10n = AppLocalizations.of(context)!;
    final requestsAsync = ref.watch(friendRequestListProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.newCrew,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, size: 22),
            tooltip: l10n.addFriend,
            onPressed: () => context.push('/add-friend'),
          ),
        ],
      ),
      body: requestsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${l10n.loadFailed}: $e',
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(friendRequestListProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.noFriendRequests,
                    style: TextStyle(color: colors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => context.push('/add-friend'),
                    icon: const Icon(Icons.person_add, size: 18),
                    label: Text(l10n.addFriendProactively),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(friendRequestListProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: requests.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 0.5, color: colors.divider),
              itemBuilder: (context, index) => _buildRequestItem(
                context,
                ref,
                colors,
                l10n,
                requests[index],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestItem(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
    AppLocalizations l10n,
    FriendRequest req,
  ) {
    final name =
        req.fromUser?.nickname ??
        req.fromUser?.username ??
        l10n.userPrefix(req.fromId.toString());
    final initial = name.isNotEmpty ? name[0] : '?';
    final isPending = req.status == 0;
    final isAccepted = req.status == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primaryGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(14)),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                if (req.message.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    req.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (isPending) ...[
            _buildActionButton(
              text: l10n.accept,
              color: colors.primary,
              onTap: () => ref
                  .read(friendNotifierProvider.notifier)
                  .accept(requestId: req.id),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              text: l10n.reject,
              color: colors.textTertiary,
              onTap: () => ref
                  .read(friendNotifierProvider.notifier)
                  .reject(requestId: req.id),
            ),
          ] else
            Text(
              isAccepted ? l10n.accepted : l10n.rejected,
              style: TextStyle(
                fontSize: 13,
                color: isAccepted ? colors.success : colors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
