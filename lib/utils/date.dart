import 'package:finances/utils/periodicity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
int _numOfWeeks(int year) {
  DateTime dec28 = DateTime(year, 12, 28);
  int dayOfDec28 = int.parse(DateFormat('D').format(dec28));
  return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
}

/// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat('D').format(date));
  int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    woy = _numOfWeeks(date.year - 18);
  } else if (woy > _numOfWeeks(date.year)) {
    woy = 1;
  }
  return woy;
}

extension Cool on DateTime {
  DateGrouping getGrouping(Periodicity periodicity) {
    var displayFormat = switch (periodicity) {
      Periodicity.day => DateFormat('yyyy-MM-dd'),
      Periodicity.week => DateFormat("yyyy 'week' ${weekNumber(this)}"),
      Periodicity.month => DateFormat('yyyy MMM'),
      Periodicity.year => DateFormat("'Year' yyyy"),
    };
    var sortFormat = switch (periodicity) {
      Periodicity.day => DateFormat('yyyy-MM-dd'),
      Periodicity.week => DateFormat('yyyy-${weekNumber(this).toString().padLeft(2, '0')}'),
      Periodicity.month => DateFormat('yyyy-MM'),
      Periodicity.year => DateFormat('yyyy'),
    };

    return DateGrouping(
      display: displayFormat.format(this),
      sort: sortFormat.format(this),
    );
  }

  bool isIn(DateTimeRange range) {
    var sameStart = DateUtils.isSameDay(this, range.start);
    var sameEnd = DateUtils.isSameDay(this, range.end);

    return (isAfter(range.start) || sameStart) && (isBefore(range.end) || sameEnd);
  }
}

class DateGrouping implements Comparable<DateGrouping> {
  final String display;
  final String sort;

  DateGrouping({
    required this.display,
    required this.sort,
  });

  @override
  int compareTo(DateGrouping other) {
    return sort.compareTo(other.sort);
  }

  @override
  bool operator ==(Object other) => other is DateGrouping && sort == other.sort;

  @override
  int get hashCode => Object.hash(display, sort);
}
