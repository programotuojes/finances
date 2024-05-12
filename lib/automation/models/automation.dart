import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:sqflite/sqflite.dart';

class Automation {
  int id;
  String name;
  CategoryModel category;
  List<Rule> rules = [];

  Automation({
    this.id = -1,
    required this.name,
    required this.category,
    List<Rule>? rules,
  }) {
    if (rules != null) {
      this.rules = rules;
    }
  }

  void addRules(Iterable<Rule> rules) {
    for (var rule in rules) {
      rule.automationId = id;
      this.rules.add(rule);
    }
  }

  factory Automation.fromMap(
    Map<String, Object?> map,
    List<Rule> rules,
  ) {
    var id = map['id'] as int;

    return Automation(
      id: id,
      name: map['name'] as String,
      category: CategoryService.instance.findById(map['categoryId'] as int)!,
      rules: rules.where((element) => element.automationId == id).toList(),
    );
  }

  Map<String, Object?> toMap({bool setId = true}) {
    return {
      'id': setId ? id : null,
      'name': name,
      'categoryId': category.id,
    };
  }

  static void createTable(Batch batch) {
    batch.execute('''
      create table automations (
        id integer primary key autoincrement,
        name text not null,
        categoryId integer not null,
        foreign key (categoryId) references categories(id) on delete cascade
      )
    ''');
  }
}

class Rule {
  int? id;
  int? automationId;
  RegExp? creditorName;
  RegExp? creditorIban;
  RegExp? remittanceInfo;

  Rule({
    this.id,
    this.automationId,
    this.creditorName,
    this.creditorIban,
    this.remittanceInfo,
  });

  factory Rule.fromMap(Map<String, Object?> map) {
    var rule = Rule.fromStrings(
      creditorName: map['creditorName'] as String?,
      creditorIban: map['creditorIban'] as String?,
      remittanceInfo: map['remittanceInfo'] as String?,
    );

    rule.id = map['id'] as int;
    rule.automationId = map['automationId'] as int;

    return rule;
  }

  factory Rule.fromStrings({
    String? creditorName,
    String? creditorIban,
    String? remittanceInfo,
  }) {
    var creditorNameProvided = creditorName != null && creditorName.isNotEmpty;
    var creditorIbanProvided = creditorIban != null && creditorIban.isNotEmpty;
    var remittanceInfoProvided = remittanceInfo != null && remittanceInfo.isNotEmpty;

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

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'creditorName': creditorName?.pattern,
      'creditorIban': creditorIban?.pattern,
      'remittanceInfo': remittanceInfo?.pattern,
      'automationId': automationId,
    };
  }

  static void createTable(Batch batch) {
    batch.execute('''
      create table automationRules (
        id integer primary key autoincrement,
        creditorName text,
        creditorIban text,
        remittanceInfo text,
        automationId integer not null,
        foreign key (automationId) references automations(id) on delete cascade
      )
    ''');
  }
}
