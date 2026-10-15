import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AppNoticeTone { success, info, warning, error }

OverlayEntry? _activeNotice;

void showAppNotice(
  BuildContext context, {
  required String message,
  AppNoticeTone tone = AppNoticeTone.success,
  String? actionLabel,
  VoidCallback? onAction,
  Duration? duration,
}) {
  _activeNotice?.remove();
  _activeNotice = null;

  final overlay = Overlay.of(context, rootOverlay: true);
  late final OverlayEntry entry;

  void dismiss() {
    if (entry.mounted) entry.remove();
    if (identical(_activeNotice, entry)) _activeNotice = null;
  }

  entry = OverlayEntry(
    builder: (context) => _AppNoticeOverlay(
      message: message,
      tone: tone,
      actionLabel: actionLabel,
      onAction: onAction,
      duration:
          duration ??
          (actionLabel == null
              ? const Duration(milliseconds: 2800)
              : const Duration(seconds: 5)),
      onDismiss: dismiss,
    ),
  );
  _activeNotice = entry;
  overlay.insert(entry);
}

class _AppNoticeOverlay extends StatefulWidget {
  const _AppNoticeOverlay({
    required this.message,
    required this.tone,
    required this.duration,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final AppNoticeTone tone;
  final Duration duration;
  final VoidCallback onDismiss;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<_AppNoticeOverlay> createState() => _AppNoticeOverlayState();
}

class _AppNoticeOverlayState extends State<_AppNoticeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> opacity;
  late final Animation<Offset> slide;
  Timer? timer;
  bool closing = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 150),
    );
    final curved = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    opacity = curved;
    slide = Tween<Offset>(
      begin: const Offset(0, -0.16),
      end: Offset.zero,
    ).animate(curved);
    animationController.forward();
    timer = Timer(widget.duration, close);
  }

  Future<void> close() async {
    if (closing || !mounted) return;
    closing = true;
    timer?.cancel();
    if (MediaQuery.disableAnimationsOf(context)) {
      widget.onDismiss();
      return;
    }
    await animationController.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    timer?.cancel();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _NoticeColors.from(widget.tone);
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 16,
      right: 16,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SlideTransition(
              position: slide,
              child: FadeTransition(
                opacity: opacity,
                child: Semantics(
                  liveRegion: true,
                  container: true,
                  child: Material(
                    color: colors.background,
                    elevation: 8,
                    shadowColor: Colors.black.withValues(alpha: 0.16),
                    surfaceTintColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    clipBehavior: Clip.antiAlias,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.border),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: colors.iconBackground,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                colors.icon,
                                size: 19,
                                color: colors.foreground,
                              ),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                widget.message,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.ink,
                                      fontWeight: FontWeight.w600,
                                      height: 1.35,
                                    ),
                              ),
                            ),
                            if (widget.actionLabel case final label?) ...[
                              const SizedBox(width: 6),
                              TextButton(
                                onPressed: () {
                                  widget.onAction?.call();
                                  close();
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: colors.foreground,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: Text(label),
                              ),
                            ] else
                              IconButton(
                                onPressed: close,
                                tooltip: 'Dismiss message',
                                visualDensity: VisualDensity.compact,
                                icon: const Icon(Icons.close, size: 19),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoticeColors {
  const _NoticeColors({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color iconBackground;
  final Color foreground;
  final IconData icon;

  factory _NoticeColors.from(AppNoticeTone tone) {
    return switch (tone) {
      AppNoticeTone.success => const _NoticeColors(
        background: Color(0xFFF7FCF9),
        border: Color(0xFFCDE8D8),
        iconBackground: Color(0xFFDDF4E7),
        foreground: Color(0xFF087443),
        icon: Icons.check_rounded,
      ),
      AppNoticeTone.info => const _NoticeColors(
        background: Color(0xFFF7FAFC),
        border: Color(0xFFD7E2E8),
        iconBackground: Color(0xFFE4EDF2),
        foreground: Color(0xFF315C6C),
        icon: Icons.info_outline_rounded,
      ),
      AppNoticeTone.warning => const _NoticeColors(
        background: Color(0xFFFFFBF2),
        border: Color(0xFFF1D9A8),
        iconBackground: Color(0xFFFFEDC9),
        foreground: Color(0xFF8A5500),
        icon: Icons.warning_amber_rounded,
      ),
      AppNoticeTone.error => const _NoticeColors(
        background: Color(0xFFFFF8F7),
        border: Color(0xFFF2C8C3),
        iconBackground: Color(0xFFFBE1DE),
        foreground: AppTheme.danger,
        icon: Icons.error_outline_rounded,
      ),
    };
  }
}
