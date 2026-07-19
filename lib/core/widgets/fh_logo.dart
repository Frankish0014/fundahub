import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum FhLogoVariant { splash, soft }

/// Concentric-circle mark matching the FundaHub Figma logo.
class FhLogo extends StatelessWidget {
  const FhLogo({super.key, this.variant = FhLogoVariant.soft, this.size = 120});

  final FhLogoVariant variant;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isSplash = variant == FhLogoVariant.splash;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSplash ? AppColors.surface : AppColors.mint,
        borderRadius: isSplash ? BorderRadius.circular(size * 0.22) : null,
        shape: isSplash ? BoxShape.rectangle : BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: CustomPaint(
        size: Size.square(size * 0.55),
        painter: _TargetPainter(color: AppColors.primary, fillCenter: true),
      ),
    );
  }
}

class _TargetPainter extends CustomPainter {
  _TargetPainter({required this.color, required this.fillCenter});

  final Color color;
  final bool fillCenter;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.09;

    canvas.drawCircle(center, size.width * 0.48, stroke);
    canvas.drawCircle(center, size.width * 0.30, stroke);

    if (fillCenter) {
      final fill = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, size.width * 0.12, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _TargetPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.fillCenter != fillCenter;
}
