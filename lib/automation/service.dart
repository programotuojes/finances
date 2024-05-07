import 'package:finances/automation/models/automation.dart';
import 'package:finances/automation/seed.dart';
import 'package:finances/category/models/category.dart';
import 'package:flutter/material.dart';

final lidlNameVariants = [
  'Lidl',
  'Lid1',
  '111791015',
];

final lidlRegex = RegExp(
  r'^(.*[\d€]{4,8}.*)(?:\n{1,2}.*(?:X|ri).*|).(\d+[\.,]\d\d)\D.*$(?:\nTaikoma nuolaida\nNuolaida.*(-\d+[\.,]\d\d))?',
  multiLine: true,
);

class AutomationService with ChangeNotifier {
  static final instance = AutomationService._ctor();

  final automations = seedData().toList();

  AutomationService._ctor();

  void add(Automation automation) {
    automations.add(automation);
    notifyListeners();
  }

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

  void update(Automation model, Automation newValues) {
    model.name = newValues.name;
    model.category = newValues.category;
    model.rules = newValues.rules;
    notifyListeners();
  }

  bool _ruleMatches(RegExp? regex, String? target) {
    return regex != null && target != null && target.contains(regex);
  }
}
