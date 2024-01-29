import 'package:finances/account/models/account.dart';
import 'package:flutter/foundation.dart';
import 'package:money2/money2.dart';

class AccountService with ChangeNotifier {
  static final instance = AccountService._ctor();
  int _lastId = 2;

  AccountService._ctor() {
    print('Account service created');
  }

  final accounts = <Account>[
    Account(id: 0, name: 'Swedbank', balance: CommonCurrencies().euro.parse('2004,50')),
    Account(id: 1, name: 'Revolut', balance: CommonCurrencies().euro.parse('3,50')),
    Account(id: 2, name: 'Cash', balance: CommonCurrencies().euro.parse('99,65')),
  ];

  void add({required String name, required Money balance}) {
    accounts.add(Account(
      id: ++_lastId,
      name: name,
      balance: balance,
    ));

    notifyListeners();
  }

  void update() {
    notifyListeners();
  }
}
