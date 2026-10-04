import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/auth_widgets.dart';
import 'email_verification_view.dart';

const bool _emailVerificationEnabled = false;

class SignupForm extends StatefulWidget {
  final void Function(String successMessage) onSignupSuccess;
  const SignupForm({super.key, required this.onSignupSuccess});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _serverError;
  bool _loading = false;
  bool _verificationVisible = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _validateEmail(String v) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(v.trim());

  bool _validate() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    setState(() {
      _nameError = name.isEmpty ? 'Please enter your name.' : null;
      _emailError = email.isEmpty
          ? 'Please enter your email address.'
          : !_validateEmail(email)
              ? 'Please enter a valid email address.'
              : null;
      _passwordError = password.isEmpty
          ? 'Please enter a password.'
          : password.length < 8
              ? 'Password must contain at least 8 characters.'
              : null;
      _confirmError = confirm.isEmpty
          ? 'Please confirm your password.'
          : confirm != password
              ? 'Passwords do not match.'
              : null;
      _serverError = null;
    });

    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _loading = true);

    final result = await AuthService.signup(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result.success) {
      if (_emailVerificationEnabled) {
        setState(() {
          _serverError = null;
          _verificationVisible = true;
        });
      } else {
        widget.onSignupSuccess('Account created successfully. Please log in.');
      }
    } else {
      setState(() => _serverError = result.error);
    }
  }

  void _returnToSignup() {
    setState(() {
      _verificationVisible = false;
      _serverError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_verificationVisible) {
      return EmailVerificationView(
        email: _emailCtrl.text.trim(),
        onVerified: () {
          setState(() => _verificationVisible = false);
          widget.onSignupSuccess(
            'Email verified successfully. Please sign in.',
          );
        },
        onChangeEmail: _returnToSignup,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          label: 'Full Name',
          hint: 'Your name',
          controller: _nameCtrl,
          errorText: _nameError,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
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
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        AuthTextField(
          label: 'Confirm Password',
          hint: '••••••••',
          controller: _confirmCtrl,
          obscure: true,
          showToggle: true,
          errorText: _confirmError,
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
            label: 'Create Account',
            loading: _loading,
            onPressed: _loading ? null : _submit,
          ),
        ),
      ],
    );
  }
}
