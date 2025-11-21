// lib/screens/course_search_screen.dart

import 'package:flutter/material.dart';
import '../models/golf_course.dart';

class CourseSearchScreen extends StatefulWidget {
  /// 전체 코스 리스트
  final List<GolfCourse> allCourses;

  /// allCourses 안 넘겨줘도 되지만, 넘겨주는게 좋음
  const CourseSearchScreen({
    Key? key,
    this.allCourses = const [],
  }) : super(key: key);

  @override
  State<CourseSearchScreen> createState() => _CourseSearchScreenState();
}

class _CourseSearchScreenState extends State<CourseSearchScreen> {
  String _query = '';
  String? _selectedCountry; // null = 전체
  bool _only18Holes = true;

  late List<GolfCourse> _recommendedCourses;
  late List<GolfCourse> _filteredCourses;

  @override
  void initState() {
    super.initState();
    _recommendedCourses = _buildRecommendedCourses(widget.allCourses);
    _filteredCourses = _applyFilters();
  }

  List<GolfCourse> _buildRecommendedCourses(List<GolfCourse> all) {
    if (all.isEmpty) return [];
    // 간단하게: 이름순 정렬 후 상위 8개 추천
    final sorted = [...all]..sort((a, b) => a.clubName.compareTo(b.clubName));
    return sorted.take(8).toList();
  }

  List<GolfCourse> _applyFilters() {
    Iterable<GolfCourse> list = widget.allCourses;

    // 검색어 필터 (클럽명 + 코스명)
    if (_query.trim().isNotEmpty) {
      final q = _query.trim().toLowerCase();
      list = list.where((c) =>
          c.clubName.toLowerCase().contains(q) ||
          c.courseName.toLowerCase().contains(q));
    }

    // 국가 필터
    if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
      list = list.where((c) => c.country == _selectedCountry);
    }

    // 18홀 필터
    if (_only18Holes) {
      list = list.where((c) => c.isEighteenHoles);
    }

    // 정렬: 국가 -> 클럽명 -> 코스명
    final result = list.toList()
      ..sort((a, b) {
        final countryCmp = a.country.compareTo(b.country);
        if (countryCmp != 0) return countryCmp;
        final clubCmp = a.clubName.compareTo(b.clubName);
        if (clubCmp != 0) return clubCmp;
        return a.courseName.compareTo(b.courseName);
      });

    return result;
  }

  List<String> get _countryOptions {
    final set = <String>{};
    for (final c in widget.allCourses) {
      if (c.country.isNotEmpty) set.add(c.country);
    }
    final list = set.toList()..sort();
    return list;
  }

  void _onCourseSelected(GolfCourse course) {
    Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = widget.allCourses.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('코스 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 추천 코스 섹션
            if (hasData && _recommendedCourses.isNotEmpty) ...[
              _SectionHeader(
                title: '추천 코스',
                subtitle: '자주 사용하거나 인기 있는 코스를 빠르게 선택해요',
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recommendedCourses.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final course = _recommendedCourses[index];
                    return _RecommendedCourseCard(
                      course: course,
                      onTap: () => _onCourseSelected(course),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // 검색창
            TextField(
              decoration: InputDecoration(
                hintText: '골프장 또는 코스명을 입력하세요',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _query = '';
                            _filteredCourses = _applyFilters();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                  _filteredCourses = _applyFilters();
                });
              },
            ),
            const SizedBox(height: 12),

            // 필터 바
            Row(
              children: [
                // 국가 드롭다운
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: theme.dividerColor.withOpacity(0.6)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isDense: true,
                        value: _selectedCountry,
                        hint: const Text('국가 전체'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('국가 전체'),
                          ),
                          ..._countryOptions.map(
                            (c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(c),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCountry = value;
                            _filteredCourses = _applyFilters();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 18홀만 토글
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: _only18Holes,
                      onChanged: (value) {
                        setState(() {
                          _only18Holes = value;
                          _filteredCourses = _applyFilters();
                        });
                      },
                    ),
                    const Text('18홀만'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 결과 리스트
            Expanded(
              child: _filteredCourses.isEmpty
                  ? Center(
                      child: Text(
                        hasData ? '조건에 맞는 코스가 없습니다.' : '등록된 코스 데이터가 없습니다.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredCourses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final course = _filteredCourses[index];
                        return _CourseResultCard(
                          course: course,
                          onTap: () => _onCourseSelected(course),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 섹션 제목 위젯
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }
}

/// 추천 코스 카드 (가로 스크롤용)
class _RecommendedCourseCard extends StatelessWidget {
  final GolfCourse course;
  final VoidCallback onTap;

  const _RecommendedCourseCard({
    Key? key,
    required this.course,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.85),
              theme.colorScheme.primary.withOpacity(0.55),
            ],
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.clubName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              course.courseName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Chip(
                  label: Text(
                    'PAR ${course.totalPar}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.15),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 6),
                if (course.country.isNotEmpty)
                  Chip(
                    label: Text(
                      course.country,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.white.withOpacity(0.15),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 검색 결과 카드
class _CourseResultCard extends StatelessWidget {
  final GolfCourse course;
  final VoidCallback onTap;

  const _CourseResultCard({
    Key? key,
    required this.course,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.06),
            ),
          ],
        ),
        child: Row(
          children: [
            // 왼쪽 아이콘/원
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.9),
                    theme.colorScheme.primary.withOpacity(0.6),
                  ],
                ),
              ),
              child: const Icon(
                Icons.golf_course,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            // 가운데 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.clubName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    course.courseName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color
                          ?.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PAR ${course.totalPar} • OUT ${course.frontNinePar} / IN ${course.backNinePar}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 오른쪽 국가 / 화살표
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (course.country.isNotEmpty)
                  Text(
                    course.country,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
