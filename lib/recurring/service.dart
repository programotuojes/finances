import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/main.dart';
import 'package:finances/recurring/models/recurring_model.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/db.dart';
import 'package:finances/utils/periodicity.dart';
import 'package:flutter/foundation.dart';
import 'package:money2/money2.dart';

class RecurringService with ChangeNotifier {
  static final instance = RecurringService._ctor();

  final List<RecurringModel> transactions = [];

  RecurringService._ctor();

  Iterable<RecurringModel> get activeTransactions => transactions.where((x) => x.nextDate() != null);

  Future<void> add({
    required Account account,
    required CategoryModel category,
    required Money money,
    required String? description,
    required Periodicity period,
    required int interval,
    required DateTime from,
    required DateTime? until,
    required TransactionType type,
  }) async {
    var model = RecurringModel(
      account: account,
      category: category,
      money: money,
      description: description,
      periodicity: period,
      interval: interval,
      from: from,
      until: until,
      type: type,
    );

    model.id = await database.insert('recurring', model.toMap());

    transactions.add(model);

    _sort();
    notifyListeners();
  }

  Future<void> confirm(RecurringModel model) async {
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

    await TransactionService.instance.add(
      transaction,
      expenses: [expense],
    );

    model.timesConfirmed++;

    await database.rawUpdate(
      'update recurring set timesConfirmed = ? where id = ?',
      [model.timesConfirmed, model.id],
    );

    _sort();
    notifyListeners();
  }

  Future<void> delete(RecurringModel model) async {
    await database.delete('recurring', where: 'id = ?', whereArgs: [model.id]);

    transactions.remove(model);

    notifyListeners();
  }

  Future<void> init() async {
    var dbRecurring = await database.query('recurring');
    transactions.addAll(dbRecurring.map((e) => RecurringModel.fromMap(e)));
  }

  Future<void> update(
    RecurringModel target, {
    Account? account,
    CategoryModel? category,
    Money? money,
    String? description,
    Periodicity? period,
    int? interval,
    DateTime? from,
    DateTime? until,
    TransactionType? type,
  }) async {
    target.account = account ?? target.account;
    target.category = category ?? target.category;
    target.money = money ?? target.money;
    target.description = description ?? target.description;
    target.periodicity = period ?? target.periodicity;
    target.interval = interval ?? target.interval;
    target.from = from ?? target.from;
    target.until = until ?? target.until;
    target.type = type ?? target.type;

    await database.update('recurring', target.toMap(), where: 'id = ?', whereArgs: [target.id]);

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
