import 'package:finances/category/models/category.dart';
import 'package:flutter/material.dart';

CategoryModel seedCategories() {
  var id = -1;

  var root = CategoryModel(
    id: CategoryIds.root,
    name: 'Root',
    icon: Icons.home_rounded,
    color: const Color(0xFFAED581),
  );

  root.addChildren([
    CategoryModel(
      id: id--,
      name: 'Food & drinks',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFFE39755),
    )..addChildren([
        CategoryModel(
          id: CategoryIds.groceries,
          name: 'Groceries',
          icon: Icons.local_grocery_store_rounded,
          color: const Color(0xFFFFD54F),
        )..addChildren([
            CategoryModel(
              id: id--,
              name: 'Milk',
              icon: Icons.water_drop_rounded,
              color: const Color(0xFFFFFFFF),
            ),
            CategoryModel(
              id: id--,
              name: 'Nuts',
              icon: Icons.egg_alt_rounded,
              color: const Color(0xFFFFD54F),
            ),
          ]),
        CategoryModel(
          id: id--,
          name: 'Coffee',
          icon: Icons.local_cafe,
          color: const Color(0xFF795548),
        ),
        CategoryModel(
          id: id--,
          name: 'Eating out',
          icon: Icons.restaurant_menu,
          color: const Color(0xFF90A4AE),
        ),
      ]),
    CategoryModel(
      id: id--,
      name: 'Housing',
      icon: Icons.house_rounded,
      color: const Color(0xFFFFD180),
    )..addChildren([
        CategoryModel(
          id: id--,
          name: 'Rent',
          icon: Icons.real_estate_agent_rounded,
          color: const Color(0xFFA1887F),
        ),
        CategoryModel(
          id: CategoryIds.utilities,
          name: 'Utilities',
          icon: Icons.warehouse_rounded,
          color: const Color(0xFF7CFFD6),
        )..addChildren([
            CategoryModel(
              id: CategoryIds.electricity,
              name: 'Electricity',
              icon: Icons.electrical_services_rounded,
              color: const Color(0xFF7CFFD6),
            ),
            CategoryModel(
              id: id--,
              name: 'Cold water',
              icon: Icons.water_drop_rounded,
              color: const Color(0xFF2196F3),
            ),
            CategoryModel(
              id: id--,
              name: 'Hot water',
              icon: Icons.hot_tub_rounded,
              color: const Color(0xFFFF8A80),
            ),
            CategoryModel(
              id: id--,
              name: 'Heating',
              icon: Icons.local_fire_department_rounded,
              color: const Color(0xFFD32F2F),
            ),
          ]),
      ]),
    CategoryModel(
      id: id--,
      name: 'Transport',
      icon: Icons.map_rounded,
      color: const Color(0xFF949599),
    )..addChildren([
        CategoryModel(
          id: CategoryIds.fuel,
          name: 'Fuel',
          icon: Icons.local_gas_station,
          color: const Color(0xFF424242),
        ),
        CategoryModel(
          id: id--,
          name: 'Maintenance',
          icon: Icons.handyman,
          color: const Color(0xFF3F51B5),
        ),
        CategoryModel(
          id: id--,
          name: 'Parking',
          icon: Icons.local_parking_rounded,
          color: const Color(0xFF2196F3),
        ),
      ]),
    CategoryModel(
      id: id--,
      name: 'Entertainment',
      icon: Icons.attractions,
      color: const Color(0xFF9CCC65),
      parent: root,
    )..addChildren([
        CategoryModel(
          id: CategoryIds.music,
          name: 'Music',
          icon: Icons.headphones,
          color: const Color(0xFF1DCE44),
        ),
        CategoryModel(
          id: id--,
          name: 'Books',
          icon: Icons.menu_book,
          color: const Color(0xFF723F13),
        ),
        CategoryModel(
          id: CategoryIds.hobbies,
          name: 'Hobbies',
          icon: Icons.sentiment_very_satisfied_rounded,
          color: const Color(0xFFC8E6C9),
        ),
        CategoryModel(
          id: id--,
          name: 'Fitness',
          icon: Icons.sports_martial_arts_rounded,
          color: const Color(0xFFC8E6C9),
        )..addChildren([
            CategoryModel(
              id: CategoryIds.gym,
              name: 'Gym membership',
              icon: Icons.fitness_center_rounded,
              color: const Color(0xFF007BCC),
            )..addChildren([
                CategoryModel(
                  id: id--,
                  name: 'Fitness',
                  icon: Icons.sports_martial_arts_rounded,
                  color: const Color(0xFFC8E6C9),
                )
              ]),
            CategoryModel(
              id: CategoryIds.supplements,
              name: 'Supplements',
              icon: Icons.breakfast_dining_rounded,
              color: const Color(0xFFE0E0E0),
            )..addChildren([
                CategoryModel(
                  id: id--,
                  name: 'Fitness',
                  icon: Icons.sports_martial_arts_rounded,
                  color: const Color(0xFFC8E6C9),
                )
              ]),
          ]),
      ]),
    CategoryModel(
      id: id--,
      name: 'Income',
      icon: Icons.attach_money_rounded,
      color: const Color(0xFFAED581),
      parent: root,
    )..addChildren([
        CategoryModel(
          id: CategoryIds.salary,
          name: 'Salary',
          icon: Icons.savings_rounded,
          color: const Color(0xFFFFEE58),
        ),
        CategoryModel(
          id: id--,
          name: 'Sale',
          icon: Icons.currency_exchange_rounded,
          color: const Color(0xFF9ED75B),
        ),
        CategoryModel(
          id: id--,
          name: 'Receiving gifts',
          icon: Icons.redeem_rounded,
          color: const Color(0xFFD2546B),
        ),
      ]),
    CategoryModel(
      id: CategoryIds.other,
      name: 'Other',
      icon: Icons.question_mark_rounded,
      color: const Color(0xFFBDBDBD),
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
