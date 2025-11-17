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

  /// JSON으로 저장 (유저가 직접 추가한 코스를 저장할 때 사용)
  Map<String, dynamic> toJson() => {
        'clubName': clubName,
        'courseName': courseName,
        'country': country,
        'lat': lat,
        'lon': lon,
        'pars': pars,
      };

  /// JSON에서 읽어오기
  ///
  /// - 우리가 만든 courses_new.json 은
  ///   { "club": "...", "course": "...", "country": "...", "pars": [4,4,...] }
  ///   이런 형식이야.
  /// - 예전 샘플 JSON(courses_sample.json)은
  ///   { "clubName": "...", "courseName": "...", "pars": [...] } 식이었지.
  /// 그래서 둘 다 지원하도록 파싱해놨어.
  factory GolfCourse.fromJson(Map<String, dynamic> json) {
    // club / clubName 둘 다 지원
    final club = (json['clubName'] ?? json['club'] ?? '') as String;
    final course = (json['courseName'] ?? json['course'] ?? '') as String;
    final country = (json['country'] ?? '') as String;

    List<int> pars;

    // 1) pars 배열이 이미 있으면 그대로 사용
    if (json['pars'] != null) {
      final raw = json['pars'] as List<dynamic>;
      pars = raw.map((e) {
        if (e is int) return e;
        return int.parse(e.toString());
      }).toList();
    } else {
      // 2) pars가 없으면 parFront + parBack 을 합쳐서 만든다
      List<int> parseList(dynamic v) {
        if (v == null) return [];
        if (v is List) {
          return v.map((e) => int.parse(e.toString())).toList();
        }
        final s = v.toString().trim();
        if (s.isEmpty) return [];
        return s.split(',').map((e) => int.parse(e.trim())).toList();
      }

      final front = parseList(json['parFront']);
      final back = parseList(json['parBack']);
      pars = [...front, ...back];
    }

    double? parseDouble(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return double.tryParse(s);
    }

    return GolfCourse(
      clubName: club,
      courseName: course,
      country: country,
      lat: parseDouble(json['lat']),
      lon: parseDouble(json['lon']),
      pars: pars,
    );
  }
}
