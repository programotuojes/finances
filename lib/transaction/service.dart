import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:flutter/foundation.dart';

class TransactionService with ChangeNotifier {
  static final TransactionService instance = TransactionService._ctor();
  TransactionService._ctor();

  List<Transaction> transactions = List.empty(growable: true);
  Iterable<Expense> get expenses sync* {
    for (final transaction in transactions) {
      for (final expense in transaction.expenses) {
        yield expense;
      }
    }
  }

  void add(Transaction transaction) {
    transactions.add(transaction);

    // TODO don't sort on every insert
    transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    notifyListeners();
  }
}
