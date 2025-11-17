// lib/screens/course_select_screen.dart
//
// 골프장 검색 + 직접 입력 화면
//

import 'package:flutter/material.dart';

import '../models/golf_course.dart';
import '../models/golf_course_repository.dart';
import '../models/hole_result.dart';
import 'score_entry_screen.dart';

class CourseSelectScreen extends StatefulWidget {
  const CourseSelectScreen({Key? key}) : super(key: key);

  @override
  State<CourseSelectScreen> createState() => _CourseSelectScreenState();
}

class _CourseSelectScreenState extends State<CourseSelectScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<GolfCourse> _results = [];

  @override
  void initState() {
    super.initState();

    CourseRepository.instance.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _results = CourseRepository.instance.allCourses;
      });
    });

    _searchCtrl.addListener(() {
      final q = _searchCtrl.text;
      setState(() {
        _results = CourseRepository.instance.search(q);
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _selectCourse(GolfCourse course) {
    final holes = List.generate(
      18,
      (i) => HoleResult(
        holeIndex: i + 1,
        par: course.pars[i],
        strokes: course.pars[i],
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

    await CourseRepository.instance.addCourse(course);
    _selectCourse(course);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFEFF8E6);
    final accent = const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          '골프장 검색',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: '골프장 / 코스 검색',
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            ),
          ),

          // 결과가 없을 때
          if (_results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: const [
                  Icon(Icons.golf_course_outlined,
                      size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    '검색 결과가 없습니다.\n직접 입력하기로 코스를 추가해 보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

          // 검색 결과 리스트
          if (_results.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                itemCount: _results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final c = _results[i];
                  final initials = _buildInitials(c.clubName);

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _selectCourse(c),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // 동그란 아이콘
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 텍스트들
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.clubName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      c.courseName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Text(
                                      ' • ',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      'Par ${c.totalPar}',
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
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // 하단 "직접 입력하기" 버튼
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _openManualInput,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: accent,
                    elevation: 2,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    '직접 입력하기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

// ------------------------------
// 직접 입력 화면
// ------------------------------

class _ManualCourseInputScreen extends StatefulWidget {
  _ManualCourseInputScreen({Key? key}) : super(key: key);

  @override
  State<_ManualCourseInputScreen> createState() =>
      _ManualCourseInputScreenState();
}

class _ManualCourseInputScreenState
    extends State<_ManualCourseInputScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('직접 입력'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _club,
              decoration: const InputDecoration(
                labelText: '골프장 이름(클럽)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _course,
              decoration: const InputDecoration(
                labelText: '코스 이름',
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
                child: const Text(
                  '확인',
                  style: TextStyle(
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
