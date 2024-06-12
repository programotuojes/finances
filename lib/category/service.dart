import 'package:collection/collection.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/seed.dart';
import 'package:finances/utils/db.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

const _lastSelectedKey = 'lastSelectedCategoryId';

class CategoryService with ChangeNotifier {
  static final instance = CategoryService._ctor();
  late SharedPreferences _storage;
  late CategoryModel _lastSelection;
  late CategoryModel _otherCategory;
  late CategoryModel _rootCategory;

  CategoryService._ctor();

  CategoryModel get lastSelection => _lastSelection;
  CategoryModel get otherCategory => _otherCategory;
  CategoryModel get rootCategory => _rootCategory;

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
      orderIndex: parent.children.length,
    );

    parent.addChild(child);

    child.id = await database.insert('categories', child.toMap(setId: false));

    notifyListeners();
  }

  CategoryModel? findById(int id, {CategoryModel? startingFrom}) {
    CategoryModel current = startingFrom ?? _rootCategory;

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
    _storage = await SharedPreferences.getInstance();

    var dbCategories = await database.query('categories', orderBy: 'orderIndex');
    var categories = dbCategories.map((e) => CategoryModel.fromMap(e)).toList();

    for (var category in categories) {
      category.addChildren(categories.where((x) => x.parentId == category.id));
    }

    var root = categories.firstWhereOrNull((category) => category.id == CategoryIds.root);
    if (root == null) {
      root = seedCategories();

      var batch = database.batch();
      _dbInsertWithChildren(batch, root);
      await batch.commit(noResult: true);
    }

    _rootCategory = root;
    _otherCategory = findById(CategoryIds.other)!;

    var lastSelectionId = _storage.getInt(_lastSelectedKey);
    if (lastSelectionId != null) {
      _lastSelection = findById(lastSelectionId) ?? root.children.first;
    } else {
      _lastSelection = root.children.first;
    }

    notifyListeners();
  }

  Future<void> setLastSelection(CategoryModel category) async {
    await _storage.setInt(_lastSelectedKey, category.id);
    _lastSelection = category;
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

    final batch = database.batch();
    for (var i = 0; i < target.children.length; i++) {
      target.children[i].orderIndex = i;
      batch.rawUpdate('update categories set orderIndex = ? where id = ?', [i, target.children[i].id]);
    }
    await batch.commit(noResult: true);

    await database.update('categories', target.toMap(), where: 'id = ?', whereArgs: [target.id]);

    notifyListeners();
  }

  void _dbInsertWithChildren(Batch batch, CategoryModel category) {
    batch.insert('categories', category.toMap());

    for (var i in category.children) {
      _dbInsertWithChildren(batch, i);
    }
  }
}
