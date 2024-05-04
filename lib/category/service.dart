import 'package:finances/category/models/category.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

({CategoryModel root, CategoryModel other}) _seed() {
  var id = 0;

  var root = CategoryModel(id: id--, name: 'Root', icon: Icons.home_rounded, color: const Color(0xFFAED581));

  var food = CategoryModel(
    id: id--,
    name: 'Food & drinks',
    icon: Icons.restaurant_rounded,
    color: const Color(0xFFE39755),
    parent: root,
  );
  var groceries = CategoryModel(
    id: CategoryIds.groceries,
    name: 'Groceries',
    icon: Icons.local_grocery_store_rounded,
    color: const Color(0xFFFFD54F),
    parent: food,
  );
  var milk = CategoryModel(
    id: id--,
    name: 'Milk',
    icon: Symbols.grocery_rounded,
    color: const Color(0xFFFFFFFF),
    parent: groceries,
  );
  var nuts = CategoryModel(
    id: id--,
    name: 'Nuts',
    icon: Symbols.nutrition,
    color: const Color(0xFFFFD54F),
    parent: groceries,
  );
  var coffee = CategoryModel(
    id: id--,
    name: 'Coffee',
    icon: Icons.local_cafe,
    color: const Color(0xFF795548),
    parent: food,
  );
  var eatingOut = CategoryModel(
    id: id--,
    name: 'Eating out',
    icon: Icons.restaurant_menu,
    color: const Color(0xFF90A4AE),
    parent: food,
  );
  food.children.addAll([
    groceries
      ..children.addAll([
        milk,
        nuts,
      ]),
    coffee,
    eatingOut,
  ]);

  var housing = CategoryModel(
    id: id--,
    name: 'Housing',
    icon: Symbols.house,
    color: const Color(0xFFFFD180),
    parent: root,
  );
  var rent = CategoryModel(
    id: id--,
    name: 'Rent',
    icon: Symbols.real_estate_agent,
    color: const Color(0xFFA1887F),
    parent: housing,
  );
  var utilities = CategoryModel(
    id: CategoryIds.utilities,
    name: 'Utilities',
    icon: Symbols.electrical_services,
    color: const Color(0xFF7CFFD6),
    parent: housing,
  );
  var electricity = CategoryModel(
    id: CategoryIds.electricity,
    name: 'Electricity',
    icon: Symbols.electrical_services,
    color: const Color(0xFF7CFFD6),
    parent: utilities,
  );
  var coldWater = CategoryModel(
    id: id--,
    name: 'Cold water',
    icon: Symbols.water_drop,
    color: const Color(0xFF2196F3),
    parent: utilities,
  );
  var hotWater = CategoryModel(
    id: id--,
    name: 'Hot water',
    icon: Symbols.bathtub,
    color: const Color(0xFFFF8A80),
    parent: utilities,
  );
  var heating = CategoryModel(
    id: id--,
    name: 'Heating',
    icon: Symbols.heat,
    color: const Color(0xFFD32F2F),
    parent: utilities,
  );
  housing.children.addAll([
    rent,
    utilities
      ..children.addAll([
        electricity,
        coldWater,
        hotWater,
        heating,
      ]),
  ]);

  var transport = CategoryModel(
    id: id--,
    name: 'Transport',
    icon: Icons.map_rounded,
    color: const Color(0xFF949599),
    parent: root,
  );
  var fuel = CategoryModel(
    id: CategoryIds.fuel,
    name: 'Fuel',
    icon: Symbols.directions_car_rounded,
    color: const Color(0xFF424242),
    parent: transport,
  );
  var maintenance = CategoryModel(
    id: id--,
    name: 'Maintenance',
    icon: Icons.handyman,
    color: const Color(0xFF3F51B5),
    parent: transport,
  );
  var parking = CategoryModel(
    id: id--,
    name: 'Parking',
    icon: Icons.local_parking_rounded,
    color: const Color(0xFF2196F3),
    parent: transport,
  );
  transport.children.addAll([
    fuel,
    maintenance,
    parking,
  ]);

  var entertainment = CategoryModel(
    id: id--,
    name: 'Entertainment',
    icon: Symbols.attractions,
    color: const Color(0xFF9CCC65),
    parent: root,
  );
  var music = CategoryModel(
    id: CategoryIds.music,
    name: 'Music',
    icon: Symbols.headphones,
    color: const Color(0xFF1DCE44),
    parent: entertainment,
  );
  var books = CategoryModel(
    id: id--,
    name: 'Books',
    icon: Symbols.menu_book,
    color: const Color(0xFF723F13),
    parent: entertainment,
  );
  var hobbies = CategoryModel(
    id: CategoryIds.hobbies,
    name: 'Hobbies',
    icon: Symbols.sports_tennis,
    color: const Color(0xFFC8E6C9),
    parent: entertainment,
  );
  var fitness = CategoryModel(
    id: id--,
    name: 'Fitness',
    icon: Symbols.sports_martial_arts,
    color: const Color(0xFFC8E6C9),
    parent: entertainment,
  );
  var gym = CategoryModel(
    id: CategoryIds.gym,
    name: 'Gym membership',
    icon: Symbols.fitness_center,
    color: const Color(0xFF007BCC),
    parent: fitness,
  );
  var supplements = CategoryModel(
    id: CategoryIds.supplements,
    name: 'Supplements',
    icon: Symbols.pill,
    color: const Color(0xFFE0E0E0),
    parent: fitness,
  );
  entertainment.children.addAll([
    music,
    books,
    hobbies,
    fitness
      ..children.addAll([
        gym,
        supplements,
      ]),
  ]);

  var income = CategoryModel(
    id: id--,
    name: 'Income',
    icon: Icons.attach_money_rounded,
    color: const Color(0xFFAED581),
    parent: root,
  );
  var salary = CategoryModel(
    id: CategoryIds.salary,
    name: 'Salary',
    icon: Symbols.savings,
    color: const Color(0xFFFFEE58),
    parent: income,
  );
  var sale = CategoryModel(
    id: id--,
    name: 'Sale',
    icon: Symbols.currency_exchange,
    color: const Color(0xFF9ED75B),
    parent: income,
  );
  var gifts = CategoryModel(
    id: id--,
    name: 'Receiving gifts',
    icon: Symbols.redeem,
    color: const Color(0xFFD2546B),
    parent: income,
  );
  income.children.addAll([
    salary,
    sale,
    gifts,
  ]);

  var other = CategoryModel(
    id: id--,
    name: 'Other',
    icon: Icons.question_mark_rounded,
    color: const Color(0xFFBDBDBD),
    parent: root,
  );

  root.children.addAll([
    food,
    housing,
    transport,
    entertainment,
    income,
    other,
  ]);

  return (root: root, other: other);
}

class CategoryIds {
  static const groceries = 1;
  static const music = 2;
  static const fuel = 4;
  static const gym = 5;
  static const supplements = 6;
  static const hobbies = 7;
  static const utilities = 8;
  static const electricity = 9;
  static const salary = 10;
}

class CategoryService with ChangeNotifier {
  static final instance = CategoryService._ctor();

  var _id = 100;
  late CategoryModel root;
  late CategoryModel categoryOther;
  late CategoryModel lastSelection;

  CategoryService._ctor() {
    var (:root, :other) = _seed();
    this.root = root;
    categoryOther = other;
    lastSelection = root.children.first;
  }

  void addChild(CategoryModel parent, CategoryModel child) {
    child.id = _id++;
    parent.children.add(child);
    child.parent = parent;
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
