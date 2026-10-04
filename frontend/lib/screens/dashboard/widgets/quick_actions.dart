import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../auth/auth_modal.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth > 500 ? 4 : 2;
            final itemWidth =
                (constraints.maxWidth - (cols - 1) * AppSpacing.md) / cols;
            return Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: _actions
                  .map(
                    (a) => SizedBox(
                      width: itemWidth,
                      child: _ActionCard(action: a),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool available;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.available = false,
  });
}

const _actions = [
  _QuickAction(
    icon: Icons.add_task_rounded,
    title: 'Add Task',
    description: 'Create a new task or reminder',
    color: AppColors.accent,
    available: false,
  ),
  _QuickAction(
    icon: Icons.auto_awesome_rounded,
    title: 'Ask LifeXA',
    description: 'Chat with your AI assistant',
    color: AppColors.blue,
    available: false,
  ),
  _QuickAction(
    icon: Icons.psychology_rounded,
    title: 'Memory',
    description: 'View your saved memories',
    color: AppColors.lavender,
    available: false,
  ),
  _QuickAction(
    icon: Icons.insights_rounded,
    title: 'Insights',
    description: 'Productivity analytics',
    color: AppColors.cyan,
    available: false,
  ),
];

class _ActionCard extends StatefulWidget {
  final _QuickAction action;
  const _ActionCard({required this.action});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.action;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (!AuthSession.instance.isAuthenticated) {
            showAuthModal(context);
          }
        },
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              color: _hovered
                  ? context.cardColor
                  : context.cardColor.withValues(alpha: 0.7),
              border: Border.all(
                color: _hovered
                    ? a.color.withValues(alpha: 0.4)
                    : context.borderColor,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: a.color.withValues(alpha: 0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    color: a.color.withValues(alpha: 0.12),
                  ),
                  child: Icon(a.icon, size: 18, color: a.color),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  a.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  a.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.textSecondary,
                    height: 1.4,
                  ),
                ),
                if (!a.available) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: context.borderColor.withValues(alpha: 0.5),
                    ),
                    child: Text(
                      'Coming soon',
                      style: TextStyle(
                        fontSize: 9,
                        color: context.mutedColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
