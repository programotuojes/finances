import 'package:finances/category/models/category.dart';
import 'package:flutter/foundation.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CategoryService with ChangeNotifier {
  static final instance = CategoryService._ctor();

  CategoryModel lastSelection = food;

  CategoryService._ctor() {
    entertainment.children = [spotify];
  }

  CategoryModel root = CategoryModel(
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

  void notify() => notifyListeners();
}

final food = CategoryModel(
  name: 'Food',
  icon: Symbols.restaurant,
  children: [
    CategoryModel(
      name: 'Groceries',
      icon: Symbols.grocery,
    ),
    CategoryModel(
      name: 'Restaurant',
      icon: Symbols.restaurant,
    ),
  ],
);

final transport = CategoryModel(
  name: 'Transportation',
  icon: Symbols.map,
  children: [
    CategoryModel(
      name: 'Bicycle',
      icon: Symbols.pedal_bike,
    ),
    CategoryModel(
      name: 'Public',
      icon: Symbols.directions_bus,
    ),
    CategoryModel(
      name: 'Vehicle',
      icon: Symbols.directions_car,
    ),
  ],
);

final income = CategoryModel(
  name: 'Income',
  icon: Symbols.attach_money,
  children: [
    CategoryModel(
      name: 'Salary',
      icon: Symbols.add_business,
    ),
    CategoryModel(
      name: 'Refunds',
      icon: Symbols.currency_exchange,
    ),
  ],
);

final entertainment = CategoryModel(
  name: 'Entertainment',
  icon: Symbols.sports_esports,
);

final spotify = CategoryModel(
  name: 'Spotify',
  icon: Symbols.headphones,
);

final other = CategoryModel(
  name: 'Other',
  icon: Symbols.question_mark,
);
