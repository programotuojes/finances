import 'package:finances/expense/models/expense.dart';
import 'package:flutter/foundation.dart';

class ExpenseService with ChangeNotifier {
  static final ExpenseService instance = ExpenseService._ctor();
  ExpenseService._ctor();

  List<Expense> expenses = List.empty(growable: true);

  void add(Expense expense) {
    expenses.add(expense);

    // TODO don't sort on every insert
    expenses.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    notifyListeners();
  }
}
