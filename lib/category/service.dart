import 'package:finances/category/models/category.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CategoryService with ChangeNotifier {
  int _id = 20;

  static final instance = CategoryService._ctor();

  CategoryModel lastSelection = food;

  CategoryService._ctor() {
    entertainment.children = [spotify];
  }

  CategoryModel root = CategoryModel(
    id: 0,
    name: 'Root',
    icon: Symbols.engineering,
    children: [
      food,
      transport,
      entertainment,
      income,
      other,
    ],
  );

  void addChild(CategoryModel parent, CategoryModel child) {
    child.id = _id++;
    parent.children.add(child);
    child.parent = parent;
    notifyListeners();
  }

  void update(CategoryModel target, String newName) {
    target.name = newName;
    notifyListeners();
  }

  CategoryModel? findById(int id, {CategoryModel? startingFrom}) {
    CategoryModel current = startingFrom ?? root;

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
}

final nuts = CategoryModel(
  id: 1,
  name: 'Nuts',
  icon: Symbols.nutrition,
);
final sports = CategoryModel(
  id: 2,
  name: 'Sport related',
  icon: Symbols.exercise,
);

final food = CategoryModel(
  id: 3,
  name: 'Food',
  icon: Symbols.restaurant,
  children: [
    CategoryModel(
      id: 4,
      name: 'Groceries',
      icon: Symbols.grocery,
    ),
    CategoryModel(
      id: 5,
      name: 'Restaurant',
      icon: Symbols.restaurant,
    ),
    nuts,
    sports,
  ],
);

final transport = CategoryModel(
  id: 6,
  name: 'Transportation',
  icon: Symbols.map,
  children: [
    CategoryModel(
      id: 7,
      name: 'Bicycle',
      icon: Symbols.pedal_bike,
    ),
    CategoryModel(
      id: 8,
      name: 'Public',
      icon: Symbols.directions_bus,
    ),
    CategoryModel(
      id: 9,
      name: 'Vehicle',
      icon: Symbols.directions_car,
    ),
  ],
);

final income = CategoryModel(
  id: 10,
  name: 'Income',
  icon: Symbols.attach_money,
  children: [
    CategoryModel(
      id: 11,
      name: 'Salary',
      icon: Symbols.add_business,
    ),
    CategoryModel(
      id: 12,
      name: 'Refunds',
      icon: Symbols.currency_exchange,
    ),
  ],
);

final entertainment = CategoryModel(
  id: 13,
  name: 'Entertainment',
  icon: Symbols.sports_esports,
);

final spotify = CategoryModel(
  id: 14,
  name: 'Spotify',
  icon: Symbols.headphones,
);

final other = CategoryModel(
  id: 15,
  name: 'Other',
  icon: Symbols.question_mark,
);
