import 'package:flutter/widgets.dart';

class CategoryModel {
  int id;
  String name;
  IconData icon;
  Color color;
  CategoryModel? parent;
  List<CategoryModel> children = [];

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.parent,
    List<CategoryModel>? children,
  }) {
    if (children != null) {
      this.children = children;
    }
  }

  bool isNestedChildOf(CategoryModel category) {
    if (this == category) {
      return true;
    }

    if (parent == null) {
      return false;
    }

    return parent!.isNestedChildOf(category);
  }
}
