import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      width: width,
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardBg.withValues(alpha: 0.85)
            : AppColorsLight.cardBg.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: context.borderColor,
          width: isDark ? 1 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColorsLight.accent)
                .withValues(alpha: isDark ? 0.35 : 0.07),
            blurRadius: isDark ? 40 : 24,
            offset: Offset(0, isDark ? 12 : 8),
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: isDark ? 0.06 : 0.09),
            blurRadius: 60,
            spreadRadius: -10,
          ),
        ],
      ),
      child: child,
    );
  }
}
