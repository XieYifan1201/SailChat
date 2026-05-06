import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../models/user.dart';
import '../store/friend_provider.dart';
import '../store/riverpod.dart';
import '../utils/app_colors.dart';

// 添加好友页，按用户名搜索并发申请
class AddFriendPage extends ConsumerStatefulWidget {
  const AddFriendPage({super.key});

  @override
  ConsumerState<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends ConsumerState<AddFriendPage> {
  final _usernameController = TextEditingController();
  final _messageController = TextEditingController();

  List<User> _searchResults = [];
  User? _selectedUser;
  bool _searching = false;
  bool _applying = false;
  String? _searchError;

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final l10n = AppLocalizations.of(context)!;
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      _showSnackBar(l10n.enterUsernameHint);
      return;
    }

    setState(() {
      _searching = true;
      _searchResults = [];
      _selectedUser = null;
      _searchError = null;
    });

    try {
      final userService = ref.read(userServiceProvider);
      final results = await userService.searchUsers(username);
      if (mounted) {
        setState(() {
          _searchResults = results.map((m) => User.fromJson(m)).toList();
          _searching = false;
          if (_searchResults.isEmpty) {
            _searchError = l10n.userNotFound;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        String msg = e.toString();
        if (msg.contains('不能添加自己')) {
          msg = l10n.cannotAddSelf;
        } else {
          msg = l10n.userNotFound;
        }
        setState(() {
          _searching = false;
          _searchError = msg;
          _searchResults = [];
        });
      }
    }
  }

  Future<void> _apply() async {
    final user = _selectedUser;
    if (user == null) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _applying = true);
    try {
      await ref
          .read(friendNotifierProvider.notifier)
          .apply(
            toUsername: user.username,
            message: _messageController.text.trim().isNotEmpty
                ? _messageController.text.trim()
                : null,
          );
      if (mounted) {
        _showSnackBar(l10n.friendRequestSent);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        String msg = e.toString();
        if (msg.contains('已经发送过')) {
          msg = l10n.alreadySentRequest;
        } else if (msg.contains('已经是你的好友')) {
          msg = l10n.alreadyFriend;
        } else if (msg.contains('不能添加自己')) {
          msg = l10n.cannotAddSelf;
        }
        _showSnackBar(msg);
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = c(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.addCrew,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchField(colors, l10n),
            if (_searching) _buildLoading(),
            if (_searchError != null) _buildError(colors),
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildResultList(colors, l10n),
            ],
            if (_selectedUser != null) ...[
              const SizedBox(height: 20),
              _buildSelectedUser(colors, l10n, _selectedUser!),
              const SizedBox(height: 20),
              _buildMessageField(colors, l10n),
              const SizedBox(height: 24),
              _buildApplyButton(colors, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.username,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(hintText: l10n.enterUsername),
                onSubmitted: (_) => _search(),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _searching ? null : _search,
                child: Text(
                  l10n.search,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.only(top: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: Text(
          _searchError!,
          style: TextStyle(color: colors.error, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildResultList(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.searchResults,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ..._searchResults.map((user) => _buildUserItem(colors, l10n, user)),
      ],
    );
  }

  Widget _buildUserItem(AppColors colors, AppLocalizations l10n, User user) {
    final isSelected = _selectedUser?.id == user.id;
    final initial = user.nickname.isNotEmpty ? user.nickname[0] : '?';

    return GestureDetector(
      onTap: () => setState(() => _selectedUser = user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
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
                    user.nickname.isNotEmpty ? user.nickname : user.username,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.accountLabel(user.username),
                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.primary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedUser(
    AppColors colors,
    AppLocalizations l10n,
    User user,
  ) {
    final initial = user.nickname.isNotEmpty ? user.nickname[0] : '?';
    final genderText = switch (user.gender) {
      1 => l10n.male,
      2 => l10n.female,
      _ => l10n.unknown,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primaryGradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(15)),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname.isNotEmpty ? user.nickname : user.username,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${l10n.accountLabel(user.username)}  ·  ${l10n.genderLabel(genderText)}',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedUser = null),
            child: Icon(Icons.close, size: 18, color: colors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageField(AppColors colors, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.requestMessage,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _messageController,
          maxLines: 3,
          decoration: InputDecoration(hintText: l10n.requestMessageHint),
        ),
      ],
    );
  }

  Widget _buildApplyButton(AppColors colors, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _applying ? null : _apply,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _applying
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                l10n.sendRequest,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
