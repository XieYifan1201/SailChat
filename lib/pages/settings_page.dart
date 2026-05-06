import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../store/auth_provider.dart';
import '../store/settings_provider.dart';
import '../store/user_provider.dart';
import '../utils/app_colors.dart';

// 设置页：主题、语言、清理缓存
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = c(context);
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          _buildGroup(
            colors,
            children: [
              _buildThemeItem(context, ref, colors, l10n, themeMode),
              _buildLocaleItem(context, ref, colors, l10n, locale),
            ],
          ),
          const SizedBox(height: 20),
          _buildGroup(
            colors,
            children: [_buildLogoutItem(context, ref, colors, l10n)],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGroup(AppColors colors, {required List<Widget> children}) {
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

  Widget _buildThemeItem(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
    AppLocalizations l10n,
    ThemeMode mode,
  ) {
    final label = switch (mode) {
      ThemeMode.light => l10n.lightMode,
      ThemeMode.dark => l10n.darkMode,
      ThemeMode.system => l10n.followSystem,
    };

    return InkWell(
      onTap: () => _showThemePicker(context, ref, colors, l10n, mode),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF5856D6),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Center(
                child: Icon(Icons.dark_mode, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                l10n.appearance,
                style: TextStyle(fontSize: 16, color: colors.textPrimary),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              '>',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 16,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocaleItem(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
    AppLocalizations l10n,
    Locale locale,
  ) {
    final label = switch (locale.scriptCode) {
      'Hant' => l10n.traditionalChinese,
      _ => switch (locale.languageCode) {
        'zh' => l10n.chinese,
        'en' => l10n.english,
        _ => locale.languageCode,
      },
    };

    return InkWell(
      onTap: () => _showLocalePicker(context, ref, colors, l10n, locale),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.border, width: 0.5)),
        ),
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
                child: Icon(Icons.language, color: Colors.white, size: 16),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                l10n.language,
                style: TextStyle(fontSize: 16, color: colors.textPrimary),
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
            const SizedBox(width: 6),
            Text(
              '>',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 16,
                fontFamily: 'serif',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
    AppLocalizations l10n,
  ) {
    return InkWell(
      onTap: () => _handleLogout(context, ref, l10n),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Center(
                child: Icon(Icons.logout, color: colors.error, size: 20),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                l10n.logout,
                style: TextStyle(fontSize: 16, color: colors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
    AppLocalizations l10n,
    ThemeMode current,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                l10n.selectAppearance,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            _buildThemeOption(
              context,
              ref,
              colors,
              l10n,
              ThemeMode.system,
              l10n.followSystem,
              current,
            ),
            _buildThemeOption(
              context,
              ref,
              colors,
              l10n,
              ThemeMode.light,
              l10n.lightMode,
              current,
            ),
            _buildThemeOption(
              context,
              ref,
              colors,
              l10n,
              ThemeMode.dark,
              l10n.darkMode,
              current,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
    AppLocalizations l10n,
    ThemeMode mode,
    String label,
    ThemeMode current,
  ) {
    final selected = mode == current;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: selected ? colors.primary : colors.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: selected ? Icon(Icons.check, color: colors.primary) : null,
      onTap: () {
        ref.read(themeProvider.notifier).setTheme(mode);
        Navigator.of(context).pop();
      },
    );
  }

  void _showLocalePicker(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
    AppLocalizations l10n,
    Locale current,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                l10n.selectLanguage,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            _buildLocaleOption(
              context,
              ref,
              colors,
              l10n,
              const Locale('zh'),
              l10n.chinese,
              current,
            ),
            _buildLocaleOption(
              context,
              ref,
              colors,
              l10n,
              const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
              l10n.traditionalChinese,
              current,
            ),
            _buildLocaleOption(
              context,
              ref,
              colors,
              l10n,
              const Locale('en'),
              l10n.english,
              current,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLocaleOption(
    BuildContext context,
    WidgetRef ref,
    AppColors colors,
    AppLocalizations l10n,
    Locale locale,
    String label,
    Locale current,
  ) {
    final selected =
        locale.languageCode == current.languageCode &&
        locale.scriptCode == current.scriptCode;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          color: selected ? colors.primary : colors.textPrimary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: selected ? Icon(Icons.check, color: colors.primary) : null,
      onTap: () {
        ref.read(localeProvider.notifier).setLocale(locale);
        Navigator.of(context).pop();
      },
    );
  }

  Future<void> _handleLogout(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmLogout),
        content: Text(l10n.confirmLogoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.confirm,
              style: TextStyle(color: c(context).error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(userProvider.notifier).clearUser();
      await ref.read(authProvider.notifier).logout();
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}
