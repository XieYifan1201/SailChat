import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

// 用户头像组件，有头像就加载网络图，没有就显示首字母
class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final double size;
  final double radius;

  const UserAvatar({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.size = 44,
    this.radius = 12,
  });

  static const String _baseUrl = 'http://10.0.2.2:8080';

  // 后端返回的可能是相对路径，得拼一下
  String? get _fullUrl {
    if (avatarUrl == null || avatarUrl!.isEmpty) return null;
    if (avatarUrl!.startsWith('http')) return avatarUrl;
    return '$_baseUrl$avatarUrl';
  }

  @override
  Widget build(BuildContext context) {
    final colors = c(context);
    final url = _fullUrl;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    if (url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, _) => _buildDefault(colors, initial),
          errorWidget: (_, _, _) => _buildDefault(colors, initial),
        ),
      );
    }

    return _buildDefault(colors, initial);
  }

  // 没头像时的兜底：渐变背景 + 首字母
  Widget _buildDefault(AppColors colors, String initial) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          colors: [colors.primary, colors.primaryGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.45,
        ),
      ),
    );
  }
}
