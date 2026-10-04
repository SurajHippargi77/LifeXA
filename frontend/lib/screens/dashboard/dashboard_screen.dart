import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../auth/auth_modal.dart';
import 'widgets/dashboard_sidebar.dart';
import 'widgets/dashboard_top_bar.dart';
import 'widgets/ai_assistant_card.dart';
import 'widgets/today_section.dart';
import 'widgets/quick_actions.dart';
import 'widgets/insight_card.dart';
import 'widgets/productivity_snapshot.dart';

export 'dashboard_section.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardSection _section = DashboardSection.home;
  bool _visible = false;
  bool _guestPromptShown = false;
  Timer? _guestPromptTimer;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    AuthSession.instance.addListener(_handleAuthChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _visible = true);
      _scheduleGuestPrompt();
    });
  }

  @override
  void dispose() {
    _guestPromptTimer?.cancel();
    AuthSession.instance.removeListener(_handleAuthChanged);
    super.dispose();
  }

  void _scheduleGuestPrompt() {
    _guestPromptTimer?.cancel();
    if (AuthSession.instance.isAuthenticated || _guestPromptShown) return;

    _guestPromptTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted || _guestPromptShown) return;
      _guestPromptShown = true;
      if (AuthSession.instance.isAuthenticated ||
          !(ModalRoute.of(context)?.isCurrent ?? true)) {
        return;
      }
      showAuthModal(context);
    });
  }

  void _handleAuthChanged() {
    if (!AuthSession.instance.isAuthenticated &&
        _isProtectedSection(_section)) {
      setState(() {
        _section = DashboardSection.home;
        _visible = true;
      });
    }
  }

  bool _isProtectedSection(DashboardSection s) => switch (s) {
        DashboardSection.assistant => true,
        DashboardSection.tasks => true,
        DashboardSection.memory => true,
        DashboardSection.insights => true,
        DashboardSection.settings => true,
        DashboardSection.profile => true,
        _ => false,
      };

  void _onSectionSelect(DashboardSection s) {
    if (_isProtectedSection(s) && !AuthSession.instance.isAuthenticated) {
      showAuthModal(context);
      return;
    }

    if (_section == s) return;
    setState(() {
      _visible = false;
      _section = s;
    });
    // Re-show after a short delay so the fade-in plays
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final isMobile = width < 600;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: context.bgColor,
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: Colors.transparent,
              child: DashboardSidebar(
                selected: _section,
                onSelect: (s) {
                  Navigator.of(context).pop();
                  _onSectionSelect(s);
                },
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Persistent sidebar on desktop
          if (isDesktop)
            DashboardSidebar(
              selected: _section,
              onSelect: _onSectionSelect,
            ),

          // Main area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top bar
                DashboardTopBar(
                  showMenuButton: !isDesktop,
                  onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                ),

                // Scrollable content
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: isMobile ? AppSpacing.md : AppSpacing.lg,
                        right: isMobile ? AppSpacing.md : AppSpacing.lg,
                        top: isMobile ? AppSpacing.md : AppSpacing.lg,
                        bottom: isMobile
                            ? AppSpacing.xl + 72
                            : AppSpacing.xl,
                      ),
                      child: AnimatedOpacity(
                        opacity: _visible ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOut,
                        child: Center(
                          child: ConstrainedBox(
                            constraints:
                                const BoxConstraints(maxWidth: 1100),
                            child: _buildContent(isMobile),
                          ),
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
      bottomNavigationBar: isMobile
          ? _MobileBottomNav(
              selected: _section,
              onSelect: _onSectionSelect,
            )
          : null,
    );
  }

  Widget _buildContent(bool isMobile) {
    if (_section == DashboardSection.home) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AiAssistantCard(),
          const SizedBox(height: AppSpacing.xl),
          if (!isMobile)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _Card(child: const TodaySection()),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  flex: 2,
                  child: _Card(child: const QuickActions()),
                ),
              ],
            )
          else ...[
            _Card(child: const TodaySection()),
            const SizedBox(height: AppSpacing.lg),
            _Card(child: const QuickActions()),
          ],
          const SizedBox(height: AppSpacing.lg),
          const InsightCard(),
          const SizedBox(height: AppSpacing.lg),
          _Card(child: const ProductivitySnapshot()),
          const SizedBox(height: AppSpacing.md),
        ],
      );
    }

    if (_section == DashboardSection.assistant) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: const AiAssistantCard(),
        ),
      );
    }

    return _SectionPlaceholder(section: _section);
  }
}

// ── Card wrapper ──────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: context.cardColor,
        border: Border.all(color: context.borderColor),
      ),
      child: child,
    );
  }
}

// ── Section placeholder ───────────────────────────────────────────────────────
class _SectionPlaceholder extends StatelessWidget {
  final DashboardSection section;
  const _SectionPlaceholder({required this.section});

  String get _label => switch (section) {
        DashboardSection.assistant => 'AI Assistant',
        DashboardSection.tasks => 'Tasks',
        DashboardSection.memory => 'Memory',
        DashboardSection.insights => 'Insights',
        DashboardSection.settings => 'Settings',
        DashboardSection.profile => 'Profile',
        _ => '',
      };

  String get _subtitle => switch (section) {
        DashboardSection.assistant =>
          'Your AI workspace will appear here.',
        DashboardSection.tasks =>
          'No tasks yet. Task management is coming in the next milestone.',
        DashboardSection.memory =>
          'Your memories will appear here once the RAG memory system is connected.',
        DashboardSection.insights =>
          'Insights will appear as LifeXA learns your preferences and patterns.',
        DashboardSection.settings =>
          'App settings and preferences will be available here.',
        DashboardSection.profile =>
          'Your profile and account details will appear here.',
        _ => 'Coming in the next milestone.',
      };

  IconData get _icon => switch (section) {
        DashboardSection.assistant => Icons.auto_awesome_rounded,
        DashboardSection.tasks => Icons.check_circle_outline_rounded,
        DashboardSection.memory => Icons.psychology_rounded,
        DashboardSection.insights => Icons.insights_rounded,
        DashboardSection.settings => Icons.settings_outlined,
        DashboardSection.profile => Icons.person_outline_rounded,
        _ => Icons.hourglass_empty_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon,
                size: 44,
                color: AppColors.lavender.withValues(alpha: 0.45)),
            const SizedBox(height: AppSpacing.md),
            Text(
              _label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mobile bottom navigation ──────────────────────────────────────────────────
class _MobileBottomNav extends StatelessWidget {
  final DashboardSection selected;
  final ValueChanged<DashboardSection> onSelect;
  const _MobileBottomNav({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const items = [
      (DashboardSection.home, Icons.home_rounded, Icons.home_outlined, 'Home'),
      (
        DashboardSection.assistant,
        Icons.auto_awesome_rounded,
        Icons.auto_awesome_outlined,
        'Assistant'
      ),
      (
        DashboardSection.tasks,
        Icons.check_circle_rounded,
        Icons.check_circle_outline_rounded,
        'Tasks'
      ),
      (
        DashboardSection.memory,
        Icons.psychology_rounded,
        Icons.psychology_outlined,
        'Memory'
      ),
      (
        DashboardSection.profile,
        Icons.person_rounded,
        Icons.person_outline_rounded,
        'Profile'
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: items.map((item) {
              final (section, activeIcon, inactiveIcon, label) = item;
              final active = selected == section;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSelect(section),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? activeIcon : inactiveIcon,
                        size: 22,
                        color: active
                            ? AppColors.lavender
                            : context.mutedColor,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          color: active
                              ? AppColors.lavender
                              : context.mutedColor,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
