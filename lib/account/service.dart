import 'package:finances/account/models/account.dart';
import 'package:flutter/foundation.dart';
import 'package:money2/money2.dart';

final cash = Account(
  id: 2,
  name: 'Cash',
  initialMoney: CommonCurrencies().euro.parse('99,65'),
);
final revolut = Account(
  id: 1,
  name: 'Revolut',
  initialMoney: CommonCurrencies().euro.parse('3,50'),
);
final swedbank = Account(
  id: 0,
  name: 'Swedbank',
  initialMoney: CommonCurrencies().euro.parse('100'),
);

class AccountService with ChangeNotifier {
  static final instance = AccountService._ctor();

  int _id = 2;
  final accounts = [revolut, swedbank, cash];
  Account lastSelection = swedbank;
  Account? _selected;

  AccountService._ctor();

  Account? get filter => _selected;

  void add({required String name, required Money balance}) {
    accounts.add(Account(
      id: _id++,
      name: name,
      initialMoney: balance,
    ));

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

  void update(
    Account target, {
    String? name,
    Money? initialMoney,
  }) {
    if (name != null) {
      target.name = name;
    }

    if (initialMoney != null) {
      target.initialMoney = initialMoney;
    }

    notifyListeners();
  }
}
