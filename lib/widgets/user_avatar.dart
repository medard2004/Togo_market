import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../Api/config/api_constants.dart';

class UserAvatar extends StatelessWidget {
  final String? url;
  final String? name;
  final double radius;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.url,
    this.name,
    this.radius = 24.0,
    this.backgroundColor,
  });

  String _getInitials(String? text) {
    if (text == null || text.trim().isEmpty) return '?';
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return text.substring(0, text.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _resolveUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('/storage/')) {
      final baseUrl = ApiConstants.baseUrl;
      final rootUrl = baseUrl.endsWith('/api')
          ? baseUrl.substring(0, baseUrl.length - 4)
          : baseUrl;
      return '$rootUrl$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = _resolveUrl(url);
    if (resolvedUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: resolvedUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? AppTheme.primaryLight,
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => _buildInitials(),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    if (name == null || name!.trim().isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? AppTheme.primaryLight,
        child: Icon(
          Icons.person,
          size: radius * 1.2,
          color: AppTheme.primary.withOpacity(0.5),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppTheme.primaryLight,
      child: Text(
        _getInitials(name),
        style: TextStyle(
          color: AppTheme.primary,
          fontSize: radius * 0.7,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
