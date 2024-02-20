import 'package:finances/account/models/account.dart';
import 'package:flutter/foundation.dart';
import 'package:money2/money2.dart';

class AccountService with ChangeNotifier {
  static final instance = AccountService._ctor();
  final accounts = [revolut, swedbank, cash];
  Account lastSelection = swedbank;
  Account? selectedFilter;

  AccountService._ctor();

  void add({required String name, required Money balance}) {
    accounts.add(Account(
      name: name,
      balance: balance,
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
  name: 'Swedbank',
  balance: CommonCurrencies().euro.parse('2004,50'),
);
final revolut = Account(
  name: 'Revolut',
  balance: CommonCurrencies().euro.parse('3,50'),
);
final cash = Account(
  name: 'Cash',
  balance: CommonCurrencies().euro.parse('99,65'),
);