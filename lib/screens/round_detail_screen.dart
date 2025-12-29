// lib/screens/round_detail_screen.dart
//
// 라운드 상세 화면 + 사진 썸네일 & 전체보기 + 인스타 감성 UI
// PDF 내보내기는 round_detail_pdf.dart 의 RoundDetailPdf.export 사용

import 'dart:io';

import 'package:flutter/material.dart';

import '../models/app_lang.dart';
import '../models/round.dart';
import '../models/hole_result.dart';
import '../services/localizer.dart';
import 'photo_gallery_screen.dart';
import 'round_detail_pdf.dart'; // PDF 전용

class RoundDetailScreen extends StatelessWidget {
  final Round round;

  const RoundDetailScreen({
    super.key,
    required this.round,
  });

  @override
  Widget build(BuildContext context) {
    // 🔹 전역 언어 상태 사용
    final lang = L10n.currentLang;

    final holes = round.holes;
    final front = holes.take(9).toList();
    final back = holes.skip(9).take(9).toList();

    final totalPar = round.pars.fold<int>(0, (a, b) => a + b);
    final totalScore = round.scoreTotal;
    final diff = totalScore - totalPar;
    final diffText = diff == 0 ? "E" : (diff > 0 ? "+$diff" : "$diff");

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.t('recent.detailTitle', lang)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildHeader(lang, totalPar, totalScore, diffText),
            const SizedBox(height: 16),
            _buildNine(lang, L10n.t('detail.frontLabel', lang), front),
            const SizedBox(height: 16),
            _buildNine(lang, L10n.t('detail.backLabel', lang), back),
            const SizedBox(height: 24),
            _buildTotals(lang, totalPar, totalScore, diffText),
            const SizedBox(height: 24),
            _buildPhotos(context, lang, round.photoPaths),
            const SizedBox(height: 24),
            _buildPdfButton(context, lang),
          ],
        ),
      ),
    );
  }

  // ---------------------------- Header ----------------------------

  Widget _buildHeader(AppLang lang, int par, int score, String diffText) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFD0F8CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            round.club,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (round.course.isNotEmpty)
            Text(
              round.course,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          const SizedBox(height: 6),
          Text(
            round.prettyDate,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip('Par', '$par'),
              const SizedBox(width: 8),
              _infoChip(L10n.t("recent.scoreLabel", lang), '$score'),
              const Spacer(),
              Text(
                diffText,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text("$label : $value"),
    );
  }

  // ---------------------------- Front / Back ----------------------------

  Widget _buildNine(AppLang lang, String title, List<HoleResult> holes) {
    final holeNumbers = holes.map((e) => '${e.holeNumber}').toList();
    final pars = holes.map((e) => '${e.par}').toList();
    final strokes = holes.map((e) => '${e.strokes ?? e.par}').toList();
    final toPars = holes.map((e) {
      final d = (e.strokes ?? e.par) - e.par;
      if (d == 0) return 'E';
      return d > 0 ? '+$d' : '$d';
    }).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7FBF5), Color(0xFFE8F5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 👉 전체 테이블 가로 스크롤
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _labelText(L10n.t('detail.holeHeader', lang)),
                    const SizedBox(height: 10),
                    _labelText('Par'),
                    const SizedBox(height: 10),
                    _labelText(L10n.t('detail.strokeHeader', lang)),
                    const SizedBox(height: 10),
                    _labelText(L10n.t('detail.toParHeader', lang)),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _scoreRow(holeNumbers, _ScoreRowType.hole),
                    const SizedBox(height: 10),
                    _scoreRow(pars, _ScoreRowType.par),
                    const SizedBox(height: 10),
                    _scoreRow(strokes, _ScoreRowType.stroke),
                    const SizedBox(height: 10),
                    _scoreRow(toPars, _ScoreRowType.toPar),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------- Totals ----------------------------

  Widget _buildTotals(AppLang lang, int totalPar, int totalScore, String diffText) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          _totalRow(L10n.t('detail.totalParLabel', lang), '$totalPar'),
          _totalRow(L10n.t('detail.totalScoreLabel', lang), '$totalScore'),
          _totalRow(L10n.t('detail.totalToParLabel', lang), diffText),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ---------------------------- Photos ----------------------------

  Widget _buildPhotos(BuildContext context, AppLang lang, List<String> paths) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10n.t('detail.photoSectionTitle', lang),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (paths.isEmpty)
            Text(
              L10n.t('detail.noPhotos', lang),
              style: const TextStyle(color: Colors.grey),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(paths.length, (index) {
                  final p = paths[index];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PhotoGalleryScreen(
                          photoPaths: paths,
                          initialIndex: index,
                        ),
                      ),
                    ),
                    child: Container(
                      width: 120,
                      height: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(p)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------- PDF 버튼 ----------------------------

  Widget _buildPdfButton(BuildContext context, AppLang lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            await RoundDetailPdf.export(context, round, lang);
          },
          icon: const Icon(Icons.picture_as_pdf),
          label: Text(L10n.t('detail.exportPdf', lang)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // 🔹 Helper UI Elements
  // =====================================================================

  Widget _labelText(String text) {
    return SizedBox(
      width: 60,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF37474F),
        ),
      ),
    );
  }
}

// 행 데이터의 유형
enum _ScoreRowType { hole, par, stroke, toPar }

// 칩 UI
Widget _scoreRow(List<String> values, _ScoreRowType type) {
  return Row(
    children: values.map((v) {
      Color bg = Colors.white;
      Color border = Colors.black12;
      Color textColor = const Color(0xFF263238);

      switch (type) {
        case _ScoreRowType.hole:
          bg = const Color(0xFF4CAF50);
          textColor = Colors.white;
          border = Colors.transparent;
          break;
        case _ScoreRowType.par:
          bg = const Color(0xFFE3F2FD);
          textColor = const Color(0xFF1565C0);
          break;
        case _ScoreRowType.stroke:
          bg = const Color(0xFFF3E5F5);
          textColor = const Color(0xFF6A1B9A);
          break;
        case _ScoreRowType.toPar:
          if (v == 'E') {
            bg = const Color(0xFFE0E0E0);
          } else if (v.startsWith('-')) {
            bg = const Color(0xFFC8E6C9);
            textColor = const Color(0xFF1B5E20);
          } else {
            bg = const Color(0xFFFFCDD2);
            textColor = const Color(0xFFB71C1C);
          }
          break;
      }

      return Container(
        width: 32,
        height: 26,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: border, width: 1),
        ),
        child: Text(
          v,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      );
    }).toList(),
  );
}
