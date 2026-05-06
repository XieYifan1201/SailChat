import 'package:flutter/material.dart';

// 自定义颜色，通过 ThemeExtension 注册到主题里，亮色暗色各一套
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color backgroundSecondary;
  final Color card;
  final Color inputFill;
  final Color border;
  final Color divider;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textHint;

  final Color primary;
  final Color primaryLight;
  final Color primaryGradientEnd;

  final Color error;
  final Color success;
  final Color warning;
  final Color info;

  final Color badge;
  final Color iconBg;

  // 聊天气泡颜色，自己发的和对方发的不一样
  final Color chatBubbleMe;
  final Color chatBubbleOther;

  const AppColors({
    required this.background,
    required this.backgroundSecondary,
    required this.card,
    required this.inputFill,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textHint,
    required this.primary,
    required this.primaryLight,
    required this.primaryGradientEnd,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.badge,
    required this.iconBg,
    required this.chatBubbleMe,
    required this.chatBubbleOther,
  });

  static const light = AppColors(
    background: Color(0xFFF8FAFC),
    backgroundSecondary: Color(0xFFF2F2F7),
    card: Colors.white,
    inputFill: Color(0xFFF1F5F9),
    border: Color(0xFFE5E5EA),
    divider: Color(0xFFF2F2F7),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textTertiary: Color(0xFF94A3B8),
    textHint: Color(0xFF8E8E93),
    primary: Color(0xFF0052D4),
    primaryLight: Color(0xFF4364F7),
    primaryGradientEnd: Color(0xFF6FB1FC),
    error: Color(0xFFFF3B30),
    success: Color(0xFF10B981),
    warning: Color(0xFFFF9500),
    info: Color(0xFF007AFF),
    badge: Color(0xFF0052D4),
    iconBg: Color(0xFFF1F5F9),
    chatBubbleMe: Color(0xFF0052D4),
    chatBubbleOther: Colors.white,
  );

  static const dark = AppColors(
    background: Color(0xFF000000),
    backgroundSecondary: Color(0xFF1C1C1E),
    card: Color(0xFF2C2C2E),
    inputFill: Color(0xFF38383A),
    border: Color(0xFF38383A),
    divider: Color(0xFF38383A),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF98989F),
    textTertiary: Color(0xFF636366),
    textHint: Color(0xFF98989F),
    primary: Color(0xFF6FB1FC),
    primaryLight: Color(0xFF4364F7),
    primaryGradientEnd: Color(0xFF0052D4),
    error: Color(0xFFFF453A),
    success: Color(0xFF30D158),
    warning: Color(0xFFFF9F0A),
    info: Color(0xFF0A84FF),
    badge: Color(0xFF0A84FF),
    iconBg: Color(0xFF38383A),
    chatBubbleMe: Color(0xFF0A84FF),
    chatBubbleOther: Color(0xFF2C2C2E),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? backgroundSecondary,
    Color? card,
    Color? inputFill,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textHint,
    Color? primary,
    Color? primaryLight,
    Color? primaryGradientEnd,
    Color? error,
    Color? success,
    Color? warning,
    Color? info,
    Color? badge,
    Color? iconBg,
    Color? chatBubbleMe,
    Color? chatBubbleOther,
  }) {
    return AppColors(
      background: background ?? this.background,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      card: card ?? this.card,
      inputFill: inputFill ?? this.inputFill,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textHint: textHint ?? this.textHint,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryGradientEnd: primaryGradientEnd ?? this.primaryGradientEnd,
      error: error ?? this.error,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      badge: badge ?? this.badge,
      iconBg: iconBg ?? this.iconBg,
      chatBubbleMe: chatBubbleMe ?? this.chatBubbleMe,
      chatBubbleOther: chatBubbleOther ?? this.chatBubbleOther,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      backgroundSecondary: Color.lerp(
        backgroundSecondary,
        other.backgroundSecondary,
        t,
      )!,
      card: Color.lerp(card, other.card, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryGradientEnd: Color.lerp(
        primaryGradientEnd,
        other.primaryGradientEnd,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      badge: Color.lerp(badge, other.badge, t)!,
      iconBg: Color.lerp(iconBg, other.iconBg, t)!,
      chatBubbleMe: Color.lerp(chatBubbleMe, other.chatBubbleMe, t)!,
      chatBubbleOther: Color.lerp(chatBubbleOther, other.chatBubbleOther, t)!,
    );
  }
}

// 快捷取颜色，用法：final colors = c(context);
AppColors c(BuildContext context) {
  return Theme.of(context).extension<AppColors>()!;
}
