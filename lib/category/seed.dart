import 'package:finances/category/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/IconPicker/Packs/MaterialRounded.dart';

CategoryModel seedCategories() {
  var id = -1;

  var root = CategoryModel(
    id: CategoryIds.root,
    name: 'Root',
    icon: roundedIcons['home_rounded']!,
    color: const Color(0xFFAED581),
    orderIndex: 0,
  );

  root.addChildren([
    CategoryModel(
      id: id--,
      name: 'Food & drinks',
      icon: roundedIcons['restaurant_rounded']!,
      color: const Color(0xFFE39755),
      orderIndex: 0,
    )..addChildren([
        CategoryModel(
          id: CategoryIds.groceries,
          name: 'Groceries',
          icon: roundedIcons['local_grocery_store_rounded']!,
          color: const Color(0xFFFFD54F),
          orderIndex: 0,
        )..addChildren([
            CategoryModel(
              id: id--,
              name: 'Milk',
              icon: roundedIcons['water_drop_rounded']!,
              color: const Color(0xFFFFFFFF),
              orderIndex: 0,
            ),
            CategoryModel(
              id: id--,
              name: 'Nuts',
              icon: roundedIcons['egg_alt_rounded']!,
              color: const Color(0xFFFFD54F),
              orderIndex: 1,
            ),
          ]),
        CategoryModel(
          id: id--,
          name: 'Coffee',
          icon: roundedIcons['local_cafe_rounded']!,
          color: const Color(0xFF795548),
          orderIndex: 1,
        ),
        CategoryModel(
          id: id--,
          name: 'Eating out',
          icon: roundedIcons['restaurant_menu_rounded']!,
          color: const Color(0xFF90A4AE),
          orderIndex: 2,
        ),
      ]),
    CategoryModel(
      id: id--,
      name: 'Housing',
      icon: roundedIcons['house_rounded']!,
      color: const Color(0xFFFFD180),
      orderIndex: 1,
    )..addChildren([
        CategoryModel(
          id: id--,
          name: 'Rent',
          icon: roundedIcons['real_estate_agent_rounded']!,
          color: const Color(0xFFA1887F),
          orderIndex: 0,
        ),
        CategoryModel(
          id: CategoryIds.utilities,
          name: 'Utilities',
          icon: roundedIcons['warehouse_rounded']!,
          color: const Color(0xFF7CFFD6),
          orderIndex: 1,
        )..addChildren([
            CategoryModel(
              id: CategoryIds.electricity,
              name: 'Electricity',
              icon: roundedIcons['electrical_services_rounded']!,
              color: const Color(0xFF7CFFD6),
              orderIndex: 0,
            ),
            CategoryModel(
              id: id--,
              name: 'Cold water',
              icon: roundedIcons['water_drop_rounded']!,
              color: const Color(0xFF2196F3),
              orderIndex: 1,
            ),
            CategoryModel(
              id: id--,
              name: 'Hot water',
              icon: roundedIcons['hot_tub_rounded']!,
              color: const Color(0xFFFF8A80),
              orderIndex: 2,
            ),
            CategoryModel(
              id: id--,
              name: 'Heating',
              icon: roundedIcons['local_fire_department_rounded']!,
              color: const Color(0xFFD32F2F),
              orderIndex: 3,
            ),
          ]),
      ]),
    CategoryModel(
      id: id--,
      name: 'Transport',
      icon: roundedIcons['map_rounded']!,
      color: const Color(0xFF949599),
      orderIndex: 2,
    )..addChildren([
        CategoryModel(
          id: CategoryIds.fuel,
          name: 'Fuel',
          icon: roundedIcons['local_gas_station_rounded']!,
          color: const Color(0xFF424242),
          orderIndex: 0,
        ),
        CategoryModel(
          id: id--,
          name: 'Maintenance',
          icon: roundedIcons['handyman_rounded']!,
          color: const Color(0xFF3F51B5),
          orderIndex: 1,
        ),
        CategoryModel(
          id: id--,
          name: 'Parking',
          icon: roundedIcons['local_parking_rounded']!,
          color: const Color(0xFF2196F3),
          orderIndex: 2,
        ),
      ]),
    CategoryModel(
      id: id--,
      name: 'Entertainment',
      icon: roundedIcons['attractions_rounded']!,
      color: const Color(0xFF9CCC65),
      parent: root,
      orderIndex: 3,
    )..addChildren([
        CategoryModel(
          id: CategoryIds.music,
          name: 'Music',
          icon: roundedIcons['headphones_rounded']!,
          color: const Color(0xFF1DCE44),
          orderIndex: 0,
        ),
        CategoryModel(
          id: id--,
          name: 'Books',
          icon: roundedIcons['menu_book_rounded']!,
          color: const Color(0xFF723F13),
          orderIndex: 1,
        ),
        CategoryModel(
          id: CategoryIds.hobbies,
          name: 'Hobbies',
          icon: roundedIcons['sentiment_very_satisfied_rounded']!,
          color: const Color(0xFFC8E6C9),
          orderIndex: 2,
        ),
        CategoryModel(
          id: id--,
          name: 'Fitness',
          icon: roundedIcons['sports_martial_arts_rounded']!,
          color: const Color(0xFFC8E6C9),
          orderIndex: 3,
        )..addChildren([
            CategoryModel(
              id: CategoryIds.gym,
              name: 'Gym membership',
              icon: roundedIcons['fitness_center_rounded']!,
              color: const Color(0xFF007BCC),
              orderIndex: 0,
            ),
            CategoryModel(
              id: CategoryIds.supplements,
              name: 'Supplements',
              icon: roundedIcons['breakfast_dining_rounded']!,
              color: const Color(0xFFE0E0E0),
              orderIndex: 1,
            ),
          ]),
      ]),
    CategoryModel(
      id: id--,
      name: 'Income',
      icon: roundedIcons['attach_money_rounded']!,
      color: const Color(0xFFAED581),
      parent: root,
      orderIndex: 4,
    )..addChildren([
        CategoryModel(
          id: CategoryIds.salary,
          name: 'Salary',
          icon: roundedIcons['savings_rounded']!,
          color: const Color(0xFFFFEE58),
          orderIndex: 0,
        ),
        CategoryModel(
          id: id--,
          name: 'Sale',
          icon: roundedIcons['currency_exchange_rounded']!,
          color: const Color(0xFF9ED75B),
          orderIndex: 1,
        ),
        CategoryModel(
          id: id--,
          name: 'Receiving gifts',
          icon: roundedIcons['redeem_rounded']!,
          color: const Color(0xFFD2546B),
          orderIndex: 2,
        ),
      ]),
    CategoryModel(
      id: CategoryIds.other,
      name: 'Other',
      icon: roundedIcons['question_mark_rounded']!,
      color: const Color(0xFFBDBDBD),
      orderIndex: 5,
    ),
  ]);

  return root;
}

class CategoryIds {
  static const root = 0;
  static const groceries = 1;
  static const music = 2;
  static const fuel = 4;
  static const gym = 5;
  static const supplements = 6;
  static const hobbies = 7;
  static const utilities = 8;
  static const electricity = 9;
  static const salary = 10;
  static const other = 11;
}
