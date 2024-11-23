import 'package:finances/utils/diacritic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void checkResult(String original, String expected) {
    test('$original -> $expected', () {
      expect(normalizeString(original), expected);
    });
  }

  group('Removing diacritics from strings', () {
    checkResult('ąčęėįšųū', 'aceeisuu');
    checkResult('ĄČĘĖĮŠŲŪ', 'ACEEISUU');
    checkResult('ABCabc123', 'ABCabc123');
  });
}
