import 'package:finances/automation/models/automation.dart';
import 'package:finances/automation/seed.dart' as seed;
import 'package:finances/category/models/category.dart';
import 'package:finances/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final lidlNameVariants = [
  'Lidl',
  'Lid1',
  '111791015',
];

final lidlRegex = RegExp(
  r'^(.*[\d€]{4,8}.*)(?:\n{1,2}.*(?:X|ri).*|).(\d+[\.,] ?\d\d)\D.*$(?:\nTaikoma nuolaida\nNuolaida.*(-\d+[\.,]\d\d))?',
  multiLine: true,
);

class AutomationService with ChangeNotifier {
  static final instance = AutomationService._ctor();
  List<Automation> _automations = [];

  AutomationService._ctor();

  Iterable<Automation> get automations => _automations;

  Future<void> add(Automation automation) async {
    _automations.add(automation);

    automation.id = await database.insert('automations', automation.toMap(setId: false));

    var batch = database.batch();
    for (var i in automation.rules) {
      i.automationId = automation.id;
      batch.insert('automationRules', i.toMap());
    }
    var ids = await batch.commit();

    for (var i = 0; i < automation.rules.length; i++) {
      automation.rules[i].id = ids[i] as int;
    }

    notifyListeners();
  }

  Future<void> delete(Automation automation) async {
    _automations.remove(automation);

    await database.delete('automations', where: 'id = ?', whereArgs: [automation.id]);

    notifyListeners();
  }

  CategoryModel? getCategory({
    String? remittanceInfo,
    String? creditorName,
    String? creditorIban,
  }) {
    for (final automation in _automations) {
      for (final rule in automation.rules) {
        if (_ruleMatches(rule.remittanceInfo, remittanceInfo)) {
          return automation.category;
        }

        if (_ruleMatches(rule.creditorName, creditorName)) {
          return automation.category;
        }
      }
    }

    return null;
  }

  Future<void> init() async {
    var dbRules = await database.query('automationRules');
    var rules = dbRules.map((e) => Rule.fromMap(e)).toList();

    var dbAutomations = await database.query('automations');
    _automations = dbAutomations.map((e) => Automation.fromMap(e, rules)).toList();

    var sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.getBool('automationsSeeded') != true) {
      await seedData();
      await sharedPrefs.setBool('automationsSeeded', true);
    }

    notifyListeners();
  }

  Future<void> seedData() async {
    var automations = seed.seedData().toList();

    var batch = database.batch();
    for (var automation in automations) {
      batch.insert('automations', automation.toMap(setId: false));
    }

    var ids = await batch.commit();
    var batch2 = database.batch();

    for (var i = 0; i < automations.length; i++) {
      var id = ids[i] as int;
      automations[i].id = id;

      for (var rule in automations[i].rules) {
        rule.automationId = id;
        batch2.insert('automationRules', rule.toMap());
      }
    }

    ids = await batch2.commit();
    var idIndex = 0;

    for (var automation in automations) {
      for (var rule in automation.rules) {
        rule.id = ids[idIndex++] as int;
      }
    }

    _automations.addAll(automations);
    notifyListeners();
  }

  Future<void> update(
    Automation target, {
    String? newName,
    CategoryModel? newCategory,
    List<Rule>? newRules,
  }) async {
    target.name = newName ?? target.name;
    target.category = newCategory ?? target.category;

    await database.update('automations', target.toMap(), where: 'id = ?', whereArgs: [target.id]);

    if (newRules != null) {
      for (var rule in newRules) {
        rule.automationId = target.id;

        var ruleExists = target.rules.any((element) => element.id == rule.id);

        if (ruleExists) {
          await database.update('automationRules', rule.toMap(), where: 'id = ?', whereArgs: [rule.id]);
        } else {
          rule.id = await database.insert('automationRules', rule.toMap());
        }
      }

      // Delete removed rules
      for (var oldRule in target.rules) {
        var oldExists = newRules.any((element) => element.id == oldRule.id);
        if (!oldExists) {
          await database.delete('automationRules', where: 'id = ?', whereArgs: [oldRule.id]);
        }
      }

      target.rules = newRules;
    }

    notifyListeners();
  }

  bool _ruleMatches(RegExp? regex, String? target) {
    return regex != null && target != null && target.contains(regex);
  }
}
