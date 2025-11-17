// lib/services/localizer.dart

import '../models/app_lang.dart';

class L10n {
  static final Map<String, Map<AppLang, String>> _values = {
    // 홈 화면
    'home.title': {
      AppLang.ko: 'Golf Diary',
      AppLang.en: 'Golf Diary',
      AppLang.ja: 'Golf Diary',
      AppLang.zh: 'Golf Diary',
    },
    'home.record': {
      AppLang.ko: '기록하기',
      AppLang.en: 'Record',
      AppLang.ja: 'スコア入力',
      AppLang.zh: '记录',
    },
    'home.recent': {
      AppLang.ko: '최근 라운드',
      AppLang.en: 'Recent Rounds',
      AppLang.ja: '最近ラウンド',
      AppLang.zh: '最近轮次',
    },

    // 언어 설정
    'lang.title': {
      AppLang.ko: '언어',
      AppLang.en: 'Language',
      AppLang.ja: '言語',
      AppLang.zh: '语言',
    },

    // 기록 플로우
    'record.title': {
      AppLang.ko: '스코어 입력',
      AppLang.en: 'Score Entry',
      AppLang.ja: 'スコア入力',
      AppLang.zh: '记分',
    },
    'record.search': {
      AppLang.ko: '검색',
      AppLang.en: 'Search',
      AppLang.ja: '検索',
      AppLang.zh: '搜索',
    },
    'record.manual': {
      AppLang.ko: '직접입력',
      AppLang.en: 'Manual Input',
      AppLang.ja: '直接入力',
      AppLang.zh: '手动输入',
    },
    'record.hint': {
      AppLang.ko: '모든 홀 Par4로 시작하며, 기록하기 화면에서 변경할 수 있어요.',
      AppLang.en: 'All holes start as Par 4; you can change them on the score screen.',
      AppLang.ja: '全ホールはパー4から始まり、スコア画面で変更できます。',
      AppLang.zh: '所有球洞初始为4杆，可在记分画面中修改。',
    },
    'record.start': {
      AppLang.ko: '기록 시작하기',
      AppLang.en: 'Start Recording',
      AppLang.ja: '記録開始',
      AppLang.zh: '开始记录',
    },

    // 스코어 입력 화면
    'score.title': {
      AppLang.ko: '스코어 입력',
      AppLang.en: 'Score Entry',
      AppLang.ja: 'スコア入力',
      AppLang.zh: '记分',
    },
    'score.save': {
      AppLang.ko: '저장하기',
      AppLang.en: 'Save',
      AppLang.ja: '保存',
      AppLang.zh: '保存',
    },

    // 최근 라운드
    'recent.title': {
      AppLang.ko: '최근 라운드',
      AppLang.en: 'Recent Rounds',
      AppLang.ja: '最近ラウンド',
      AppLang.zh: '最近轮次',
    },
  };

  static String t(String key, AppLang lang) {
    final map = _values[key];
    if (map == null) return key;
    return map[lang] ??
        map[AppLang.en] ??
        map.values.first;
  }
}
