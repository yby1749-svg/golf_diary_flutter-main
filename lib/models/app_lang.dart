// lib/models/app_lang.dart

import 'package:flutter/material.dart';

/// 지원 언어 코드
enum AppLang { ko, en, ja, zh }

extension AppLangX on AppLang {
  String get code {
    switch (this) {
      case AppLang.ko:
        return 'ko';
      case AppLang.en:
        return 'en';
      case AppLang.ja:
        return 'ja';
      case AppLang.zh:
        return 'zh';
    }
  }

  String get displayName {
    switch (this) {
      case AppLang.ko:
        return '한국어';
      case AppLang.en:
        return 'English';
      case AppLang.ja:
        return '日本語';
      case AppLang.zh:
        return '中文';
    }
  }

  Locale get locale => Locale(code);
}

AppLang appLangFromCode(String? code) {
  switch (code) {
    case 'en':
      return AppLang.en;
    case 'ja':
      return AppLang.ja;
    case 'zh':
      return AppLang.zh;
    case 'ko':
    default:
      return AppLang.ko;
  }
}
