// lib/screens/record_flow_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../models/app_lang.dart';
import '../models/hole_result.dart';
import '../services/localizer.dart';
import '../models/golf_course.dart';
import 'score_entry_screen.dart';
import 'course_search_screen.dart';



class RecordFlowScreen extends StatefulWidget {
  const RecordFlowScreen({super.key});

  @override
  State<RecordFlowScreen> createState() => _RecordFlowScreenState();
}

class _RecordFlowScreenState extends State<RecordFlowScreen> {
  String? selectedClubName;
  String? selectedCourseName;

  final TextEditingController _clubController = TextEditingController();
  final TextEditingController _courseController = TextEditingController();

  @override
  void dispose() {
    _clubController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  List<HoleResult> _makeDefaultHoles() {
    final List<HoleResult> list = [];
    for (int i = 0; i < 18; i++) {
      list.add(HoleResult(holeIndex: i + 1, par: 4, strokes: 4));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final AppLang lang = settings.lang;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('record.title', lang)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          if (selectedClubName != null && selectedCourseName != null)
            Column(
              children: [
                Text(
                  selectedClubName!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  selectedCourseName!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // 검색 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final GolfCourse? picked =
                          await Navigator.of(context).push<GolfCourse>(
                        MaterialPageRoute(
                          builder: (_) =>
                              CourseSearchScreen(lang: lang),
                        ),
                      );

                      if (picked != null) {
                        setState(() {
                          selectedClubName = picked.clubName;
                          selectedCourseName = picked.courseName;
                        });
                      }
                    },
                    child: Text(L10n.t('record.search', lang)),
                  ),
                ),
                const SizedBox(width: 12),
                // 직접입력 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _openManualDialog(context, lang);
                    },
                    child: Text(L10n.t('record.manual', lang)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              L10n.t('record.hint', lang),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final club =
                      selectedClubName ?? _clubController.text.trim();
                  final course =
                      selectedCourseName ?? _courseController.text.trim();

                  if (club.isEmpty || course.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('골프장과 코스를 입력해주세요.'),
                      ),
                    );
                    return;
                  }

                  final holes = _makeDefaultHoles();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ScoreEntryScreen(
                        clubName: club,
                        courseName: course,
                        holes: holes,
                      ),
                    ),
                  );
                },
                child: Text(L10n.t('record.start', lang)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openManualDialog(BuildContext context, AppLang lang) async {
    _clubController.text = selectedClubName ?? '';
    _courseController.text = selectedCourseName ?? '';

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(L10n.t('record.manual', lang)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _clubController,
                decoration: const InputDecoration(
                  labelText: '클럽 이름',
                ),
              ),
              TextField(
                controller: _courseController,
                decoration: const InputDecoration(
                  labelText: '코스 이름',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '모든 홀 Par4로 설정되며, 다음 화면에서 변경할 수 있어요.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('닫기'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  selectedClubName = _clubController.text.trim();
                  selectedCourseName = _courseController.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
