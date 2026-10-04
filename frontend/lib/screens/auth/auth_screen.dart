import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import 'login_form.dart';
import 'signup_form.dart';

enum _AuthTab { login, signup }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  _AuthTab _tab = _AuthTab.login;
  String? _signupSuccessMessage;

  late final AnimationController _tabCtrl;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    _tabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _buildTabAnimations(forward: true);
    _tabCtrl.forward();
  }

  void _buildTabAnimations({required bool forward}) {
    _formFade = CurvedAnimation(parent: _tabCtrl, curve: Curves.easeIn);
    _formSlide = Tween<Offset>(
      begin: Offset(forward ? 0.04 : -0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _tabCtrl, curve: Curves.easeOutCubic));
  }

  Future<void> _switchTab(_AuthTab tab, {String? successMessage}) async {
    if (tab == _tab && successMessage == null) return;
    await _tabCtrl.reverse();
    setState(() {
      _tab = tab;
      _signupSuccessMessage = successMessage;
      _buildTabAnimations(forward: tab == _AuthTab.signup);
    });
    _tabCtrl.forward();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width.clamp(0.0, 460.0);
    final isNarrow = size.width < 480;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : AppColorsLight.background,
      body: Stack(
        children: [
          // Background radial gradient
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.2),
                radius: 1.4,
                colors: isDark
                    ? const [Color(0xFF111936), AppColors.background]
                    : [AppColorsLight.backgroundAlt, AppColorsLight.background],
              ),
            ),
          ),

          // Ambient glow — violet
          Align(
            alignment: const Alignment(-0.6, -0.7),
            child: Container(
              width: size.width * 0.55,
              height: size.width * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.accent.withValues(alpha: 0.10),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // Ambient glow — cyan
          Align(
            alignment: const Alignment(0.6, 0.6),
            child: Container(
              width: size.width * 0.40,
              height: size.width * 0.40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.cyan.withValues(alpha: 0.07),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // Content — scrollable, no visible scrollbar
          SafeArea(
            child: Center(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context)
                    .copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isNarrow ? AppSpacing.md : AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LogoHeader(cardWidth: cardWidth),
                      const SizedBox(height: AppSpacing.lg),

                      GlassCard(
                        width: cardWidth,
                        padding: EdgeInsets.all(
                            isNarrow ? AppSpacing.lg : AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome to LifeXA',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your intelligent life assistant',
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            _TabToggle(
                              selected: _tab,
                              onSelect: (tab) => _switchTab(tab),
                            ),

                            // Success banner shown after signup
                            if (_tab == _AuthTab.login &&
                                _signupSuccessMessage != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              _SuccessBanner(
                                message: _signupSuccessMessage!,
                                onDismiss: () => setState(
                                    () => _signupSuccessMessage = null),
                              ),
                            ],

                            const SizedBox(height: AppSpacing.xl),

                            FadeTransition(
                              opacity: _formFade,
                              child: SlideTransition(
                                position: _formSlide,
                                child: _tab == _AuthTab.login
                                    ? const LoginForm()
                                    : SignupForm(
                                        onSignupSuccess: (msg) => _switchTab(
                                          _AuthTab.login,
                                          successMessage: msg,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
    final color = isDark ? AppColors.cyan : AppColorsLight.cyan;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.10 : 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
            color: color.withValues(alpha: isDark ? 0.35 : 0.45)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: color),
            ),
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

// ── Logo header ───────────────────────────────────────────────────────────────

class _LogoHeader extends StatelessWidget {
  final double cardWidth;
  const _LogoHeader({required this.cardWidth});

  @override
  Widget build(BuildContext context) {
    final logoSize = (cardWidth * 0.35).clamp(72.0, 120.0);
    return _AuthLogo(width: logoSize, isDark: Theme.of(context).brightness == Brightness.dark);
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
            ? AppColors.background.withValues(alpha: 0.6)
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

class _TabItem extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabItem(
      {required this.label, required this.active, required this.onTap});

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md - 1),
              gradient: widget.active
                  ? const LinearGradient(
                      colors: [AppColors.accent, AppColors.blue, AppColors.cyan],
                    )
                  : null,
              color: !widget.active && _hovered
                  ? (isDark
                      ? AppColors.border.withValues(alpha: 0.3)
                      : AppColorsLight.border.withValues(alpha: 0.18))
                  : null,
              boxShadow: widget.active
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    widget.active ? FontWeight.w600 : FontWeight.w400,
                color: widget.active
                    ? Colors.white
                    : (isDark ? context.textSecondary : AppColorsLight.textSecondary),
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
