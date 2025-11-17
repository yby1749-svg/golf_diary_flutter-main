// lib/services/golf_course_db.dart

import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/golf_course.dart';

class GolfCourseDb {
  GolfCourseDb._();

  static List<GolfCourse>? _cache;

  /// assets/courses_new.json 에서 한 번만 읽어와서 캐싱
  static Future<List<GolfCourse>> loadCourses() async {
    if (_cache != null) return _cache!;

    // 👉 방금 pubspec.yaml 에 등록한 파일 경로
    final jsonStr = await rootBundle.loadString('assets/courses_new.json');

    final list = json.decode(jsonStr) as List<dynamic>;

    _cache = list
        .map((e) => GolfCourse.fromJson(e as Map<String, dynamic>))
        .toList();

    return _cache!;
  }
}
