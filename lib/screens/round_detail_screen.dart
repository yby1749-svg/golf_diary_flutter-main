// lib/screens/round_detail_screen.dart
//
// 라운드 상세 화면 + 사진 보기 + PDF 미리보기 / 공유

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/round.dart';
import '../models/hole_result.dart';

class RoundDetailScreen extends StatelessWidget {
  final Round round;

  const RoundDetailScreen({Key? key, required this.round}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<HoleResult> holes = round.holes;
    final front = holes.take(9).toList();
    final back = holes.skip(9).take(9).toList();

    final totalPar = holes.fold<int>(
      0,
      (sum, h) => sum + (h.par ?? 0),
    );

    final totalScore = holes.fold<int>(
      0,
      (sum, h) => sum + (h.strokes ?? h.par ?? 0),
    );

    final diff = totalScore - totalPar;
    final totalToParText = diff == 0 ? 'E' : (diff > 0 ? '+$diff' : '$diff');

    final photos = round.photoPaths; // ✅ 사진 리스트

    return Scaffold(
      appBar: AppBar(
        title: const Text('라운드 상세'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 헤더 카드
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      // 왼쪽: 골프장 / 코스 / 날짜
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              round.clubName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              round.courseName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _fmtDate(round.date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 오른쪽: 총합
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

              // 전반 1–9
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _NineHoleScoreTable(
                  title: '전반 1–9',
                  holes: front,
                ),
              ),
              const SizedBox(height: 24),

              // 후반 10–18
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _NineHoleScoreTable(
                  title: '후반 10–18',
                  holes: back,
                ),
              ),
              const SizedBox(height: 24),

              // 총 Par / 총 타수 / 합계 To Par 카드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      _TotalRow(label: '총 Par', value: '$totalPar'),
                      const SizedBox(height: 4),
                      _TotalRow(label: '총 타수', value: '$totalScore'),
                      const SizedBox(height: 4),
                      _TotalRow(
                        label: '합계 To Par',
                        value: totalToParText,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 사진 섹션
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '사진',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (photos.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhotoViewerScreen(
                                photoPaths: photos,
                                initialIndex: 0,
                              ),
                            ),
                          );
                        },
                        child: const Text('전체보기'),
                      ),
                  ],
                ),
              ),
              SizedBox(
                height: 120,
                child: photos.isEmpty
                    ? const Center(
                        child: Text('등록된 사진이 없습니다.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final path = photos[index];
                          final label = '사진 ${index + 1}';
                          return _PhotoThumb(
                            label: label,
                            path: path,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PhotoViewerScreen(
                                    photoPaths: photos,
                                    initialIndex: index,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),

              // PDF 내보내기 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RoundPdfPreviewScreen(round: round),
                          ),
                        );
                      },
                      icon: const Icon(Icons.ios_share),
                      label: const Text('PDF 내보내기'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmtDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// 전/후반 9홀 테이블 (4줄이 한 번에 스크롤)
class _NineHoleScoreTable extends StatelessWidget {
  final String title;
  final List<HoleResult> holes; // 최대 9개

  const _NineHoleScoreTable({
    Key? key,
    required this.title,
    required this.holes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 부족한 칸은 빈칸으로 채워서 항상 9칸 유지
    final holeNumbers = <int>[];
    final pars = <int>[];
    final strokes = <int>[];
    final toPars = <String>[];

    for (var h in holes) {
      final p = h.par ?? 0;
      final s = h.strokes ?? h.par ?? 0;
      final d = s - p;

      holeNumbers.add(h.holeIndex);
      pars.add(p);
      strokes.add(s);

      if (d == 0) {
        toPars.add('E');
      } else if (d > 0) {
        toPars.add('+$d');
      } else {
        toPars.add('$d');
      }
    }

    while (holeNumbers.length < 9) {
      holeNumbers.add(0);
      pars.add(0);
      strokes.add(0);
      toPars.add('');
    }

    final parSum = pars.fold<int>(0, (a, b) => a + b);
    final scoreSum = strokes.fold<int>(0, (a, b) => a + b);
    final diffSum = scoreSum - parSum;
    final toParSum =
        diffSum == 0 ? 'E' : (diffSum > 0 ? '+$diffSum' : '$diffSum');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // 전체 가로 스크롤 카드
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _colorRow(
                  label: 'Hole',
                  values: holeNumbers.map((e) => e == 0 ? '' : '$e').toList(),
                  sumText: 'Sum',
                  bgColor: const Color(0xFFEDEDED),
                ),
                const SizedBox(height: 6),
                _colorRow(
                  label: 'Par',
                  values: pars.map((e) => e == 0 ? '' : '$e').toList(),
                  sumText: '$parSum',
                  bgColor: const Color(0xFFCDE7FF), // 하늘색
                ),
                const SizedBox(height: 6),
                _colorRow(
                  label: 'Stroke',
                  values: strokes.map((e) => e == 0 ? '' : '$e').toList(),
                  sumText: '$scoreSum',
                  bgColor: const Color(0xFFD4F5D0), // 연한 초록
                ),
                const SizedBox(height: 6),
                _toParColorRow(
                  values: toPars,
                  sumText: toParSum,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 공통 컬러 줄 (Hole / Par / Stroke)
Widget _colorRow({
  required String label,
  required List<String> values,
  required String sumText,
  required Color bgColor,
}) {
  return Row(
    children: [
      SizedBox(
        width: 50,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(width: 6),
      ...values.map(
        (v) => Container(
          width: 36,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(v)),
        ),
      ),
      const SizedBox(width: 6),
      Container(
        width: 45,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(sumText)),
      ),
    ],
  );
}

/// To Par 전용 컬러 줄
Widget _toParColorRow({
  required List<String> values,
  required String sumText,
}) {
  Color cellColor(String v) {
    if (v.isEmpty) return const Color(0xFFF0F0F0);
    if (v == 'E') return const Color(0xFFF0F0F0); // 이븐
    if (v.startsWith('-')) return const Color(0xFFB6F8B6); // 버디이하
    return const Color(0xFFFFF2B3); // 보기 이상
  }

  return Row(
    children: [
      const SizedBox(
        width: 50,
        child: Text(
          'To Par',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      const SizedBox(width: 6),
      ...values.map(
        (v) => Container(
          width: 36,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: cellColor(v),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(v)),
        ),
      ),
      const SizedBox(width: 6),
      Container(
        width: 45,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: cellColor(sumText),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(sumText)),
      ),
    ],
  );
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;

  const _TotalRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// 사진 썸네일 (탭 가능)
class _PhotoThumb extends StatelessWidget {
  final String label;
  final String? path;
  final VoidCallback? onTap;

  const _PhotoThumb({
    Key? key,
    required this.label,
    this.path,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (path == null || path!.isEmpty) {
      content = Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
      );
    } else {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(path!),
          fit: BoxFit.cover,
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: content),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: const EdgeInsets.all(6),
                padding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
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

/// 전체 사진 크게 보기
class PhotoViewerScreen extends StatefulWidget {
  final List<String> photoPaths;
  final int initialIndex;

  const PhotoViewerScreen({
    Key? key,
    required this.photoPaths,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photoPaths;

    return Scaffold(
      appBar: AppBar(
        title: const Text('사진 보기'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final path = photos[index];
          return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: path.isEmpty
                ? const Text(
                    '이미지를 불러올 수 없습니다.',
                    style: TextStyle(color: Colors.white),
                  )
                : InteractiveViewer(
                    child: Image.file(File(path)),
                  ),
          );
        },
      ),
    );
  }
}

/// PDF 미리보기 + 공유 화면
class RoundPdfPreviewScreen extends StatelessWidget {
  final Round round;

  const RoundPdfPreviewScreen({Key? key, required this.round})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF 미리보기'),
      ),
      body: PdfPreview(
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowSharing: true,
        allowPrinting: true,
        build: (context) => _buildPdf(round),
      ),
    );
  }

  // PdfPreview 에서 기대하는 타입: FutureOr<Uint8List>
  Future<Uint8List> _buildPdf(Round round) async {
    final pdf = pw.Document();

    final holes = round.holes;
    final front = holes.take(9).toList();
    final back = holes.skip(9).take(9).toList();

    final totalPar = holes.fold<int>(
      0,
      (sum, h) => sum + (h.par ?? 0),
    );

    final totalScore = holes.fold<int>(
      0,
      (sum, h) => sum + (h.strokes ?? h.par ?? 0),
    );

    final diff = totalScore - totalPar;
    final totalToParText =
        diff == 0 ? 'E' : (diff > 0 ? '+$diff' : '$diff');

    // 🔹 사진 파일을 실제로 읽어서 PDF용 바이트로 준비
    final List<Uint8List> photoBytes = [];
    try {
      for (final path in round.photoPaths) {
        if (path.isEmpty) continue;
        final file = File(path);
        if (!file.existsSync()) continue;
        final bytes = await file.readAsBytes();
        photoBytes.add(bytes);
      }
    } catch (_) {
      // 사진 읽다 실패해도 PDF 전체는 계속 생성되도록
    }

    // 페이지 1: 스코어카드
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Scorecard',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('${round.clubName} • ${round.courseName}'),
              pw.Text(_fmtDatePdf(round.date)),
              pw.SizedBox(height: 16),
              pw.Divider(),
              pw.SizedBox(height: 16),
              _buildNineTablePdf(
                // 🔧 특수 대시 대신 일반 하이픈 사용 → 글자 깨짐 방지
                title: 'Front 9 (1-9)',
                holes: front,
              ),
              pw.SizedBox(height: 16),
              _buildNineTablePdf(
                title: 'Back 9 (10-18)',
                holes: back,
              ),
              pw.SizedBox(height: 16),
              _buildTotalCardPdf(
                totalPar: totalPar,
                totalScore: totalScore,
                totalToParText: totalToParText,
              ),
              pw.Spacer(),
              _buildFooter(page: 1, totalPages: 2),
            ],
          );
        },
      ),
    );

    // 페이지 2: Photos
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Photos',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              if (photoBytes.isEmpty)
                pw.Text(
                  'No photos saved.',
                  style: const pw.TextStyle(fontSize: 12),
                )
              else
                pw.Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(photoBytes.length, (index) {
                    final label =
                        '#${index + 1} · ${_fmtDatePdf(round.date)}';
                    return pw.Container(
                      width: 120,
                      height: 160,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey300,
                        borderRadius: pw.BorderRadius.circular(16),
                      ),
                      child: pw.Stack(
                        children: [
                          pw.Positioned.fill(
                            child: pw.Image(
                              pw.MemoryImage(photoBytes[index]),
                              fit: pw.BoxFit.cover,
                            ),
                          ),
                          pw.Align(
                            alignment: pw.Alignment.bottomLeft,
                            child: pw.Container(
                              margin: const pw.EdgeInsets.all(6),
                              padding: const pw.EdgeInsets.symmetric(
                                vertical: 3,
                                horizontal: 6,
                              ),
                              decoration: pw.BoxDecoration(
                                color: PdfColor(0, 0, 0, 0.7),
                                borderRadius: pw.BorderRadius.circular(10),
                              ),
                              child: pw.Text(
                                label,
                                style: const pw.TextStyle(
                                  fontSize: 10,
                                  color: PdfColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              pw.Spacer(),
              _buildFooter(page: 2, totalPages: 2),
            ],
          );
        },
      ),
    );

    return pdf.save(); // Future<Uint8List>
  }

  // 🔹 PDF용 To Par 셀 색상
  PdfColor _toParPdfColor(String v) {
    if (v.isEmpty || v == 'E') {
      return PdfColor(0.94, 0.94, 0.94, 1.0); // 연회색
    }
    if (v.startsWith('-')) {
      return PdfColor(0.71, 0.97, 0.71, 1.0); // 연초록
    }
    return PdfColor(1.0, 0.95, 0.7, 1.0); // 연노랑
  }

  pw.Widget _buildNineTablePdf({
    required String title,
    required List<HoleResult> holes,
  }) {
    final holeNumbers = <int>[];
    final pars = <int>[];
    final strokes = <int>[];
    final toPars = <String>[];

    for (var h in holes) {
      final p = h.par ?? 0;
      final s = h.strokes ?? h.par ?? 0;
      final d = s - p;

      holeNumbers.add(h.holeIndex);
      pars.add(p);
      strokes.add(s);

      if (d == 0) {
        toPars.add('E');
      } else if (d > 0) {
        toPars.add('+$d');
      } else {
        toPars.add('$d');
      }
    }

    while (holeNumbers.length < 9) {
      holeNumbers.add(0);
      pars.add(0);
      strokes.add(0);
      toPars.add('');
    }

    final parSum = pars.fold<int>(0, (a, b) => a + b);
    final scoreSum = strokes.fold<int>(0, (a, b) => a + b);
    final diffSum = scoreSum - parSum;
    final toParSum =
        diffSum == 0 ? 'E' : (diffSum > 0 ? '+$diffSum' : '$diffSum');

    final parBg = PdfColor(205 / 255, 231 / 255, 1.0, 1.0); // CDE7FF
    final strokeBg = PdfColor(212 / 255, 245 / 255, 208 / 255, 1.0); // D4F5D0
    final defaultBg = PdfColor(0.93, 0.93, 0.93, 1.0);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Column(
            children: [
              _scoreRowPdf(
                label: 'Hole',
                values:
                    holeNumbers.map((e) => e == 0 ? '' : '$e').toList(),
                sumText: 'Sum',
                bgColor: defaultBg,
              ),
              pw.SizedBox(height: 4),
              _scoreRowPdf(
                label: 'Par',
                values: pars.map((e) => e == 0 ? '' : '$e').toList(),
                sumText: '$parSum',
                bgColor: parBg,
              ),
              pw.SizedBox(height: 4),
              _scoreRowPdf(
                label: 'Strokes',
                values: strokes.map((e) => e == 0 ? '' : '$e').toList(),
                sumText: '$scoreSum',
                bgColor: strokeBg,
              ),
              pw.SizedBox(height: 4),
              _toParRowPdf(
                values: toPars,
                sumText: toParSum,
                defaultBg: defaultBg,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _scoreRowPdf({
    required String label,
    required List<String> values,
    required String sumText,
    required PdfColor bgColor,
  }) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 40,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(width: 4),
        ...values.map(
          (v) => pw.Expanded(
            child: pw.Container(
              margin:
                  const pw.EdgeInsets.symmetric(horizontal: 1.5),
              padding: const pw.EdgeInsets.symmetric(
                  vertical: 4, horizontal: 2),
              decoration: pw.BoxDecoration(
                color: bgColor,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Center(
                child: pw.Text(
                  v,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ),
          ),
        ),
        pw.SizedBox(width: 4),
        pw.Container(
          width: 34,
          padding: const pw.EdgeInsets.symmetric(
              vertical: 4, horizontal: 2),
          decoration: pw.BoxDecoration(
            color: bgColor,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Center(
            child: pw.Text(
              sumText,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _toParRowPdf({
    required List<String> values,
    required String sumText,
    required PdfColor defaultBg,
  }) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 40,
          child: pw.Text(
            'To Par',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(width: 4),
        ...values.map(
          (v) {
            final bg = v.isEmpty ? defaultBg : _toParPdfColor(v);
            return pw.Expanded(
              child: pw.Container(
                margin:
                    const pw.EdgeInsets.symmetric(horizontal: 1.5),
                padding: const pw.EdgeInsets.symmetric(
                    vertical: 4, horizontal: 2),
                decoration: pw.BoxDecoration(
                  color: bg,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Center(
                  child: pw.Text(
                    v,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ),
            );
          },
        ),
        pw.SizedBox(width: 4),
        pw.Container(
          width: 34,
          padding: const pw.EdgeInsets.symmetric(
              vertical: 4, horizontal: 2),
          decoration: pw.BoxDecoration(
            color: _toParPdfColor(sumText),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Center(
            child: pw.Text(
              sumText,
              style: const pw.TextStyle(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTotalCardPdf({
    required int totalPar,
    required int totalScore,
    required String totalToParText,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(16),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _totalRowPdf('Total Par', '$totalPar'),
          _totalRowPdf('Total Strokes', '$totalScore'),
          _totalRowPdf('To Par', totalToParText),
        ],
      ),
    );
  }

  pw.Widget _totalRowPdf(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(label)),
          pw.Text(
            value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter({required int page, required int totalPages}) {
    return pw.Row(
      children: [
        pw.Text(
          'Generated by GolfDiary',
          style: const pw.TextStyle(fontSize: 9),
        ),
        pw.Spacer(),
        pw.Text(
          '$page / $totalPages',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ],
    );
  }

  static String _fmtDatePdf(DateTime date) {
    return '${date.year}. ${date.month.toString().padLeft(2, '0')}. ${date.day.toString().padLeft(2, '0')}';
  }
}
