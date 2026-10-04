import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../auth/auth_modal.dart';

class AiAssistantCard extends StatefulWidget {
  const AiAssistantCard({super.key});

  @override
  State<AiAssistantCard> createState() => _AiAssistantCardState();
}

class _AiAssistantCardState extends State<AiAssistantCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow;
  late final Animation<double> _glowAnim;
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _focused = false;
  bool _sending = false;

  // Chat history: {role: 'user'|'assistant'|'error', text: '...'}
  final List<Map<String, String>> _messages = [];

  static const _chips = [
    'Plan my day',
    "What's important today?",
    'Help me focus',
    'Remember something',
  ];

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glow, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glow.dispose();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    // Auth gate
    if (!AuthSession.instance.isAuthenticated) {
      final loggedIn = await showAuthModal(context);
      if (!loggedIn || !mounted) return;
    }

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _inputCtrl.clear();
      _sending = true;
    });
    _scrollToBottom();

    final result = await AuthService.chat(message: text);
    if (!mounted) return;

    if (result.success) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': result.token ?? '…'});
        _sending = false;
      });
    } else if (result.error == 'session_expired') {
      setState(() => _sending = false);
      if (mounted) {
        await showAuthModal(context);
      }
    } else {
      setState(() {
        _messages.add({
          'role': 'error',
          'text': result.error ?? 'Something went wrong.',
        });
        _sending = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state so UI updates when user logs in/out
    context.watch<AuthSession>();
    final isAuth = AuthSession.instance.isAuthenticated;
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        color: context.cardColor,
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Stack(
          children: [
            // Ambient glow top-right
            Positioned(
              top: -40,
              right: -40,
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (context, child) => Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.accent
                          .withValues(alpha: 0.10 * _glowAnim.value),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),
            // Ambient glow bottom-left
            Positioned(
              bottom: -30,
              left: 60,
              child: AnimatedBuilder(
                animation: _glowAnim,
                builder: (context, child) => Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppColors.cyan
                          .withValues(alpha: 0.07 * _glowAnim.value),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, AppColors.blue],
                          ),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'AI Assistant',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      if (isAuth)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: AppColors.cyan.withValues(alpha: 0.12),
                            border: Border.all(
                                color: AppColors.cyan.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'Connected',
                            style: TextStyle(
                                fontSize: 10,
                                color: AppColors.cyan,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'How can I help you today?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAuth
                        ? 'Ask LifeXA about your tasks, plans, memories, or anything on your mind.'
                        : 'Sign in to start chatting with your personal AI assistant.',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  // Chat history
                  if (_messages.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 260),
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(scrollbars: false),
                        child: ListView.separated(
                          controller: _scrollCtrl,
                          shrinkWrap: true,
                          itemCount:
                              _messages.length + (_sending ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, i) {
                            if (_sending && i == _messages.length) {
                              return _TypingIndicator();
                            }
                            final msg = _messages[i];
                            return _ChatBubble(
                              text: msg['text']!,
                              role: msg['role']!,
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // Input row
                  Focus(
                    onFocusChange: (v) => setState(() => _focused = v),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        color: context.bgColor,
                        border: Border.all(
                          color: _focused
                              ? AppColors.accent
                              : context.borderColor,
                          width: _focused ? 1.5 : 1.0,
                        ),
                        boxShadow: _focused
                            ? [
                                BoxShadow(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.12),
                                  blurRadius: 16,
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputCtrl,
                              enabled: !_sending,
                              onSubmitted: (_) => _send(),
                              style: TextStyle(
                                  fontSize: 14, color: context.textPrimary),
                              decoration: InputDecoration(
                                hintText: isAuth
                                    ? 'Ask LifeXA anything...'
                                    : 'Sign in to chat with LifeXA...',
                                hintStyle: TextStyle(
                                    color: context.mutedColor, fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md, vertical: 14),
                              ),
                            ),
                          ),
                          // Mic — future
                          Tooltip(
                            message: 'Voice input — coming soon',
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(Icons.mic_none_rounded,
                                  size: 20, color: context.mutedColor),
                            ),
                          ),
                          // Send
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _SendButton(
                              sending: _sending,
                              onPressed: _send,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Suggestion chips
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: _chips
                        .map((c) => _SuggestionChip(
                              label: c,
                              onTap: () {
                                _inputCtrl.text = c;
                                _send();
                              },
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chat bubble ───────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final String text;
  final String role;
  const _ChatBubble({required this.text, required this.role});

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    final isError = role == 'error';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: isError
              ? AppColors.error.withValues(alpha: 0.12)
              : isUser
                  ? AppColors.accent.withValues(alpha: 0.18)
                  : context.bgColor,
          border: Border.all(
            color: isError
                ? AppColors.error.withValues(alpha: 0.3)
                : isUser
                    ? AppColors.accent.withValues(alpha: 0.3)
                    : context.borderColor,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isError
                ? AppColors.error
                : isUser
                    ? AppColors.lavender
                    : context.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────
class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: context.bgColor,
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: AppColors.lavender.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'LifeXA is thinking…',
              style: TextStyle(
                  fontSize: 12,
                  color: context.mutedColor,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Send button ───────────────────────────────────────────────────────────────
class _SendButton extends StatefulWidget {
  final bool sending;
  final VoidCallback onPressed;
  const _SendButton({required this.sending, required this.onPressed});

  @override
  State<_SendButton> createState() => _SendButtonState();
}

class _SendButtonState extends State<_SendButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.sending ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            gradient: _hovered && !widget.sending
                ? const LinearGradient(
                    colors: [AppColors.accent, AppColors.blue])
                : null,
            color: _hovered && !widget.sending
                ? null
                : AppColors.accent.withValues(alpha: 0.15),
          ),
          child: widget.sending
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppColors.lavender.withValues(alpha: 0.7),
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  size: 16,
                  color: _hovered ? Colors.white : AppColors.lavender,
                ),
        ),
      ),
    );
  }
}

// ── Suggestion chip ───────────────────────────────────────────────────────────
class _SuggestionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
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
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _hovered
                ? AppColors.accent.withValues(alpha: 0.15)
                : context.bgColor,
            border: Border.all(
              color: _hovered
                  ? AppColors.accent.withValues(alpha: 0.5)
                  : context.borderColor,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              color: _hovered ? AppColors.lavender : context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
