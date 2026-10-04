import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/auth_widgets.dart';

enum _AuthTab { login, signup }

/// Shows the LifeXA auth modal. Returns true if the user successfully logged in.
Future<bool> showAuthModal(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.65),
    builder: (_) => const _AuthModal(),
  );
  return result == true;
}

class _AuthModal extends StatefulWidget {
  const _AuthModal();

  @override
  State<_AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<_AuthModal>
    with SingleTickerProviderStateMixin {
  _AuthTab _tab = _AuthTab.login;
  String? _signupSuccessMessage;

  late final AnimationController _tabCtrl;
  late Animation<double> _formFade;

  @override
  void initState() {
    super.initState();
    _tabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..value = 1.0;
    _formFade = CurvedAnimation(parent: _tabCtrl, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _switchTab(_AuthTab tab, {String? successMessage}) async {
    if (tab == _tab && successMessage == null) return;
    await _tabCtrl.reverse();
    if (!mounted) return;
    setState(() {
      _tab = tab;
      _signupSuccessMessage = successMessage;
    });
    _tabCtrl.forward();
  }

  void _onLoginSuccess() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 500;
    final modalWidth = isMobile ? size.width * 0.95 : 440.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 24,
        vertical: 24,
      ),
      child: Container(
        width: modalWidth,
        constraints: BoxConstraints(maxHeight: size.height * 0.92),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.12),
              blurRadius: 48,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      // Logo
                      _AuthLogo(width: 36, isDark: Theme.of(context).brightness == Brightness.dark),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to LifeXA',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            Text(
                              'Sign in to unlock your personal experience.',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Close button
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            size: 20, color: context.mutedColor),
                        onPressed: () => Navigator.of(context).pop(false),
                        tooltip: 'Close',
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Tab toggle
                  _TabToggle(
                    selected: _tab,
                    onSelect: (t) => _switchTab(t),
                  ),

                  // Success banner after signup
                  if (_tab == _AuthTab.login &&
                      _signupSuccessMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _SuccessBanner(
                      message: _signupSuccessMessage!,
                      onDismiss: () =>
                          setState(() => _signupSuccessMessage = null),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // Form
                  FadeTransition(
                    opacity: _formFade,
                    child: _tab == _AuthTab.login
                        ? _LoginForm(onSuccess: _onLoginSuccess)
                        : _SignupForm(
                            onSuccess: (msg) => _switchTab(
                              _AuthTab.login,
                              successMessage: msg,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthLogo extends StatelessWidget {
  final double width;
  final bool isDark;

  const _AuthLogo({required this.width, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (isDark) {
      return ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => RadialGradient(
          center: Alignment.center,
          radius: 0.50,
          colors: const [
            Colors.white,
            Colors.white,
            Color(0xCCFFFFFF),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 0.72, 1.0],
        ).createShader(rect),
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            AppColors.background,
            BlendMode.screen,
          ),
          child: Image.asset(
            'assets/logo/lifexalogo.png',
            width: width,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return Image.asset(
      'assets/logo/lifexalogo.png',
      width: width,
      fit: BoxFit.contain,
    );
  }
}

// ── Tab toggle ────────────────────────────────────────────────────────────────
class _TabToggle extends StatelessWidget {
  final _AuthTab selected;
  final ValueChanged<_AuthTab> onSelect;
  const _TabToggle({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? context.bgColor.withValues(alpha: 0.6)
            : AppColorsLight.background.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Login',
            active: selected == _AuthTab.login,
            onTap: () => onSelect(_AuthTab.login),
          ),
          _TabItem(
            label: 'Sign Up',
            active: selected == _AuthTab.signup,
            onTap: () => onSelect(_AuthTab.signup),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabItem({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md - 1),
            gradient: active
                ? const LinearGradient(
                    colors: [AppColors.accent, AppColors.blue, AppColors.cyan])
                : null,
            color: active
                ? null
                : (isDark
                    ? Colors.transparent
                    : AppColorsLight.backgroundAlt.withValues(alpha: 0.7)),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active
                  ? Colors.white
                  : (isDark ? context.textSecondary : AppColorsLight.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Success banner ────────────────────────────────────────────────────────────
class _SuccessBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _SuccessBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final textColor = isDark ? AppColors.cyan : AppColorsLight.cyan;
    final bgColor = isDark
        ? AppColors.cyan.withValues(alpha: 0.10)
        : AppColorsLight.cyan.withValues(alpha: 0.12);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: textColor.withValues(alpha: isDark ? 0.35 : 0.45),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 15, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 13, color: textColor)),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close_rounded,
                size: 14, color: context.mutedColor),
          ),
        ],
      ),
    );
  }
}

// ── Login form ────────────────────────────────────────────────────────────────
class _LoginForm extends StatefulWidget {
  final VoidCallback onSuccess;
  const _LoginForm({required this.onSuccess});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
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
          ? 'Please enter your email.'
          : !_validateEmail(email)
              ? 'Please enter a valid email.'
              : null;
      _passwordError =
          password.isEmpty ? 'Please enter your password.' : null;
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
      widget.onSuccess();
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
      ],
    );
  }
}

// ── Signup form ───────────────────────────────────────────────────────────────
class _SignupForm extends StatefulWidget {
  final void Function(String msg) onSuccess;
  const _SignupForm({required this.onSuccess});

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
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
          ? 'Please enter your email.'
          : !_validateEmail(email)
              ? 'Please enter a valid email.'
              : null;
      _passwordError = password.isEmpty
          ? 'Please enter a password.'
          : password.length < 8
              ? 'Password must be at least 8 characters.'
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
      widget.onSuccess('Account created successfully. Please log in.');
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
