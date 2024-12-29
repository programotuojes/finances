import 'dart:math';

import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/utils/db.dart';
import 'package:flutter/foundation.dart';
import 'package:money2/money2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountService with ChangeNotifier {
  static final instance = AccountService._ctor();
  late SharedPreferences _storage;
  List<Account> _accounts = [];
  late Account _lastSelection;

  Account? _selected;
  AccountService._ctor();

  Iterable<Account> get accounts => _accounts;
  Account? get filter => _selected;
  Account get lastSelection => _lastSelection;

  Future<Account> add({
    required String name,
    required Money initialMoney,
  }) async {
    var account = Account(name: name, initialMoney: initialMoney);

    account.id = await database.insert(
      'accounts',
      account.toMap(),
    );

    await setLastSelection(account);

    _accounts.add(account);

    notifyListeners();

    return account;
  }

  void filterBy(Account account) {
    if (_selected == account) {
      _selected = null;
    } else {
      _selected = account;
    }
    notifyListeners();
  }

  Future<void> initialize() async {
    var dbAccounts = await database.query('accounts');
    _accounts = dbAccounts.map((e) => Account.fromTable(e)).toList();

    _storage = await SharedPreferences.getInstance();
    var lastSelectionId = _storage.getInt('lastSelectionId');
    var lastSelection = accounts.firstWhereOrNull((element) => element.id == lastSelectionId);

    if (lastSelection != null) {
      _lastSelection = lastSelection;
    }

    notifyListeners();
  }

  Future<void> setLastSelection(Account account) async {
    await _storage.setInt('lastSelectionId', account.id!);
    _lastSelection = account;
  }

  Future<void> update(
    Account target, {
    String? name,
    Money? initialMoney,
  }) async {
    await _updateExpenseIfNeeded(target.id!, target.currency, initialMoney?.currency);

    target.name = name ?? target.name;
    target.initialMoney = initialMoney ?? target.initialMoney;

    await database.update('accounts', target.toMap(), where: 'id = ?', whereArgs: [target.id]);

    await setLastSelection(target);

    notifyListeners();
  }

  Future<void> _updateExpenseIfNeeded(int accountId, Currency oldCurrency, Currency? newCurrency) async {
    if (newCurrency == null) {
      return;
    }

    var oldDigits = oldCurrency.decimalDigits;
    var newDigits = newCurrency.decimalDigits;

    if (oldDigits > newDigits) {
      var divisor = pow(10, oldDigits - newDigits);
      // TODO needs to be changed after multi-currency transfers
      await database.rawUpdate('''
      UPDATE expenses
      SET moneyMinor = moneyMinor / ?
      WHERE id IN (
        SELECT expenses.id
        FROM expenses
        JOIN transactions ON transactions.id = expenses.transactionId
        WHERE transactions.accountId = ?
      )
    ''', [divisor, accountId]);
    } else if (oldDigits < newDigits) {
      var multiplier = pow(10, newDigits - oldDigits);
      await database.rawUpdate('''
      UPDATE expenses
      SET moneyMinor = moneyMinor * ?
      WHERE id IN (
        SELECT expenses.id
        FROM expenses
        JOIN transactions ON transactions.id = expenses.transactionId
        WHERE transactions.accountId = ?
      )
    ''', [multiplier, accountId]);
    }
  }
}
