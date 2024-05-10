import 'package:finances/category/models/category.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class Automation with ChangeNotifier {
  String name;
  CategoryModel category;

  /// All rules are ORed together
  List<Rule> rules = [];

  Automation({
    required this.name,
    required this.category,
    List<Rule>? rules,
  }) {
    if (rules != null) {
      this.rules = rules;
    }
  }

  static void createTable(Batch batch) {
    batch.execute('''
      CREATE TABLE automations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');
  }
}

class Rule {
  RegExp? creditorName;
  RegExp? creditorIban;
  RegExp? remittanceInfo;

  Rule({
    this.creditorName,
    this.creditorIban,
    this.remittanceInfo,
  });

  factory Rule.fromStrings({
    required String creditorName,
    required String creditorIban,
    required String remittanceInfo,
  }) {
    var creditorNameProvided = creditorName.isNotEmpty;
    var creditorIbanProvided = creditorIban.isNotEmpty;
    var remittanceInfoProvided = remittanceInfo.isNotEmpty;

    assert(
      creditorNameProvided || creditorIbanProvided || remittanceInfoProvided,
      'At least one field must be provided',
    );

    return Rule(
      creditorName: creditorNameProvided ? RegExp(creditorName) : null,
      creditorIban: creditorIbanProvided ? RegExp(creditorIban) : null,
      remittanceInfo: remittanceInfoProvided ? RegExp(remittanceInfo) : null,
    );
  }

  static void createTable(Batch batch) {
    batch.execute('''
      CREATE TABLE automationRules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        creditorName TEXT,
        creditorIban TEXT
        remittanceInfo TEXT,
        automationId INTEGER NOT NULL,
        FOREIGN KEY (automationId) REFERENCES automations(id) ON DELETE CASCADE
      )
    ''');
  }
}
