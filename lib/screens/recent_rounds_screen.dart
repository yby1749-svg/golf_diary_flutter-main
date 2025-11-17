// lib/screens/recent_rounds_screen.dart
//
// 최근 라운드 목록 화면

import 'package:flutter/material.dart';

import '../models/round.dart';
import 'round_detail_screen.dart';

class RecentRoundsScreen extends StatelessWidget {
  const RecentRoundsScreen({Key? key}) : super(key: key);

  String _formatDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y.$m.$d';
  }

  @override
  Widget build(BuildContext context) {
    final rounds = GlobalRounds.rounds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('최근 라운드'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: rounds.isEmpty
            ? const Center(
                child: Text('아직 저장된 라운드가 없습니다.'),
              )
            : ListView.separated(
                itemCount: rounds.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final round = rounds[index];
                  final dateText = _formatDate(round.date);
                  final scoreText =
                      '${round.totalScore} (${round.diffLabel})';

                  return ListTile(
                    title: Text(
                      round.clubName.isEmpty
                          ? '골프장 미입력'
                          : round.clubName,
                    ),
                    subtitle: Text(
                      '${round.courseName.isEmpty ? '코스 미입력' : round.courseName} · $dateText',
                    ),
                    trailing: Text(
                      scoreText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoundDetailScreen(round: round),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
