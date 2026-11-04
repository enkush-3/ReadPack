import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/helper/translation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLocalizations and Translation Helper', () {
    test('AppLocalizations translates direct and nested keys', () {
      final sampleJson = {
        'app': {
          'title': 'ReadPack',
          'loading': 'Ачааллаж байна...',
        },
        'home': {
          'streakBadge': '🔥 {streak} хоног',
        },
        'simpleKey': 'Энгийн утга',
      };

      final l10n = AppLocalizations(const Locale('mn'));
      l10n.sentences = sampleJson;

      expect(l10n.t('simpleKey'), 'Энгийн утга');
      expect(l10n.t('app.title'), 'ReadPack');
      expect(l10n.t('app.loading'), 'Ачааллаж байна...');
      expect(l10n.t('home.streakBadge', {'streak': '5'}), '🔥 5 хоног');
      expect(l10n.t('non.existent.key', null, 'Өгөгдмөл'), 'Өгөгдмөл');
    });

    test('Supported locales contain mn and en', () {
      expect(AppLocalizations.supportedLocales, contains(const Locale('mn')));
      expect(AppLocalizations.supportedLocales, contains(const Locale('en')));
    });

    test('Locale asset files contain valid parseable JSON', () async {
      final mnString = await rootBundle.loadString('assets/locales/mn.json');
      final enString = await rootBundle.loadString('assets/locales/en.json');

      final mnMap = json.decode(mnString) as Map<String, dynamic>;
      final enMap = json.decode(enString) as Map<String, dynamic>;

      expect(mnMap.containsKey('app'), isTrue);
      expect(enMap.containsKey('app'), isTrue);
      expect(mnMap.containsKey('home'), isTrue);
      expect(enMap.containsKey('home'), isTrue);
      expect(mnMap.containsKey('book'), isTrue);
      expect(enMap.containsKey('book'), isTrue);
      expect(mnMap.containsKey('profile'), isTrue);
      expect(enMap.containsKey('profile'), isTrue);
    });
  });
}
