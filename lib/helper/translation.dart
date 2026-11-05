import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  Map<String, dynamic> _localizedStrings = {};

  AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('mn'),
    Locale('en'),
  ];

  @visibleForTesting
  set sentences(Map<String, dynamic> map) {
    _localizedStrings = map;
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString =
        await rootBundle.loadString('assets/locales/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    _localizedStrings = jsonMap;
    return true;
  }

  String? translate(String key, [Map<String, String>? params, String? fallback]) {
    final parts = key.split('.');
    dynamic current = _localizedStrings;

    for (final part in parts) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return fallback;
      }
    }

    if (current == null) return fallback;
    String result = current.toString();
    if (params != null) {
      params.forEach((paramKey, value) {
        result = result.replaceAll('{$paramKey}', value);
      });
    }
    return result;
  }

  String? t(String key, [Map<String, String>? params, String? fallback]) =>
      translate(key, params, fallback);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'mn'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}