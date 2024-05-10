import 'package:flutter/widgets.dart';

class CategoryModel {
  int id;
  String name;
  Color color;
  IconData icon;
  CategoryModel? parent;
  List<CategoryModel> children = [];

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
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
