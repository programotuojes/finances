import 'package:finances/budget/models/budget.dart';
import 'package:finances/utils/periodicity.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class BudgetService with ChangeNotifier {
  static final instance = BudgetService._ctor();

  final List<Budget> budgets = [];

  BudgetService._ctor();

  void add(Budget budget) {
    budgets.add(budget);
    notifyListeners();
  }

  void delete(Budget budget) {
    budgets.remove(budget);
    notifyListeners();
  }

  void update(
    Budget target, {
    String? name,
    Money? limit,
    Periodicity? period,
    List<BudgetCategory>? categories,
  }) {
    if (name != null) {
      target.name = name;
    }
    if (limit != null) {
      target.limit = limit;
    }
    if (period != null) {
      target.period = period;
    }
    if (categories != null) {
      target.categories = categories;
    }

    notifyListeners();
  }
}
