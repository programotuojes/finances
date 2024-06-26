import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/utils/periodicity.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';
import 'package:sqflite/sqflite.dart';

class RecurringModel {
  int? id;
  Account account;
  CategoryModel category;
  Money money;
  String? _description;
  Periodicity periodicity;
  int interval;
  DateTime _from;
  DateTime? _until;
  int timesConfirmed;
  TransactionType type;

  RecurringModel({
    this.id,
    required this.account,
    required this.category,
    required this.money,
    required String? description,
    required this.periodicity,
    required this.interval,
    required DateTime from,
    required DateTime? until,
    this.timesConfirmed = 0,
    required this.type,
  })  : _from = DateUtils.dateOnly(from),
        _until = until != null ? DateUtils.dateOnly(until) : null {
    this.description = description;
  }

  factory RecurringModel.fromMap(Map<String, Object?> map) {
    var untilMs = map['dateUntilMs'] as int?;

    return RecurringModel(
      id: map['id'] as int,
      account: AccountService.instance.accounts.firstWhere((x) => x.id == map['accountId'] as int),
      category: CategoryService.instance.findById(map['categoryId'] as int)!,
      money: Money.fromInt(
        map['moneyMinor'] as int,
        decimalDigits: map['moneyDecimalDigits'] as int,
        isoCode: map['currencyIsoCode'] as String,
      ),
      description: map['description'] as String?,
      periodicity: Periodicity.values[map['period'] as int],
      interval: map['interval'] as int,
      from: DateTime.fromMillisecondsSinceEpoch(map['dateFromMs'] as int),
      until: untilMs != null ? DateTime.fromMicrosecondsSinceEpoch(untilMs) : null,
      timesConfirmed: map['timesConfirmed'] as int,
      type: TransactionType.values[map['type'] as int],
    );
  }

  String? get description => _description;

  set description(String? value) {
    if (value != null && value.isNotEmpty) {
      _description = value;
    } else {
      _description = null;
    }
  }

  DateTime get from => _from;

  set from(DateTime value) {
    _from = DateUtils.dateOnly(value);
  }

  Iterable<DateTime> get transactionDates sync* {
    DateTime point = from;

    do {
      yield point;
      point = switch (periodicity) {
        Periodicity.day => point.copyWith(day: point.day + interval),
        Periodicity.week => point.copyWith(day: point.day + interval * 7),
        Periodicity.month => point.copyWith(month: point.month + interval),
        Periodicity.year => point.copyWith(year: point.year + interval),
      };
    } while (until == null || !point.isAfter(until!));
  }

  DateTime? get until => _until;

  set until(DateTime? value) {
    if (value != null) {
      _until = DateUtils.dateOnly(value);
    } else {
      _until = value;
    }
  }

  DateTime? nextDate() {
    return transactionDates.skip(timesConfirmed).firstOrNull;
  }

  Map<String, Object?> toMap() {
    return {
      'accountId': account.id,
      'categoryId': category.id,
      'moneyMinor': money.minorUnits.toInt(),
      'moneyDecimalDigits': money.decimalDigits,
      'currencyIsoCode': money.currency.isoCode,
      'description': description,
      'period': periodicity.index,
      'interval': interval,
      'dateFromMs': _from.millisecondsSinceEpoch,
      'dateUntilMs': _until?.millisecondsSinceEpoch,
      'timesConfirmed': timesConfirmed,
      'type': type.index,
    };
  }

  static void createTable(Batch batch) {
    batch.execute('''
      create table recurring (
        id integer primary key autoincrement,
        accountId integer not null,
        categoryId integer not null,
        moneyMinor integer not null,
        moneyDecimalDigits integer not null,
        currencyIsoCode text not null,
        description text,
        period integer not null,
        interval integer not null,
        dateFromMs integer not null,
        dateUntilMs integer,
        timesConfirmed integer not null,
        type integer not null,
        foreign key (accountId) references accounts(id) on delete cascade,
        foreign key (categoryId) references categories(id) on delete cascade
      )
    ''');
  }
}
