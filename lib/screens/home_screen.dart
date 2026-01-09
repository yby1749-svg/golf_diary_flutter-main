import 'package:flutter/material.dart';

import '../models/golf_course.dart';
import '../services/localizer.dart';
import 'course_select_screen.dart';
import 'recent_rounds_screen.dart';
import 'language_settings_screen.dart';
import 'game_screen.dart';
import 'score_entry_screen.dart';

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

  Map<String, dynamic>? _draft; // 진행 중인 라운드

  @override
  void initState() {
    super.initState();
    _checkDraft();

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

  Future<void> _checkDraft() async {
    final draft = await ScoreEntryScreen.getDraft();
    if (mounted) {
      setState(() {
        _draft = draft;
      });
    }
  }

  void _continueDraft() {
    if (_draft == null) return;

    final clubName = _draft!['clubName'] as String? ?? '';
    final courseName = _draft!['courseName'] as String? ?? '';
    final pars = (_draft!['pars'] as List).cast<int>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScoreEntryScreen(
          selectedCourse: GolfCourse(
            clubName: clubName,
            courseName: courseName,
            pars: pars,
          ),
        ),
      ),
    ).then((_) => _checkDraft()); // 돌아오면 다시 체크
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

                // ⬆ GOLF DIARY 제목 애니메이션 (구름 효과)
                Positioned(
                  top: size.height * 0.10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: ScaleTransition(
                          scale: _scale,
                          child: Stack(
                            children: [
                              // 녹색 구름 아웃라인 (여러 겹)
                              Text(
                                'GOLF DIARY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 12
                                    ..color = const Color(0xFF2E7D32).withOpacity(0.3),
                                ),
                              ),
                              Text(
                                'GOLF DIARY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 8
                                    ..color = const Color(0xFF2E7D32).withOpacity(0.5),
                                ),
                              ),
                              Text(
                                'GOLF DIARY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 4
                                    ..color = const Color(0xFF2E7D32),
                                ),
                              ),
                              // 메인 텍스트 (흰색)
                              const Text(
                                'GOLF DIARY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 52,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ⬇ 계속하기 버튼 (진행 중인 라운드가 있을 때만 표시)
                if (_draft != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 240,
                    child: Center(
                      child: _ContinueButton(
                        clubName: _draft!['clubName'] as String? ?? '',
                        onPressed: _continueDraft,
                      ),
                    ),
                  ),

                // ⬇ 기록하기 버튼
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 170,
                  child: Center(
                    child: _MainFilledButton(
                      text: L10n.tr('home.record'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CourseSelectScreen(),
                          ),
                        ).then((_) => _checkDraft()); // 돌아오면 다시 체크
                      },
                    ),
                  ),
                ),

                // ⬇ 게임 버튼
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 100,
                  child: Center(
                    child: _MainOutlinedButton(
                      text: L10n.tr('home.game'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GameScreen(),
                          ),
                        );
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

class _ContinueButton extends StatelessWidget {
  final String clubName;
  final VoidCallback onPressed;

  const _ContinueButton({
    required this.clubName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB74D), // 주황색
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              L10n.tr('home.continue'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (clubName.isNotEmpty)
              Text(
                clubName,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
