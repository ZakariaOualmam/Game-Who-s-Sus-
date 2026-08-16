import 'dart:async';

import 'package:flutter/material.dart';

import '../core/game_time_format.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../l10n/app_localizations.dart';

/// A single-running, self-cancelling countdown pill.
///
/// Ticks every second and fires [onFinished] exactly once when the countdown
/// reaches zero. The timer is cancelled in [State.dispose], so screens can
/// navigate away (or rebuild) without leaving orphaned timers behind or firing
/// callbacks on an unmounted widget.
class GameCountdown extends StatefulWidget {
  const GameCountdown({
    super.key,
    required this.duration,
    required this.onFinished,
    this.label,
    this.warningAt = const Duration(seconds: 10),
    this.dangerAt = const Duration(seconds: 5),
    this.compact = false,
  });

  /// Total countdown duration.
  final Duration duration;

  /// Invoked once when the countdown reaches zero.
  final VoidCallback onFinished;

  /// Optional caption shown above the pill (e.g. "Time left").
  final String? label;

  /// Remaining time at or below this turns the pill into a warning.
  final Duration warningAt;

  /// Remaining time at or below this turns the pill red.
  final Duration dangerAt;

  /// Smaller pill for tight layouts.
  final bool compact;

  @override
  State<GameCountdown> createState() => _GameCountdownState();
}

class _GameCountdownState extends State<GameCountdown> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration.inSeconds;
    if (_remainingSeconds > 0) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (_finished) return;
    if (_remainingSeconds <= 1) {
      _timer?.cancel();
      _timer = null;
      _finished = true;
      setState(() => _remainingSeconds = 0);
      widget.onFinished();
    } else {
      setState(() => _remainingSeconds -= 1);
    }
  }

  bool get _isDanger => _remainingSeconds <= widget.dangerAt.inSeconds;
  bool get _isWarning => _remainingSeconds <= widget.warningAt.inSeconds;

  Color get _accent {
    if (_isDanger) return AppColors.danger;
    if (_isWarning) return AppColors.warning;
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final remaining = Duration(seconds: _remainingSeconds);
    final accent = _accent;

    final pill = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: widget.compact
          ? const EdgeInsets.symmetric(horizontal: 14, vertical: 8)
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
        boxShadow: _isWarning
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 14,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isDanger ? Icons.timer_off_outlined : Icons.timer_outlined,
            color: accent,
            size: widget.compact ? 18 : 22,
          ),
          const SizedBox(width: 8),
          Text(
            formatGameDuration(l10n, remaining),
            style: AppTypography.bodyBold(context).copyWith(
              color: _isWarning ? accent : AppColors.textPrimary,
              fontSize: widget.compact ? 16 : 20,
            ),
          ),
        ],
      ),
    );

    if (widget.label == null) return pill;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label!.toUpperCase(),
          style: AppTypography.caption(context).copyWith(letterSpacing: 2),
        ),
        const SizedBox(height: 6),
        pill,
      ],
    );
  }
}
