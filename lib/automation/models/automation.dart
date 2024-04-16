import 'package:finances/category/models/category.dart';
import 'package:flutter/foundation.dart';

class Automation with ChangeNotifier {
  /// All rules are ORed together
  List<Rule> rules = List.empty(growable: true);
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
  RegExp regex;
  bool invert;

  Rule({
    required this.regex,
    this.invert = false,
  });
}
