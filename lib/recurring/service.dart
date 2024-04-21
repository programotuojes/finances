import 'package:finances/account/service.dart';
import 'package:finances/category/service.dart';
import 'package:finances/extensions/money.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:flutter/foundation.dart';

final _r1 = RecurringModel(
  account: swedbank,
  category: spotify,
  money: '2.2'.toMoney()!,
  description: null,
  periodicity: Periodicity.month,
  interval: 1,
  from: DateTime.now(),
  until: null,
  type: TransactionType.expense,
);
final _r2 = RecurringModel(
  account: revolut,
  category: transport,
  money: '120'.toMoney()!,
  description: 'Insurance',
  periodicity: Periodicity.year,
  interval: 1,
  from: DateTime.now(),
  until: DateTime.now().add(const Duration(days: 365 * 2)),
  type: TransactionType.expense,
);
final _r3 = RecurringModel(
  account: swedbank,
  category: food,
  money: '6'.toMoney()!,
  description: 'Lunch delivery',
  periodicity: Periodicity.day,
  interval: 2,
  from: DateTime.now(),
  until: null,
  type: TransactionType.expense,
);
final _r4 = RecurringModel(
  account: swedbank,
  category: entertainment,
  money: '10'.toMoney()!,
  description: 'Netfilx',
  periodicity: Periodicity.month,
  interval: 1,
  from: DateTime.now().subtract(const Duration(days: 10)),
  until: null,
  type: TransactionType.expense,
);

class RecurringService with ChangeNotifier {
  static final instance = RecurringService._ctor();

  final List<RecurringModel> transactions;

  RecurringService._ctor() : transactions = [_r1, _r2, _r3, _r4] {
    confirm(_r1);
    confirm(_r2);
    _sort();
  }

  Iterable<RecurringModel> get activeTransactions =>
      transactions.where((x) => x.nextDate(DateTime.now()) != null);

  void add(RecurringModel model) {
    transactions.add(model);
    _sort();
    notifyListeners();
  }

  void confirm(RecurringModel model) {
    final nextDate = model.nextDate(DateTime.now());

    if (nextDate == null) {
      print('Tried to confirm an already ended recurring transaction');
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
    _sort(basedOn: nextDate);
    notifyListeners();
  }

  void delete(RecurringModel model) {
    transactions.remove(model);
    notifyListeners();
  }

  void update(RecurringModel model, RecurringModel newValues) {
    model.account = newValues.account;
    model.category = newValues.category;
    model.money = newValues.money;
    model.description = newValues.description;
    model.periodicity = newValues.periodicity;
    model.interval = newValues.interval;
    model.from = newValues.from;
    model.until = newValues.until;
    model.type = newValues.type;
    _sort();
    notifyListeners();
  }

  void _sort({DateTime? basedOn}) {
    final now = basedOn ?? DateTime.now();
    transactions.sort((a, b) {
      final aDate = a.nextDate(now);
      final bDate = b.nextDate(now);

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
