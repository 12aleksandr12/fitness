import 'package:fitness_app/core/app_languages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final localeControllerProvider = AsyncNotifierProvider<LocaleController, Locale>(LocaleController.new);

class LocaleController extends AsyncNotifier<Locale> {
  static const _key = 'app_locale';
  static const _storage = FlutterSecureStorage();

  @override
  Future<Locale> build() async {
    final stored = await _storage.read(key: _key);
    return localeFromCode(stored);
  }

  Future<void> setCode(String code) async {
    final locale = localeFromCode(code);
    await _storage.write(key: _key, value: locale.languageCode);
    state = AsyncData(locale);
  }
}
