import 'package:finances/budget/models/budget.dart';
import 'package:finances/utils/db.dart';
import 'package:finances/utils/periodicity.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

class BudgetService with ChangeNotifier {
  static final instance = BudgetService._ctor();

  List<Budget> _budgets = [];

  BudgetService._ctor();

  Iterable<Budget> get budgets => _budgets;

  Future<void> init() async {
    var dbBudgetCategories = await database.query('budgetCategories');
    var budgetCategories = dbBudgetCategories.map((e) => BudgetCategory.fromMap(e)).toList();

    var dbBudgets = await database.query('budgets');
    _budgets = dbBudgets.map((e) => Budget.fromMap(e, budgetCategories)).toList();

    notifyListeners();
  }

  Future<void> add(Budget budget) async {
    _budgets.add(budget);

    budget.id = await database.insert('budgets', budget.toMap());

    var batch = database.batch();
    for (var i in budget.categories) {
      i.budgetId = budget.id;
      batch.insert('budgetCategories', i.toMap());
    }
    var ids = await batch.commit();

    for (var i = 0; i < budget.categories.length; i++) {
      budget.categories[i].id = ids[i] as int;
    }

    notifyListeners();
  }

  Future<void> delete(Budget budget) async {
    _budgets.remove(budget);

    await database.delete('budgets', where: 'id = ?', whereArgs: [budget.id]);

    notifyListeners();
  }

  Future<void> update(
    Budget target, {
    String? name,
    Money? limit,
    Periodicity? period,
    List<BudgetCategory>? budgetCategories,
  }) async {
    target.name = name ?? target.name;
    target.limit = limit ?? target.limit;
    target.period = period ?? target.period;

    await database.update('budgets', target.toMap(), where: 'id = ?', whereArgs: [target.id]);

    if (budgetCategories != null) {
      for (var i in budgetCategories) {
        i.budgetId = target.id;

        var exists = target.categories.any((element) => element.id == i.id);

        if (exists) {
          await database.update('budgetCategories', i.toMap(), where: 'id = ?', whereArgs: [i.id]);
        } else {
          i.id = await database.insert('budgetCategories', i.toMap());
        }
      }

      // Delete removed elements
      for (var old in target.categories) {
        var oldExists = budgetCategories.any((element) => element.id == old.id);
        if (!oldExists) {
          await database.delete('budgetCategories', where: 'id = ?', whereArgs: [old.id]);
        }
      }

      target.categories = budgetCategories;
    }

    notifyListeners();
  }
}
