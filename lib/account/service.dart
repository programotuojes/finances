import 'package:finances/account/models/account.dart';
import 'package:flutter/foundation.dart';
import 'package:money2/money2.dart';

class AccountService with ChangeNotifier {
  int _id = 2;
  static final instance = AccountService._ctor();
  final accounts = [revolut, swedbank, cash];
  Account lastSelection = swedbank;
  Account? selectedFilter;

  AccountService._ctor();

  void add({required String name, required Money balance}) {
    accounts.add(Account(
      id: _id++,
      name: name,
      initialMoney: balance,
    ));

    notifyListeners();
  }

  void update() {
    notifyListeners();
  }

  void filterBy(Account i) {
    if (selectedFilter == i) {
      selectedFilter = null;
    } else {
      selectedFilter = i;
    }
    notifyListeners();
  }
}

final swedbank = Account(
  id: 0,
  name: 'Swedbank',
  initialMoney: CommonCurrencies().euro.parse('100'),
);
final revolut = Account(
  id: 1,
  name: 'Revolut',
  initialMoney: CommonCurrencies().euro.parse('3,50'),
);
final cash = Account(
  id: 2,
  name: 'Cash',
  initialMoney: CommonCurrencies().euro.parse('99,65'),
);
