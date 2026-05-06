import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../utils/app_colors.dart';
import '../utils/cache_storage.dart';

// 数据管理页，查看和清理本地缓存
class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  String _chatDataSize = '';

  @override
  void initState() {
    super.initState();
    _calculateSize();
  }

  Future<void> _calculateSize() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    int totalBytes = 0;
    for (final key in keys) {
      if (key.startsWith('cached_chat_history_')) {
        final raw = prefs.getString(key);
        if (raw != null) {
          totalBytes += raw.length * 2;
        }
      }
    }
    if (mounted) {
      setState(() {
        _chatDataSize = totalBytes == 0 ? '0 B' : _formatBytes(totalBytes);
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _clearChatData() async {
    final l10n = AppLocalizations.of(context)!;
    final colors = c(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearChatData),
        content: Text(l10n.clearChatDataConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm, style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await CacheStorage.clearChatHistory();
      setState(() => _chatDataSize = '0 B');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.chatDataCleared)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = c(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        title: Text(
          l10n.dataManagement,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: colors.card,
              border: Border.symmetric(
                horizontal: BorderSide(color: colors.border, width: 0.5),
              ),
            ),
            child: InkWell(
              onTap: () {},
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colors.info,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.chat_bubble,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        l10n.chatHistory,
                        style: TextStyle(
                          fontSize: 16,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      _chatDataSize.isEmpty ? l10n.calculating : _chatDataSize,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: colors.card,
              border: Border.symmetric(
                horizontal: BorderSide(color: colors.border, width: 0.5),
              ),
            ),
            child: InkWell(
              onTap: _clearChatData,
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Center(
                        child: Icon(
                          Icons.delete_outline,
                          color: colors.error,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        l10n.clearChatData,
                        style: TextStyle(fontSize: 16, color: colors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 8),
            child: Text(
              l10n.clearChatDataHint,
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
