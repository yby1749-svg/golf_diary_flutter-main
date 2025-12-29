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
    'course.manualInputDesc': {
      'ko': '골프장 이름과 코스를 직접 입력하세요',
      'en': 'Enter club name and course manually',
      'ja': 'ゴルフ場名とコースを直接入力',
      'zh': '手动输入球场名称和球道',
    },
    'course.savedCourses': {
      'ko': '저장된 코스',
      'en': 'Saved Courses',
      'ja': '保存済みコース',
      'zh': '已保存球场',
    },
    'course.deleteTitle': {
      'ko': '코스 삭제',
      'en': 'Delete Course',
      'ja': 'コース削除',
      'zh': '删除球场',
    },
    'course.deleteMessage': {
      'ko': '이 코스를 삭제하시겠습니까?',
      'en': 'Delete this course?',
      'ja': 'このコースを削除しますか？',
      'zh': '确定删除此球场吗？',
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
    'recent.scoreTrend': {
      'ko': '점수 추세',
      'en': 'Score Trend',
      'ja': 'スコアトレンド',
      'zh': '成绩趋势',
    },
    'recent.average': {
      'ko': '평균',
      'en': 'Average',
      'ja': '平均',
      'zh': '平均',
    },
    'recent.best': {
      'ko': '최고',
      'en': 'Best',
      'ja': 'ベスト',
      'zh': '最好',
    },
    'recent.trend': {
      'ko': '변화',
      'en': 'Trend',
      'ja': 'トレンド',
      'zh': '趋势',
    },
    'recent.clearConfirmTitle': {
      'ko': '전체 삭제',
      'en': 'Delete All',
      'ja': '全て削除',
      'zh': '删除全部',
    },
    'recent.clearConfirmMessage': {
      'ko': '모든 라운드를 삭제하시겠습니까?',
      'en': 'Delete all rounds?',
      'ja': '全てのラウンドを削除しますか？',
      'zh': '是否删除所有轮次？',
    },
    'recent.clearButton': {
      'ko': '삭제',
      'en': 'Delete',
      'ja': '削除',
      'zh': '删除',
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

    // ---------- 게임 ----------
    'home.game': {
      'ko': '게임',
      'en': 'Game',
      'ja': 'ゲーム',
      'zh': '游戏',
    },
    'game.title': {
      'ko': '게임',
      'en': 'Game',
      'ja': 'ゲーム',
      'zh': '游戏',
    },
    'game.ownerPick': {
      'ko': '오너 뽑기',
      'en': 'Pick Owner',
      'ja': 'オナー決め',
      'zh': '选发球权',
    },
    'game.ownerPickDesc': {
      'ko': '누가 먼저 티샷을 할지 뽑아보세요',
      'en': 'Pick who tees off first',
      'ja': '誰が最初にティーショットするか決めよう',
      'zh': '选择谁先开球',
    },
    'game.teamPick': {
      'ko': '젓가락 뽑기',
      'en': 'Chopstick Draw',
      'ja': '割り箸くじ',
      'zh': '筷子抽签',
    },
    'game.teamPickDesc': {
      'ko': '젓가락을 뽑아 팀을 정해보세요',
      'en': 'Draw chopsticks to decide teams',
      'ja': '割り箸を引いてチームを決めよう',
      'zh': '抽筷子决定队伍',
    },
    'game.enterPlayerName': {
      'ko': '플레이어 이름 입력',
      'en': 'Enter player name',
      'ja': 'プレイヤー名を入力',
      'zh': '输入球员姓名',
    },
    'game.addPlayersHint': {
      'ko': '플레이어를 추가해주세요 (최소 2명)',
      'en': 'Add players (min. 2)',
      'ja': 'プレイヤーを追加してください（2人以上）',
      'zh': '请添加球员（至少2人）',
    },
    'game.pickOwner': {
      'ko': '오너 뽑기',
      'en': 'Pick Owner',
      'ja': 'オナーを決める',
      'zh': '选发球权',
    },
    'game.ownerResult': {
      'ko': '오너는',
      'en': 'Owner is',
      'ja': 'オナーは',
      'zh': '发球权归',
    },
    'game.pickTeams': {
      'ko': '팀 뽑기',
      'en': 'Pick Teams',
      'ja': 'チームを決める',
      'zh': '分组',
    },
    'game.reshuffleTeams': {
      'ko': '다시 뽑기',
      'en': 'Reshuffle',
      'ja': 'やり直し',
      'zh': '重新分组',
    },
    'game.teamA': {
      'ko': 'A팀',
      'en': 'Team A',
      'ja': 'Aチーム',
      'zh': 'A组',
    },
    'game.teamB': {
      'ko': 'B팀',
      'en': 'Team B',
      'ja': 'Bチーム',
      'zh': 'B组',
    },

    // ---------- 오너 뽑기 나침반 ----------
    'game.compassTitle': {
      'ko': '🏌️ 오너 뽑기 나침반 ⛳',
      'en': '🏌️ Owner Compass ⛳',
      'ja': '🏌️ オナー決めコンパス ⛳',
      'zh': '🏌️ 发球权指南针 ⛳',
    },
    'game.compassSpinning': {
      'ko': '나침반이 돌아가는 중...',
      'en': 'Compass is spinning...',
      'ja': 'コンパスが回転中...',
      'zh': '指南针旋转中...',
    },
    'game.compassDecided': {
      'ko': '오너가 결정되었습니다!',
      'en': 'Owner has been decided!',
      'ja': 'オナーが決まりました！',
      'zh': '发球权已决定！',
    },
    'game.compassSpin': {
      'ko': '나침반을 돌려보세요!',
      'en': 'Spin the compass!',
      'ja': 'コンパスを回そう！',
      'zh': '转动指南针！',
    },
    'game.ownerDecided': {
      'ko': '오너 결정!',
      'en': 'Owner Decided!',
      'ja': 'オナー決定！',
      'zh': '发球权决定！',
    },
    'game.honorTeeShot': {
      'ko': '명예의 티샷을 하세요!',
      'en': 'Take the honor tee shot!',
      'ja': '名誉のティーショットを！',
      'zh': '请开球！',
    },
    'game.playerTurn': {
      'ko': 'Player {num} 차례',
      'en': 'Player {num}\'s turn',
      'ja': 'プレイヤー{num}の番',
      'zh': '玩家{num}的回合',
    },

    // ---------- 젓가락 뽑기 ----------
    'game.chopstickTitle': {
      'ko': '🥢 젓가락 뽑기',
      'en': '🥢 Chopstick Draw',
      'ja': '🥢 割り箸くじ',
      'zh': '🥢 筷子抽签',
    },
    'game.gameComplete': {
      'ko': '게임 완료!',
      'en': 'Game Complete!',
      'ja': 'ゲーム完了！',
      'zh': '游戏完成！',
    },

    // ---------- 튜토리얼 ----------
    'tutorial.step1Title': {
      'ko': '직접 입력',
      'en': 'Manual Input',
      'ja': '手動入力',
      'zh': '手动输入',
    },
    'tutorial.step1Desc': {
      'ko': '직접 입력 버튼을 눌러주세요',
      'en': 'Tap the Manual Input button',
      'ja': '手動入力ボタンをタップ',
      'zh': '点击手动输入按钮',
    },
    'tutorial.step2Title': {
      'ko': '골프장 / 코스 입력',
      'en': 'Enter Club / Course',
      'ja': 'ゴルフ場 / コース入力',
      'zh': '输入球场 / 球道',
    },
    'tutorial.step2Desc': {
      'ko': '골프장 이름과 코스를 입력하고\nOK 버튼을 눌러주세요',
      'en': 'Enter club name and course,\nthen tap OK',
      'ja': 'ゴルフ場名とコースを入力し\nOKをタップ',
      'zh': '输入球场名称和球道\n然后点击确定',
    },
    'tutorial.step3Title': {
      'ko': '파 선택',
      'en': 'Select Par',
      'ja': 'パー選択',
      'zh': '选择标准杆',
    },
    'tutorial.step3Desc': {
      'ko': '각 홀의 파(Par)를 설정하세요\n파란색 버튼을 눌러 변경할 수 있어요',
      'en': 'Set the Par for each hole\nTap the blue button to change',
      'ja': '各ホールのパーを設定\n青いボタンで変更できます',
      'zh': '设置每洞的标准杆\n点击蓝色按钮可更改',
    },
    'tutorial.step4Title': {
      'ko': '스코어 입력',
      'en': 'Enter Score',
      'ja': 'スコア入力',
      'zh': '输入成绩',
    },
    'tutorial.step4Desc': {
      'ko': '- / + 버튼으로\n타수를 입력하세요',
      'en': 'Use - / + buttons\nto enter strokes',
      'ja': '- / + ボタンで\n打数を入力',
      'zh': '使用 - / + 按钮\n输入杆数',
    },
    'tutorial.step5Title': {
      'ko': '잠금',
      'en': 'Lock',
      'ja': 'ロック',
      'zh': '锁定',
    },
    'tutorial.step5Desc': {
      'ko': '잠금 버튼을 눌러\n스코어를 확정하세요',
      'en': 'Tap the lock button\nto confirm score',
      'ja': 'ロックボタンで\nスコアを確定',
      'zh': '点击锁定按钮\n确认成绩',
    },
    'tutorial.skip': {
      'ko': '건너뛰기',
      'en': 'Skip',
      'ja': 'スキップ',
      'zh': '跳过',
    },
    'tutorial.prev': {
      'ko': '이전',
      'en': 'Prev',
      'ja': '前へ',
      'zh': '上一步',
    },
    'tutorial.next': {
      'ko': '다음',
      'en': 'Next',
      'ja': '次へ',
      'zh': '下一步',
    },
    'tutorial.done': {
      'ko': '완료',
      'en': 'Done',
      'ja': '完了',
      'zh': '完成',
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
