import 'dart:ui' show PlatformDispatcher;

import 'package:daily_you/config_provider.dart';
import 'package:daily_you/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

Locale effectiveAppLocale() => resolveAppLocale(
      ConfigProvider.instance.getOverrideLanguage() ??
          PlatformDispatcher.instance.locale,
    );

/// Vietnamese is the fallback for this distribution. An explicit language
/// selection (including following the system) remains available in settings.
Locale resolveAppLocale(Locale? locale) {
  if (locale != null) {
    final supported = AppLocalizations.supportedLocales;
    for (final candidate in supported) {
      if (candidate.languageCode == locale.languageCode &&
          candidate.scriptCode == locale.scriptCode &&
          candidate.countryCode == locale.countryCode) {
        return candidate;
      }
    }
    for (final candidate in supported) {
      if (candidate.languageCode == locale.languageCode) return candidate;
    }
  }
  return const Locale('vi');
}
