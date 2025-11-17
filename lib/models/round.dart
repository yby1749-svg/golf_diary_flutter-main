// lib/models/round.dart

import 'dart:convert';

import 'hole_result.dart';

class Round {
  final String id;
  final String clubName;
  final String courseName;
  final DateTime date;
  final List<HoleResult> holes;

  /// 사진 파일 경로 리스트 (0개일 수도 있음)
  final List<String> photoPaths;

  Round({
    required this.id,
    required this.clubName,
    required this.courseName,
    required this.date,
    required this.holes,
    List<String>? photoPaths,
  }) : photoPaths = photoPaths ?? const [];

  int get totalPar =>
      holes.fold<int>(0, (sum, h) => sum + (h.par ?? 4));

  int get totalScore =>
      holes.fold<int>(0, (sum, h) => sum + (h.strokes ?? h.par ?? 4));

  int get diff => totalScore - totalPar;

  String get diffLabel {
    if (diff > 0) return '+$diff';
    if (diff < 0) return diff.toString();
    return 'E';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clubName': clubName,
      'courseName': courseName,
      'date': date.toIso8601String(),
      'holes': holes.map((h) => h.toJson()).toList(),
      'photos': photoPaths,
    };
  }

  factory Round.fromJson(Map<String, dynamic> json) {
    final holesJson = (json['holes'] as List<dynamic>? ?? []);
    final photosJson = (json['photos'] as List<dynamic>? ?? []);

    return Round(
      id: (json['id'] ?? '') as String,
      clubName: (json['clubName'] ?? '') as String,
      courseName: (json['courseName'] ?? '') as String,
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      holes: holesJson
          .map((e) => HoleResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      photoPaths: photosJson.map((e) => e.toString()).toList(),
    );
  }

  Round copyWith({
    String? id,
    String? clubName,
    String? courseName,
    DateTime? date,
    List<HoleResult>? holes,
    List<String>? photoPaths,
  }) {
    return Round(
      id: id ?? this.id,
      clubName: clubName ?? this.clubName,
      courseName: courseName ?? this.courseName,
      date: date ?? this.date,
      holes: holes ?? this.holes,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }

  static String encodeList(List<Round> rounds) => json.encode(
        rounds.map((r) => r.toJson()).toList(),
      );

  static List<Round> decodeList(String src) {
    final list = json.decode(src) as List<dynamic>;
    return list
        .map((e) => Round.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// ✅ 간단한 전역 라운드 저장소
class GlobalRounds {
  static final List<Round> rounds = [];

  static void add(Round round) {
    rounds.insert(0, round); // 최근 라운드가 위로 오게
  }

  static void clear() {
    rounds.clear();
  }
}
