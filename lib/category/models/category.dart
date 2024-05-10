import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

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

  static void createTable(Batch batch) {
    batch.execute('''
      create table categories (
        id integer primary key autoincrement,
        name text not null,
        color integer not null,
        iconPack text not null,
        iconKey text not null,
        parentId integer,
        foreign key (parentId) references categories(id) on delete cascade
      )
    ''');
  }
}
