// lib/models/round.dart
//
// 최근 라운드 1건을 나타내는 모델
// - club / course / scoreTotal / date / pars / strokes / photoPaths
// - prettyDate, holes 등 편의 getter 포함

import 'hole_result.dart';

class Round {
  final String club;          // 골프장 이름
  final String course;        // 코스 이름
  final int scoreTotal;       // 총 타수
  final DateTime date;        // 라운드 날짜
  final List<int> pars;       // 각 홀 파
  final List<int> strokes;    // 각 홀 실제 타수
  final List<String> photoPaths; // 사진 파일 경로 리스트

  Round({
    required this.club,
    required this.course,
    required this.scoreTotal,
    required this.date,
    required this.pars,
    required this.strokes,
    this.photoPaths = const [],
  });

  // 예전 코드 호환용 getter
  String get clubName => club;
  String get courseName => course;

  // "2025-11-20" 형식
  String get prettyDate {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // HoleResult 리스트 (전/후반 화면, PDF에서 사용)
  List<HoleResult> get holes {
    final int count = pars.length;
    return List.generate(count, (i) {
      final par = pars[i];
      final stroke =
          i < strokes.length && strokes[i] > 0 ? strokes[i] : par;
      return HoleResult(
        holeIndex: i + 1,
        par: par,
        strokes: stroke,
      );
    });
  }

  // ---- 직렬화 / 역직렬화 ----

  Map<String, dynamic> toMap() {
    return {
      'club': club,
      'course': course,
      'scoreTotal': scoreTotal,
      'date': date.toIso8601String(),
      'pars': pars,
      'strokes': strokes,
      'photoPaths': photoPaths,
    };
  }

  factory Round.fromMap(Map<String, dynamic> map) {
    final dynamic dateRaw = map['date'];
    DateTime date;
    if (dateRaw is String) {
      date = DateTime.tryParse(dateRaw) ?? DateTime.now();
    } else if (dateRaw is int) {
      date = DateTime.fromMillisecondsSinceEpoch(dateRaw);
    } else {
      date = DateTime.now();
    }

    List<int> _intList(dynamic v) {
      if (v is List) {
        return v.map((e) => (e as num).toInt()).toList();
      }
      return <int>[];
    }

    List<String> _stringList(dynamic v) {
      if (v is List) {
        return v.map((e) => e.toString()).toList();
      }
      return <String>[];
    }

    return Round(
      club: (map['club'] ?? map['clubName'] ?? '') as String,
      course: (map['course'] ?? map['courseName'] ?? '') as String,
      scoreTotal: (map['scoreTotal'] ?? 0 as Object) is int
          ? map['scoreTotal'] as int
          : int.tryParse('${map['scoreTotal']}') ?? 0,
      date: date,
      pars: _intList(map['pars']),
      strokes: _intList(map['strokes']),
      photoPaths: _stringList(map['photoPaths']),
    );
  }
}
