// lib/models/app_settings.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_lang.dart';

/// 앱 전체에서 사용하는 설정 (현재는 언어만)
class AppSettings extends ChangeNotifier {
  static const _keyLang = 'app_lang';

  AppLang _lang = AppLang.ko;
  bool _loaded = false;

  AppSettings() {
    _load();
  }

  AppLang get lang => _lang;
  Locale get locale => _lang.locale;
  bool get isLoaded => _loaded;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyLang);
    _lang = appLangFromCode(code);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLang lang) async {
    if (_lang == lang) return;

    _lang = lang;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLang, _lang.code);
  }
}
