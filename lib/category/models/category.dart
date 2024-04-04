import 'package:finances/category/service.dart';
import 'package:flutter/widgets.dart';

class CategoryModel {
  String name;
  IconData icon;
  CategoryModel? parent;
  List<CategoryModel> children = List.empty(growable: true);

  CategoryModel({
    required this.name,
    required this.icon,
    this.parent,
    List<CategoryModel>? children,
  }) {
    if (children != null) {
      this.children = children;
    }
  }

  void addChild(String name, IconData icon) {
    children.add(CategoryModel(
      name: name,
      icon: icon,
      parent: this,
    ));
    CategoryService.instance.notify();
  }

  void update(String newName) {
    name = newName;
    CategoryService.instance.notify();
  }
}
