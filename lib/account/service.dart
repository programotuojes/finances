import 'package:finances/account/models/account.dart';
import 'package:finances/main.dart';
import 'package:finances/utils/db.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/foundation.dart';
import 'package:money2/money2.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Only used as a placeholder to pass null checks.
final _initialAccount = Account(
  id: -1,
  name: '',
  initialMoney: zeroEur,
);

class AccountService with ChangeNotifier {
  static final instance = AccountService._ctor();
  late final SharedPreferences storage;

  final List<Account> accounts = [];
  Account lastSelection = _initialAccount;
  Account? _selected;

  AccountService._ctor();

  Future<void> initialize() async {
    var accounts = await Db.instance.db.query('accounts');
    this.accounts.addAll(accounts.map((e) => Account.fromTable(e)));

    storage = await SharedPreferences.getInstance();
    var lastSelectionId = storage.getInt('lastSelectionId');
    if (lastSelectionId != null) {
      lastSelection = this.accounts.firstWhere(
            (account) => account.id == lastSelectionId,
            orElse: () => _initialAccount,
          );
    }
  }

  Account? get filter => _selected;

  Future<void> add({
    required String name,
    required Money initialMoney,
  }) async {
    var account = Account(name: name, initialMoney: initialMoney);

    account.id = await Db.instance.db.insert(
      'accounts',
      account.toMap(),
    );

    accounts.add(account);
    logger.t('Added account', error: account.toMap());

    notifyListeners();
  }

  void filterBy(Account account) {
    if (_selected == account) {
      _selected = null;
    } else {
      _selected = account;
    }
    notifyListeners();
  }

  Future<void> update(
    Account target, {
    String? name,
    Money? initialMoney,
  }) async {
    target.name = name ?? target.name;
    target.initialMoney = initialMoney ?? target.initialMoney;

    await Db.instance.db.update(
      'accounts',
      target.toMap(),
      where: 'id = ?',
      whereArgs: [target.id],
    );

    notifyListeners();
  }
}
