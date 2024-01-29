import 'package:finances/category/service.dart';

class CategoryModel {
  String name;
  CategoryModel? parent;
  List<CategoryModel> children = List.empty(growable: true);

  CategoryModel({
    required this.name,
    this.parent,
    List<CategoryModel>? children,
  }) {
    if (children != null) {
      this.children = children;
    }
  }

  void addChild(String name) {
    children.add(CategoryModel(
      name: name,
      parent: this,
    ));
    CategoryService.instance.notify();
  }

  void update(String newName) {
    name = newName;
    CategoryService.instance.notify();
  }
}
