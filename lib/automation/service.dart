import 'package:finances/automation/models/automation.dart';
import 'package:finances/category/service.dart';
import 'package:finances/extensions/money.dart';
import 'package:finances/transaction/models/attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:money2/money2.dart';
import 'package:uri_to_file/uri_to_file.dart';

List<Automation> _seedData() {
  var auto1 = Automation(
    name: 'Deserts',
    category: food,
    rules: [
      Rule(regex: RegExp('bandelė')),
      Rule(regex: RegExp('Kibin')),
    ],
  );

  var auto2 = Automation(
    name: 'Nuts',
    category: nuts,
    rules: [
      Rule(regex: RegExp('pistacijos')),
      Rule(regex: RegExp('Anakard')),
    ],
  );
  var auto3 = Automation(
    name: 'Bars',
    category: sports,
    rules: [
      Rule(regex: RegExp('Batonėlis')),
    ],
  );

  return [auto1, auto2, auto3];
}

class AutomationService with ChangeNotifier {
  static final instance = AutomationService._ctor();

  List<Automation> automations = _seedData();

  AutomationService._ctor();

  void delete(Automation automation) {
    automations.remove(automation);
    notifyListeners();
  }

  Automation? getAutomationForLineItem(String lineItem) {
    for (final auto in automations) {
      for (final rule in auto.rules) {
        final result = lineItem.contains(rule.regex);
        if (result ^ rule.invert) {
          return auto;
        }
      }
    }

    return null;
  }

  void save(Automation model) {
    automations.add(model);
    notifyListeners();
  }

  void update(Automation model, Automation newValues) {
    model.name = newValues.name;
    model.category = newValues.category;
    model.rules = newValues.rules;
    notifyListeners();
  }
}

final lidlRegex = RegExp(
  r'^(.*[\d€]{4,8}.*)(?:\n{1,2}.*(?:X|ri).*|).(\d+[\.,]\d\d)\D.*$(?:\nTaikoma nuolaida\nNuolaida.*(-\d+[\.,]\d\d))?',
  multiLine: true,
);

Future<String> extractText(Attachment attachment) async {
  var file = await toFile(attachment.file.path);
  var text = await FlutterTesseractOcr.extractText(
    file.path,
    language: 'lit',
    args: {
      'psm': '4',
      // 'preserve_interword_spaces': '1',
    },
  );
  return text;
}

Stream<({String text, Money money})> extractLineItems(String? text) async* {
  if (text == null) {
    return;
  }

  if (text.contains('Lidl')) {
    for (var match in lidlRegex.allMatches(text)) {
      var lineItem = _parseLineItem(match);
      if (lineItem != null) {
        yield lineItem;
      }
    }
  } else {
    throw UnimplementedError();
  }
}

({String text, Money money})? _parseLineItem(RegExpMatch match) {
  var name = match.group(1);
  if (name == null) {
    return null;
  }

  var money = match.group(2)?.toMoney('EUR');
  if (money == null) {
    return null;
  }

  var discount = match.group(3)?.toMoney('EUR');
  if (discount != null) {
    money -= discount;
  }

  return (text: name, money: money);
}
