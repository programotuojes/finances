import 'package:collection/collection.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/seed.dart';
import 'package:finances/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class CategoryService with ChangeNotifier {
  static final instance = CategoryService._ctor();
  late final SharedPreferences storage;

  late CategoryModel rootCategory;
  late CategoryModel otherCategory;
  late CategoryModel lastSelection;

  CategoryService._ctor();

  Future<void> addChild(
    CategoryModel parent, {
    required String name,
    required Color color,
    required IconData icon,
  }) async {
    var child = CategoryModel(
      name: name,
      color: color,
      icon: icon,
    );

    parent.addChild(child);

    child.id = await Db.instance.db.insert(
      'categories',
      child.toMap(setId: false),
    );

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

  Future<void> initialize() async {
    storage = await SharedPreferences.getInstance();

    var dbCategories = await Db.instance.db.query('categories');
    var categories = dbCategories.map((e) => CategoryModel.fromMap(e)).toList();

    for (var category in categories) {
      category.addChildren(categories.where((x) => x.parentId == category.id));
    }

    var root = categories.firstWhereOrNull((category) => category.id == CategoryIds.root);

    if (root == null) {
      var root = seedCategories();

      var batch = Db.instance.db.batch();
      _insertWithChildren(batch, root);
      await batch.commit(noResult: true);

      rootCategory = root;
      otherCategory = root.children.firstWhere((element) => element.id == CategoryIds.other);
      lastSelection = root.children.first;
    } else {
      rootCategory = root;
      otherCategory = categories.firstWhere((element) => element.id == CategoryIds.other);

      var lastSelectionId = storage.getInt('lastSelectionId');
      if (lastSelectionId != null) {
        lastSelection = categories.firstWhere((element) => element.id == lastSelectionId);
      } else {
        lastSelection = rootCategory.children.first;
      }
    }
  }

  Future<void> update(
    CategoryModel target, {
    String? newName,
    Color? newColor,
    IconData? newIcon,
  }) async {
    target.name = newName ?? target.name;
    target.color = newColor ?? target.color;
    target.icon = newIcon ?? target.icon;

    await Db.instance.db.update(
      'categories',
      target.toMap(),
      where: 'id = ?',
      whereArgs: [target.id],
    );

    notifyListeners();
  }

  void _insertWithChildren(Batch batch, CategoryModel parent) {
    batch.insert('categories', parent.toMap());

    for (var i in parent.children) {
      _insertWithChildren(batch, i);
    }
  }
}
