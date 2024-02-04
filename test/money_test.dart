import 'package:finances/extensions/money.dart';
import 'package:test/test.dart';

void main() {
  test('EUR with dot minor separator', () {
    expect(
      '123.45'.toMoney('EUR').toString(),
      '123,45€',
    );
  });

  test('EUR with comma minor separator', () {
    expect(
      '123,45'.toMoney('EUR').toString(),
      '123,45€',
    );
  });

  test('Amount without separator', () {
    expect(
      '69'.toMoney('EUR').toString(),
      '69,00€',
    );
  });

  test('Amount with tens of cents', () {
    expect(
      '4.2'.toMoney('EUR').toString(),
      '4,20€',
    );
  });
}
