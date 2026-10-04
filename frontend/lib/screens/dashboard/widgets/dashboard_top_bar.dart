import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../services/auth_service.dart';
import '../../auth/auth_modal.dart';

class DashboardTopBar extends StatelessWidget {
  final bool showMenuButton;
  final VoidCallback? onMenuTap;

  const DashboardTopBar({
    super.key,
    this.showMenuButton = false,
    this.onMenuTap,
  });

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final themeProvider = context.watch<ThemeProvider>();
    // Watch auth session so top bar rebuilds on login/logout
    context.watch<AuthSession>();
    final isAuth = AuthSession.instance.isAuthenticated;
    final borderCol = context.borderColor;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.cardColor.withValues(alpha: 0.95),
        border: Border(bottom: BorderSide(color: borderCol, width: 1)),
      ),
      child: Row(
        children: [
          // Hamburger on mobile/tablet
          if (showMenuButton) ...[
            IconButton(
              icon: Icon(Icons.menu_rounded,
                  color: context.textSecondary, size: 22),
              onPressed: onMenuTap,
              tooltip: 'Menu',
            ),
            const SizedBox(width: 4),
          ],

          // Mobile: compact logo
          if (isMobile) ...[
            _MobileTopBarLogo(isDark: isDark),
            const SizedBox(width: AppSpacing.sm),
          ],

          // Greeting (desktop only)
          Expanded(
            child: isMobile
                ? const SizedBox.shrink()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAuth
                            ? '${_greeting()}, ${_displayName()}'
                            : _greeting(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        isAuth
                            ? "Here's what your day looks like."
                            : 'Sign in to unlock your personal LifeXA experience.',
                        style: TextStyle(
                            fontSize: 12, color: context.textSecondary),
                      ),
                    ],
                  ),
          ),

          // Theme toggle
          Tooltip(
            message: isDark ? 'Switch to light mode' : 'Switch to dark mode',
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  key: ValueKey(isDark),
                  color: context.textSecondary,
                  size: 20,
                ),
              ),
              onPressed: themeProvider.toggle,
            ),
          ),

          // Notifications (placeholder)
          Tooltip(
            message: 'Notifications — coming soon',
            child: IconButton(
              icon: Icon(Icons.notifications_none_rounded,
                  color: context.textSecondary, size: 20),
              onPressed: () {},
            ),
          ),

          const SizedBox(width: 4),

          // Auth: Sign In button OR profile menu
          if (!isAuth)
            _SignInButton(onTap: () => showAuthModal(context))
          else
            _ProfileMenu(
              onLogout: () {
                AuthSession.instance.clear();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
    );
  }

  String _displayName() {
    final name = AuthSession.instance.userName;
    if (name != null && name.isNotEmpty) {
      return name.split(' ').first;
    }
    final email = AuthSession.instance.userEmail;
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'there';
  }
}

// ── Sign In button (shown when logged out) ────────────────────────────────────
class _SignInButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SignInButton({required this.onTap});

  @override
  State<_SignInButton> createState() => _SignInButtonState();
}

class _SignInButtonState extends State<_SignInButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: _hovered
                ? const LinearGradient(
                    colors: [AppColors.accent, AppColors.blue])
                : null,
            border: Border.all(
              color: _hovered
                  ? Colors.transparent
                  : AppColors.accent.withValues(alpha: 0.5),
            ),
            color: _hovered
                ? null
                : AppColors.accent.withValues(alpha: 0.08),
          ),
          child: Text(
            'Sign In',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _hovered ? Colors.white : AppColors.lavender,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Profile menu (shown when logged in) ───────────────────────────────────────
class _ProfileMenu extends StatelessWidget {
  final VoidCallback onLogout;
  const _ProfileMenu({required this.onLogout});

  String _initial() {
    final name = AuthSession.instance.userName;
    if (name != null && name.isNotEmpty) return name[0].toUpperCase();
    final email = AuthSession.instance.userEmail;
    if (email != null && email.isNotEmpty) return email[0].toUpperCase();
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Profile',
      offset: const Offset(0, 48),
      color: context.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: context.borderColor),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'profile',
          child: _MenuItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              context: context),
        ),
        PopupMenuItem(
          value: 'settings',
          child: _MenuItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              context: context),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'logout',
          child: _MenuItem(
              icon: Icons.logout_rounded,
              label: 'Logout',
              context: context,
              isDestructive: true),
        ),
      ],
      onSelected: (val) {
        if (val == 'logout') onLogout();
      },
      child: CircleAvatar(
        radius: 17,
        backgroundColor: AppColors.accent.withValues(alpha: 0.18),
        child: Text(
          _initial(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.lavender,
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final BuildContext context;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.context,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext _) {
    final color = isDestructive ? AppColors.error : context.textSecondary;
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.sm),
        Text(label,
            style: TextStyle(
                fontSize: 13, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ── Mobile logo ───────────────────────────────────────────────────────────────
class _MobileTopBarLogo extends StatelessWidget {
  final bool isDark;
  const _MobileTopBarLogo({required this.isDark});

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
          colorFilter: ColorFilter.mode(
            AppColors.background,
            BlendMode.screen,
          ),
          child: Image.asset(
            'assets/logo/lifexalogo.png',
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
    return Image.asset(
      'assets/logo/lifexalogo.png',
      height: 32,
      fit: BoxFit.contain,
    );
  }
}
