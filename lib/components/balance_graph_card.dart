import 'package:finances/account/service.dart';
import 'package:finances/components/home_card.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/money.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money2/money2.dart';

final _dateFormatter = DateFormat('MMM d');
const _interval = 5.0 * Duration.millisecondsPerDay;
const _days = 30;
final _listenables = Listenable.merge([
  TransactionService.instance,
  AccountService.instance,
]);

class BalanceGraphCard extends StatelessWidget {
  const BalanceGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    var borderSide = BorderSide(
      color: Theme.of(context).colorScheme.onSurface,
    );

    var gridLine = FlLine(
      color: Theme.of(context).colorScheme.outline,
      dashArray: [10, 10],
      strokeWidth: 0.3,
    );

    return HomeCard(
      title: 'Balance',
      padding: const EdgeInsets.only(right: 40),
      child: SizedBox(
        height: 200,
        child: ListenableBuilder(
          listenable: _listenables,
          builder: (context, child) {
            var spots = _getPeriodizedPoints().toList();

            return LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: _xAxis,
                      interval: _interval,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 70,
                      getTitlesWidget: _yAxis,
                    ),
                  ),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) =>
                        Theme.of(context).colorScheme.surfaceVariant,
                    getTooltipItems: (spots) => spots.map((spot) {
                      var date = _dateFormatter.format(
                          DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()));
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(0)} €\n$date',
                        Theme.of(context).textTheme.bodyMedium!,
                      );
                    }).toList(),
                  ),
                ),
                borderData: FlBorderData(
                  border: Border(
                    left: borderSide,
                    bottom: borderSide,
                  ),
                ),
                gridData: FlGridData(
                  verticalInterval: _interval,
                  getDrawingHorizontalLine: (value) => gridLine,
                  getDrawingVerticalLine: (value) => gridLine,
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    preventCurveOverShooting: true,
                    dotData: const FlDotData(show: false),
                    color: Theme.of(context).colorScheme.primary,
                    spots: spots,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _xAxis(value, meta) {
    if (value == meta.min) {
      return const SizedBox.shrink();
    }

    String text;
    if (value == meta.max) {
      text = 'Today';
    } else {
      text = _dateFormatter
          .format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text),
    );
  }

  Widget _yAxis(value, meta) {
    if (value == meta.max || value == meta.min) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('${meta.formattedValue} €'),
    );
  }

  Iterable<FlSpot> _getPeriodizedPoints() sync* {
    var runningTotal = AccountService.instance.accounts
        .fold(zeroEur, (acc, x) => acc + x.initialMoney);

    var graphStartDate = DateUtils.dateOnly(DateTime.now())
        .subtract(const Duration(days: _days - 1));

    for (var i = 0; i <= _days; i++) {
      var date = graphStartDate.add(Duration(days: i));

      yield FlSpot(
        date.millisecondsSinceEpoch.toDouble(),
        runningTotal.amount.toDecimal().toDouble(),
      );

      runningTotal += _getExpenditureOnDate(date);
    }
  }

  Money _getExpenditureOnDate(DateTime date) {
    return TransactionService.instance.expenses
        .where((x) => DateUtils.isSameDay(x.transaction.dateTime, date))
        .map((e) => e.signedMoney)
        .fold(zeroEur, (acc, x) => acc + x);
  }
}
