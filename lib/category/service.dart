import 'package:finances/category/models/category.dart';
import 'package:flutter/foundation.dart';

class CategoryService with ChangeNotifier {
  static final instance = CategoryService._ctor();

  CategoryModel lastSelection = food;

  CategoryService._ctor();

  CategoryModel root = CategoryModel(
    name: 'Root',
    children: [
      food,
      transport,
      income,
      other,
    ],
  );

  void notify() => notifyListeners();
}

final food = CategoryModel(
  name: 'Food',
  children: [
    CategoryModel(name: 'Groceries'),
    CategoryModel(name: 'Restaurant'),
  ],
);

final transport = CategoryModel(
  name: 'Transportation',
  children: [
    CategoryModel(name: 'Bicycle'),
    CategoryModel(name: 'Public'),
    CategoryModel(name: 'Vehicle'),
  ],
);

final income = CategoryModel(
  name: 'Income',
  children: [
    CategoryModel(name: 'Salary'),
    CategoryModel(name: 'Refunds'),
  ],
);

final other = CategoryModel(name: 'Other');
