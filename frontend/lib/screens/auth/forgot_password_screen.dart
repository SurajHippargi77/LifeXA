import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/glass_card.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  String? _emailError;
  bool _submitted = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _validateEmail(String v) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim());

  void _submit() {
    final email = _emailCtrl.text.trim();
    setState(() {
      _emailError = email.isEmpty
          ? 'Please enter your email address.'
          : !_validateEmail(email)
              ? 'Please enter a valid email address.'
              : null;
    });
    if (_emailError != null) return;
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width.clamp(0.0, 440.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.3, -0.5),
                radius: 1.3,
                colors: [Color(0xFF111936), AppColors.background],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: AppSpacing.md, top: AppSpacing.sm),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textSecondary, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Back',
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xl),
                        child: GlassCard(
                          width: cardWidth,
                          child: _submitted
                              ? _buildSentState()
                              : _buildForm(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Password reset is not yet available.\nEnter your email and we\'ll notify you when this feature launches.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AuthTextField(
          label: 'Email',
          hint: 'you@example.com',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          textInputAction: TextInputAction.done,
          onEditingComplete: _submit,
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: _PrimaryButton(
            label: 'Send Reset Link',
            onPressed: _submit,
          ),
        ),
      ],
    );
  }

  Widget _buildSentState() {
    return Column(
      children: [
        const Icon(Icons.info_outline_rounded,
            color: AppColors.lavender, size: 40),
        const SizedBox(height: AppSpacing.md),
        const Text(
          'Coming Soon',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Password reset is not yet available.\nWe\'ll add this feature in a future update.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Back to Login',
            style: TextStyle(color: AppColors.lavender, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

// Local minimal primary button (avoids importing GradientButton just for this screen)
class _PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : (_hovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.blue, AppColors.cyan],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent
                      .withValues(alpha: _hovered ? 0.50 : 0.32),
                  blurRadius: _hovered ? 32 : 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'Send Reset Link',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
