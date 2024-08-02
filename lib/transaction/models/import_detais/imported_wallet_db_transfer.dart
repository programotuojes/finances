import 'package:sqflite/sqflite.dart';

class ImportedWalletDbTransfer {
  static const tableName = 'importedWalletDbTransfers';

  int? id;
  int? parentId;

  String recordId;
  String accountId;
  String categoryId;
  String transferId;
  String? transferAccountId;

  ImportedWalletDbTransfer({
    this.id,
    this.parentId,
    required this.recordId,
    required this.accountId,
    required this.categoryId,
    required this.transferId,
    required this.transferAccountId,
  });

  factory ImportedWalletDbTransfer.fromMap(Map<String, Object?> map) {
    return ImportedWalletDbTransfer(
      id: map['id'] as int,
      parentId: map['parentId'] as int,
      recordId: map['recordId'] as String,
      accountId: map['accountId'] as String,
      categoryId: map['categoryId'] as String,
      transferId: map['transferId'] as String,
      transferAccountId: map['transferAccountId'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'parentId': parentId,
      'recordId': recordId,
      'accountId': accountId,
      'categoryId': categoryId,
      'transferId': transferId,
      'transferAccountId': transferAccountId,
    };
  }

  static void createTable(Batch batch) {
    batch.execute('''
      create table $tableName (
        id integer primary key autoincrement,
        parentId integer not null,
        recordId text not null,
        accountId text not null,
        categoryId text not null,
        transferId text not null,
        transferAccountId text,
        foreign key (parentId) references transfers(id) on delete cascade
      )
    ''');
  }
}
