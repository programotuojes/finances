import 'package:flutter/widgets.dart';

class CategoryModel {
  int id;
  String name;
  IconData icon;
  CategoryModel? parent;
  List<CategoryModel> children = [];

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.parent,
    List<CategoryModel>? children,
  }) {
    if (children != null) {
      this.children = children;
    }
  }
}

