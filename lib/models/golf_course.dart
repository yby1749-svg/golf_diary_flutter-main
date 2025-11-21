// lib/models/golf_course.dart

class GolfCourse {
  /// 골프장 이름 (클럽 이름)
  final String clubName;

  /// 코스 이름 (East / West / Main 등)
  final String courseName;

  /// 18홀 파 배열 (1~18홀)
  final List<int> pars;

  /// 국가 코드 (예: "KR", "JP", "PH")
  final String country;

  /// 위도 / 경도 (없으면 null)
  final double? lat;
  final double? lon;

  GolfCourse({
    required this.clubName,
    required this.courseName,
    required this.pars,
    this.country = '',
    this.lat,
    this.lon,
  });

  /// 전체 파 합계
  int get totalPar => pars.fold(0, (a, b) => a + b);

  /// 18홀 여부
  bool get isEighteenHoles => pars.length == 18;

  /// 전반 파 합계 (데이터가 모자라면 있는 만큼만 계산)
  int get frontNinePar =>
      pars.take(9).fold(0, (a, b) => a + b);

  /// 후반 파 합계 (데이터가 모자라면 있는 만큼만 계산)
  int get backNinePar =>
      pars.skip(9).take(9).fold(0, (a, b) => a + b);

  /// 화면에 보여줄 대표 이름
  String get displayName => '$clubName / $courseName';

  /// JSON으로 저장 (유저가 직접 추가한 코스를 저장할 때 사용)
  Map<String, dynamic> toJson() => {
        'clubName': clubName,
        'courseName': courseName,
        'pars': pars,
        'country': country,
        'lat': lat,
        'lon': lon,
      };

  /// JSON에서 로드 (커스텀 코스를 다시 불러올 때 사용)
  factory GolfCourse.fromJson(Map<String, dynamic> json) {
    final parsDynamic = json['pars'];
    List<int> parsedPars = [];

    if (parsDynamic is String) {
      // "4,4,3,4,..." 형식일 때
      parsedPars = parsDynamic
          .split(',')
          .map((e) => int.tryParse(e.trim()) ?? 0)
          .toList();
    } else if (parsDynamic is List) {
      parsedPars = parsDynamic
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .toList();
    }

    return GolfCourse(
      clubName: json['clubName'] ?? '',
      courseName: json['courseName'] ?? '',
      pars: parsedPars,
      country: json['country'] ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
    );
  }
}
