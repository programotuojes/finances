import 'package:money2/money2.dart';
import 'package:sqflite/sqflite.dart';

class Account {
  int id;
  String name;
  Money initialMoney;

  Account({
    this.id = -1,
    required this.name,
    required this.initialMoney,
  });

  static void createTable(Batch batch) {
    batch.execute('''
      create table accounts (
        id integer primary key autoincrement,
        name text not null,
        moneyMinor integer not null,
        moneyDecimalDigits integer not null,
        currencyIsoCode text not null
      )
      ''');
  }

  factory Account.fromTable(Map<String, Object?> map) {
    return Account(
      id: map['id'] as int,
      name: map['name'] as String,
      initialMoney: Money.fromInt(
        map['moneyMinor'] as int,
        decimalDigits: map['moneyDecimalDigits'] as int,
        isoCode: map['currencyIsoCode'] as String,
      ),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
      'moneyMinor': initialMoney.minorUnits.toInt(),
      'moneyDecimalDigits': initialMoney.decimalDigits,
      'currencyIsoCode': initialMoney.currency.isoCode,
    };
  }
}
