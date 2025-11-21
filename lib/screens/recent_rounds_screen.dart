// lib/screens/recent_rounds_screen.dart
//
// 최근 라운드 목록 화면
// - 리스트에서 항목을 누르면 RoundDetailScreen(사진 + PDF 미리보기)로 이동

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recent_rounds_store.dart';
import '../services/localizer.dart';
import 'round_detail_screen.dart';

class RecentRoundsScreen extends StatelessWidget {
  const RecentRoundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<RecentRoundsStore>();

    // 🔹 이제 전역 언어 상태 사용
    final lang = L10n.currentLang;

    return Scaffold(
      backgroundColor: const Color(0xFFF6EFFF), // 연보라 배경
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6EFFF),
        elevation: 0,
        centerTitle: true,
        title: Text(L10n.t('recent.title', lang)),
        actions: [
          if (store.rounds.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(L10n.t('recent.clearConfirmTitle', lang)),
                      content: Text(L10n.t('recent.clearConfirmMessage', lang)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(L10n.t('common.cancel', lang)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(L10n.t('recent.clearButton', lang)),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed == true) {
                  await store.clear();
                }
              },
            ),
        ],
      ),
      body: store.rounds.isEmpty
          ? Center(
              child: Text(
                L10n.t('recent.empty', lang),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            )
          : ListView.builder(
              itemCount: store.rounds.length,
              itemBuilder: (context, index) {
                final r = store.rounds[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RoundDetailScreen(round: r),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        // 왼쪽: 골프장 이름 + 총 타수
                        Expanded(
                          child: Text(
                            "${r.club} (${r.scoreTotal})",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // 오른쪽: 코스 + 날짜
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              r.course,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r.prettyDate,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
