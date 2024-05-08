import 'package:finances/category/models/category.dart';
import 'package:finances/category/seed.dart';
import 'package:flutter/material.dart';


class CategoryService with ChangeNotifier {
  static final instance = CategoryService._ctor();

  var _id = 100;
  late CategoryModel rootCategory;
  late CategoryModel otherCategory;
  late CategoryModel lastSelection;

  CategoryService._ctor() {
    var (:root, :other) = seedCategories();
    rootCategory = root;
    otherCategory = other;
    lastSelection = root.children.first;
  }

  void addChild(CategoryModel parent, CategoryModel child) {
    child.id = _id++;
    parent.children.add(child);
    child.parent = parent;
    notifyListeners();
  }

  CategoryModel? findById(int id, {CategoryModel? startingFrom}) {
    CategoryModel current = startingFrom ?? rootCategory;

    if (current.id == id) {
      return current;
    }

    for (var x in current.children) {
      var result = findById(id, startingFrom: x);
      if (result != null) {
        return result;
      }
    }

    return null;
  }

  void update(
    CategoryModel target, {
    String? newName,
    Color? newColor,
  }) {
    if (newName != null) {
      target.name = newName;
    }

    if (newColor != null) {
      target.color = newColor;
    }

    notifyListeners();
  }
}
