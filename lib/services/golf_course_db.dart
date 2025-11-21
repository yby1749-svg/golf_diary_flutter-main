// lib/services/golf_course_db.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/golf_course.dart';

class GolfCourseDB {
  GolfCourseDB._();
  static final GolfCourseDB instance = GolfCourseDB._();

  bool _loaded = false;
  final List<GolfCourse> _courses = [];

  /// 앱 번들의 CSV에서 코스 로드
  /// 이미 로드됐다면 다시 읽지 않음
  Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;

    _courses.clear();

    // ✅ 네가 사용하는 CSV 파일명으로 바꿔줘
    // 예: assets/courses_new.csv
    final csvString = await rootBundle.loadString('assets/courses_new.csv');

    final lines = const LineSplitter().convert(csvString);

    // 첫 줄에 헤더가 있다면 건너뜀
    bool isHeader = true;
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      if (isHeader) {
        isHeader = false;
        continue;
      }

      // 예시 포맷:
      // clubName,courseName,country,"4,4,3,4,5,4,3,4,4","4,4,4,5,3,4,4,3,5"
      final cols = _parseCsvLine(line);
      if (cols.length < 5) continue;

      final clubName = cols[0].trim();
      final courseName = cols[1].trim();
      final country = cols[2].trim();
      final front9 = cols[3].split(',').map((e) => int.tryParse(e) ?? 4).toList();
      final back9 = cols[4].split(',').map((e) => int.tryParse(e) ?? 4).toList();

      if (front9.length != 9 || back9.length != 9) continue;

      final pars = <int>[...front9, ...back9];

      _courses.add(
        GolfCourse(
          clubName: clubName,
          courseName: courseName,
          pars: pars,
          country: country,
        ),
      );
    }

    _loaded = true;
  }

  /// 로드된 전체 코스 리스트
  List<GolfCourse> get courses => List.unmodifiable(_courses);

  // 간단 CSV 파서 (따옴표 포함된 필드 대응)
  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    result.add(buffer.toString());
    return result;
  }
}
