import 'package:collection/collection.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/components/category_icon.dart';
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
  final _historyStack = [CategoryService.instance.rootCategory];
  var _hoveredIndex = -1;
  var _clickedIndex = -1;

  @override
  Widget build(BuildContext context) {
    var categoryWithTotals = _historyStack.last.children.groupFoldBy<CategoryModel, Money>(
      (category) => category,
      (total, category) => (total ?? zeroEur) + _getTotalOfCategory(category),
    )..removeWhere((key, value) => value.isZero);
    var total = categoryWithTotals.values.fold(zeroEur, (acc, x) => acc + x);
    var sections = _getSections(categoryWithTotals, total).toList();

    return GestureDetector(
      onTap: () {
        setState(() {
          _resetIndices();
        });
      },
      child: HomeCard(
        title: 'Expenses by category',
        crossAxisAlignment: CrossAxisAlignment.stretch,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                if (sections.isEmpty)
                  Center(
                    child: Container(
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
                    ),
                  )
                else
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _getCenter(categoryWithTotals, total),
                      SizedBox(
                        height: 220,
                        width: 220,
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              mouseCursorResolver: (event, response) {
                                if (response?.touchedSection?.touchedSection != null) {
                                  return SystemMouseCursors.click;
                                }

                                return MouseCursor.defer;
                              },
                              touchCallback: (event, pieTouchResponse) {
                                var index = pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1;

                                setState(() {
                                  if (event is FlTapUpEvent) {
                                    _clickedIndex = index;
                                  }

                                  if (!event.isInterestedForInteractions) {
                                    index = -1;
                                  }

                                  _hoveredIndex = index;
                                });
                              },
                            ),
                            centerSpaceRadius: 70,
                            sections: sections,
                          ),
                        ),
                      ),
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
            ),
            if (_historyStack.length > 1)
              Align(
                alignment: Alignment.topLeft,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _clickedIndex = -1;
                      if (_historyStack.length > 1) {
                        _historyStack.removeLast();
                      }
                    });
                  },
                  child: const Text('Go back'),
                ),
              ),
            if (_clickedIndex != -1)
              Align(
                alignment: Alignment.topRight,
                child: OutlinedButton(
                  onPressed: () {
                    var clickedCategory = categoryWithTotals.keys.elementAt(_clickedIndex);
                    setState(() {
                      _clickedIndex = -1;
                      _historyStack.add(clickedCategory);
                    });
                  },
                  child: const Text('Go deeper'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Listenable.merge([CategoryService.instance, TransactionService.instance]).addListener(() {
      if (!mounted) {
        return;
      }

      setState(() {
        _resetIndices();
        _historyStack
          ..clear()
          ..add(CategoryService.instance.rootCategory);
      });
    });
  }

  Widget _getCenter(
    Map<CategoryModel, Money> categoryWithTotals,
    Money total,
  ) {
    String title, amount;
    var index = _hoveredIndex != -1 ? _hoveredIndex : _clickedIndex;

    if (index != -1 && index < categoryWithTotals.length) {
      title = categoryWithTotals.keys.elementAt(index).name;
      amount = categoryWithTotals.values.elementAt(index).toString();
    } else {
      title = 'Total';
      amount = total.toString();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TODO handle long title names
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

    for (var entry in categoryWithTotals.entries.sorted((a, b) => b.value.compareTo(a.value))) {
      var category = entry.key;
      var money = entry.value;

      if (money.isZero) {
        continue;
      }

      var showIcon = money.dividedBy(total) > 0.05;
      var radius = 40.0;

      if (index == _clickedIndex) {
        radius += 10;
      }

      if (index == _hoveredIndex) {
        radius += 5;
      }

      yield PieChartSectionData(
        value: money.amount.toDecimal().toDouble(),
        title: category.name,
        color: category.color,
        radius: radius,
        showTitle: false,
        badgeWidget: showIcon ? CategoryIcon(icon: category.icon, backgroundColor: category.color) : null,
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

  void _resetIndices() {
    _hoveredIndex = -1;
    _clickedIndex = -1;
  }
}
