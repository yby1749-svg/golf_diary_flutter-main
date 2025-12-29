// lib/screens/round_detail_pdf.dart
//
// 라운드 상세 PDF 생성 전용 모듈
// - 컬러풀 스코어카드
// - 다국어 라벨 (L10n)
// - 사진 페이지 (있을 때만)

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/app_lang.dart';
import '../models/round.dart';
import '../models/hole_result.dart';
import '../services/localizer.dart';

class RoundDetailPdf {
  /// 라운드 상세 화면에서 호출하는 메서드
  static Future<void> export(
    BuildContext context,
    Round round,
    AppLang lang,
  ) async {
    final bytes = await _buildPdf(round, lang);
    await Printing.layoutPdf(
      onLayout: (format) async => bytes,
    );
  }
}

// =====================================================
// PDF 생성 로직
// =====================================================

Future<Uint8List> _buildPdf(Round r, AppLang lang) async {
  // 1) 폰트 로드
  // ※ 중국어가 □ 로 나오면 CJK 지원 폰트를 하나 더 넣고
  //    아래 경로를 그 폰트로 바꿔 주면 돼.
  final ByteData fontData =
      await rootBundle.load('assets/fonts/GolfDiarySans.ttf');
  final pw.Font baseFont = pw.Font.ttf(fontData);

  // 2) 테마 설정
  final theme = pw.ThemeData.withFont(
    base: baseFont,
    bold: baseFont,
  );

  final doc = pw.Document(theme: theme);

  final holes = r.holes;
  final front = holes.take(9).toList();
  final back = holes.skip(9).take(9).toList();

  final totalPar = r.pars.fold<int>(0, (a, b) => a + b);
  final totalScore = r.scoreTotal;
  final diff = totalScore - totalPar;
  final diffText = diff == 0 ? "E" : (diff > 0 ? "+$diff" : "$diff");

  // ---------- 공통: 스코어 테이블 빌더 ----------
  pw.Widget scoreTable(
    String title,
    List<HoleResult> list,
    String rangeLabel,
  ) {
    const headerColor = PdfColors.green;
    const labelBg = PdfColors.grey300;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          '$title $rangeLabel',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.3),
          children: [
            // Hole header
            pw.TableRow(
              children: [
                _pdfCell(
                  L10n.t('detail.holeHeader', lang),
                  bold: true,
                  color: headerColor,
                  textColor: PdfColors.white,
                ),
                ...list.map(
                  (e) => _pdfCell(
                    '${e.holeNumber}',
                    bold: true,
                    color: headerColor,
                    textColor: PdfColors.white,
                  ),
                ),
              ],
            ),
            // Par row
            pw.TableRow(
              children: [
                _pdfCell(
                  'Par',
                  bold: true,
                  color: labelBg,
                  textColor: PdfColors.black,
                ),
                ...list.map(
                  (e) => _pdfCell('${e.par}'),
                ),
              ],
            ),
            // Stroke row
            pw.TableRow(
              children: [
                _pdfCell(
                  L10n.t('detail.strokeHeader', lang),
                  bold: true,
                  color: labelBg,
                  textColor: PdfColors.black,
                ),
                ...list.map(
                  (e) => _pdfCell('${e.strokes ?? e.par}'),
                ),
              ],
            ),
            // To Par row
            pw.TableRow(
              children: [
                _pdfCell(
                  L10n.t('detail.toParHeader', lang),
                  bold: true,
                  color: labelBg,
                  textColor: PdfColors.black,
                ),
                ...list.map((e) {
                  final s = e.strokes ?? e.par;
                  final d = s - e.par;
                  final t = d == 0 ? "E" : (d > 0 ? "+$d" : "$d");
                  PdfColor tc = PdfColors.black;
                  if (d < 0) {
                    tc = PdfColors.green;
                  } else if (d > 0) {
                    tc = PdfColors.red;
                  }
                  return _pdfCell(
                    t,
                    bold: true,
                    textColor: tc,
                  );
                }),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Calculate statistics for the round
  final frontNineScore = front.fold<int>(0, (sum, hole) => sum + (hole.strokes ?? hole.par));
  final backNineScore = back.fold<int>(0, (sum, hole) => sum + (hole.strokes ?? hole.par));
  final frontNinePar = front.fold<int>(0, (sum, hole) => sum + hole.par);
  final backNinePar = back.fold<int>(0, (sum, hole) => sum + hole.par);

  // Count scoring performance
  int birdies = 0;
  int pars = 0;
  int bogeys = 0;
  int doubles = 0;

  for (final hole in holes) {
    final s = hole.strokes ?? hole.par;
    final d = s - hole.par;
    if (d <= -2) {
      birdies++;
    } else if (d == -1) {
      birdies++;
    } else if (d == 0) {
      pars++;
    } else if (d == 1) {
      bogeys++;
    } else if (d >= 2) {
      doubles++;
    }
  }

  // ---------- 1페이지: 스코어 카드 ----------
  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      build: (context) => [
        // 상단 요약 카드 - Enhanced with gradient-like effect
        pw.Container(
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColors.green700,
            borderRadius: pw.BorderRadius.circular(16),
            boxShadow: [
              pw.BoxShadow(
                color: PdfColors.grey400,
                blurRadius: 10,
                offset: const PdfPoint(0, 4),
              ),
            ],
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          L10n.t('recent.detailTitle', lang),
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          r.club,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                        if (r.course.isNotEmpty)
                          pw.Text(
                            r.course,
                            style: pw.TextStyle(
                              fontSize: 13,
                              color: PdfColors.white,
                            ),
                          ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          _fmtDateLocalized(r.date, lang),
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Large score display
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          '$totalScore',
                          style: pw.TextStyle(
                            fontSize: 36,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700,
                          ),
                        ),
                        pw.Text(
                          diffText,
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: diff < 0
                                ? PdfColors.green
                                : (diff > 0 ? PdfColors.red : PdfColors.grey800),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.white, thickness: 0.5),
              pw.SizedBox(height: 12),
              // Score breakdown
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _scoreBreakdown(
                    label: L10n.t('detail.frontLabel', lang),
                    score: '$frontNineScore',
                    par: '$frontNinePar',
                  ),
                  pw.Container(
                    width: 1,
                    height: 40,
                    color: PdfColors.white,
                  ),
                  _scoreBreakdown(
                    label: L10n.t('detail.backLabel', lang),
                    score: '$backNineScore',
                    par: '$backNinePar',
                  ),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 20),

        // Statistics Card
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(12),
            border: pw.Border.all(color: PdfColors.green200, width: 1),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _statBadge(
                icon: '🦅',
                label: 'Birdies',
                value: '$birdies',
                color: PdfColors.blue,
              ),
              _statBadge(
                icon: '✓',
                label: 'Pars',
                value: '$pars',
                color: PdfColors.green,
              ),
              _statBadge(
                icon: '+1',
                label: 'Bogeys',
                value: '$bogeys',
                color: PdfColors.orange,
              ),
              _statBadge(
                icon: '+2',
                label: 'Doubles+',
                value: '$doubles',
                color: PdfColors.red,
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 24),

        scoreTable(
          L10n.t('detail.frontLabel', lang),
          front,
          '1-9',
        ),
        pw.SizedBox(height: 20),
        scoreTable(
          L10n.t('detail.backLabel', lang),
          back,
          '10-18',
        ),

        pw.SizedBox(height: 24),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Generated by GolfDiary (PDF v3)',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ),
      ],
    ),
  );

  // ---------- 2페이지: 사진 (있을 때만) ----------
  if (r.photoPaths.isNotEmpty) {
    final List<pw.Widget> photoWidgets = [];

    for (final path in r.photoPaths) {
      final file = File(path);
      if (!file.existsSync()) continue;

      final bytes = await file.readAsBytes();
      photoWidgets.add(
        pw.Container(
          width: 150,
          height: 110,
          margin: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: PdfColors.green, width: 0.5),
          ),
          child: pw.ClipRRect(
            horizontalRadius: 8,
            verticalRadius: 8,
            child: pw.Image(
              pw.MemoryImage(bytes),
              fit: pw.BoxFit.cover,
            ),
          ),
        ),
      );
    }

    if (photoWidgets.isNotEmpty) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) => [
            pw.Text(
              L10n.t('detail.photoSectionTitle', lang),
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.green,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: photoWidgets,
            ),
          ],
        ),
      );
    }
  }

  return doc.save();
}

// =====================================================
// 헬퍼 위젯 & 함수
// =====================================================

pw.Widget _pdfCell(
  String text, {
  bool bold = false,
  PdfColor? color,
  PdfColor? textColor,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    alignment: pw.Alignment.center,
    color: color,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: textColor ?? PdfColors.black,
      ),
    ),
  );
}

pw.Widget _summaryChip({
  required String label,
  required String value,
  required PdfColor bg,
  required PdfColor textColor,
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: pw.BoxDecoration(
      color: bg,
      borderRadius: pw.BorderRadius.circular(20),
    ),
    child: pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          '$label : ',
          style: pw.TextStyle(
            fontSize: 10,
            color: textColor,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

String _fmtDateLocalized(DateTime d, AppLang lang) {
  switch (lang) {
    case AppLang.ko:
      return "${d.year}년 ${d.month}월 ${d.day}일";
    case AppLang.ja:
      return "${d.year}年${d.month}月${d.day}日";
    case AppLang.zh:
      return "${d.year}-${d.month}-${d.day}";
    case AppLang.en:
    default:
      return "${d.month}/${d.day}/${d.year}";
  }
}

pw.Widget _scoreBreakdown({
  required String label,
  required String score,
  required String par,
}) {
  return pw.Column(
    children: [
      pw.Text(
        label,
        style: pw.TextStyle(
          fontSize: 11,
          color: PdfColors.white,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        score,
        style: pw.TextStyle(
          fontSize: 20,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
      pw.Text(
        'Par $par',
        style: pw.TextStyle(
          fontSize: 9,
          color: PdfColors.white,
        ),
      ),
    ],
  );
}

pw.Widget _statBadge({
  required String icon,
  required String label,
  required String value,
  required PdfColor color,
}) {
  return pw.Column(
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: color.shade(0.1),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          icon,
          style: const pw.TextStyle(fontSize: 16),
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(
        value,
        style: pw.TextStyle(
          fontSize: 18,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
      pw.Text(
        label,
        style: const pw.TextStyle(
          fontSize: 9,
          color: PdfColors.grey700,
        ),
      ),
    ],
  );
}
