import 'package:finances/category/models/category.dart';
import 'package:flutter/foundation.dart';

class Automation with ChangeNotifier {
  /// All rules are ORed together
  List<Rule> rules = [];
  CategoryModel category;
  String name;

  Automation({
    required this.name,
    required this.category,
    List<Rule>? rules,
  }) {
    if (rules != null) {
      this.rules = rules;
    }
  }
}

class Rule {
  RegExp? remittanceInfo;
  RegExp? creditorName;
  RegExp? creditorIban;

  Rule({
    this.remittanceInfo,
    this.creditorName,
    this.creditorIban,
  });

  factory Rule.fromStrings({
    required String remittanceInfo,
    required String creditorName,
    required String creditorIban,
  }) {
    var a = remittanceInfo.isNotEmpty;
    var b = creditorName.isNotEmpty;
    var c = creditorIban.isNotEmpty;

    assert(a || b || c, 'At least one field must be provided');

    return Rule(
      remittanceInfo: a ? RegExp(remittanceInfo) : null,
      creditorName: b ? RegExp(creditorName) : null,
      creditorIban: c ? RegExp(creditorIban) : null,
    );
  }
}
