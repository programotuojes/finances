import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/main.dart';
import 'package:finances/utils/db.dart';
import 'package:flutter/foundation.dart';
import 'package:money2/money2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountService with ChangeNotifier {
  static final instance = AccountService._ctor();
  late final SharedPreferences storage;

  final List<Account> accounts = [];
  late Account _lastSelection;
  Account? _selected;

  AccountService._ctor();

  Account? get filter => _selected;
  Account get lastSelection => _lastSelection;

  Future<void> add({
    required String name,
    required Money initialMoney,
  }) async {
    var account = Account(name: name, initialMoney: initialMoney);

    account.id = await Db.instance.db.insert(
      'accounts',
      account.toMap(),
    );

    await setLastSelection(account);

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

  Future<void> initialize() async {
    var dbAccounts = await Db.instance.db.query('accounts');
    accounts.addAll(dbAccounts.map((e) => Account.fromTable(e)));

    storage = await SharedPreferences.getInstance();
    var lastSelectionId = storage.getInt('lastSelectionId');
    var lastSelection = accounts.firstWhereOrNull((element) => element.id == lastSelectionId);

    if (lastSelection != null) {
      _lastSelection = lastSelection;
    } else if (accounts.isNotEmpty) {
      _lastSelection = accounts.first;
      await storage.setInt('lastSelectionId', _lastSelection.id!);
    } else {
      logger.i('''
Could not set last account selection, because there are no accounts.
This should only happen on the very first launch.''');
    }
  }

  Future<void> setLastSelection(Account account) async {
    await storage.setInt('lastSelectionId', account.id!);
    _lastSelection = account;
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

    await setLastSelection(target);

    notifyListeners();
  }
}
