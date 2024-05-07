import 'package:finances/category/models/category.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/date.dart';
import 'package:finances/utils/money.dart';
import 'package:finances/utils/periodicity.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class Budget {
  String name;
  Money limit;
  Periodicity period;
  List<BudgetCategory> categories;

  Budget({
    required this.name,
    required this.limit,
    required this.period,
    required this.categories,
  });

  DateTimeRange currentRange(DateTime now) {
    var start = switch (period) {
      Periodicity.day => DateTime(now.year, now.month, now.day),
      Periodicity.week => DateUtils.dateOnly(now.subtract(Duration(days: now.weekday - 1))),
      Periodicity.month => DateTime(now.year, now.month),
      Periodicity.year => DateTime(now.year),
    };

    var end = switch (period) {
      Periodicity.day => DateTime(start.year, start.month, start.day + 1, 0, 0, -1),
      Periodicity.week => DateTime(start.year, start.month, start.day + 7, 0, 0, -1),
      Periodicity.month => DateTime(start.year, start.month + 1, 0, 0, 0, -1),
      Periodicity.year => DateTime(start.year + 1, 1, 1, 0, 0, -1),
    };

    return DateTimeRange(start: start, end: end);
  }

  Money usedThisPeriod(DateTime now) {
    var range = currentRange(now);

    Money total = zeroEur;

    for (var budget in categories) {
      total += TransactionService.instance.expenses
          .where((expense) =>
              expense.transaction.dateTime.isIn(range) &&
              expense.transaction.type == TransactionType.expense &&
              _categoryMatches(expense.category, budget))
          .map((expense) => expense.money)
          .fold(zeroEur, (acc, x) => acc + x);
    }

    return total;
  }

  bool _categoryMatches(CategoryModel expenseCategory, BudgetCategory budgetCategory) {
    if (budgetCategory.includeChildren) {
      return expenseCategory.isNestedChildOf(budgetCategory.category);
    }

    return expenseCategory == budgetCategory.category;
  }
}

class BudgetCategory {
  CategoryModel category;
  bool includeChildren;

  BudgetCategory({
    required this.category,
    required this.includeChildren,
  });

  BudgetCategory copy() {
    return BudgetCategory(
      category: category,
      includeChildren: includeChildren,
    );
  }
}
