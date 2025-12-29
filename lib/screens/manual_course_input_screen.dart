// lib/screens/manual_course_input_screen.dart

import 'package:flutter/material.dart';
import '../models/golf_course.dart';
import 'score_entry_screen.dart';

class ManualCourseInputScreen extends StatefulWidget {
  const ManualCourseInputScreen({Key? key}) : super(key: key);

  @override
  State<ManualCourseInputScreen> createState() =>
      _ManualCourseInputScreenState();
}

class _ManualCourseInputScreenState extends State<ManualCourseInputScreen> {
  final _clubController = TextEditingController();
  final _courseController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _clubController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  void _startManualRound() {
    if (!_formKey.currentState!.validate()) return;

    final clubName = _clubController.text.trim();
    final courseName = _courseController.text.trim();

    // 기본 18홀 전부 Par 4
    final manualCourse = GolfCourse(
      clubName: clubName,
      courseName: courseName,
      pars: List<int>.filled(18, 4),
      country: '',
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ScoreEntryScreen(
          selectedCourse: manualCourse,
          // 선택사항: 수동 코스 여부가 필요하면 여기에 bool 플래그 추가 가능
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('코스 직접 입력'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '골프장 정보를 입력하세요',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '처음에는 모든 홀이 Par 4로 설정되고, \n'
                  '다음 화면에서 홀별 Par를 자유롭게 변경할 수 있어요.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),

                // 클럽 이름
                TextFormField(
                  controller: _clubController,
                  decoration: const InputDecoration(
                    labelText: '골프장 이름 (클럽명)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '골프장 이름을 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 코스 이름
                TextFormField(
                  controller: _courseController,
                  decoration: const InputDecoration(
                    labelText: '코스 이름 (예: Main Course)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '코스 이름을 입력하세요.';
                    }
                    return null;
                  },
                ),

                const Spacer(),

                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: _startManualRound,
                      child: const Text('기록 시작'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
