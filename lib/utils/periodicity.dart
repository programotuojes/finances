enum Periodicity {
  day,
  week,
  month,
  year;
}

extension StringFormats on Periodicity {
  String toLy() {
    return switch (this) {
      Periodicity.day => 'Daily',
      Periodicity.week => 'Weekly',
      Periodicity.month => 'Monthly',
      Periodicity.year => 'Yearly',
    };
  }
}
