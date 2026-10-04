import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class InsightCard extends StatelessWidget {
  const InsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: context.cardColor,
        border: Border.all(color: context.borderColor),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.cardColor,
            AppColors.accent.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.blue],
              ),
            ),
            child: const Icon(Icons.psychology_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'LifeXA Insight',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: AppColors.accent.withValues(alpha: 0.12),
                        border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.25)),
                      ),
                      child: const Text(
                        'Personalized',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.lavender,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Your personalized insights will appear here as LifeXA learns your preferences and patterns.',
                  style: TextStyle(
                    fontSize: 13,
                    color: context.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Powered by RAG memory — coming in the next milestone.',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.mutedColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
