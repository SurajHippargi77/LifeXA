import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/auth_widgets.dart';
import '../../screens/dashboard/dashboard_screen.dart';
import 'forgot_password_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _serverError;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _validateEmail(String v) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim());

  bool _validate() {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    setState(() {
      _emailError = email.isEmpty
          ? 'Please enter your email address.'
          : !_validateEmail(email)
              ? 'Please enter a valid email address.'
              : null;
      _passwordError = password.isEmpty ? 'Please enter your password.' : null;
      _serverError = null;
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _loading = true);

    final result = await AuthService.login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      // TODO: persist token via secure storage in a future task
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const DashboardScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            final fade =
                CurvedAnimation(parent: animation, curve: Curves.easeOut);
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: animation, curve: Curves.easeOutCubic));
            return FadeTransition(
                opacity: fade,
                child: SlideTransition(position: slide, child: child));
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    } else {
      setState(() => _serverError = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          label: 'Email',
          hint: 'you@example.com',
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          errorText: _emailError,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          label: 'Password',
          hint: '••••••••',
          controller: _passwordCtrl,
          obscure: true,
          showToggle: true,
          errorText: _passwordError,
          textInputAction: TextInputAction.done,
          onEditingComplete: _loading ? null : _submit,
        ),

        if (_serverError != null) ...[
          const SizedBox(height: AppSpacing.md),
          AuthErrorBanner(message: _serverError!),
        ],

        const SizedBox(height: AppSpacing.xl),

        SizedBox(
          width: double.infinity,
          child: AuthSubmitButton(
            label: 'Login',
            loading: _loading,
            onPressed: _loading ? null : _submit,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen()),
            ),
            child: Text(
              'Forgot password?',
              style: TextStyle(
                color: context.isDark ? AppColors.lavender : AppColorsLight.accent,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Row(children: [
          Expanded(child: Divider(color: context.borderColor)),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              'or',
              style: TextStyle(
                  color: context.mutedColor.withValues(alpha: context.isDark ? 0.7 : 0.9),
                  fontSize: 12),
            ),
          ),
          Expanded(child: Divider(color: context.borderColor)),
        ]),

        const SizedBox(height: AppSpacing.md),

        SizedBox(
          width: double.infinity,
          child: _SocialButton(
            label: 'Continue with Google',
            icon: Icons.g_mobiledata_rounded,
            onPressed: null,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Text(
            'Google sign-in coming soon',
            style: TextStyle(fontSize: 11, color: context.mutedColor),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  const _SocialButton(
      {required this.label, required this.icon, required this.onPressed});

  @override
  State<_SocialButton> createState() => _SocialButtonState();
}

class _SocialButtonState extends State<_SocialButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final isDark = context.isDark;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _hovered && enabled
                ? AppColors.lavender.withValues(alpha: 0.4)
                : context.borderColor,
          ),
          color: isDark
              ? AppColors.background.withValues(alpha: 0.5)
              : AppColorsLight.background.withValues(alpha: 0.7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon,
                size: 20,
                color: enabled
                    ? context.textSecondary
                    : context.mutedColor),
            const SizedBox(width: 8),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                color: enabled
                    ? context.textSecondary
                    : context.mutedColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
