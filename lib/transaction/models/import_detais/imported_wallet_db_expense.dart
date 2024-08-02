import 'package:sqflite/sqflite.dart';

class ImportedWalletDbExpense {
  static const tableName = 'importedWalletDbExpense';

  int? id;
  int? parentId;

  String recordId;
  String accountId;
  String categoryId;

  ImportedWalletDbExpense({
    this.id,
    this.parentId,
    required this.recordId,
    required this.accountId,
    required this.categoryId,
  });

  factory ImportedWalletDbExpense.fromMap(Map<String, Object?> map) {
    return ImportedWalletDbExpense(
      id: map['id'] as int,
      parentId: map['parentId'] as int,
      recordId: map['recordId'] as String,
      accountId: map['accountId'] as String,
      categoryId: map['categoryId'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'parentId': parentId,
      'recordId': recordId,
      'accountId': accountId,
      'categoryId': categoryId,
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
        foreign key (parentId) references expenses(id) on delete cascade
      )
    ''');
  }
}
