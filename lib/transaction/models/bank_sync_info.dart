import 'package:sqflite/sqflite.dart';

class BankSyncInfo {
  int? id;
  int? dbTransactionId;
  String transactionId;
  String? creditorName;
  String? creditorIban;
  String? debtorName;
  String? debtorIban;
  String? remittanceInfo;

  BankSyncInfo({
    this.id,
    this.dbTransactionId,
    required this.transactionId,
    required this.creditorName,
    required this.creditorIban,
    required this.debtorName,
    required this.debtorIban,
    required this.remittanceInfo,
  });

  factory BankSyncInfo.fromMap(Map<String, Object?> map) {
    return BankSyncInfo(
      id: map['id'] as int,
      dbTransactionId: map['dbTransactionId'] as int,
      transactionId: map['transactionId'] as String,
      creditorName: map['creditorName'] as String?,
      creditorIban: map['creditorIban'] as String?,
      debtorName: map['debtorName'] as String?,
      debtorIban: map['debtorIban'] as String?,
      remittanceInfo: map['remittanceInfo'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'transactionId': transactionId,
      'creditorName': creditorName,
      'creditorIban': creditorIban,
      'debtorName': debtorName,
      'debtorIban': debtorIban,
      'remittanceInfo': remittanceInfo,
      'dbTransactionId': dbTransactionId,
    };
  }

  static void createTable(Batch batch) {
    batch.execute('''
      create table bankSyncInfo (
        id integer primary key autoincrement,
        transactionId text not null,
        creditorName text,
        creditorIban text,
        debtorName text,
        debtorIban text,
        remittanceInfo text,
        dbTransactionId integer not null unique,
        foreign key (dbTransactionId) references transactions(id) on delete cascade
      )
    ''');
  }
}
