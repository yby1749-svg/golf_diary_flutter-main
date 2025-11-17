// lib/screens/course_search_screen.dart
//
// CSV → JSON으로 가져온 코스 DB + 내가 직접 추가한 코스
// 를 한 화면에서 검색해서 선택하는 화면.
//

import 'package:flutter/material.dart';

import '../models/app_lang.dart';
import '../models/golf_course.dart';
import '../models/golf_course_repository.dart';
import '../services/golf_course_db.dart';
import '../services/localizer.dart';

class CourseSearchScreen extends StatefulWidget {
  final AppLang lang;

  const CourseSearchScreen({super.key, required this.lang});

  @override
  State<CourseSearchScreen> createState() => _CourseSearchScreenState();
}

class _CourseSearchScreenState extends State<CourseSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;
  bool _showOnlyMyCourses = false;

  // 전체 코스
  final List<GolfCourse> _allCourses = [];
  // 필터된 코스
  List<GolfCourse> _filteredCourses = [];
  // 내 코스인지 표시하기 위한 key set
  final Set<String> _myCourseKeys = {};

  @override
  void initState() {
    super.initState();
    _load();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilter);
    _searchController.dispose();
    super.dispose();
  }

  String _courseKey(GolfCourse c) =>
      '${c.clubName}///${c.courseName}///${c.totalPar}';

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    // 1) CSV → JSON에서 읽어온 코스들
    final dbCourses = await GolfCourseDb.loadCourses();

    // 2) 내가 직접 추가한 코스들 (SharedPreferences)
    await CourseRepository.instance.initialize();
    final myCourses = CourseRepository.instance.allCourses;

    // 내 코스 key 기록
    _myCourseKeys
      ..clear()
      ..addAll(myCourses.map(_courseKey));

    // 3) 중복 제거해서 합치기 (내 코스 우선)
    _allCourses
      ..clear()
      ..addAll(myCourses);

    for (final c in dbCourses) {
      final key = _courseKey(c);
      if (!_myCourseKeys.contains(key)) {
        _allCourses.add(c);
      }
    }

    // 정렬: 클럽 이름 → 코스 이름
    _allCourses.sort((a, b) {
      final c = a.clubName.toLowerCase().compareTo(b.clubName.toLowerCase());
      if (c != 0) return c;
      return a.courseName.toLowerCase().compareTo(b.courseName.toLowerCase());
    });

    setState(() {
      _filteredCourses = List.from(_allCourses);
      _loading = false;
    });
  }

  void _applyFilter() {
    final q = _searchController.text.trim().toLowerCase();

    List<GolfCourse> base =
        _showOnlyMyCourses ? _allCourses.where(_isMyCourse).toList() : _allCourses;

    if (q.isEmpty) {
      setState(() {
        _filteredCourses = base;
      });
      return;
    }

    setState(() {
      _filteredCourses = base.where((c) {
        final text = '${c.clubName} ${c.courseName} ${c.country}'.toLowerCase();
        return text.contains(q);
      }).toList();

    });
  }

  bool _isMyCourse(GolfCourse c) => _myCourseKeys.contains(_courseKey(c));

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    const bgColor = Color(0xFFEFF8E6);
    const accent = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          L10n.t('record.search', lang),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: L10n.t('record.search', lang),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // "전체 / 내 코스만" 토글
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('전체'),
                  selected: !_showOnlyMyCourses,
                  onSelected: (v) {
                    setState(() {
                      _showOnlyMyCourses = false;
                    });
                    _applyFilter();
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('내가 추가한 코스'),
                  selected: _showOnlyMyCourses,
                  onSelected: (v) {
                    setState(() {
                      _showOnlyMyCourses = true;
                    });
                    _applyFilter();
                  },
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 목록 / 로딩 / 결과 없음
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCourses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.golf_course_outlined,
                              size: 40,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '검색 결과가 없습니다.\n직접 입력하기로 코스를 추가해 보세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: _filteredCourses.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final c = _filteredCourses[index];
                          final initials = _buildInitials(c.clubName);
                          final isMine = _isMyCourse(c);

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Navigator.pop(context, c);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // 동그란 이니셜
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: accent.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: accent,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // 텍스트들
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.clubName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              c.courseName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const Text(
                                              ' • ',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              'Par ${c.totalPar}',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: accent,
                                                fontWeight:
                                                    FontWeight.w500,
                                              ),
                                            ),
                                            if (isMine) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding:
                                                    const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration:
                                                    BoxDecoration(
                                                  color: accent
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(10),
                                                ),
                                                child: const Text(
                                                  '내 코스',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: accent,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _buildInitials(String clubName) {
    final trimmed = clubName.trim();
    if (trimmed.isEmpty) return '?';
    if (trimmed.length <= 2) return trimmed;
    return trimmed.substring(0, 2);
  }
}
