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

  test('Just cents', () {
    expect(
      '.42'.toMoney('EUR').toString(),
      '0,42€',
    );
  });

  test('Amount with just dot separator', () {
    expect(
      '1.'.toMoney('EUR').toString(),
      '1,00€',
    );
  });

  test('Amount with just comma separator', () {
    expect(
      '1,'.toMoney('EUR').toString(),
      '1,00€',
    );
  });
}
