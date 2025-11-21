// lib/models/hole_result.dart
//
// 각 홀의 결과를 표현하는 모델
//
// - 예전 코드: HoleResult(holeIndex: 1, par: 4)
// - 신규 코드: HoleResult(holeNumber: 1, par: 4)
// 둘 다 동작하도록 호환 처리.

class HoleResult {
  /// 1 ~ 18
  final int holeNumber;

  /// 파 (기본 3, 4, 5)
  int par;

  /// 실제 타수 (입력 전에는 null)
  int? strokes;

  /// 퍼트 수 (선택 입력)
  int? putts;

  /// 메모 (선택)
  String? note;

  HoleResult({
    int? holeIndex,      // 옛날 코드용
    int? holeNumber,     // 새 코드용
    required this.par,
    this.strokes,
    this.putts,
    this.note,
  }) : holeNumber = holeNumber ?? holeIndex ?? 1;

  /// 예전 코드에서 쓰던 이름도 그대로 지원
  int get holeIndex => holeNumber;

  /// 스코어 입력 여부
  bool get hasScore => strokes != null;

  /// 파 대비 + / - (아직 기록 안 했으면 null)
  int? get diffFromPar {
    if (strokes == null) return null;
    return strokes! - par;
  }

  HoleResult copyWith({
    int? par,
    int? strokes,
    int? putts,
    String? note,
  }) {
    return HoleResult(
      holeNumber: holeNumber,
      par: par ?? this.par,
      strokes: strokes ?? this.strokes,
      putts: putts ?? this.putts,
      note: note ?? this.note,
    );
  }

  // ---- JSON 직렬화 (최근 라운드 저장용) ----

  factory HoleResult.fromJson(Map<String, dynamic> json) {
    // holeNumber / holeIndex / hole 등의 다양한 키를 최대한 받아줌
    final h = json['holeNumber'] ??
        json['holeIndex'] ??
        json['hole'] ??
        json['index'] ??
        1;

    return HoleResult(
      holeNumber: h is int ? h : int.tryParse(h.toString()) ?? 1,
      par: json['par'] is int
          ? json['par'] as int
          : int.tryParse(json['par']?.toString() ?? '') ?? 4,
      strokes: json['strokes'] is int
          ? json['strokes'] as int
          : (json['strokes'] != null
              ? int.tryParse(json['strokes'].toString())
              : null),
      putts: json['putts'] is int
          ? json['putts'] as int
          : (json['putts'] != null
              ? int.tryParse(json['putts'].toString())
              : null),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'holeNumber': holeNumber,
      'par': par,
      'strokes': strokes,
      'putts': putts,
      'note': note,
    };
  }
}
