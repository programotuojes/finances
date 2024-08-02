/// Database `db.sqlite3`.
/// Table `maps_6`.
class Account {
  /// JSON prop name `_id`.
  String id;

  bool archived;
  int initAmount;
  String name;

  Account({
    required this.id,
    required this.archived,
    required this.initAmount,
    required this.name,
  });
}

/// Database `db.sqlite3`.
/// Table `maps_7`.
class Category {
  // _id
  String id;
  String name;

  Category({
    required this.id,
    required this.name,
  });
}

/// Database `uuid-records.db`.
/// Table `records`.
class Record {
  RecordType type;
  String note;
  String accountId;
  String categoryId;
  int recordDate;
  double amountReal;
  bool transfer;
  String? transferAccountId;
  String? transferId;

  Record({
    required this.type,
    required this.note,
    required this.accountId,
    required this.categoryId,
    required this.recordDate,
    required this.amountReal,
    required this.transfer,
    required this.transferAccountId,
    required this.transferId,
  });
}

/// 0 = income.
/// 1 = expense.
enum RecordType {
  income,
  expense,
}
