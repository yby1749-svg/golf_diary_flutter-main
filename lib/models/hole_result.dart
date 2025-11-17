// lib/models/hole_result.dart

class HoleResult {
  final int holeIndex; // 1~18
  final int? par;
  final int? strokes;

  HoleResult({
    required this.holeIndex,
    this.par,
    this.strokes,
  });

  HoleResult copyWith({
    int? holeIndex,
    int? par,
    int? strokes,
  }) {
    return HoleResult(
      holeIndex: holeIndex ?? this.holeIndex,
      par: par ?? this.par,
      strokes: strokes ?? this.strokes,
    );
  }

  /// ScoreEntryScreen 등에서 deep copy 할 때 사용
  HoleResult copy() => HoleResult(
        holeIndex: holeIndex,
        par: par,
        strokes: strokes,
      );

  Map<String, dynamic> toJson() {
    return {
      'holeIndex': holeIndex,
      'par': par,
      'strokes': strokes,
    };
  }

  factory HoleResult.fromJson(Map<String, dynamic> json) {
    return HoleResult(
      holeIndex: (json['holeIndex'] ?? 1) as int,
      par: json['par'] as int?,
      strokes: json['strokes'] as int?,
    );
  }
}
