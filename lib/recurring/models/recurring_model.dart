import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:money2/money2.dart';

enum Periodicity {
  day,
  week,
  month,
  year,
}

extension LyNaming on Periodicity {
  String toLy() {
    return switch (this) {
      Periodicity.day => 'Daily',
      Periodicity.week => 'Weekly',
      Periodicity.month => 'Monthly',
      Periodicity.year => 'Yearly',
    };
  }
}

class RecurringModel {
  Account account;
  CategoryModel category;
  Money money;
  String? _description;
  Periodicity periodicity;
  int interval;
  DateTime _from;
  DateTime? _until;
  int timesConfirmed = 0;
  TransactionType type;

  RecurringModel({
    required this.account,
    required this.category,
    required this.money,
    required String? description,
    required this.periodicity,
    required this.interval,
    required DateTime from,
    required DateTime? until,
    required this.type,
  })  : _from = DateUtils.dateOnly(from),
        _until = until != null ? DateUtils.dateOnly(until) : null {
    this.description = description;
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

  String get humanReadablePeriod {
    var period = periodicity.name;

    if (interval != 1) {
      period += 's';
    }

    return 'Every $interval $period';
  }

  Iterable<DateTime> get transactionDates sync* {
    DateTime point = from;

    do {
      yield point;
      point = switch (periodicity) {
        Periodicity.day => point.copyWith(
            day: point.day + interval,
          ),
        Periodicity.week => point.copyWith(
            day: point.day + interval * 7,
          ),
        Periodicity.month => point.copyWith(
            month: point.month + interval,
          ),
        Periodicity.year => point.copyWith(
            year: point.year + interval,
          ),
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

  DateTime? nextDate(DateTime now) {
    return transactionDates.skip(timesConfirmed).firstOrNull;
  }
}
