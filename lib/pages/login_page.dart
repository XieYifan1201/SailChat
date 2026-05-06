import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../store/auth_provider.dart';
import '../store/riverpod.dart';
import '../utils/app_colors.dart';

// 登录注册页
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLoginView = true;

  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _captchaController = TextEditingController();

  Uint8List? _captchaBytes;
  bool _captchaLoading = false;
  bool _submitLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCaptcha();
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  Future<void> _fetchCaptcha() async {
    setState(() => _captchaLoading = true);
    try {
      final dio = ref.read(httpClientProvider);
      final response = await dio.get<List<int>>(
        '/captcha',
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _captchaBytes = Uint8List.fromList(response.data!);
        });
      }
    } catch (e) {
    } finally {
      setState(() => _captchaLoading = false);
    }
  }

  void _toggleView() {
    setState(() {
      _isLoginView = !_isLoginView;
    });
    _fetchCaptcha();
  }

  Future<void> _handleSubmit() async {
    if (_submitLoading) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() => _submitLoading = true);

    try {
      final userService = ref.read(userServiceProvider);

      if (_isLoginView) {
        final token = await userService.login(
          username: _accountController.text,
          password: _passwordController.text,
          captchaCode: _captchaController.text,
        );
        await ref.read(authProvider.notifier).login(token);
        if (mounted) {
          context.go('/chats');
        }
      } else {
        await userService.register(
          username: _usernameController.text,
          password: _passwordController.text,
          email: _emailController.text,
          captchaCode: _captchaController.text,
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.registerSuccess)));
          _toggleView();
        }
      }
    } on DioException catch (e) {
      String message;
      if (e.response != null) {
        // 后端返回的业务错误，尽量拿 message 字段
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        } else {
          message = '服务器错误 (${e.response!.statusCode})';
        }
      } else {
        // 网络层错误，连接超时、DNS 失败等
        message = '网络连接失败: ${e.message ?? e.type.toString()}';
      }
      if (mounted) {
        if (message.contains('验证码')) _fetchCaptcha();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('未知错误: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _submitLoading = false);
      }
    }
  }

  void _socialLogin(String type) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final colors = c(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.card,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colors.primary.withValues(alpha: 0.1), colors.card],
                ),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      Expanded(
                        child: _isLoginView
                            ? _buildLoginView(colors, l10n)
                            : _buildRegisterView(colors, l10n),
                      ),
                      _buildSocialLogin(colors, l10n),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginView(AppColors colors, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeText(colors, 'SailChat', l10n.loginToContinue),
          const SizedBox(height: 40),
          _buildInputField(
            colors,
            l10n,
            controller: _accountController,
            hintText: l10n.account,
          ),
          const SizedBox(height: 15),
          _buildInputField(
            colors,
            l10n,
            controller: _passwordController,
            hintText: l10n.enterPassword,
            obscureText: true,
          ),
          const SizedBox(height: 15),
          _buildCaptchaField(colors, l10n),
          const SizedBox(height: 10),
          _buildPrimaryButton(colors, l10n.login, _handleSubmit),
          _buildTextLink(colors, l10n.registerNew, _toggleView),
        ],
      ),
    );
  }

  Widget _buildRegisterView(AppColors colors, AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWelcomeText(colors, l10n.register, l10n.quickRegister),
          const SizedBox(height: 40),
          _buildInputField(
            colors,
            l10n,
            controller: _usernameController,
            hintText: l10n.setAccount,
          ),
          const SizedBox(height: 15),
          _buildInputField(
            colors,
            l10n,
            controller: _emailController,
            hintText: l10n.setEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          _buildInputField(
            colors,
            l10n,
            controller: _passwordController,
            hintText: l10n.setPassword,
            obscureText: true,
          ),
          const SizedBox(height: 15),
          _buildCaptchaField(colors, l10n),
          const SizedBox(height: 10),
          _buildPrimaryButton(colors, l10n.confirmRegister, _handleSubmit),
          _buildTextLink(colors, l10n.alreadyHaveAccount, _toggleView),
        ],
      ),
    );
  }

  Widget _buildCaptchaField(AppColors colors, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildInputField(
            colors,
            l10n,
            controller: _captchaController,
            hintText: l10n.captcha,
            keyboardType: TextInputType.text,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _captchaLoading ? null : _fetchCaptcha,
          child: Container(
            width: 100,
            height: 54,
            decoration: BoxDecoration(
              color: colors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildCaptchaImage(colors),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptchaImage(AppColors colors) {
    if (_captchaLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.primary,
          ),
        ),
      );
    }

    if (_captchaBytes == null) {
      return Center(child: Icon(Icons.refresh, color: colors.textSecondary));
    }

    return Image.memory(
      _captchaBytes!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Center(child: Icon(Icons.refresh, color: colors.textSecondary)),
    );
  }

  Widget _buildWelcomeText(AppColors colors, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(fontSize: 15, color: colors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildInputField(
    AppColors colors,
    AppLocalizations l10n, {
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: colors.inputFill,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 16, color: colors.textHint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
        ),
        style: TextStyle(fontSize: 16, color: colors.textPrimary),
      ),
    );
  }

  Widget _buildPrimaryButton(
    AppColors colors,
    String text,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 54,
      margin: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        onPressed: _submitLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
        ),
        child: _submitLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildTextLink(AppColors colors, String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontSize: 14, color: colors.primary),
        ),
      ),
    );
  }

  Widget _buildSocialLogin(AppColors colors, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 1, color: colors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                l10n.socialLogin,
                style: TextStyle(fontSize: 13, color: colors.textTertiary),
              ),
            ),
            Expanded(child: Container(height: 1, color: colors.border)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(
              colors,
              assetPath: 'assets/icons/wechat.svg',
              onTap: () => _socialLogin('WeChat'),
              color: const Color(0xFF07C160),
            ),
            const SizedBox(width: 30),
            _buildSocialIcon(
              colors,
              assetPath: 'assets/icons/qq.svg',
              onTap: () => _socialLogin('QQ'),
              color: const Color(0xFF12B7F5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(
    AppColors colors, {
    required String assetPath,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: colors.inputFill,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            width: 28,
            height: 28,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
