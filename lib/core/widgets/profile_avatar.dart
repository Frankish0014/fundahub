import 'dart:convert';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Displays a user profile photo from Firebase Storage URL or an embedded
/// `data:image/...;base64,...` value stored in Firestore (web fallback).
class ProfileAvatar extends StatelessWidget {
  ProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.initial,
    this.radius = 32,
    Color? backgroundColor,
  }) : backgroundColor = backgroundColor ?? AppColors.avatarBg;

  final String? photoUrl;
  final String initial;
  final double radius;
  final Color backgroundColor;

  static ImageProvider? imageProvider(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    final value = url.trim();
    if (value.startsWith('data:image')) {
      try {
        final encoded = value.contains(',') ? value.split(',').last : value;
        return MemoryImage(base64Decode(encoded));
      } catch (_) {
        return null;
      }
    }
    return NetworkImage(value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = imageProvider(photoUrl);
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: provider,
      child: provider == null
          ? Text(
              initial,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: radius * 0.9,
              ),
            )
          : null,
    );
  }
}
