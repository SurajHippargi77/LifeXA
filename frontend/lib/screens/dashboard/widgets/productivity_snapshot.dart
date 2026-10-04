import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ProductivitySnapshot extends StatelessWidget {
  const ProductivitySnapshot({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Productivity',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppColors.cyan.withValues(alpha: 0.10),
                border: Border.all(
                  color: AppColors.cyan.withValues(alpha: 0.25),
                ),
              ),
              child: const Text(
                'Coming soon',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth < 480 ? 2 : 4;
            final spacing = AppSpacing.sm;
            final tileWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _StatTile(
                  width: tileWidth,
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Completed',
                  value: '—',
                  color: AppColors.cyan,
                ),
                _StatTile(
                  width: tileWidth,
                  icon: Icons.timer_outlined,
                  label: 'Focus time',
                  value: '—',
                  color: AppColors.accent,
                ),
                _StatTile(
                  width: tileWidth,
                  icon: Icons.event_outlined,
                  label: 'Upcoming',
                  value: '—',
                  color: AppColors.blue,
                ),
                _StatTile(
                  width: tileWidth,
                  icon: Icons.local_fire_department_outlined,
                  label: 'Streak',
                  value: '—',
                  color: AppColors.lavender,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            color: AppColors.cyan.withValues(alpha: 0.05),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.15)),
          ),
          child: Text(
            'Your productivity insights will appear here once task tracking is connected.',
            style: TextStyle(fontSize: 11, color: context.mutedColor),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: context.cardColor,
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: context.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
