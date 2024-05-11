import 'package:finances/automation/models/automation.dart';
import 'package:finances/automation/seed.dart';
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
  r'^(.*[\d€]{4,8}.*)(?:\n{1,2}.*(?:X|ri).*|).(\d+[\.,]\d\d)\D.*$(?:\nTaikoma nuolaida\nNuolaida.*(-\d+[\.,]\d\d))?',
  multiLine: true,
);

class AutomationService with ChangeNotifier {
  static final instance = AutomationService._ctor();

  final List<Automation> automations = [];

  AutomationService._ctor();

  Future<void> add(Automation automation) async {
    automations.add(automation);

    automation.id = await Db.instance.db.insert(
      'automations',
      automation.toMap(setId: false),
    );

    var batch = Db.instance.db.batch();
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
    automations.remove(automation);

    await Db.instance.db.delete(
      'automations',
      where: 'id = ?',
      whereArgs: [automation.id],
    );

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

  Future<void> init() async {
    var dbCategories = await Db.instance.db.query('categories');
    var categories = dbCategories.map((e) => CategoryModel.fromMap(e)).toList();

    var dbRules = await Db.instance.db.query('automationRules');
    var rules = dbRules.map((e) => Rule.fromMap(e)).toList();

    var dbAutomations = await Db.instance.db.query('automations');
    automations.addAll(dbAutomations.map((e) => Automation.fromMap(e, categories, rules)));

    var sharedPrefs = await SharedPreferences.getInstance();
    if (sharedPrefs.getBool('seeded') != true) {
      var seed = seedData().toList();

      for (var automation in seed) {
        automation.id = await Db.instance.db.insert('automations', automation.toMap(setId: false));

        var batch = Db.instance.db.batch();
        for (var rule in automation.rules) {
          rule.automationId = automation.id;
          batch.insert('automationRules', rule.toMap());
        }

        var ids = await batch.commit();
        for (var i = 0; i < automation.rules.length; i++) {
          automation.rules[i].id = ids[i] as int;
        }
      }

      automations.addAll(seed);
      await sharedPrefs.setBool('seeded', true);
    }
  }

  Future<void> update(
    Automation target, {
    String? newName,
    CategoryModel? newCategory,
    List<Rule>? newRules,
  }) async {
    target.name = newName ?? target.name;
    target.category = newCategory ?? target.category;

    await Db.instance.db.update('automations', target.toMap(), where: 'id = ?', whereArgs: [target.id]);

    if (newRules != null) {
      for (var rule in newRules) {
        rule.automationId = target.id;

        var ruleExists = target.rules.any((element) => element.id == rule.id);

        if (ruleExists) {
          await Db.instance.db.update('automationRules', rule.toMap(), where: 'id = ?', whereArgs: [rule.id]);
        } else {
          rule.id = await Db.instance.db.insert('automationRules', rule.toMap());
        }
      }

      // Delete removed rules
      for (var oldRule in target.rules) {
        var oldExists = newRules.any((element) => element.id == oldRule.id);
        if (!oldExists) {
          await Db.instance.db.delete('automationRules', where: 'id = ?', whereArgs: [oldRule.id]);
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
