import 'package:collection/collection.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/home_card.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/date.dart';
import 'package:finances/utils/money.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class PieChartCard extends StatefulWidget {
  final DateTimeRange dateRange;

  const PieChartCard({
    super.key,
    required this.dateRange,
  });

  @override
  State<PieChartCard> createState() => _PieChartCardState();
}

class _PieChartCardState extends State<PieChartCard> {
  var _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return HomeCard(
      title: 'Expenses by category',
      child: ListenableBuilder(
          listenable: Listenable.merge([
            CategoryService.instance,
            TransactionService.instance,
          ]),
          builder: (context, child) {
            var categoryWithTotals = CategoryService.instance.root.children.groupFoldBy<CategoryModel, Money>(
              (category) => category,
              (total, category) => (total ?? zeroEur) + _getTotalOfCategory(category),
            )..removeWhere((key, value) => value.isZero);
            var total = categoryWithTotals.values.fold(zeroEur, (acc, x) => acc + x);
            var sections = _getSections(categoryWithTotals, total).toList();

            if (sections.isEmpty) {
              return Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 40,
                    color: Colors.grey,
                  ),
                ),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'No expenses found',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          centerSpaceRadius: 70,
                          sections: sections,
                        ),
                      ),
                    ),
                    _getCenter(categoryWithTotals, total),
                  ],
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    for (var section in sections)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: section.color,
                              borderRadius: const BorderRadius.all(Radius.circular(4)),
                            ),
                            width: 16,
                            height: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(section.title),
                        ],
                      ),
                  ],
                )
              ],
            );
          }),
    );
  }

  Widget _getCenter(
    Map<CategoryModel, Money> categoryWithTotals,
    Money total,
  ) {
    String title, amount;

    if (_touchedIndex != -1) {
      title = categoryWithTotals.keys.elementAt(_touchedIndex).name;
      amount = categoryWithTotals.values.elementAt(_touchedIndex).toString();
    } else {
      title = 'Total';
      amount = total.toString();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        Text(
          amount,
          textScaler: const TextScaler.linear(1.5),
        ),
      ],
    );
  }

  Iterable<PieChartSectionData> _getSections(
    Map<CategoryModel, Money> categoryWithTotals,
    Money total,
  ) sync* {
    var index = 0;

    for (var entry in categoryWithTotals.entries) {
      var category = entry.key;
      var money = entry.value;

      if (money.isZero) {
        continue;
      }

      var showIcon = money.dividedBy(total) > 0.05;

      yield PieChartSectionData(
        value: money.amount.toDecimal().toDouble(),
        title: category.name,
        color: category.color,
        radius: index == _touchedIndex ? 50 : 40,
        showTitle: false,
        badgeWidget: showIcon
            ? Icon(
                category.icon,
                color: category.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              )
            : null,
        // badgePositionPercentageOffset: 0.9,
      );

      index++;
    }
  }

  Money _getTotalOfCategory(CategoryModel category) {
    return TransactionService.instance.expenses
        .where((expense) =>
            expense.transaction.type == TransactionType.expense &&
            expense.transaction.dateTime.isIn(widget.dateRange) &&
            expense.category.isNestedChildOf(category))
        .map((e) => e.money)
        .fold(zeroEur, (acc, x) => acc + x);
  }
}
