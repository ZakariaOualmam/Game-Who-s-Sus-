import '../l10n/app_localizations.dart';

/// Formats a game duration (e.g. discussion/voting timer) for display.
String formatGameDuration(AppLocalizations l10n, Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  if (minutes > 0 && seconds > 0) {
    return l10n.settingsMinSec(minutes, seconds);
  }
  if (minutes > 0) {
    return l10n.settingsMinutes(minutes);
  }
  return l10n.settingsSeconds(seconds);
}
