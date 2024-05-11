import 'package:flutter/widgets.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:sqflite/sqflite.dart';

class CategoryModel {
  int id;
  String name;
  Color color;
  IconData icon;
  int? parentId;
  CategoryModel? parent;
  final List<CategoryModel> children = [];

  CategoryModel({
    this.id = -1,
    required this.name,
    required this.color,
    required this.icon,
    this.parentId,
    this.parent,
  }) {
    if (parent != null) {
      parentId = parent?.id;
    }
  }

  factory CategoryModel.fromMap(Map<String, Object?> map) {
    var icon = deserializeIcon(
      {
        'pack': map['iconPack'],
        'key': map['iconKey'],
      },
      iconPack: IconPack.allMaterial,
    )!;

    return CategoryModel(
      id: map['id'] as int,
      name: map['name'] as String,
      color: Color(map['color'] as int),
      icon: icon,
      parentId: map['parentId'] as int?,
    );
  }

  void addChildren(Iterable<CategoryModel> children) {
    for (var i in children) {
      addChild(i);
    }
  }

  void addChild(CategoryModel child) {
    children.add(child);
    child.parent = this;
    child.parentId = id;
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

  Map<String, Object?> toMap({bool setId = true}) {
    var icon = serializeIcon(this.icon, iconPack: IconPack.allMaterial)!;

    return {
      'id': setId ? id : null,
      'name': name,
      'color': color.value,
      'iconPack': icon['pack'],
      'iconKey': icon['key'],
      'parentId': parent?.id,
    };
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
