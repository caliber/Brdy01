import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/brdy_colors.dart';

class DifferentialLineChart extends StatelessWidget {
  const DifferentialLineChart({super.key, required this.spots});

  final List<FlSpot> spots;

  @override
  Widget build(BuildContext context) {
    if (spots.length < 2) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'NOT ENOUGH DATA',
            style: GoogleFonts.sometypeMono(
              color: context.brdyColors.onSurfaceMuted,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          backgroundColor: context.brdyColors.background,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: context.brdyColors.divider,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: GoogleFonts.sometypeMono(
                      fontSize: 10,
                      color: context.brdyColors.onSurfaceMuted,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: context.brdyColors.accent,
              barWidth: 2,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotCirclePainter(
                  radius: 3,
                  color: context.brdyColors.accent,
                  strokeColor: context.brdyColors.background,
                  strokeWidth: 1.5,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: context.brdyColors.accent.withOpacity(0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
