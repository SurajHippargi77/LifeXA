import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _breathe;

  late final Animation<double> _glowFade;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _hintFade;
  late final Animation<double> _breatheAnim;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    )..repeat(reverse: true);

    _glowFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.0, 0.30, curve: Curves.easeIn),
    );
    _logoFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.08, 0.45, curve: Curves.easeIn),
    );
    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _intro,
        curve: const Interval(0.08, 0.50, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.42, 0.68, curve: Curves.easeIn),
    );
    _hintFade = CurvedAnimation(
      parent: _intro,
      curve: const Interval(0.65, 0.88, curve: Curves.easeIn),
    );
    _breatheAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _breathe, curve: Curves.easeInOut));

    _intro.forward();

    // Auto-navigate after 2.6 seconds
    _navigationTimer = Timer(const Duration(milliseconds: 2600), _navigate);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _intro.dispose();
    _breathe.dispose();
    super.dispose();
  }

  void _navigate() {
    if (!mounted) return;
    // Import is resolved at runtime via the route
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showSubtitle = size.height >= 220;
    final showHint = size.height >= 290;
    final reservedHeight =
        (showSubtitle ? 40.0 : 0.0) + (showHint ? 45.0 : 0.0) + 20.0;
    final logoSize = (size.width * 0.38)
        .clamp(140.0, 280.0)
        .clamp(0.0, size.height - reservedHeight)
        .toDouble();
    final glowLarge = size.width.clamp(300.0, 900.0) * 0.65;
    final glowSmall = size.width.clamp(300.0, 900.0) * 0.42;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.background
          : AppColorsLight.background,
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background radial gradient
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.2),
                  radius: 1.4,
                  colors: isDark
                      ? const [Color(0xFF111936), AppColors.background]
                      : const [
                          AppColorsLight.backgroundAlt,
                          AppColorsLight.background,
                        ],
                ),
              ),
            ),

            // Ambient glow — violet top-left
            FadeTransition(
              opacity: _glowFade,
              child: Align(
                alignment: const Alignment(-0.55, -0.65),
                child: Container(
                  width: glowLarge,
                  height: glowLarge,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.14),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Ambient glow — cyan bottom-right
            FadeTransition(
              opacity: _glowFade,
              child: Align(
                alignment: const Alignment(0.55, 0.55),
                child: Container(
                  width: glowSmall,
                  height: glowSmall,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.cyan.withValues(alpha: 0.09),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Breathing glow behind logo
            FadeTransition(
              opacity: _logoFade,
              child: AnimatedBuilder(
                animation: _breatheAnim,
                builder: (context, child) => Container(
                  width: logoSize * 1.3,
                  height: logoSize * 1.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(
                          alpha: 0.10 * _breatheAnim.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: isDark
                        ? ShaderMask(
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
                                width: logoSize,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/logo/lifexalogo.png',
                            width: logoSize,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),

                if (showSubtitle) const SizedBox(height: 20),

                // Subtitle
                if (showSubtitle)
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: Text(
                      'Your Intelligent Life Assistant',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColorsLight.textSecondary,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),

                if (showHint) const SizedBox(height: 32),

                // Feature hint
                if (showHint)
                  FadeTransition(
                    opacity: _hintFade,
                    child: Text(
                      'AI  •  Memory  •  Tasks  •  Insights',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.muted : AppColorsLight.muted,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
