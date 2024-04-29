import 'package:finances/automation/models/automation.dart';
import 'package:finances/category/models/category.dart';
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
      Rule(remittanceInfo: RegExp('bandelė')),
      Rule(remittanceInfo: RegExp('Kibin')),
    ],
  );

  var auto2 = Automation(
    name: 'Nuts',
    category: nuts,
    rules: [
      Rule(remittanceInfo: RegExp('pistacijos')),
      Rule(remittanceInfo: RegExp('Anakard')),
    ],
  );
  var auto3 = Automation(
    name: 'Bars',
    category: sports,
    rules: [
      Rule(remittanceInfo: RegExp('Batonėlis')),
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

  CategoryModel? getCategory({
    String? remittanceInfo,
    String? creditorName,
    String? creditorIban,
  }) {
    for (final automation in automations) {
      for (final rule in automation.rules) {
        if (_ruleMatches(rule.remittanceInfo, remittanceInfo)) {
          return automation.category;
        }

        if (_ruleMatches(rule.creditorName, creditorName)) {
          return automation.category;
        }

        if (_ruleMatches(rule.creditorIban, creditorIban)) {
          return automation.category;
        }
      }
    }

    return null;
  }

  bool _ruleMatches(RegExp? regex, String? target) {
    return regex != null && target != null && target.contains(regex);
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

  var money = match.group(2)?.toMoney();
  if (money == null) {
    return null;
  }

  var discount = match.group(3)?.toMoney();
  if (discount != null) {
    money -= discount;
  }

  return (text: name, money: money);
}
