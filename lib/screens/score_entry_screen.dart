// lib/screens/score_entry_screen.dart
//
// - 스코어 기록 화면
// - 홀별 Par / 타수 입력 + 잠금 기능
// - 저장 시 RecentRoundsStore에 Round 저장 (사진 경로까지 포함)
// - 저장 후 사진(카메라/앨범/나중에) 선택 → 최근 라운드 화면으로 이동
// - 다국어(Localizer) 대응

import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_lang.dart';
import '../models/hole_result.dart';
import '../models/round.dart';
import '../models/recent_rounds_store.dart';
import '../models/golf_course.dart';
import '../services/localizer.dart';
import '../services/photo_helper.dart';
import 'recent_rounds_screen.dart';

class ScoreEntryScreen extends StatefulWidget {
  static const _draftKey = 'draft_round';

  /// 예전 방식: 외부에서 만들어진 홀 리스트 + 코스 이름 전달
  final String? clubName;
  final String? courseName;
  final List<HoleResult>? holes;

  /// 새 방식: 선택된 코스 모델 자체를 전달 (pars 기반으로 내부에서 초기화)
  final GolfCourse? selectedCourse;

  /// 저장 콜백 (선택 사항)
  final void Function(List<int> strokes, List<int> pars)? onSave;

  /// 새로 입력한 코스 저장 여부
  final bool saveAsNewCourse;

  const ScoreEntryScreen({
    super.key,
    this.holes,
    this.clubName,
    this.courseName,
    this.onSave,
    this.selectedCourse,
    this.saveAsNewCourse = false,
  });

  /// 진행 중인 라운드가 있는지 확인
  static Future<Map<String, dynamic>?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftJson = prefs.getString(_draftKey);
    if (draftJson == null) return null;
    try {
      return jsonDecode(draftJson) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// 진행 중인 라운드 삭제
  static Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  @override
  State<ScoreEntryScreen> createState() => _ScoreEntryScreenState();
}

class _ScoreEntryScreenState extends State<ScoreEntryScreen>
    with WidgetsBindingObserver {
  static const _draftKey = 'draft_round';

  late List<int> strokes;
  late List<int> pars;
  late List<bool> _locked; // 홀 잠금 여부

  String _clubName = '';
  String _courseName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _clubName = widget.clubName ?? widget.selectedCourse?.clubName ?? '';
    _courseName = widget.courseName ?? widget.selectedCourse?.courseName ?? '';

    // 1) 우선 순위:
    //   - widget.holes 가 있으면 그대로 사용 (예전 방식 호환)
    //   - 없고 selectedCourse 가 있으면 그 코스의 pars 사용
    //   - 둘 다 없으면 기본 18홀 Par4
    if (widget.holes != null && widget.holes!.isNotEmpty) {
      final holeList = widget.holes!;
      pars = holeList.map((e) => e.par).toList();
      strokes = holeList.map((e) => e.strokes ?? e.par).toList();
    } else if (widget.selectedCourse != null &&
        widget.selectedCourse!.pars.isNotEmpty) {
      pars = List<int>.from(widget.selectedCourse!.pars);
      strokes = List<int>.from(pars); // 처음 타수 = Par로 시작
    } else {
      pars = List<int>.filled(18, 4);
      strokes = List<int>.from(pars);
    }

    _locked = List<bool>.filled(pars.length, false);

    // 저장된 진행 중인 라운드가 있으면 복원
    _loadDraft();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 백그라운드로 가거나 종료될 때 자동 저장
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveDraft();
    }
  }

  /// 진행 중인 라운드를 SharedPreferences에 저장
  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draft = {
      'clubName': _clubName,
      'courseName': _courseName,
      'pars': pars,
      'strokes': strokes,
      'locked': _locked.map((e) => e ? 1 : 0).toList(),
      'savedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_draftKey, jsonEncode(draft));
  }

  /// 저장된 진행 중인 라운드 복원
  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftJson = prefs.getString(_draftKey);
    if (draftJson == null) return;

    try {
      final draft = jsonDecode(draftJson) as Map<String, dynamic>;
      final savedClub = draft['clubName'] as String? ?? '';
      final savedCourse = draft['courseName'] as String? ?? '';

      // 같은 코스의 진행 중인 라운드인 경우에만 복원
      if (savedClub == _clubName && savedCourse == _courseName) {
        final savedPars = (draft['pars'] as List).cast<int>();
        final savedStrokes = (draft['strokes'] as List).cast<int>();
        final savedLocked = (draft['locked'] as List)
            .map((e) => e == 1)
            .toList();

        if (savedPars.length == pars.length) {
          setState(() {
            pars = List<int>.from(savedPars);
            strokes = List<int>.from(savedStrokes);
            _locked = List<bool>.from(savedLocked);
          });
        }
      }
    } catch (_) {
      // 복원 실패 시 무시
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 🔹 이제 이 화면도 L10n.currentLang 기준으로 언어 결정
    final lang = L10n.currentLang;

    final clubText = widget.clubName ??
        widget.selectedCourse?.clubName ??
        L10n.t('score.noCourseSelected', lang);
    final courseText = widget.courseName ??
        widget.selectedCourse?.courseName ??
        '';

    // "진행"은 잠금된 홀 개수 기준
    final completed = _locked.where((e) => e).length;
    final total = strokes.length;
    final allLocked = completed == total; // 모든 홀이 잠금되었는지

    final totalPar = pars.fold(0, (a, b) => a + b);
    final totalScore = strokes.fold(0, (a, b) => a + b);
    final diff = totalScore - totalPar;

    // 전반/후반 계산 (9홀 기준)
    final frontEnd = total >= 9 ? 9 : total;
    final hasBack = total > 9;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF8E6),
      appBar: AppBar(
        title: Text(L10n.t('score.title', lang)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(theme, clubText, courseText, totalPar, diff, lang),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "${L10n.t('score.progressPrefix', lang)}: "
              "$completed / $total ${L10n.t('score.holeSuffix', lang)}",
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                // 전반 헤더
                _buildSectionHeader(
                  theme,
                  lang,
                  L10n.t('detail.frontLabel', lang),
                  0,
                  frontEnd,
                ),
                // 전반 홀들
                for (int i = 0; i < frontEnd; i++)
                  _buildHoleRow(theme, lang, i),
                // 전반 소계
                _buildSubtotal(theme, lang, 0, frontEnd),

                // 후반이 있으면
                if (hasBack) ...[
                  const SizedBox(height: 16),
                  // 후반 헤더
                  _buildSectionHeader(
                    theme,
                    lang,
                    L10n.t('detail.backLabel', lang),
                    frontEnd,
                    total,
                  ),
                  // 후반 홀들
                  for (int i = frontEnd; i < total; i++)
                    _buildHoleRow(theme, lang, i),
                  // 후반 소계
                  _buildSubtotal(theme, lang, frontEnd, total),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
          // 저장 버튼: 모든 홀이 잠금되었을 때만 표시
          if (allLocked)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onTapSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    L10n.t('score.save', lang),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Text(
                L10n.t('score.lockAllToSave', lang),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- 전반/후반 섹션 헤더 ----------------

  Widget _buildSectionHeader(
    ThemeData theme,
    AppLang lang,
    String title,
    int start,
    int end,
  ) {
    final sectionLocked = _locked.sublist(start, end).where((e) => e).length;
    final sectionTotal = end - start;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
          ),
          const Spacer(),
          Text(
            '$sectionLocked / $sectionTotal ${L10n.t('score.holeSuffix', lang)}',
            style: TextStyle(
              fontSize: 13,
              color: sectionLocked == sectionTotal
                  ? const Color(0xFF2E7D32)
                  : Colors.grey[600],
              fontWeight: sectionLocked == sectionTotal
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          if (sectionLocked == sectionTotal)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.check_circle,
                size: 18,
                color: Color(0xFF2E7D32),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- 전반/후반 소계 ----------------

  Widget _buildSubtotal(
    ThemeData theme,
    AppLang lang,
    int start,
    int end,
  ) {
    final sectionPars = pars.sublist(start, end);
    final sectionStrokes = strokes.sublist(start, end);

    final sectionPar = sectionPars.fold(0, (a, b) => a + b);
    final sectionScore = sectionStrokes.fold(0, (a, b) => a + b);
    final sectionDiff = sectionScore - sectionPar;

    final diffText = sectionDiff == 0
        ? 'E'
        : (sectionDiff > 0 ? '+$sectionDiff' : '$sectionDiff');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSubtotalItem(
            L10n.t('score.subtotalPar', lang),
            '$sectionPar',
            Colors.grey[700]!,
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade300,
          ),
          _buildSubtotalItem(
            L10n.t('score.subtotalScore', lang),
            '$sectionScore',
            Colors.black,
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade300,
          ),
          _buildSubtotalItem(
            'To Par',
            diffText,
            sectionDiff > 0
                ? Colors.red
                : (sectionDiff < 0 ? Colors.blue : Colors.grey[700]!),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtotalItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ---------------- Header 카드 ----------------

  Widget _buildHeader(
    ThemeData theme,
    String club,
    String course,
    int par,
    int diff,
    AppLang lang,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: const BoxDecoration(
        color: Color(0xFFDDECCF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            club,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                course,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF2E7D32),
                    width: 1,
                  ),
                ),
                child: Text(
                  "Par $par",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                diff == 0 ? "E" : (diff > 0 ? "+$diff" : "$diff"),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- Hole Row ----------------

  Widget _buildHoleRow(ThemeData theme, AppLang lang, int i) {
    final isLocked = _locked[i];
    final parVal = pars[i];

    final bgColor = isLocked
        ? const Color(0xFFC9E7B6) // 잠금된 홀 → 조금 더 진한 초록
        : const Color(0xFFD8EDC9);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // H1 + Par x
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "H${i + 1}",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                "Par $parVal",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          // Par 버튼 (P3 / P4 / P5 / P6 – 단일 버튼, 탭 시 순환)
          _buildParChip(i, isLocked),

          const Spacer(),

          // - 5 + 컨트롤
          _buildStrokeControl(i, isLocked),

          const SizedBox(width: 20),

          // 잠금 버튼
          _buildLockButton(i, isLocked, lang),
        ],
      ),
    );
  }

  // Par 버튼 색상
  Color _parColor(int par) {
    switch (par) {
      case 3:
        return const Color(0xFFFFB74D); // P3: 주황(앰버)
      case 4:
        return const Color(0xFF64B5F6); // P4: 파랑
      case 5:
        return const Color(0xFFBA68C8); // P5: 퍼플
      case 6:
        return const Color(0xFFE57373); // P6: 레드 톤
      default:
        return const Color(0xFFFFB74D);
    }
  }

  Widget _buildParChip(int index, bool isLocked) {
    final parVal = pars[index];
    final bg = _parColor(parVal).withOpacity(isLocked ? 0.45 : 1.0);

    return GestureDetector(
      onTap: isLocked
          ? null
          : () {
              setState(() {
                _cyclePar(index);
              });
              _saveDraft(); // 자동 저장
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Text(
          "P$parVal",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _cyclePar(int index) {
    const options = [3, 4, 5, 6];

    final current = pars[index];
    int currentIdx = options.indexOf(current);
    if (currentIdx == -1) currentIdx = 1; // 기본 P4

    final newPar = options[(currentIdx + 1) % options.length];
    final oldPar = pars[index];

    pars[index] = newPar;

    // 사용자가 아직 타수를 직접 건드리지 않았다면(=oldPar와 같으면) 같이 변경
    if (strokes[index] == oldPar) {
      strokes[index] = newPar;
    }
  }

  Widget _buildStrokeControl(int index, bool isLocked) {
    final canEdit = !isLocked;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: canEdit
              ? () {
                  setState(() {
                    if (strokes[index] > 1) strokes[index]--;
                  });
                  _saveDraft(); // 자동 저장
                }
              : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text(
          "${strokes[index]}",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          onPressed: canEdit
              ? () {
                  setState(() {
                    strokes[index]++;
                  });
                  _saveDraft(); // 자동 저장
                }
              : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }

  Widget _buildLockButton(int index, bool isLocked, AppLang lang) {
    final icon = isLocked ? Icons.lock : Icons.lock_open;
    final bgColor =
        isLocked ? const Color(0xFF2E7D32) : Colors.white;
    final iconColor =
        isLocked ? Colors.white : const Color(0xFF4CAF50);

    return GestureDetector(
      onTap: () async {
        if (!isLocked) {
          // 잠그기: 바로 잠금
          setState(() {
            _locked[index] = true;
          });
          _saveDraft(); // 자동 저장
        } else {
          // 잠금 해제: 확인 팝업
          final result = await showDialog<bool>(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(L10n.t('score.unlockTitle', lang)),
                content: Text(
                  L10n.t(
                    'score.unlockMessage',
                    lang,
                    params: {
                      'hole': 'H${index + 1}',
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(L10n.t('common.cancel', lang)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(L10n.t('score.unlock', lang)),
                  ),
                ],
              );
            },
          );

          if (result == true) {
            setState(() {
              _locked[index] = false;
            });
            _saveDraft(); // 자동 저장
          }
        }
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF4CAF50),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor,
        ),
      ),
    );
  }

  // ---------------- 저장 로직 ----------------

  /// 저장 버튼 탭 시 호출
  Future<void> _onTapSave() async {
    // 1) 외부 콜백 (PDF 등 다른 로직에서 사용 가능)
    widget.onSave?.call(
      List<int>.from(strokes),
      List<int>.from(pars),
    );

    // 🔹 언어도 여기서 L10n.currentLang 기준으로
    final lang = L10n.currentLang;

    // 2) 사진 선택 시트
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L10n.t("photo.sheetTitle", lang),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(L10n.t("photo.take", lang)),
                  onTap: () => Navigator.pop(context, "camera"),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(L10n.t("photo.fromGalleryTitle", lang)),
                  onTap: () => Navigator.pop(context, "gallery"),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: Text(L10n.t("photo.later", lang)),
                  onTap: () => Navigator.pop(context, "later"),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    // 3) 선택 결과에 따라 실제 사진 경로 가져오기
    List<String> photoPaths = [];

    if (action == "camera") {
      photoPaths = await PhotoHelper.takePhoto();
    } else if (action == "gallery") {
      photoPaths = await PhotoHelper.pickFromGallery();
    } else {
      photoPaths = [];
    }

    // 4) 현재 입력값 기준으로 총 점수 계산
    final totalScore = strokes.fold<int>(0, (a, b) => a + b);

    // 5) Round 생성 + 최근 라운드 저장
    final round = Round(
      club: widget.clubName ??
          widget.selectedCourse?.clubName ??
          '',
      course: widget.courseName ??
          widget.selectedCourse?.courseName ??
          '',
      scoreTotal: totalScore,
      date: DateTime.now(),
      pars: List<int>.from(pars),
      strokes: List<int>.from(strokes),
      photoPaths: photoPaths,
    );

    await context.read<RecentRoundsStore>().add(round);

    // 6) 진행 중인 라운드 draft 삭제
    await ScoreEntryScreen.clearDraft();

    // 7) 새 코스 저장 (직접 입력한 경우)
    if (widget.saveAsNewCourse) {
      await _saveNewCourse();
    }

    if (!mounted) return;

    // 8) 최근 라운드 화면으로 이동
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const RecentRoundsScreen(),
      ),
    );
  }

  /// 새 코스를 저장 (실제 입력한 파 값으로)
  Future<void> _saveNewCourse() async {
    final clubName = widget.clubName ?? widget.selectedCourse?.clubName ?? '';
    final courseName = widget.courseName ?? widget.selectedCourse?.courseName ?? '';

    if (clubName.isEmpty || courseName.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final coursesJson = prefs.getStringList('saved_courses') ?? [];

    // 중복 체크
    final exists = coursesJson.any((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map['clubName'] == clubName && map['courseName'] == courseName;
    });

    if (exists) return;

    // 실제 입력한 파 값으로 저장
    final newCourse = jsonEncode({
      'clubName': clubName,
      'courseName': courseName,
      'pars': pars,
    });

    coursesJson.add(newCourse);
    await prefs.setStringList('saved_courses', coursesJson);
  }
}
