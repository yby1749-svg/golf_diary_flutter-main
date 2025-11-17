// lib/screens/score_entry_screen.dart
// 스코어 기록하기 화면 + 사진 선택 후 최근 라운드로 이동

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/hole_result.dart';
import '../models/round.dart';
import 'recent_rounds_screen.dart';

class ScoreEntryScreen extends StatefulWidget {
  final String? clubName;
  final String? courseName;
  final List<HoleResult>? holes;

  /// 필요하면 외부 저장 로직에 쓰는 콜백 (옵션)
  final void Function(List<int> scores, List<int> pars)? onSave;

  const ScoreEntryScreen({
    Key? key,
    this.clubName,
    this.courseName,
    this.holes,
    this.onSave,
  }) : super(key: key);

  @override
  State<ScoreEntryScreen> createState() => _ScoreEntryScreenState();
}

class _ScoreEntryScreenState extends State<ScoreEntryScreen> {
  static const int totalHoles = 18;

  late List<int> parValues;
  late List<int> scores;
  late List<bool> recorded;

  @override
  void initState() {
    super.initState();

    // 기본값: 모든 홀 Par 4 / 스코어 4
    parValues = List<int>.filled(totalHoles, 4);
    scores = List<int>.filled(totalHoles, 4);
    recorded = List<bool>.filled(totalHoles, false);

    // 만약 외부에서 holes 를 넘겨줬으면 거기 값으로 세팅
    if (widget.holes != null && widget.holes!.length == totalHoles) {
      for (int i = 0; i < totalHoles; i++) {
        final h = widget.holes![i];
        if (h.par != null) {
          parValues[i] = h.par!;
          scores[i] = h.strokes ?? h.par!;
          recorded[i] = true;
        }
      }
    }
  }

  int get completedHolesCount =>
      recorded.where((r) => r).length;

  int get totalPar =>
      parValues.fold(0, (sum, p) => sum + p);

  int get totalScore =>
      scores.fold(0, (sum, s) => sum + s);

  String get totalToParText {
    final diff = totalScore - totalPar;
    if (diff == 0) return 'E';
    if (diff > 0) return '+$diff';
    return '$diff';
  }

  void _setPar(int holeIndex, int par) {
    setState(() {
      parValues[holeIndex] = par;
      scores[holeIndex] = par; // 선택한 Par와 점수 맞추기
      recorded[holeIndex] = true;
    });
  }

  void _changeScore(int holeIndex, int delta) {
    setState(() {
      scores[holeIndex] += delta;
      if (scores[holeIndex] < 1) scores[holeIndex] = 1;
      if (scores[holeIndex] > 15) scores[holeIndex] = 15;
      recorded[holeIndex] = true;
    });
  }

  void _completeHoleByCheck(int holeIndex) {
    setState(() {
      recorded[holeIndex] = true;
    });
  }

  /// 방금 기록한 라운드를 전역 리스트(GlobalRounds)에 추가
  void _saveRoundToGlobalStore({List<String> photoPaths = const []}) {
    final holes = List<HoleResult>.generate(
      totalHoles,
      (index) => HoleResult(
        holeIndex: index + 1,
        par: parValues[index],
        strokes: scores[index],
      ),
    );

    final round = Round(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      clubName: widget.clubName ?? 'Unknown',
      courseName: widget.courseName ?? '',
      date: DateTime.now(),
      holes: holes,
      photoPaths: photoPaths,
    );

    GlobalRounds.add(round);
  }

  Future<void> _onTapSave() async {
    // 1) 필요하면 외부 저장 콜백 호출
    widget.onSave?.call(
      List<int>.from(scores),
      List<int>.from(parValues),
    );

    // 2) 사진 선택 액션 시트
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '사진을 어떻게 할까요?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('사진 찍기'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('앨범에서 올리기'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('나중에'),
                  onTap: () => Navigator.pop(context, 'later'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || result == null) return;

    List<String> photoPaths = [];

    if (result == 'camera') {
      // 사진 찍기 화면으로 이동 → 선택된 사진 경로 리스트를 반환받음
      final selected = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (_) => const TakePhotoScreen(),
        ),
      );
      if (selected != null) {
        photoPaths = selected;
      }
    } else if (result == 'gallery') {
      // 앨범에서 선택 화면으로 이동 → 선택된 사진 경로 리스트를 반환받음
      final selected = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (_) => const SelectFromAlbumScreen(),
        ),
      );
      if (selected != null) {
        photoPaths = selected;
      }
    } else if (result == 'later') {
      // 사진 없이 바로 저장
      photoPaths = const [];
    }

    // 3) 라운드 저장
    _saveRoundToGlobalStore(photoPaths: photoPaths);

    if (!mounted) return;

    // 4) 최근 라운드 화면으로 이동 (현재 화면 대체)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const RecentRoundsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clubText = widget.clubName ?? '골프장 미선택';
    final courseText = widget.courseName ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('스코어 기록하기'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 요약 카드
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    // 골프장 / 코스
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clubText,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (courseText.isNotEmpty)
                            Text(
                              courseText,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    // 합계
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Par $totalPar'),
                        Text('Score $totalScore'),
                        const SizedBox(height: 4),
                        Text(
                          totalToParText,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 진행도
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '진행: $completedHolesCount / $totalHoles 홀',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // H1~H18 리스트
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: totalHoles,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final holeNumber = index + 1;
                  final par = parValues[index];
                  final score = scores[index];
                  final isRecorded = recorded[index];

                  final rowBgColor = isRecorded
                      ? const Color(0xFFC8E6C9) // 기록한 홀
                      : const Color(0xFFF5F5F5); // 아직 안한 홀

                  return Container(
                    color: rowBgColor,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        _StatusCheck(
                          recorded: isRecorded,
                          onTap: () => _completeHoleByCheck(index),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 40,
                          child: Text(
                            'H$holeNumber',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _ParChip(
                                label: 'P3',
                                selected: par == 3,
                                onTap: () => _setPar(index, 3),
                              ),
                              _ParChip(
                                label: 'P4',
                                selected: par == 4,
                                onTap: () => _setPar(index, 4),
                              ),
                              _ParChip(
                                label: 'P5',
                                selected: par == 5,
                                onTap: () => _setPar(index, 5),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _RoundIconButton(
                              icon: Icons.remove,
                              onTap: () => _changeScore(index, -1),
                            ),
                            const SizedBox(width: 4),
                            SizedBox(
                              width: 32,
                              child: Center(
                                child: Text(
                                  '$score',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            _RoundIconButton(
                              icon: Icons.add,
                              onTap: () => _changeScore(index, 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 하단 저장 버튼
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onTapSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    '저장하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 체크 동그라미
class _StatusCheck extends StatelessWidget {
  final bool recorded;
  final VoidCallback onTap;

  const _StatusCheck({
    Key? key,
    required this.recorded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = recorded ? const Color(0xFF2E7D32) : Colors.white;
    final border =
        recorded ? const Color(0xFF2E7D32) : const Color(0xFFBDBDBD);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bg,
          border: Border.all(color: border, width: 1.5),
        ),
        child: recorded
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}

/// Par 버튼
class _ParChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ParChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFFFFA726) : const Color(0xFFE0E0E0);
    final fg = selected ? Colors.white : const Color(0xFF424242);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

/// - / + 버튼
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({
    Key? key,
    required this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBDBDBD)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: const Color(0xFF424242),
        ),
      ),
    );
  }
}

/// 📷 사진 찍기 화면 (image_picker 사용)
class TakePhotoScreen extends StatefulWidget {
  const TakePhotoScreen({Key? key}) : super(key: key);

  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  XFile? _image;
  final _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _image = picked;
      });
    }
  }

  void _complete() {
    // 선택된 사진 경로를 리스트로 반환
    if (_image != null) {
      Navigator.pop<List<String>>(context, [_image!.path]);
    } else {
      Navigator.pop<List<String>>(context, []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 찍기'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _image == null
                  ? const Icon(Icons.photo_camera_outlined, size: 60)
                  : Image.file(
                      File(_image!.path),
                      width: 200,
                    ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _takePhoto,
                child: const Text('사진 찍기'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _complete,
                child: const Text('완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🖼 앨범에서 선택 화면
class SelectFromAlbumScreen extends StatefulWidget {
  const SelectFromAlbumScreen({Key? key}) : super(key: key);

  @override
  State<SelectFromAlbumScreen> createState() => _SelectFromAlbumScreenState();
}

class _SelectFromAlbumScreenState extends State<SelectFromAlbumScreen> {
  final _picker = ImagePicker();
  List<XFile> _images = [];

  Future<void> _pickFromGallery() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _images = picked;
      });
    }
  }

  void _complete() {
    final paths = _images.map((e) => e.path).toList();
    Navigator.pop<List<String>>(context, paths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앨범에서 올리기'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFromGallery,
              child: const Text('앨범에서 선택'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _images.isEmpty
                  ? const Center(child: Text('선택된 사진이 없습니다.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        final img = _images[index];
                        return Image.file(
                          File(img.path),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _complete,
                  child: const Text('완료'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
