import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import '../models/user.dart';
import '../store/riverpod.dart';
import '../store/user_provider.dart';
import '../utils/app_colors.dart';
import '../utils/user_avatar.dart';

// 编辑个人资料页
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _nicknameController;
  late TextEditingController _regionController;
  late TextEditingController _signatureController;
  int _gender = 0;
  String? _avatarUrl;
  bool _saving = false;
  bool _uploadingAvatar = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value;
    _nicknameController = TextEditingController(text: user?.nickname ?? '');
    _regionController = TextEditingController(text: user?.region ?? '');
    _signatureController = TextEditingController(text: user?.signature ?? '');
    _gender = user?.gender ?? 0;
    _avatarUrl = user?.avatar;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _regionController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      final userService = ref.read(userServiceProvider);
      final newUrl = await userService.uploadAvatar(filePath: image.path);
      setState(() => _avatarUrl = newUrl);
      await ref.read(userProvider.notifier).fetchUserInfo();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.avatarUploadSuccess)));
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.avatarUploadFailed)));
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final userService = ref.read(userServiceProvider);
      await userService.updateProfile(
        nickname: _nicknameController.text.trim(),
        region: _regionController.text.trim(),
        gender: _gender,
        signature: _signatureController.text.trim(),
      );
      await ref.read(userProvider.notifier).fetchUserInfo();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.saveSuccess)));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = c(context);
    final l10n = AppLocalizations.of(context)!;
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: colors.backgroundSecondary,
      appBar: AppBar(
        title: Text(
          l10n.profile,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    l10n.save,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.loadFailed}: $e')),
        data: (user) => _buildForm(colors, l10n, user),
      ),
    );
  }

  Widget _buildForm(AppColors colors, AppLocalizations l10n, User user) {
    return ListView(
      children: [
        const SizedBox(height: 20),
        _buildGroup(colors, children: [_buildAvatarRow(colors, l10n, user)]),
        const SizedBox(height: 20),
        _buildGroup(
          colors,
          children: [
            _buildFieldRow(
              colors,
              l10n.username,
              user.username,
              enabled: false,
            ),
            _buildEditableRow(colors, l10n.nickname, _nicknameController),
            _buildGenderRow(colors, l10n),
            _buildEditableRow(colors, l10n.region, _regionController),
          ],
        ),
        const SizedBox(height: 20),
        _buildGroup(
          colors,
          children: [
            _buildEditableRow(
              colors,
              l10n.signature,
              _signatureController,
              maxLines: 3,
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
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

  Widget _buildAvatarRow(AppColors colors, AppLocalizations l10n, User user) {
    final displayName = user.nickname.isNotEmpty
        ? user.nickname
        : user.username;

    return InkWell(
      onTap: () => _showAvatarPicker(colors, l10n),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Stack(
              children: [
                UserAvatar(
                  avatarUrl: _avatarUrl,
                  name: displayName,
                  size: 50,
                  radius: 14,
                ),
                if (_uploadingAvatar)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                l10n.avatar,
                style: TextStyle(fontSize: 16, color: colors.textPrimary),
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

  Widget _buildFieldRow(
    AppColors colors,
    String label,
    String value, {
    bool enabled = true,
  }) {
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
              style: TextStyle(
                fontSize: 16,
                color: enabled ? colors.textPrimary : colors.textTertiary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(
    AppColors colors,
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return InkWell(
      onTap: () =>
          _showEditDialog(colors, label, controller, maxLines: maxLines),
      child: Container(
        height: maxLines > 1 ? null : 54,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                controller.text.isEmpty ? '' : controller.text,
                style: TextStyle(fontSize: 16, color: colors.textPrimary),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: 6),
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

  Widget _buildGenderRow(AppColors colors, AppLocalizations l10n) {
    final genderText = switch (_gender) {
      1 => l10n.male,
      2 => l10n.female,
      _ => l10n.unknown,
    };

    return InkWell(
      onTap: () => _showGenderPicker(colors, l10n),
      child: Container(
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
                l10n.gender,
                style: TextStyle(fontSize: 16, color: colors.textPrimary),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                genderText,
                style: TextStyle(fontSize: 16, color: colors.textPrimary),
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(width: 6),
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

  void _showAvatarPicker(AppColors colors, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                l10n.changeAvatar,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndUploadAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromAlbum),
              onTap: () {
                Navigator.of(context).pop();
                _pickAndUploadAvatar(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    AppColors colors,
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    final tempController = TextEditingController(text: controller.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(label),
        content: TextField(
          controller: tempController,
          maxLines: maxLines,
          autofocus: true,
          decoration: InputDecoration(hintText: label),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              controller.text = tempController.text;
              setState(() {});
              Navigator.of(context).pop();
            },
            child: Text(
              AppLocalizations.of(context)!.confirm,
              style: TextStyle(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showGenderPicker(AppColors colors, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Text(
                l10n.selectGender,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
            ),
            _buildGenderOption(colors, l10n, 0, l10n.unknown),
            _buildGenderOption(colors, l10n, 1, l10n.male),
            _buildGenderOption(colors, l10n, 2, l10n.female),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(
    AppColors colors,
    AppLocalizations l10n,
    int value,
    String label,
  ) {
    final selected = _gender == value;
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
        setState(() => _gender = value);
        Navigator.of(context).pop();
      },
    );
  }
}
