// lib/models/round_summary.dart

class RoundSummary {
  final String clubName;
  final String courseName;
  final DateTime playedAt;
  final List<int> pars;   // 18홀 Par
  final List<int> scores; // 18홀 Stroke

  RoundSummary({
    required this.clubName,
    required this.courseName,
    required this.playedAt,
    required this.pars,
    required this.scores,
  });

  int get totalPar => pars.fold(0, (a, b) => a + b);
  int get totalScore => scores.fold(0, (a, b) => a + b);
  int get diff => totalScore - totalPar;

  String get toParText {
    if (diff == 0) return 'E';
    return diff > 0 ? '+$diff' : '$diff';
  }
}

/// 전역 최근 라운드 리스트 (간단 버전)
class GlobalRounds {
  static final List<RoundSummary> rounds = [];
}
