import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_widgets.dart';

class EmailVerificationView extends StatefulWidget {
  final String email;
  final VoidCallback onVerified;
  final VoidCallback onChangeEmail;
  final VoidCallback? onReturnToLogin;

  const EmailVerificationView({
    super.key,
    required this.email,
    required this.onVerified,
    required this.onChangeEmail,
    this.onReturnToLogin,
  });

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  static const int _codeLength = 6;

  final List<TextEditingController> _controllers = List.generate(
    _codeLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _codeLength,
    (_) => FocusNode(),
  );

  bool _loading = false;
  bool _resending = false;
  int _cooldownSeconds = 0;
  String? _errorMessage;
  String? _successMessage;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startCooldown([int seconds = 45]) {
    _timer?.cancel();
    _cooldownSeconds = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
        return;
      }
      setState(() => _cooldownSeconds--);
    });
  }

  String get _code => _controllers.map((controller) => controller.text).join();

  void _onDigitChanged(String value, int index) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isEmpty) {
        _controllers[index].clear();
        return;
      }
      final firstDigit = digits.substring(0, 1);
      _controllers[index].text = firstDigit;
      _controllers[index].selection = TextSelection.collapsed(offset: 1);
    }

    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }

    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
  }

  Future<void> _verifyCode() async {
    final code = _code.trim();
    if (code.length != _codeLength) {
      setState(() => _errorMessage = 'Please enter the 6-digit code we sent to your email.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await AuthService.verifyEmailCode(
      email: widget.email,
      code: code,
    );

    if (!mounted) return;

    setState(() => _loading = false);

    if (result.success) {
      setState(() => _successMessage = 'Email verified successfully.');
      widget.onVerified();
      return;
    }

    setState(() {
      _errorMessage = result.error ??
          'Unable to verify your email right now. Please try again.';
    });
  }

  Future<void> _resendCode() async {
    if (_cooldownSeconds > 0 || _resending) return;

    setState(() {
      _resending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await AuthService.resendVerificationCode(email: widget.email);

    if (!mounted) return;

    setState(() => _resending = false);

    if (result.success) {
      _startCooldown(45);
      setState(() => _successMessage = 'Verification code sent again.');
      for (final controller in _controllers) {
        controller.clear();
      }
      FocusScope.of(context).requestFocus(_focusNodes.first);
      return;
    }

    setState(() => _errorMessage = result.error ?? 'Unable to resend the code right now.');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.blue, AppColors.cyan],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: const Icon(
              Icons.mark_email_unread_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: Text(
            'Verify your email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: Text(
            "We've sent a verification code to\n${widget.email}",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: context.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Enter the 6-digit code',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_codeLength, (index) {
            return SizedBox(
              width: 42,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                maxLength: 1,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: isDark
                      ? AppColors.background.withValues(alpha: 0.55)
                      : AppColorsLight.backgroundAlt.withValues(alpha: 0.8),
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: context.borderColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: BorderSide(
                      color: context.borderColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    borderSide: const BorderSide(
                      color: AppColors.accent,
                      width: 1.5,
                    ),
                  ),
                  hintText: '_',
                  hintStyle: TextStyle(
                    color: context.mutedColor,
                  ),
                ),
                onChanged: (value) => _onDigitChanged(value, index),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (_errorMessage != null) ...[
          AuthErrorBanner(message: _errorMessage!),
          const SizedBox(height: AppSpacing.md),
        ],
        if (_successMessage != null) ...[
          _SuccessBanner(
            message: _successMessage!,
            onDismiss: () => setState(() => _successMessage = null),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        SizedBox(
          width: double.infinity,
          child: AuthSubmitButton(
            label: _loading ? 'Verifying...' : 'Verify Email',
            loading: _loading,
            onPressed: _loading ? null : _verifyCode,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: TextButton(
            onPressed: (_cooldownSeconds > 0 || _resending) ? null : _resendCode,
            child: Text(
              _cooldownSeconds > 0
                  ? 'Resend code in ${_cooldownSeconds}s'
                  : (_resending ? 'Sending code...' : 'Resend code'),
              style: TextStyle(
                color: (_cooldownSeconds > 0 || _resending)
                    ? context.mutedColor
                    : (isDark ? AppColors.lavender : AppColorsLight.accent),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: TextButton(
            onPressed: widget.onChangeEmail,
            child: Text(
              'Change email',
              style: TextStyle(
                color: context.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (widget.onReturnToLogin != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: TextButton(
              onPressed: widget.onReturnToLogin,
              child: Text(
                'Back to login',
                style: TextStyle(
                  color: isDark ? AppColors.lavender : AppColorsLight.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _SuccessBanner({
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final color = isDark ? AppColors.cyan : AppColorsLight.cyan;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.10 : 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.45),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: color),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close_rounded,
              size: 14,
              color: context.mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}
