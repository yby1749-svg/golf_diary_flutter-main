// lib/models/golf_course_repository.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'golf_course.dart';

class CourseRepository {
  CourseRepository._internal();

  /// 싱글톤 인스턴스
  static final CourseRepository instance = CourseRepository._internal();

  static const _storageKey = 'user_courses_v1';

  final List<GolfCourse> _courses = [];
  bool _initialized = false;

  /// 앱 시작 시 한 번만 호출해서 저장된 코스 + 기본 코스를 불러온다.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        _courses.addAll(
          list.map((e) => GolfCourse.fromJson(e as Map<String, dynamic>)),
        );
      } catch (e) {
        // 파싱 실패 시 그냥 무시하고 기본 코스만 사용
      }
    }

    // ✅ 처음 실행할 때만 기본 코스 4개(대표 코스) 채워넣기
    if (_courses.isEmpty) {
      _courses.addAll([
        // 🇰🇷 한국
        GolfCourse(
          clubName: 'Korea Country Club',
          courseName: 'Main Course',
          pars: [
            4, 4, 4, 3, 5, 4, 4, 3, 5, // Front 9 (36)
            4, 4, 5, 3, 4, 4, 4, 3, 5, // Back 9 (36) = 72
          ],
        ),

        // 🇯🇵 일본
        GolfCourse(
          clubName: 'Tokyo Golf Club',
          courseName: 'East Course',
          pars: [
            4, 4, 3, 4, 5, 4, 3, 4, 5,
            4, 4, 4, 5, 3, 4, 4, 3, 5,
          ],
        ),

        // 🇵🇭 필리핀
        GolfCourse(
          clubName: 'Manila Golf & Country Club',
          courseName: 'Championship',
          pars: [
            4, 4, 4, 3, 5, 4, 4, 3, 5,
            4, 5, 4, 3, 4, 4, 4, 3, 5,
          ],
        ),

        // 🇨🇳 중국
        GolfCourse(
          clubName: 'Mission Hills Golf Club',
          courseName: 'World Cup Course',
          pars: [
            4, 4, 4, 3, 5, 4, 3, 4, 5,
            4, 4, 5, 3, 4, 4, 3, 4, 5,
          ],
        ),
      ]);

      await _save();
    }
  }

  /// 내부 저장소에 현재 코스 리스트 저장
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _courses.map((c) => c.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  /// 모든 코스 (읽기 전용)
  List<GolfCourse> get allCourses => List.unmodifiable(_courses);

  /// 검색어로 코스 검색
  List<GolfCourse> search(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) return allCourses;

    return _courses.where((c) {
      final text =
          '${c.clubName} ${c.courseName} ${c.country}'.toLowerCase();
      return text.contains(query);
    }).toList();
  }

  /// 유저가 직접 코스를 추가할 때 사용
  Future<void> addCourse(GolfCourse course) async {
    _courses.add(course);
    await _save();
  }
}
