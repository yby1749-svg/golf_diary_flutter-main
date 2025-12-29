// lib/services/golf_course_db.dart
//
// CSV 기반 골프장 DB 로딩
// - assets/courses_new.csv 를 파싱해서 List<GolfCourse> 로 변환
// - 따옴표(") + 콤마(,) 포함된 필드도 안전하게 처리

import 'dart:convert'; // LineSplitter
import 'package:flutter/services.dart' show rootBundle;

import '../models/golf_course.dart';

class GolfCourseDB {
  static bool _loaded = false;
  static final List<GolfCourse> _courses = [];

  /// CSV에서 코스 데이터 로드
  static Future<void> load({bool force = false}) async {
    if (_loaded && !force) return;

    _courses.clear();

    // assets/courses_new.csv 읽기
    final csvString = await rootBundle.loadString('assets/courses_new.csv');

    // 줄 단위로 나누기
    final lines = const LineSplitter().convert(csvString);
    if (lines.isEmpty) return;

    // 첫 줄은 헤더: id,club,course,country,lat,lon,parFront,parBack
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final cols = _parseCsvLine(line);
      // 최소 8개 컬럼(id 포함)이어야 함
      if (cols.length < 8) continue;

      final club = cols[1].trim();
      final course = cols[2].trim();
      final country = cols[3].trim();
      final latStr = cols[4].trim();
      final lonStr = cols[5].trim();
      final frontStr = cols[6].trim();
      final backStr = cols[7].trim();

      // 앞/뒤 9홀 파 배열
      final front = frontStr
          .split(',')
          .map((s) => int.tryParse(s.trim()) ?? 4)
          .toList();
      final back = backStr
          .split(',')
          .map((s) => int.tryParse(s.trim()) ?? 4)
          .toList();

      // 9 + 9 홀이 아니면 스킵
      if (front.length != 9 || back.length != 9) continue;

      final pars = <int>[...front, ...back];

      _courses.add(
        GolfCourse(
          clubName: club,
          courseName: course,
          country: country,
          pars: pars,
          lat: latStr.isEmpty ? null : double.tryParse(latStr),
          lon: lonStr.isEmpty ? null : double.tryParse(lonStr),
        ),
      );
    }

    _loaded = true;
  }

  /// 외부에서 사용하는 전체 코스 리스트
  static List<GolfCourse> get allCourses => List.unmodifiable(_courses);

  /// 따옴표 포함 CSV 한 줄 파서
  /// 예: 1,Army Golf Club,Main,PH,,,"4,4,4,4,4,4,4,4,4","4,4,4,4,4,4,4,4,4"
  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') {
        // 따옴표 토글
        inQuotes = !inQuotes;
      } else if (ch == ',' && !inQuotes) {
        // 따옴표 밖의 콤마 → 필드 구분
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(ch);
      }
    }
    // 마지막 필드
    result.add(buffer.toString());

    return result;
  }
}
