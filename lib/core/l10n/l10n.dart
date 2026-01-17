import 'package:flutter/widgets.dart';
import '../../l10n/generated/app_localizations.dart';

export '../../l10n/generated/app_localizations.dart';

/// Extension for easy access to AppLocalizations from BuildContext
extension AppLocalizationsX on BuildContext {
  /// Get the current AppLocalizations instance
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Shorthand for localized strings
  AppLocalizations get tr => AppLocalizations.of(this);
}
