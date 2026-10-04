import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../auth/auth_modal.dart';

class TodaySection extends StatelessWidget {
  const TodaySection({super.key});

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthSession>().isAuthenticated;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Today',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            Text(
              _formattedDate(),
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: context.bgColor.withValues(alpha: 0.45),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.accent.withValues(alpha: 0.9),
                size: 24,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your tasks will appear here',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                isAuthenticated
                    ? 'Your personal task list will be ready here when task management is connected.'
                    : 'Sign in to create, manage, and organize your tasks with LifeXA.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: context.textSecondary,
                ),
              ),
              if (!isAuthenticated) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _SignInButton(
                    onPressed: () => showAuthModal(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.login_rounded, size: 17),
      label: const Text('Sign In / Sign Up'),
      style: TextButton.styleFrom(
        foregroundColor: context.isDark ? AppColors.lavender : AppColorsLight.accent,
        minimumSize: const Size(48, 44),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.45)),
        ),
      ),
    );
  }
}
