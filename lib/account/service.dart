import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/utils/db.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/foundation.dart';
import 'package:money2/money2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountService with ChangeNotifier {
  static final instance = AccountService._ctor();
  late SharedPreferences _storage;
  List<Account> _accounts = [];
  late Account _lastSelection;

  Account? _selected;
  bool needsInput = false;
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

    if (_accounts.isEmpty) {
      var account = Account(name: '', initialMoney: zeroEur);
      account.id = await database.insert('accounts', account.toMap());
      _accounts.add(account);
    }

    if (_accounts.first.name == '') {
      needsInput = true;
    }

    _storage = await SharedPreferences.getInstance();
    var lastSelectionId = _storage.getInt('lastSelectionId');
    var lastSelection = accounts.firstWhereOrNull((element) => element.id == lastSelectionId);

    if (lastSelection != null) {
      _lastSelection = lastSelection;
    } else {
      _lastSelection = accounts.first;
      await _storage.setInt('lastSelectionId', _lastSelection.id!);
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
    target.name = name ?? target.name;
    target.initialMoney = initialMoney ?? target.initialMoney;

    await database.update('accounts', target.toMap(), where: 'id = ?', whereArgs: [target.id]);

    await setLastSelection(target);

    notifyListeners();
  }
}
