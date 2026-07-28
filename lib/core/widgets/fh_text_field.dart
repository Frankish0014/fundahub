import 'package:flutter/material.dart';

class FhTextField extends StatelessWidget {
  const FhTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.maxLines = 1,
  });

  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: obscureText ? 1 : maxLines,
      style: theme.textTheme.bodyLarge?.copyWith(color: colors.onSurface),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: colors.onSurfaceVariant,
        ),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, color: colors.onSurfaceVariant),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor ?? colors.surface,
      ),
    );
  }
}
