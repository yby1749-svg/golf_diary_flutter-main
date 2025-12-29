// lib/screens/score_trend_chart.dart
//
// 스코어 추세 그래프 위젯
// - 최근 라운드의 점수 발전을 보여주는 곡선 그래프

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/round.dart';
import '../services/localizer.dart';

class ScoreTrendChart extends StatelessWidget {
  final List<Round> rounds;

  const ScoreTrendChart({
    super.key,
    required this.rounds,
  });

  @override
  Widget build(BuildContext context) {
    final lang = L10n.currentLang;

    if (rounds.isEmpty) {
      return const SizedBox.shrink();
    }

    // 최근 10개 라운드만 표시 (최신이 오른쪽)
    final displayRounds = rounds.take(10).toList().reversed.toList();

    // 차트 데이터 포인트 생성
    final spots = <FlSpot>[];
    for (int i = 0; i < displayRounds.length; i++) {
      spots.add(FlSpot(i.toDouble(), displayRounds[i].scoreTotal.toDouble()));
    }

    // Y축 범위 계산
    final scores = displayRounds.map((r) => r.scoreTotal).toList();
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final yMin = (minScore - 10).toDouble();
    final yMax = (maxScore + 10).toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10n.t('recent.scoreTrend', lang),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= displayRounds.length) {
                          return const Text('');
                        }
                        final round = displayRounds[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            '${round.date.month}/${round.date.day}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 10,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                    left: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                minX: 0,
                maxX: (displayRounds.length - 1).toDouble(),
                minY: yMin,
                maxY: yMax,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF4CAF50),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black87,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final round = displayRounds[touchedSpot.x.toInt()];
                        return LineTooltipItem(
                          '${round.club}\n${touchedSpot.y.toInt()}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildStatistics(displayRounds, lang),
        ],
      ),
    );
  }

  Widget _buildStatistics(List<Round> rounds, dynamic lang) {
    final scores = rounds.map((r) => r.scoreTotal).toList();
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    final best = scores.reduce((a, b) => a < b ? a : b);
    final latest = scores.last;
    final trend = latest - avg;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _statItem(
          label: L10n.t('recent.average', lang),
          value: avg.toStringAsFixed(1),
          color: Colors.blue,
        ),
        _statItem(
          label: L10n.t('recent.best', lang),
          value: best.toString(),
          color: Colors.green,
        ),
        _statItem(
          label: L10n.t('recent.trend', lang),
          value: trend > 0 ? '+${trend.toStringAsFixed(1)}' : trend.toStringAsFixed(1),
          color: trend > 0 ? Colors.red : Colors.green,
        ),
      ],
    );
  }

  Widget _statItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
