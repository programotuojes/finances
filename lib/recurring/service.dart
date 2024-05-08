import 'package:finances/main.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:flutter/foundation.dart';

class RecurringService with ChangeNotifier {
  static final instance = RecurringService._ctor();

  final List<RecurringModel> transactions = [];

  RecurringService._ctor();

  Iterable<RecurringModel> get activeTransactions => transactions.where((x) => x.nextDate() != null);

  void add(RecurringModel model) {
    transactions.add(model);
    _sort();
    notifyListeners();
  }

  void confirm(RecurringModel model) {
    final nextDate = model.nextDate();

    if (nextDate == null) {
      logger.w('Tried to confirm an already ended recurring transaction');
      return;
    }

    final transaction = Transaction(
      account: model.account,
      dateTime: nextDate,
      type: model.type,
    );

    final expense = Expense(
      transaction: transaction,
      money: model.money,
      category: model.category,
      description: model.description,
    );

    TransactionService.instance.add(
      transaction,
      expenses: [expense],
    );

    model.timesConfirmed++;
    _sort();
    notifyListeners();
  }

  void delete(RecurringModel model) {
    transactions.remove(model);
    notifyListeners();
  }

  void update(RecurringModel target, RecurringModel newValues) {
    target.account = newValues.account;
    target.category = newValues.category;
    target.money = newValues.money;
    target.description = newValues.description;
    target.periodicity = newValues.periodicity;
    target.interval = newValues.interval;
    target.from = newValues.from;
    target.until = newValues.until;
    target.type = newValues.type;
    _sort();
    notifyListeners();
  }

  void _sort() {
    transactions.sort((a, b) {
      final aDate = a.nextDate();
      final bDate = b.nextDate();

      if (aDate == null && bDate == null) {
        return 0;
      } else if (aDate == null) {
        return 1;
      } else if (bDate == null) {
        return -1;
      }

      return aDate.compareTo(bDate);
    });
  }
}
