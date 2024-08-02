/// Database file `/data/data/com.droid4you.application.wallet/files/local-<guid>.cblite2/db.sqlite3`.
/// Table `maps_6`.
class Account {
  String id;
  String name;

  Account({
    required this.id,
    required this.name,
  });
}

/// Database file `/data/data/com.droid4you.application.wallet/files/local-<guid>.cblite2/db.sqlite3`.
/// Table `maps_7`.
class Category {
  String id;
  String name;

  Category({
    required this.id,
    required this.name,
  });
}

/// Database file `/data/data/com.droid4you.application.wallet/databases/<guid>-records.db`.
/// Table `records`.
class Record {
  String id;
  String note;
  String accountId;
  String categoryId;
  int recordDate;
  double amountReal;
  bool transfer;
  String? transferAccountId;
  String? transferId;

  Record({
    required this.id,
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
