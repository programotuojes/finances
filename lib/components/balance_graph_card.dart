import 'package:finances/components/home_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _dateFormatter = DateFormat('MMM d');

class BalanceGraphCard extends StatelessWidget {
  final List<ChartData> data = [
    ChartData(DateTime.now().subtract(const Duration(days: 22)), 145),
    ChartData(DateTime.now().subtract(const Duration(days: 12)), 159),
    ChartData(DateTime.now().subtract(const Duration(days: 5)), 224),
    ChartData(DateTime.now().subtract(const Duration(days: 4)), 140),
    ChartData(DateTime.now().subtract(const Duration(days: 3)), 137),
    ChartData(DateTime.now().subtract(const Duration(days: 2)), 150),
    ChartData(DateTime.now().subtract(const Duration(days: 1)), 150),
    ChartData(DateTime.now(), 100),
  ];

  BalanceGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    var borderSide = BorderSide(
      color: Theme.of(context).colorScheme.onSurface,
    );

    var gridLine = FlLine(
      color: Theme.of(context).colorScheme.outline,
      dashArray: [10, 10],
      strokeWidth: 0.5,
    );

    var minDate = data.first.x.millisecondsSinceEpoch;
    var maxDate = data.last.x.millisecondsSinceEpoch;
    var interval =
        (maxDate - minDate) / (MediaQuery.of(context).size.width / 100);

    return HomeCard(
      title: 'Balance',
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.max || value == meta.min) {
                      return const SizedBox.shrink();
                    }

                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text('${meta.formattedValue} €'),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: interval,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value == meta.max || value == meta.min) {
                      return const SizedBox.shrink();
                    }
                    var dateTime =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    var formatted = _dateFormatter.format(dateTime);

                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(formatted),
                    );
                  },
                ),
              ),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
            ),
            borderData: FlBorderData(
              border: Border(
                left: borderSide,
                bottom: borderSide,
              ),
            ),
            gridData: FlGridData(
              verticalInterval: interval,
              getDrawingHorizontalLine: (value) => gridLine,
              getDrawingVerticalLine: (value) => gridLine,
            ),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                preventCurveOverShooting: true,
                dotData: const FlDotData(show: false),
                color: Theme.of(context).colorScheme.primary,
                spots: [
                  for (var point in data)
                    FlSpot(point.x.millisecondsSinceEpoch.toDouble(), point.y),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);

  final DateTime x;
  final double y;
}
