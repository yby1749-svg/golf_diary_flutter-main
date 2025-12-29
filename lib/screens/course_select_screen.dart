// lib/screens/course_select_screen.dart
//
// 골프장 선택 화면 (직접 입력 + 샘플 코스)
//

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_lang.dart';
import '../models/golf_course.dart';
import '../models/hole_result.dart';
import '../services/localizer.dart';
import 'score_entry_screen.dart';

class CourseSelectScreen extends StatefulWidget {
  const CourseSelectScreen({Key? key}) : super(key: key);

  @override
  State<CourseSelectScreen> createState() => _CourseSelectScreenState();
}

class _CourseSelectScreenState extends State<CourseSelectScreen> {
  bool _showTutorial = false;
  List<GolfCourse> _savedCourses = [];

  // 샘플 코스
  final GolfCourse _sampleCourse = GolfCourse(
    clubName: 'Sample Resort',
    courseName: 'Sample',
    pars: [4, 4, 3, 4, 5, 4, 3, 4, 5, 4, 4, 3, 4, 5, 4, 3, 4, 5], // Par 72
  );

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _loadSavedCourses();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('course_select_tutorial_seen') ?? false;
    if (!seen && mounted) {
      setState(() => _showTutorial = true);
    }
  }

  Future<void> _loadSavedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final coursesJson = prefs.getStringList('saved_courses') ?? [];
    final courses = coursesJson.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return GolfCourse(
        clubName: map['clubName'] as String,
        courseName: map['courseName'] as String,
        pars: (map['pars'] as List<dynamic>).cast<int>(),
      );
    }).toList();
    if (mounted) {
      setState(() => _savedCourses = courses);
    }
  }

  Future<void> _saveCourse(GolfCourse course) async {
    final prefs = await SharedPreferences.getInstance();

    // 중복 체크
    final exists = _savedCourses.any((c) =>
      c.clubName == course.clubName && c.courseName == course.courseName);
    if (exists) return;

    _savedCourses.add(course);
    final coursesJson = _savedCourses.map((c) => jsonEncode({
      'clubName': c.clubName,
      'courseName': c.courseName,
      'pars': c.pars,
    })).toList();
    await prefs.setStringList('saved_courses', coursesJson);
    if (mounted) setState(() {});
  }

  Future<void> _deleteCourse(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _savedCourses.removeAt(index);
    final coursesJson = _savedCourses.map((c) => jsonEncode({
      'clubName': c.clubName,
      'courseName': c.courseName,
      'pars': c.pars,
    })).toList();
    await prefs.setStringList('saved_courses', coursesJson);
    if (mounted) setState(() {});
  }

  Future<void> _dismissTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('course_select_tutorial_seen', true);
    if (mounted) {
      setState(() => _showTutorial = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFEFF8E6);
    final accent = const Color(0xFF2E7D32);
    final lang = L10n.currentLang;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
            title: Text(
              L10n.t('course.searchTitle', lang),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 직접 입력 버튼 (상단)
              _buildManualInputCard(accent, lang),

              const SizedBox(height: 24),

              // 샘플 코스
              _buildCourseCard(_sampleCourse, accent, isSample: true),

              // 저장된 코스들
              if (_savedCourses.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  L10n.t('course.savedCourses', lang),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(_savedCourses.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildSavedCourseCard(
                      _savedCourses[index],
                      accent,
                      index,
                      lang,
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        // 튜토리얼 오버레이
        if (_showTutorial)
          _CourseTutorialOverlay(onDismiss: _dismissTutorial),
      ],
    );
  }

  Widget _buildManualInputCard(Color accent, AppLang lang) {
    return InkWell(
      onTap: _openManualInput,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      L10n.t('course.manualInput', lang),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      L10n.t('course.manualInputDesc', lang),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCard(GolfCourse course, Color accent, {bool isSample = false}) {
    final initials = _buildInitials(course.clubName);

    return InkWell(
      onTap: () => _startWithCourse(course),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // 이니셜 원형
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSample ? Colors.grey.withOpacity(0.15) : accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: isSample ? Colors.grey : accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.clubName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSample ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          course.courseName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        Text(
                          'Par ${course.totalPar}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isSample ? Colors.grey : accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedCourseCard(GolfCourse course, Color accent, int index, AppLang lang) {
    final initials = _buildInitials(course.clubName);

    return InkWell(
      onTap: () => _startWithCourse(course),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // 이니셜 원형
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.clubName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          course.courseName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const Text(
                          ' • ',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        Text(
                          'Par ${course.totalPar}',
                          style: TextStyle(
                            fontSize: 13,
                            color: accent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 휴지통 아이콘
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(L10n.t('course.deleteTitle', lang)),
                      content: Text(L10n.t('course.deleteMessage', lang)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(L10n.t('common.cancel', lang)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: Text(L10n.t('recent.clearButton', lang)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    _deleteCourse(index);
                  }
                },
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startWithCourse(GolfCourse course) {
    // 18홀 결과 객체 생성
    final holes = List<HoleResult>.generate(
      18,
      (index) => HoleResult(
        holeNumber: index + 1,
        par: course.pars[index],
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScoreEntryScreen(
          clubName: course.clubName,
          courseName: course.courseName,
          holes: holes,
        ),
      ),
    );
  }

  Future<void> _openManualInput() async {
    final res = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => _ManualCourseInputScreen(),
      ),
    );

    if (res == null) return;

    final course = GolfCourse(
      clubName: res['club'] as String,
      courseName: res['course'] as String,
      pars: (res['pars'] as List<dynamic>).cast<int>(),
    );

    // 코스는 저장하지 않고, ScoreEntryScreen에서 저장 완료 후 저장
    final holes = List<HoleResult>.generate(
      18,
      (index) => HoleResult(
        holeNumber: index + 1,
        par: course.pars[index],
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScoreEntryScreen(
          clubName: course.clubName,
          courseName: course.courseName,
          holes: holes,
          saveAsNewCourse: true, // 저장 완료 후 실제 파 값으로 코스 저장
        ),
      ),
    );
  }

  String _buildInitials(String clubName) {
    final trimmed = clubName.trim();
    if (trimmed.isEmpty) return '?';

    // 한글/영문 섞여도 앞 1~2글자 정도만 보여주기
    if (trimmed.length <= 2) return trimmed;
    return trimmed.substring(0, 2);
  }
}

class _ManualCourseInputScreen extends StatefulWidget {
  _ManualCourseInputScreen({Key? key}) : super(key: key);

  @override
  State<_ManualCourseInputScreen> createState() =>
      _ManualCourseInputScreenState();
}

class _ManualCourseInputScreenState extends State<_ManualCourseInputScreen> {
  final TextEditingController _club = TextEditingController();
  final TextEditingController _course = TextEditingController();

  @override
  void dispose() {
    _club.dispose();
    _course.dispose();
    super.dispose();
  }

  void _submit() {
    final club = _club.text.trim();
    final course = _course.text.trim();

    if (club.isEmpty || course.isEmpty) {
      return;
    }

    // 18홀 모두 Par4 로 시작 (ScoreEntryScreen 에서 자유롭게 수정)
    final pars = List<int>.filled(18, 4);

    Navigator.pop<Map<String, dynamic>>(context, {
      'club': club,
      'course': course,
      'pars': pars,
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF2E7D32);
    final lang = L10n.currentLang;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('manual.title', lang)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _club,
              decoration: InputDecoration(
                labelText: L10n.t('manual.clubLabel', lang),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _course,
              decoration: InputDecoration(
                labelText: L10n.t('manual.courseLabel', lang),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Text(
                  L10n.t('common.ok', lang),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ==================== 5단계 튜토리얼 오버레이 ====================
class _CourseTutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const _CourseTutorialOverlay({required this.onDismiss});

  @override
  State<_CourseTutorialOverlay> createState() => _CourseTutorialOverlayState();
}

class _CourseTutorialOverlayState extends State<_CourseTutorialOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _fadeController;
  late AnimationController _handController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _handAnimation;
  late Animation<double> _pulseAnimation;

  // 5단계 튜토리얼 (아이콘만 정의, 텍스트는 다국어 처리)
  final List<IconData> _stepIcons = [
    Icons.touch_app,
    Icons.edit,
    Icons.golf_course,
    Icons.sports_golf,
    Icons.lock,
  ];

  String _getStepTitle(int step, AppLang lang) {
    final keys = [
      'tutorial.step1Title',
      'tutorial.step2Title',
      'tutorial.step3Title',
      'tutorial.step4Title',
      'tutorial.step5Title',
    ];
    return L10n.t(keys[step], lang);
  }

  String _getStepDesc(int step, AppLang lang) {
    final keys = [
      'tutorial.step1Desc',
      'tutorial.step2Desc',
      'tutorial.step3Desc',
      'tutorial.step4Desc',
      'tutorial.step5Desc',
    ];
    return L10n.t(keys[step], lang);
  }

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _handAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _handController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _handController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepIcons.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onDismiss();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final lang = L10n.currentLang;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // 반투명 배경
            Positioned.fill(
              child: GestureDetector(
                onTap: _nextStep,
                child: Container(
                  color: Colors.black.withOpacity(0.85),
                ),
              ),
            ),

            // 모의 화면 표시
            Center(
              child: Container(
                width: size.width * 0.85,
                height: size.height * 0.55,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF8E6),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _buildMockScreen(_currentStep, size),
                ),
              ),
            ),

            // 손가락 애니메이션
            AnimatedBuilder(
              animation: _handAnimation,
              builder: (context, child) {
                final pos = _getHandPosition(_currentStep, size);
                final progress = _handAnimation.value;
                final x = pos['startX']! + (pos['endX']! - pos['startX']!) * progress;
                final y = pos['startY']! + (pos['endY']! - pos['startY']!) * progress;

                return Positioned(
                  left: x,
                  top: y,
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: const Icon(
                      Icons.touch_app,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              },
            ),

            // 설명 카드
            Positioned(
              bottom: 100,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 단계 번호와 아이콘
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${_currentStep + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          _stepIcons[_currentStep],
                          color: const Color(0xFF2E7D32),
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 제목
                    Text(
                      _getStepTitle(_currentStep, lang),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 설명
                    Text(
                      _getStepDesc(_currentStep, lang),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 단계 인디케이터
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _stepIcons.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: index == _currentStep ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: index == _currentStep
                                ? const Color(0xFF2E7D32)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 하단 버튼들
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  // 건너뛰기
                  TextButton(
                    onPressed: widget.onDismiss,
                    child: Text(
                      L10n.t('tutorial.skip', lang),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // 이전
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _prevStep,
                      child: Text(
                        L10n.t('tutorial.prev', lang),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  // 다음/완료
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _currentStep < _stepIcons.length - 1
                          ? L10n.t('tutorial.next', lang)
                          : L10n.t('tutorial.done', lang),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _getHandPosition(int step, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.35;

    switch (step) {
      case 0: // 직접 입력 버튼
        return {
          'startX': centerX + 60,
          'startY': centerY - 80,
          'endX': centerX - 20,
          'endY': centerY - 100,
        };
      case 1: // 골프장/코스 입력 & OK 버튼
        return {
          'startX': centerX + 60,
          'startY': centerY + 100,
          'endX': centerX - 20,
          'endY': centerY + 80,
        };
      case 2: // 파 선택
        return {
          'startX': centerX - 60,
          'startY': centerY - 20,
          'endX': centerX - 100,
          'endY': centerY - 40,
        };
      case 3: // 스코어 입력
        return {
          'startX': centerX + 80,
          'startY': centerY - 20,
          'endX': centerX + 40,
          'endY': centerY - 40,
        };
      case 4: // 잠금
        return {
          'startX': centerX + 130,
          'startY': centerY - 20,
          'endX': centerX + 100,
          'endY': centerY - 40,
        };
      default:
        return {
          'startX': centerX,
          'startY': centerY,
          'endX': centerX,
          'endY': centerY,
        };
    }
  }

  Widget _buildMockScreen(int step, Size size) {
    switch (step) {
      case 0:
        return _buildMockCourseSelectScreen();
      case 1:
        return _buildMockManualInputScreen();
      case 2:
      case 3:
      case 4:
        return _buildMockScoreEntryScreen(step);
      default:
        return const SizedBox();
    }
  }

  // 모의 코스 선택 화면
  Widget _buildMockCourseSelectScreen() {
    return Column(
      children: [
        // 앱바
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const Text(
            'Select Course',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 직접 입력 버튼 (하이라이트)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.yellow, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_note, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manual Input',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Enter club and course',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 샘플 코스
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('Sa', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sample Resort', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('Sample • Par 72', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 모의 직접 입력 화면
  Widget _buildMockManualInputScreen() {
    return Column(
      children: [
        // 앱바
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const Text(
            'Manual Input',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 입력 필드들 (하이라이트)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.yellow.withOpacity(0.3), blurRadius: 8),
              ],
            ),
            child: Column(
              children: [
                // Club name
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    children: [
                      Text('Club name', style: TextStyle(color: Colors.grey[600])),
                      const Spacer(),
                      const Text('My Golf Club', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Course name
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                  ),
                  child: Row(
                    children: [
                      Text('Course name', style: TextStyle(color: Colors.grey[600])),
                      const Spacer(),
                      const Text('East Course', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        // OK 버튼 (하이라이트)
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.yellow, width: 3),
              boxShadow: [
                BoxShadow(color: Colors.yellow.withOpacity(0.5), blurRadius: 10),
              ],
            ),
            child: const Center(
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 모의 스코어 입력 화면
  Widget _buildMockScoreEntryScreen(int step) {
    return Column(
      children: [
        // 앱바
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: const Text(
            'Score Entry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        // 코스 정보
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Golf Club', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('East Course • Par 72', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Text('E', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('Progress: 0 / 18 holes', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        // 홀 카드
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildMockHoleCard(1, step),
              const SizedBox(height: 8),
              _buildMockHoleCard(2, step, isHighlighted: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMockHoleCard(int holeNum, int step, {bool isHighlighted = true}) {
    final bool highlightPar = step == 2 && isHighlighted;
    final bool highlightScore = step == 3 && isHighlighted;
    final bool highlightLock = step == 4 && isHighlighted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD5E8C5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 홀 번호
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('H$holeNum', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('Par 4', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 12),
          // 파 버튼
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: highlightPar ? Colors.yellow : const Color(0xFF64B5F6),
              borderRadius: BorderRadius.circular(20),
              border: highlightPar ? Border.all(color: Colors.orange, width: 3) : null,
              boxShadow: highlightPar ? [BoxShadow(color: Colors.yellow.withOpacity(0.8), blurRadius: 10)] : null,
            ),
            child: const Text('P4', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const Spacer(),
          // - 버튼
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: highlightScore ? Colors.yellow : Colors.grey[400]!, width: highlightScore ? 3 : 1),
              shape: BoxShape.circle,
              color: highlightScore ? Colors.yellow.withOpacity(0.3) : null,
            ),
            child: const Icon(Icons.remove, size: 18),
          ),
          // 스코어
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: highlightScore ? Colors.yellow : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: highlightScore ? Border.all(color: Colors.orange, width: 2) : null,
            ),
            child: const Text('4', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          // + 버튼
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: highlightScore ? Colors.yellow : Colors.grey[400]!, width: highlightScore ? 3 : 1),
              shape: BoxShape.circle,
              color: highlightScore ? Colors.yellow.withOpacity(0.3) : null,
            ),
            child: const Icon(Icons.add, size: 18),
          ),
          const SizedBox(width: 12),
          // 잠금 버튼
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: highlightLock ? Colors.yellow : const Color(0xFF2E7D32),
                width: highlightLock ? 3 : 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: highlightLock ? Colors.yellow.withOpacity(0.3) : null,
              boxShadow: highlightLock ? [BoxShadow(color: Colors.yellow.withOpacity(0.8), blurRadius: 10)] : null,
            ),
            child: Icon(
              Icons.lock_open,
              size: 18,
              color: highlightLock ? Colors.orange : const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}

