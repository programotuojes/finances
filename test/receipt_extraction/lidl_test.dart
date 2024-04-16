import 'dart:io';

import 'package:finances/automation/service.dart';
import 'package:flutter_test/flutter_test.dart';

File testFile(int num) {
  final number = num.toString().padLeft(2, '0');
  return File('test/receipt_extraction/test_data/lidl_$number.txt');
}

void assertMatch(
  RegExpMatch match,
  String name,
  String amount, {
  String? discount,
}) {
  expect(match.group(1)?.trim(), name);
  expect(match.group(2)?.trim(), amount);
  expect(match.group(3)?.trim(), discount);
}

void main() {
  test('Lidl 1', () async {
    final receipt = await testFile(1).readAsString();
    final matches = lidlRegex.allMatches(receipt).toList();

    expect(matches.length, 4);

    assertMatch(
      matches[0],
      '77503078  Tofu rūkytas',
      '4,98',
    );
    assertMatch(
      matches[1],
      '6704839  Batonėlis žemės rieš tų sk. 7',
      '3,16',
    );
    assertMatch(
      matches[2],
      '7609133  Kibinas su vištiena',
      '2,30',
    );
    assertMatch(
      matches[3],
      '5504481  Miel bandelė su ag.',
      '0,59',
    );
  });

  test('Lidl 2', () async {
    final receipt = await testFile(2).readAsString();
    final matches = lidlRegex.allMatches(receipt).toList();

    expect(matches.length, 3);

    assertMatch(
      matches[0],
      '6704839  Batonėlis žemės riešutų sk.',
      '3,16',
    );
    assertMatch(
      matches[1],
      '0083017  Pievagrybiai balti',
      '1,59',
      discount: '-0,80',
    );
    assertMatch(
      matches[2],
      '7602802  Kibin.su višt.garst.',
      '1,70',
    );
  });

  test('Lidl 3', () async {
    final receipt = await testFile(3).readAsString();
    final matches = lidlRegex.allMatches(receipt).toList();

    expect(matches.length, 6);

    assertMatch(
      matches[0],
      'E 750378. Tofu rūkytas',
      '2,97',
    );
    assertMatch(
      matches[1],
      '0012971  Anakardžių riešutai',
      '2,89',
    );
    assertMatch(
      matches[2],
      '0082€15 Paprikos raudonosios',
      '0,99',
    );
    assertMatch(
      matches[3],
      '6704€79 = Batonėlis žemės riešutų sk. i pam———',
      '3,16',
    );
    assertMatch(
      matches[4],
      '008075 Saldžiosios bulvės "i',
      '1,23',
    );
    assertMatch(
      matches[5],
      '760262 Kibin.su višt.garst.',
      '1,70',
    );
  });

  test('Lidl 4', () async {
    final receipt = await testFile(4).readAsString();
    final matches = lidlRegex.allMatches(receipt).toList();

    expect(matches.length, 7);

    assertMatch(
      matches[0],
      '503078 Tofu rūkytas                                      aa             i',
      '5,94',
    );
    assertMatch(
      matches[1],
      '0080000 Bananai                                                           2',
      '0,81',
    );
    assertMatch(
      matches[2],
      '0082755 Morkos',
      '0,15',
    );
    assertMatch(
      matches[3],
      '0082440 Pomidorai slyviniai',
      '1,04',
    );
    assertMatch(
      matches[4],
      '5504481  Miel.bandelė su ag.',
      '0,59',
    );
    assertMatch(
      matches[5],
      '7609133  Kibinas su vištiena',
      '2,30',
    );
    assertMatch(
      matches[6],
      '6704839  Batonėlis žemės riešutų sk.',
      '6,32',
    );
  });

  test('Lidl 5', () async {
    final receipt = await testFile(5).readAsString();
    final matches = lidlRegex.allMatches(receipt).toList();

    expect(matches.length, 7);

    assertMatch(
      matches[0],
      '0124068 Kokosų pienas, Asia Tight',
      '1,35',
    );
    assertMatch(
      matches[1],
      '503078. Tofu rūkytas',
      '2,97',
    );
    assertMatch(
      matches[2],
      '0160503  Skrud.sūd.pistacijos',
      '7,99',
    );
    assertMatch(
      matches[3],
      '29044€1  Miel.bandelė su ag.',
      '0,99',
    );
    assertMatch(
      matches[4],
      '7602€02  Kibin.su višt.garst',
      '1,70',
    );
    assertMatch(
      matches[5],
      '6704€39  „Batonėlis žemės riešutų sk. —',
      '3,16',
    );
    assertMatch(
      matches[6],
      '0082440 Pomidorai slyviniai',
      '0,52',
    );
  });

  test('Number of pieces not mistaken for price', () async {
    final receipt = await testFile(6).readAsString();
    final matches = lidlRegex.allMatches(receipt).toList();

    expect(matches.length, 0);
  });
}
