import 'package:flutter/material.dart';
import 'package:golf_diary_flutter/data/default_courses.dart'; // 임시 기본 코스
import '../models/golf_course.dart';
import '../services/localizer.dart';
import 'course_select_screen.dart';
import 'recent_rounds_screen.dart';
import 'language_settings_screen.dart';
import 'score_entry_screen.dart';
import 'manual_course_input_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // 아래에서 위로 크게 올라오게 (0.6 정도에서 시작)
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // 투명 → 불투명
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    // 작게 → 크게
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🌄 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/golf_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                // 🌐 우측 상단 언어 변경 글로브
                Positioned(
                  top: 8,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.language),
                    color: const Color(0xFF2E7D32),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LanguageSettingsScreen(),
                        ),
                      );
                      // 언어 바뀐 후 다시 그리기
                      setState(() {});
                    },
                  ),
                ),

                // ⬆ GOLF DIARY 제목 애니메이션
                Positioned(
                  top: size.height * 0.12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: ScaleTransition(
                          scale: _scale,
                          child: const Text(
                            'GOLF DIARY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ↓ 기록하기 버튼
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 100,
                  child: Center(
                    child: _MainFilledButton(
                      text: L10n.tr('home.record'),
                      onPressed: () async {
                        // TODO: 나중엔 여기서 실제 GolfCourseDB / Repository에서 코스 목록을 가져오면 된다.
                        // final courses = GolfCourseDB.instance.courses;
                        // 지금은 기본 코스 리스트로 테스트
                        final courses = kDefaultCourses;

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseSelectScreen(
                              allCourses: courses,
                            ),
                          ),
                        );

                        // 1) 코스를 선택한 경우
                        if (result is GolfCourse) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScoreEntryScreen(
                                selectedCourse: result,
                              ),
                            ),
                          );
                          return;
                        }

                        // 2) "직접 입력" 버튼을 누른 경우
                        if (result == 'manual') {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ManualCourseInputScreen(),
                            ),
                          );
                          return;
                        }
                      },
                    ),
                  ),
                ),

                // ⬇ 최근 라운드 버튼
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30,
                  child: Center(
                    child: _MainOutlinedButton(
                      text: L10n.tr('home.recent'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RecentRoundsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= 버튼 스타일 =================

class _MainFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _MainFilledButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.9),
          foregroundColor: const Color(0xFF2E7D32),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MainOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _MainOutlinedButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.white.withOpacity(0.9),
            width: 2,
          ),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
