import '../models/app_lang.dart';

class L10n {
  /// 현재 선택된 언어 (기본: 한국어)
  /// LanguageSettingsScreen 등에서 L10n.currentLang = AppLang.en; 이런 식으로 바꿔주면 됨.
  static AppLang currentLang = AppLang.ko;

  // key → langCode → text
  static const Map<String, Map<String, String>> _values = {
    // ---------- 공통 ----------
    'common.cancel': {
      'ko': '취소',
      'en': 'Cancel',
      'ja': 'キャンセル',
      'zh': '取消',
    },
    'common.ok': {
      'ko': '확인',
      'en': 'OK',
      'ja': 'OK',
      'zh': '确定',
    },
    'lang.title': {
      'ko': '언어 설정',
      'en': 'Language',
      'ja': '言語設定',
      'zh': '语言设置',
    },


    // ====== Round Detail ======
    'detail.exportPdf': {
      'ko': 'PDF로 내보내기',
      'en': 'Export PDF',
      'ja': 'PDFを書き出す',
      'zh': '导出 PDF',
    },

    // ---------- 홈 ----------
    'home.title': {
      'ko': '골프 다이어리',
      'en': 'Golf Diary',
      'ja': 'ゴルフダイアリー',
      'zh': '高尔夫日记',
    },
    'home.record': {
      'ko': '기록하기',
      'en': 'Record',
      'ja': 'スコア入力',
      'zh': '记分输入',
    },
    'home.recent': {
      'ko': '최근 라운드',
      'en': 'Recent Rounds',
      'ja': '最近ラウンド',
      'zh': '最近轮次',
    },

    // ---------- 코스 검색 / 직접 입력 ----------
    'course.searchTitle': {
      'ko': '코스 선택',
      'en': 'Select Course',
      'ja': 'コース選択',
      'zh': '选择球场',
    },
    'course.searchHint': {
      'ko': '골프장 / 코스 이름 검색',
      'en': 'Search club / course',
      'ja': 'ゴルフ場 / コース名で検索',
      'zh': '搜索球场 / 球道名称',
    },
    'course.manualInput': {
      'ko': '직접 입력',
      'en': 'Manual Input',
      'ja': '手動入力',
      'zh': '手动输入',
    },

    'manual.title': {
      'ko': '직접 입력',
      'en': 'Manual Input',
      'ja': '手動入力',
      'zh': '手动输入',
    },
    'manual.clubLabel': {
      'ko': '골프장 이름',
      'en': 'Club name',
      'ja': 'ゴルフ場名',
      'zh': '球场名称',
    },
    'manual.courseLabel': {
      'ko': '코스 이름',
      'en': 'Course name',
      'ja': 'コース名',
      'zh': '球道名称',
    },

    // ---------- 스코어 입력 ----------
    'score.title': {
      'ko': '스코어 기록하기',
      'en': 'Score Entry',
      'ja': 'スコア入力',
      'zh': '记分输入',
    },
    'score.progressPrefix': {
      'ko': '진행',
      'en': 'Progress',
      'ja': '進行',
      'zh': '进度',
    },
    'score.holeSuffix': {
      'ko': '홀',
      'en': 'holes',
      'ja': 'ホール',
      'zh': '洞',
    },
    'score.save': {
      'ko': '저장하기',
      'en': 'Save',
      'ja': '保存',
      'zh': '保存',
    },
    'score.noCourseSelected': {
      'ko': '먼저 골프장을 선택하세요',
      'en': 'Please select a course first',
      'ja': '先にコースを選択してください',
      'zh': '请先选择球场',
    },

    // 잠금 관련
    'score.unlockTitle': {
      'ko': '잠금 해제',
      'en': 'Unlock score',
      'ja': 'スコアのロック解除',
      'zh': '解锁成绩',
    },
    // {hole} 자리 치환용
    'score.unlockMessage': {
      'ko': '{hole} 홀의 스코어 잠금을 해제할까요?',
      'en': 'Unlock score of {hole}?',
      'ja': '{hole} ホールのスコアロックを解除しますか？',
      'zh': '要解锁 {hole} 洞的成绩吗？',
    },
    'score.unlock': {
      'ko': '잠금 해제',
      'en': 'Unlock',
      'ja': 'ロック解除',
      'zh': '解锁',
    },

    // ---------- 최근 라운드 리스트 ----------
    'recent.title': {
      'ko': '최근 라운드',
      'en': 'Recent Rounds',
      'ja': '最近ラウンド',
      'zh': '最近轮次',
    },
    'recent.empty': {
      'ko': '아직 저장된 라운드가 없습니다.',
      'en': 'No rounds saved yet.',
      'ja': '保存されたラウンドがありません。',
      'zh': '还没有保存的轮次。',
    },
    'recent.scoreLabel': {
      'ko': '총 타수',
      'en': 'Score',
      'ja': 'スコア',
      'zh': '总杆',
    },

    // ---------- 라운드 상세 ----------
    'recent.detailTitle': {
      'ko': '라운드 상세',
      'en': 'Round Detail',
      'ja': 'ラウンド詳細',
      'zh': '轮次详情',
    },
    'detail.frontLabel': {
      'ko': '전반',
      'en': 'Front 9',
      'ja': '前半',
      'zh': '前九',
    },
    'detail.backLabel': {
      'ko': '후반',
      'en': 'Back 9',
      'ja': '後半',
      'zh': '后九',
    },
    'detail.holeHeader': {
      'ko': 'Hole',
      'en': 'Hole',
      'ja': 'ホール',
      'zh': '洞',
    },
    'detail.strokeHeader': {
      'ko': '타수',
      'en': 'Strokes',
      'ja': '打数',
      'zh': '杆数',
    },
    'detail.toParHeader': {
      'ko': 'To Par',
      'en': 'To Par',
      'ja': '対パー',
      'zh': '相对标准杆',
    },
    'detail.totalParLabel': {
      'ko': '총 Par',
      'en': 'Total Par',
      'ja': '合計パー',
      'zh': '总标准杆',
    },
    'detail.totalScoreLabel': {
      'ko': '총 타수',
      'en': 'Total Score',
      'ja': '合計打数',
      'zh': '总杆数',
    },
    'detail.totalToParLabel': {
      'ko': '합계 To Par',
      'en': 'To Par (Total)',
      'ja': 'トータル対パー',
      'zh': '总相对标准杆',
    },
    'detail.photoSectionTitle': {
      'ko': '라운드 사진',
      'en': 'Round Photos',
      'ja': 'ラウンド写真',
      'zh': '轮次照片',
    },
    'detail.noPhotos': {
      'ko': '저장된 사진이 없습니다.',
      'en': 'No photos.',
      'ja': '写真はありません。',
      'zh': '没有照片。',
    },

    // ---------- 사진 선택 바텀 시트 ----------
    'photo.sheetTitle': {
      'ko': '사진 추가 방법 선택',
      'en': 'Add photos',
      'ja': '写真の追加方法を選択',
      'zh': '选择添加照片方式',
    },
    'photo.take': {
      'ko': '사진 찍기',
      'en': 'Take photo',
      'ja': '写真を撮る',
      'zh': '拍照',
    },
    'photo.fromGalleryTitle': {
      'ko': '앨범에서 선택',
      'en': 'Choose from gallery',
      'ja': 'アルバムから選択',
      'zh': '从相册选择',
    },
    'photo.later': {
      'ko': '나중에',
      'en': 'Later',
      'ja': 'あとで',
      'zh': '以后再说',
    },
  };

  /// 명시적으로 언어를 넘길 때 사용하는 함수
  static String t(String key, AppLang lang, {Map<String, String>? params}) {
    String text = _values[key]?[lang.code] ?? key;
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }

  /// 현재 선택된 언어 [currentLang]을 사용해서 번역
  static String tr(String key, {Map<String, String>? params}) {
    return t(key, currentLang, params: params);
  }
}
