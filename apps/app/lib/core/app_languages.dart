import 'package:flutter/material.dart';

class AppLanguage {
  const AppLanguage(this.code, this.nativeName);

  final String code;
  final String nativeName;

  Locale get locale => Locale(code);
}

/// Hard cap: at most six UI languages.
const List<AppLanguage> appLanguages = [
  AppLanguage('ru', 'Русский'),
  AppLanguage('en', 'English'),
  AppLanguage('uk', 'Українська'),
  AppLanguage('de', 'Deutsch'),
  AppLanguage('fr', 'Français'),
  AppLanguage('es', 'Español'),
];

Locale localeFromCode(String? code) {
  for (final lang in appLanguages) {
    if (lang.code == code) {
      return lang.locale;
    }
  }
  return const Locale('ru');
}

String nativeNameFor(Locale locale) {
  for (final lang in appLanguages) {
    if (lang.code == locale.languageCode) {
      return lang.nativeName;
    }
  }
  return appLanguages.first.nativeName;
}
