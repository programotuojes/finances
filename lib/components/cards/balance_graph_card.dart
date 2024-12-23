import 'package:finances/account/service.dart';
import 'package:finances/components/home_card.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/money.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money2/money2.dart';

// TODO allow to configure
final _barChartCurrency = CommonCurrencies().euro;

final _dateFormatter = DateFormat('MMM d');
final _listenables = Listenable.merge([
  TransactionService.instance,
  AccountService.instance,
]);

class BalanceGraphCard extends StatelessWidget {
  final DateTimeRange range;

  BalanceGraphCard({
    super.key,
    required DateTimeRange range,
  }) : range = DateUtils.datesOnly(range);

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
        child: LayoutBuilder(builder: (context, constraints) {
          double? horizontalInterval = range.duration.inMilliseconds / (constraints.maxWidth / 100).ceil();
          if (horizontalInterval == double.infinity) {
            horizontalInterval = null;
          }

          return ListenableBuilder(
            listenable: _listenables,
            builder: (context, child) {
              var spots = _getPeriodizedPoints().toList(growable: false);

              return LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: _xAxis,
                        interval: horizontalInterval,
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
                      getTooltipColor: (spot) => Theme.of(context).colorScheme.surfaceContainerHighest,
                      getTooltipItems: (spots) => spots.map((spot) {
                        var date = _dateFormatter.format(DateTime.fromMillisecondsSinceEpoch(spot.x.toInt()));
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(0)} ${_barChartCurrency.symbol}\n$date',
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
                    verticalInterval: horizontalInterval,
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
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _xAxis(value, meta) {
    if (value == meta.min || value == meta.max) {
      return const SizedBox.shrink();
    }

    String text;
    if (value == meta.max) {
      text = 'Today';
    } else {
      text = _dateFormatter.format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text),
    );
  }

  Widget _yAxis(double value, TitleMeta meta) {
    if (value == meta.max || value == meta.min) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('${meta.formattedValue} ${_barChartCurrency.symbol}'),
    );
  }

  Iterable<FlSpot> _getPeriodizedPoints() sync* {
    var initial = AccountService.instance.accounts
        .where((x) => x.currency.isoCode == _barChartCurrency.isoCode)
        .fold(Fixed.zero, (acc, x) => acc + x.initialMoney.amount);

    var moneyOnStart = _getTotalExpenditureOn(range.start);
    var runningTotal = initial + moneyOnStart;

    for (var i = 0; i <= range.duration.inDays; i++) {
      var date = range.start.add(Duration(days: i));
      runningTotal += _getExpenditureOnDate(date);

      yield FlSpot(
        date.millisecondsSinceEpoch.toDouble(),
        runningTotal.toDecimal().toDouble(),
      );
    }
  }

  Fixed _getExpenditureOnDate(DateTime date) {
    return TransactionService.instance.expenses
        .where((x) =>
            DateUtils.isSameDay(x.transaction.dateTime, date) &&
            x.transaction.account.currency.isoCode == _barChartCurrency.isoCode)
        .map((e) => e.signedMoney.amount)
        .fold(Fixed.zero, (acc, x) => acc + x);
  }

  Fixed _getTotalExpenditureOn(DateTime date) {
    return TransactionService.instance.expenses
        .where((x) =>
            x.transaction.dateTime.isBefore(date) &&
            x.transaction.account.currency.isoCode == _barChartCurrency.isoCode)
        .map((e) => e.signedMoney.amount)
        .fold(Fixed.zero, (acc, x) => acc + x);
  }
}
