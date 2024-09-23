import 'package:finances/category/models/category.dart';
import 'package:finances/components/category_icon.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/date.dart';
import 'package:finances/utils/money.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class PieChartLayer {
  final DateTimeRange _dateRangeFilter;
  final CategoryModel _parent;
  Money _total = zeroEur;
  Map<CategoryModel, Money> _categoryTotals = {};

  Money get total => _total;
  Map<CategoryModel, Money> get categoryTotals => _categoryTotals;

  PieChartLayer({
    required DateTimeRange dateRangeFilter,
    required CategoryModel parent,
  })  : _dateRangeFilter = dateRangeFilter,
        _parent = parent {
    final categorySums = <MapEntry<CategoryModel, Money>>[];

    for (final category in parent.children) {
      final categoryTotal = TransactionService.instance.expenses
          .where((expense) =>
              expense.transaction.type == TransactionType.expense &&
              expense.transaction.dateTime.isIn(_dateRangeFilter) &&
              expense.category.isNestedChildOf(category))
          .map((e) => e.money)
          .fold(zeroEur, (acc, x) => acc + x);

      if (categoryTotal.isZero) {
        continue;
      }

      categorySums.add(MapEntry(category, categoryTotal));
      _total += categoryTotal;
    }

    final parentTotal = TransactionService.instance.expenses
        .where((expense) =>
            expense.transaction.type == TransactionType.expense &&
            expense.transaction.dateTime.isIn(_dateRangeFilter) &&
            expense.category == parent)
        .map((e) => e.money)
        .fold(zeroEur, (acc, x) => acc + x);

    if (!parentTotal.isZero) {
      categorySums.add(MapEntry(parent, parentTotal));
      _total += parentTotal;
    }

    categorySums.sort((a, b) => b.value.compareTo(a.value));
    _categoryTotals = Map.fromEntries(categorySums);
  }

  Iterable<PieChartSectionData> getSections({
    required int clickedIndex,
    required int hoveredIndex,
  }) sync* {
    var index = 0;

    for (var entry in _categoryTotals.entries) {
      var category = entry.key;
      var money = entry.value;

      if (money.isZero) {
        continue;
      }

      var showIcon = money.dividedBy(total) > 0.05;
      var radius = 40.0;

      if (index == clickedIndex) {
        radius += 10;
      }

      if (index == hoveredIndex) {
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

  Widget getCenterText({
    required int clickedIndex,
    required int hoveredIndex,
  }) {
    String title, amount;
    var index = hoveredIndex != -1 ? hoveredIndex : clickedIndex;

    if (index != -1 && index < _categoryTotals.length) {
      title = _categoryTotals.keys.elementAt(index).name;
      amount = _categoryTotals.values.elementAt(index).toString();
    } else {
      title = 'Total';
      amount = total.toString();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TODO handle long title names
        Text(title),
        Text(amount, textScaler: const TextScaler.linear(1.5)),
      ],
    );
  }

  PieChartLayer createNewLayer(int index) {
    return PieChartLayer(
      dateRangeFilter: _dateRangeFilter,
      parent: _categoryTotals.keys.elementAt(index),
    );
  }

  bool canClick(int index) {
    if (index < 0) {
      return false;
    }

    final category = _categoryTotals.keys.elementAt(index);
    return category != _parent && category.children.isNotEmpty;
  }
}
