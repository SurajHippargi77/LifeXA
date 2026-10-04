import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscure;
  final bool showToggle;
  final TextInputType keyboardType;
  final String? errorText;
  final TextInputAction textInputAction;
  final VoidCallback? onEditingComplete;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscure = false,
    this.showToggle = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.onEditingComplete,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscured = true;
  bool _focused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscure;
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _focused = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final isDark = context.isDark;
    final borderColor = hasError
        ? context.errorColor
        : _focused
            ? AppColors.accent
            : context.borderColor;
    final fillColor = isDark
        ? AppColors.background.withValues(alpha: 0.6)
        : AppColorsLight.cardBg.withValues(alpha: 0.9);
    final shadowColor = hasError
        ? context.errorColor.withValues(alpha: isDark ? 0.12 : 0.18)
        : AppColors.accent.withValues(alpha: isDark ? 0.12 : 0.18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: borderColor,
              width: _focused ? 1.5 : 1.0,
            ),
            color: fillColor,
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 12,
                      spreadRadius: 0,
                    )
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.showToggle ? _obscured : widget.obscure,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onEditingComplete: widget.onEditingComplete,
            style: TextStyle(
              fontSize: 15,
              color: context.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: context.mutedColor.withValues(alpha: isDark ? 1 : 0.8),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14,
              ),
              suffixIcon: widget.showToggle
                  ? IconButton(
                      icon: Icon(
                        _obscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: context.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscured = !_obscured),
                    )
                  : null,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.info_outline, size: 13, color: context.errorColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  widget.errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.errorColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
