import 'dart:convert';
import 'dart:io';

import 'package:daily_you/app_locale.dart';
import 'package:daily_you/config_provider.dart';
import 'package:daily_you/custom_locale_delegates.dart';
import 'package:daily_you/l10n/generated/app_localizations.dart';
import 'package:daily_you/pages/settings/language_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../support/config_provider_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  useTemporaryConfig();

  test('Vietnamese covers every source message and preserves arguments', () {
    final source = jsonDecode(File('lib/l10n/intl_en.arb').readAsStringSync())
        as Map<String, dynamic>;
    final translated =
        jsonDecode(File('lib/l10n/intl_vi.arb').readAsStringSync())
            as Map<String, dynamic>;
    final arguments = RegExp(r'\{(\w+)(?:\}|,)');
    for (final key in source.keys.where((key) => !key.startsWith('@'))) {
      expect(translated[key], isA<String>(), reason: key);
      expect((translated[key] as String).trim(), isNotEmpty, reason: key);
      Set<String> parameters(String value) =>
          arguments.allMatches(value).map((match) => match.group(1)!).toSet();
      expect(parameters(translated[key]), parameters(source[key]), reason: key);
      expect(translated[key], isNot(contains('\uFFFD')), reason: key);
    }
  });

  test('fresh installs default to Vietnamese; unsupported locales fall back',
      () {
    expect(ConfigProvider.instance.getOverrideLanguage(), const Locale('vi'));
    expect(resolveAppLocale(null), const Locale('vi'));
    expect(resolveAppLocale(const Locale('zz')), const Locale('vi'));
    expect(resolveAppLocale(const Locale('en')), const Locale('en'));
    expect(
        resolveAppLocale(
            const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')),
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
  });

  test('Vietnamese counts and progress interpolate without English fallback',
      () {
    final l10n = lookupAppLocalizations(const Locale('vi'));
    for (final count in [0, 1, 2, 100]) {
      expect(l10n.logCount(count), '$count bài nhật ký');
      expect(l10n.flashbackWeek(count), '$count tuần trước');
    }
    expect(l10n.creatingBackupStatus(50), 'Đang tạo bản sao lưu… 50%');
    expect(l10n.deleteTagMessage(2, 'Sức khỏe'), contains('2 bài nhật ký'));
    expect(l10n.welcomeLogBodyText, contains('Chào mừng'));
    expect(l10n.templateDefaultSummaryBody, contains('### Tổng kết\n'));
  });

  test('saved language choices survive reloading settings', () async {
    final config = ConfigProvider.instance;
    await config.set(Settings.overrideLanguage, {'languageCode': 'en'});
    await config.flushConfig();
    await config.readConfig();
    expect(config.getOverrideLanguage(), const Locale('en'));
    await config.set(Settings.overrideLanguage, null);
    await config.flushConfig();
    await config.readConfig();
    expect(config.getOverrideLanguage(), isNull);
  });

  Widget localized(Widget child) => ChangeNotifierProvider.value(
        value: ConfigProvider.instance,
        child: MaterialApp(
          locale: const Locale('vi'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...appLocalizationsDelegates,
          ],
          home: child,
        ),
      );

  for (final width in [360.0, 1280.0]) {
    testWidgets('Vietnamese language settings fit a $width pixel viewport',
        (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(localized(const LanguageSettings()));
      await tester.pumpAndSettle();
      expect(find.text('Ngôn ngữ'), findsOneWidget);
      expect(find.text('Tiếng Việt'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
}
