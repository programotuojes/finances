import 'package:finances/components/home_card.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BalanceGraphCard extends StatelessWidget {
  final List<ChartData> data = [
    ChartData(DateTime.now().subtract(const Duration(days: 7)), 145),
    ChartData(DateTime.now().subtract(const Duration(days: 6)), 159),
    ChartData(DateTime.now().subtract(const Duration(days: 5)), 224),
    ChartData(DateTime.now().subtract(const Duration(days: 4)), 140),
    ChartData(DateTime.now().subtract(const Duration(days: 3)), 137),
    ChartData(DateTime.now().subtract(const Duration(days: 2)), 150),
    ChartData(DateTime.now(), 100),
  ];

  BalanceGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      title: 'Balance',
      child: SizedBox(
        height: 200,
        child: SfCartesianChart(
          primaryXAxis: const DateTimeAxis(),
          series: <SplineSeries<ChartData, DateTime>>[
            SplineSeries<ChartData, DateTime>(
              dataSource: data,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
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
