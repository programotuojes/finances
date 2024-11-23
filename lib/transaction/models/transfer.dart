import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/transaction/models/import_detais/imported_wallet_db_transfer.dart';
import 'package:finances/utils/diacritic.dart';
import 'package:money2/money2.dart';
import 'package:sqflite/sqflite.dart';

class Transfer {
  int? id;
  Money money;
  String? description;
  Account? from;
  Account? to;
  DateTime dateTime;
  ImportedWalletDbTransfer? importedWalletDbTransfer;

  Transfer({
    this.id,
    required this.money,
    required this.description,
    required this.from,
    required this.to,
    required this.dateTime,
    this.importedWalletDbTransfer,
  });

  factory Transfer.fromMap(
    Map<String, Object?> map,
    List<ImportedWalletDbTransfer> importedWalletDbTransfers,
  ) {
    final id = map['id'] as int;
    final accounts = AccountService.instance.accounts;

    return Transfer(
      id: id,
      money: Money.fromInt(
        map['moneyMinor'] as int,
        decimalDigits: map['moneyDecimalDigits'] as int,
        isoCode: map['currencyIsoCode'] as String,
      ),
      description: map['description'] as String?,
      from: accounts.firstWhereOrNull((x) => x.id == map['fromAccountId'] as int?),
      to: accounts.firstWhereOrNull((x) => x.id == map['toAccountId'] as int?),
      dateTime: DateTime.fromMillisecondsSinceEpoch(map['dateTimeMs'] as int),
      importedWalletDbTransfer: importedWalletDbTransfers.firstWhereOrNull((x) => x.parentId == id),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'moneyMinor': money.minorUnits.toInt(),
      'moneyDecimalDigits': money.decimalDigits,
      'currencyIsoCode': money.currency.isoCode,
      'description': description,
      'descriptionNorm': normalizeString(description),
      'fromAccountId': from?.id,
      'toAccountId': to?.id,
      'dateTimeMs': dateTime.millisecondsSinceEpoch,
    };
  }

  static void createTable(Batch batch) {
    batch.execute('''
      create table transfers (
        id integer primary key autoincrement,
        moneyMinor integer not null,
        moneyDecimalDigits integer not null,
        currencyIsoCode text not null,
        description text,
        descriptionNorm text,
        fromAccountId integer,
        toAccountId integer,
        dateTimeMs integer not null,
        foreign key (fromAccountId) references accounts(id) on delete set null,
        foreign key (toAccountId) references accounts(id) on delete set null
      )
    ''');
  }

  bool matchesFilter(RegExp regex) {
    // TODO normalize only once per object creation and description update
    final descriptionMatches = normalizeString(description)?.contains(regex) == true;
    if (descriptionMatches) {
      return true;
    }

    final categoryMatches = 'Transfer'.contains(regex);
    if (categoryMatches) {
      return true;
    }

    final fromNameMatches = from?.name.contains(regex) == true;
    if (fromNameMatches) {
      return true;
    }

    final toNameMatches = to?.name.contains(regex) == true;
    if (toNameMatches) {
      return true;
    }

    return false;
  }
}
