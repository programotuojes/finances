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
  money: '2.2'.toMoney('EUR')!,
  description: null,
  periodicity: Periodicity.month,
  interval: 1,
  from: DateTime.now(),
  until: null,
);
final _r2 = RecurringModel(
  account: revolut,
  category: transport,
  money: '120'.toMoney('EUR')!,
  description: 'Insurance',
  periodicity: Periodicity.year,
  interval: 1,
  from: DateTime.now(),
  until: DateTime.now().add(const Duration(days: 365 * 2)),
);
final _r3 = RecurringModel(
  account: swedbank,
  category: food,
  money: '6'.toMoney('EUR')!,
  description: 'Lunch delivery',
  periodicity: Periodicity.day,
  interval: 2,
  from: DateTime.now(),
  until: null,
);
final _r4 = RecurringModel(
  account: swedbank,
  category: entertainment,
  money: '10'.toMoney('EUR')!,
  description: 'Netfilx',
  periodicity: Periodicity.month,
  interval: 1,
  from: DateTime.now().subtract(const Duration(days: 10)),
  until: null,
);

class RecurringService with ChangeNotifier {
  static final instance = RecurringService._ctor();
  final List<RecurringModel> transactions;

  RecurringService._ctor() : transactions = [_r1, _r2, _r3, _r4] {
    confirm(_r1);
    confirm(_r2);
  }

  void confirm(RecurringModel model) {
    final dateTime = model.nextDate(DateTime.now());

    if (dateTime == null) {
      print('Tried to confirm an already ended recurring transaction');
      return;
    }

    final transaction = Transaction(
      account: model.account,
      dateTime: dateTime,
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
      attachments: [],
    );

    model.timesConfirmed++;
    transactions.sort((a, b) {
      final aDate = a.nextDate(dateTime);
      final bDate = b.nextDate(dateTime);

      if (aDate == null) {
        return -1;
      } else if (bDate == null) {
        return 1;
      }

      if (aDate.isBefore(bDate)) {
        return -1;
      } else if (aDate.isAfter(bDate)) {
        return 1;
      } else {
        return 0;
      }
    });
    notifyListeners();
  }
}
