import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../auth/auth_modal.dart';
import '../dashboard_section.dart';

export '../dashboard_section.dart';

class DashboardSidebar extends StatelessWidget {
  final DashboardSection selected;
  final ValueChanged<DashboardSection> onSelect;

  const DashboardSidebar({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  void _logout(BuildContext context) {
    AuthSession.instance.clear();
    // Stay on dashboard — it works as a public preview after logout
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final borderCol = context.borderColor;
    final isDark = context.isDark;
    final isAuth = AuthSession.instance.isAuthenticated;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: context.cardColor.withValues(alpha: 0.95),
        border: Border(right: BorderSide(color: borderCol, width: 1)),
      ),
      child: Column(
        children: [
          // Logo area
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderCol, width: 1)),
            ),
            child: Row(
              children: [
                _LogoImage(isDark: isDark, size: 32),
                const SizedBox(width: AppSpacing.sm),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [AppColors.accent, AppColors.blue, AppColors.cyan],
                  ).createShader(bounds),
                  child: const Text(
                    'LifeXA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Nav items
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Column(
                    children: [
                      _NavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Home',
                        active: selected == DashboardSection.home,
                        onTap: () => onSelect(DashboardSection.home),
                      ),
                      _NavItem(
                        icon: Icons.auto_awesome_outlined,
                        activeIcon: Icons.auto_awesome_rounded,
                        label: 'AI Assistant',
                        active: selected == DashboardSection.assistant,
                        onTap: () => onSelect(DashboardSection.assistant),
                      ),
                      _NavItem(
                        icon: Icons.check_circle_outline_rounded,
                        activeIcon: Icons.check_circle_rounded,
                        label: 'Tasks',
                        active: selected == DashboardSection.tasks,
                        onTap: () => onSelect(DashboardSection.tasks),
                      ),
                      _NavItem(
                        icon: Icons.psychology_outlined,
                        activeIcon: Icons.psychology_rounded,
                        label: 'Memory',
                        active: selected == DashboardSection.memory,
                        onTap: () => onSelect(DashboardSection.memory),
                      ),
                      _NavItem(
                        icon: Icons.insights_outlined,
                        activeIcon: Icons.insights_rounded,
                        label: 'Insights',
                        active: selected == DashboardSection.insights,
                        onTap: () => onSelect(DashboardSection.insights),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.sm),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: isAuth ? 'Profile' : 'Profile',
                  active: selected == DashboardSection.profile,
                  onTap: () {
                    if (!isAuth) {
                      showAuthModal(context);
                      return;
                    }
                    onSelect(DashboardSection.profile);
                  },
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Settings',
                  active: selected == DashboardSection.settings,
                  onTap: () {
                    if (!isAuth) {
                      showAuthModal(context);
                      return;
                    }
                    onSelect(DashboardSection.settings);
                  },
                ),
                if (isAuth) ...[
                  _NavItem(
                    icon: Icons.logout_rounded,
                    activeIcon: Icons.logout_rounded,
                    label: 'Logout',
                    active: false,
                    isDestructive: true,
                    onTap: () => _logout(context),
                  ),
                ] else ...[
                  _NavItem(
                    icon: Icons.login_rounded,
                    activeIcon: Icons.login_rounded,
                    label: 'Sign In',
                    active: false,
                    onTap: () => showAuthModal(context),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Theme-aware logo: on dark use screen blend to dissolve dark bg;
/// on light render directly (logo has transparent/white bg areas).
class _LogoImage extends StatelessWidget {
  final bool isDark;
  final double size;
  const _LogoImage({required this.isDark, required this.size});

  @override
  Widget build(BuildContext context) {
    if (isDark) {
      return ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => RadialGradient(
          center: Alignment.center,
          radius: 0.55,
          colors: const [
            Colors.white,
            Colors.white,
            Color(0xCCFFFFFF),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 0.72, 1.0],
        ).createShader(rect),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(AppColors.background, BlendMode.screen),
          child: Image.asset(
            'assets/logo/lifexalogo.png',
            width: size,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    // Light mode: render logo directly, no blend needed
    return Image.asset(
      'assets/logo/lifexalogo.png',
      width: size,
      fit: BoxFit.contain,
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final bool isDestructive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final Color textColor;

    if (widget.isDestructive) {
      iconColor = textColor = _hovered ? AppColors.error : context.mutedColor;
    } else if (widget.active) {
      iconColor = textColor = AppColors.lavender;
    } else {
      iconColor = textColor = _hovered
          ? context.textPrimary
          : context.textSecondary;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: widget.active
                ? AppColors.accent.withValues(alpha: 0.12)
                : _hovered
                ? context.borderColor.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Icon(
                widget.active ? widget.activeIcon : widget.icon,
                size: 18,
                color: iconColor,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.active
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
