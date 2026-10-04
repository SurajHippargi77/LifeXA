import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AuthSubmitButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  State<AuthSubmitButton> createState() => _AuthSubmitButtonState();
}

class _AuthSubmitButtonState extends State<AuthSubmitButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final isDark = context.isDark;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed!();
              }
            : null,
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : (_hovered && enabled ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              gradient: LinearGradient(
                colors: enabled
                    ? [AppColors.accent, AppColors.blue, AppColors.cyan]
                    : [AppColors.muted, AppColors.muted],
              ),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.accent
                            .withValues(alpha: _hovered ? 0.50 : 0.30),
                        blurRadius: _hovered ? 32 : 18,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: widget.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final errorColor = context.errorColor;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: isDark ? 0.10 : 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: errorColor.withValues(alpha: isDark ? 0.30 : 0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              size: 15, color: errorColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
