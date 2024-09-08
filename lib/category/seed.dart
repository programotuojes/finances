import 'package:finances/category/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/IconPicker/Packs/FontAwesome.dart';
import 'package:flutter_iconpicker/IconPicker/Packs/MaterialDefault.dart';

CategoryModel seedCategories() {
  var id = 1;

  var root = CategoryModel(
    id: CategoryIds.root,
    name: 'Root',
    icon: defaultIcons['home']!,
    color: const Color(0xFFAED581),
  );

  root.addChildren([
    CategoryModel(
      id: id++,
      name: 'Food',
      icon: defaultIcons['restaurant']!,
      color: const Color(0xFFFFB74D),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Groceries',
          icon: defaultIcons['shopping_basket']!,
          color: const Color(0xFF4FC3F7),
        ),
        CategoryModel(
          id: id++,
          name: 'Restaurants, cafes',
          icon: defaultIcons['table_bar']!,
          color: const Color(0xFFFF8A65),
        ),
      ]),
    CategoryModel(
      id: id++,
      name: 'Substances',
      icon: defaultIcons['liquor']!,
      color: const Color(0xFFC62828),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Alcohol',
          icon: defaultIcons['local_bar']!,
          color: const Color(0xFFFFE082),
        ),
        CategoryModel(
          id: id++,
          name: 'Tobacco',
          icon: defaultIcons['smoking_rooms']!,
          color: const Color(0xFF3E2723),
        ),
        CategoryModel(
          id: id++,
          name: 'Vape',
          icon: defaultIcons['vaping_rooms']!,
          color: const Color(0xFF4DB6AC),
        ),
        CategoryModel(
          id: id++,
          name: 'Drugs',
          icon: fontAwesomeIcons['cannabis']!,
          color: const Color(0xFF388E3C),
        ),
      ]),
    CategoryModel(
      id: id++,
      name: 'Shopping',
      icon: defaultIcons['shopping_bag']!,
      color: const Color(0xFF2196F3),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Clothes, shoes & accessories',
          icon: fontAwesomeIcons['shirt']!,
          color: const Color(0xFFD32F2F),
        ),
        CategoryModel(
          id: id++,
          name: 'Body care',
          icon: fontAwesomeIcons['soap']!,
          color: const Color(0xFFE0E0E0),
        ),
        CategoryModel(
          id: id++,
          name: 'Stationary',
          icon: fontAwesomeIcons['paperclip']!,
          color: const Color(0xFF7E57C2),
        ),
        CategoryModel(
          id: id++,
          name: 'Tools',
          icon: defaultIcons['home_repair_service']!,
          color: const Color(0xFFBCAAA4),
        ),
        CategoryModel(
          id: id++,
          name: 'Electronics, accessories',
          icon: defaultIcons['devices']!,
          color: const Color(0xFF4CAF50),
        ),
        CategoryModel(
          id: id++,
          name: 'Software',
          icon: defaultIcons['code']!,
          color: const Color(0xFF0288D1),
        ),
      ]),
    CategoryModel(
      id: id++,
      name: 'Pets',
      icon: defaultIcons['pets']!,
      color: const Color(0xFFA1887F),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Food',
          icon: defaultIcons['set_meal']!,
          color: const Color(0xFFEF9A9A),
        ),
        CategoryModel(
          id: id++,
          name: 'Toys & accessories',
          icon: fontAwesomeIcons['baseball']!,
          color: const Color(0xFF9575CD),
        ),
        CategoryModel(
          id: id++,
          name: 'Vet',
          icon: fontAwesomeIcons['userDoctor']!,
          color: const Color(0xFFF5F5F5),
        ),
      ]),
    CategoryModel(
      id: id++,
      name: 'Housing',
      icon: defaultIcons['home']!,
      color: const Color(0xFFF9A825),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Rent, mortgage',
          icon: defaultIcons['payments']!,
          color: const Color(0xFF303F9F),
        ),
        CategoryModel(
          id: id++,
          name: 'Utilities',
          icon: defaultIcons['shower']!,
          color: const Color(0xFF29B6F6),
        ),
        CategoryModel(
          id: id++,
          name: 'Maintenance & housewares',
          icon: defaultIcons['real_estate_agent']!,
          color: const Color(0xFF26A69A),
        ),
      ]),
    CategoryModel(
      id: id++,
      name: 'Recreation',
      icon: defaultIcons['beach_access']!,
      color: const Color(0xFFCDDC39),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Hobbies & activities',
          icon: defaultIcons['mood']!,
          color: const Color(0xFFD4E157),
        ),
        CategoryModel(
          id: id++,
          name: 'Events (holidays, birthdays)',
          icon: defaultIcons['cake']!,
          color: const Color(0xFF64B5F6),
        ),
        CategoryModel(
          id: id++,
          name: 'Travel, hotels',
          icon: defaultIcons['luggage']!,
          color: const Color(0xFF7986CB),
        ),
        CategoryModel(
          id: id++,
          name: 'Entertainment',
          icon: defaultIcons['event_seat']!,
          color: const Color(0xFFFFA000),
        )..addChildren([
            CategoryModel(
              id: id++,
              name: 'Games',
              icon: defaultIcons['videogame_asset']!,
              color: const Color(0xFF00695C),
            ),
            CategoryModel(
              id: id++,
              name: 'Books',
              icon: defaultIcons['auto_stories']!,
              color: const Color(0xFF795548),
            ),
            CategoryModel(
              id: id++,
              name: 'Music, concerts',
              icon: defaultIcons['headphones']!,
              color: const Color(0xFF66BB6A),
            ),
            CategoryModel(
              id: id++,
              name: 'Movies, shows',
              icon: defaultIcons['live_tv']!,
              color: const Color(0xFFD32F2F),
            ),
          ]),
      ]),
    CategoryModel(
      id: id++,
      name: 'Personal development',
      icon: defaultIcons['trending_up']!,
      color: const Color(0xFF81D4FA),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Education',
          icon: defaultIcons['school']!,
          color: const Color(0xFF607D8B),
        ),
        CategoryModel(
          id: id++,
          name: 'Fitness',
          icon: defaultIcons['fitness_center']!,
          color: const Color(0xFF388E3C),
        )..addChildren([
            CategoryModel(
              id: id++,
              name: 'Memberships',
              icon: defaultIcons['card_membership']!,
              color: const Color(0xFF4FC3F7),
            ),
            CategoryModel(
              id: id++,
              name: 'Supplements',
              icon: fontAwesomeIcons['jar']!,
              color: const Color(0xFFEFEBE9),
            ),
            CategoryModel(
              id: id++,
              name: 'Exercise equipment',
              icon: fontAwesomeIcons['dumbbell']!,
              color: const Color(0xFF7986CB),
            ),
          ]),
      ]),
    CategoryModel(
      id: id++,
      name: 'Medical',
      icon: defaultIcons['local_hospital']!,
      color: const Color(0xFFBBDEFB),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Medical services',
          icon: fontAwesomeIcons['userNurse']!,
          color: const Color(0xFF7986CB),
        ),
        CategoryModel(
          id: id++,
          name: 'Medications, supplements',
          icon: defaultIcons['medication']!,
          color: const Color(0xFFEEEEEE),
        ),
        CategoryModel(
          id: id++,
          name: 'Supplies (bandages, PPE, tests)',
          icon: defaultIcons['masks']!,
          color: const Color(0xFF01579B),
        ),
      ]),
    CategoryModel(
      id: id++,
      name: 'Transportation',
      icon: defaultIcons['transfer_within_a_station']!,
      color: const Color(0xFF949599),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Bicycle, scooter',
          icon: defaultIcons['directions_bike']!,
          color: const Color(0xFFD4E157),
        )..addChildren([
            CategoryModel(
              id: id++,
              name: 'Maintenance',
              icon: defaultIcons['build']!,
              color: const Color(0xFFA1887F),
            ),
            CategoryModel(
              id: id++,
              name: 'Rent',
              icon: defaultIcons['payments']!,
              color: const Color(0xFF388E3C),
            ),
          ]),
        CategoryModel(
          id: id++,
          name: 'Public transport',
          icon: defaultIcons['departure_board']!,
          color: const Color(0xFFE57373),
        ),
        CategoryModel(
          id: id++,
          name: 'Taxi',
          icon: defaultIcons['local_taxi']!,
          color: const Color(0xFF757575),
        ),
        CategoryModel(
          id: id++,
          name: 'Intercity (train, coach)',
          icon: defaultIcons['tram']!,
          color: const Color(0xFF80CBC4),
        ),
        CategoryModel(
          id: id++,
          name: 'Car',
          icon: defaultIcons['directions_car']!,
          color: const Color(0xFF827717),
        )..addChildren([
            CategoryModel(
              id: id++,
              name: 'Fuel',
              icon: defaultIcons['local_gas_station']!,
              color: const Color(0xFF512DA8),
            ),
            CategoryModel(
              id: id++,
              name: 'Maintenance, insurance',
              icon: defaultIcons['car_repair']!,
              color: const Color(0xFF2196F3),
            ),
            CategoryModel(
              id: id++,
              name: 'Parking',
              icon: defaultIcons['local_parking']!,
              color: const Color(0xFFFFB74D),
            ),
            CategoryModel(
              id: id++,
              name: 'Rent',
              icon: defaultIcons['car_rental']!,
              color: const Color(0xFF006064),
            ),
          ]),
        CategoryModel(
          id: id++,
          name: 'Long distance',
          icon: defaultIcons['flight']!,
          color: const Color(0xFF424242),
        ),
      ]),
    CategoryModel(
      id: id++,
      name: 'Financial, legal',
      icon: defaultIcons['policy']!,
      color: const Color(0xFF7986CB),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Fees',
          icon: defaultIcons['price_check']!,
          color: const Color(0xFFE64A19),
        ),
        CategoryModel(
          id: id++,
          name: 'Taxes',
          icon: defaultIcons['account_balance']!,
          color: const Color(0xFF43A047),
        ),
        CategoryModel(
          id: id++,
          name: 'Fines',
          icon: defaultIcons['money_off']!,
          color: const Color(0xFF1976D2),
        ),
        CategoryModel(
          id: id++,
          name: 'Work expenses',
          icon: defaultIcons['engineering']!,
          color: const Color(0xFFAD1457),
        ),
        CategoryModel(
          id: id++,
          name: 'Investments',
          icon: defaultIcons['trending_down']!,
          color: const Color(0xFFEF5350),
        ),
      ]),
    CategoryModel(
      id: id++,
      name: 'Gifts & donations',
      icon: defaultIcons['volunteer_activism']!,
      color: const Color(0xFF8BC34A),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Personal gifts',
          icon: defaultIcons['card_giftcard']!,
          color: const Color(0xFF64B5F6),
        ),
        CategoryModel(
          id: id++,
          name: 'Occasion-based (birthdays, souvenirs)',
          icon: defaultIcons['cake']!,
          color: const Color(0xFFFFEE58),
        ),
        CategoryModel(
          id: id++,
          name: 'Donations',
          icon: defaultIcons['emoji_emotions']!,
          color: const Color(0xFFDCE775),
        ),
      ]),
    CategoryModel(
      id: id++,
      name: 'Income',
      icon: defaultIcons['paid']!,
      color: const Color(0xFFAED581),
    )..addChildren([
        CategoryModel(
          id: id++,
          name: 'Salary',
          icon: defaultIcons['savings']!,
          color: const Color(0xFFFFEE58),
        ),
        CategoryModel(
          id: id++,
          name: 'Sale',
          icon: defaultIcons['currency_exchange']!,
          color: const Color(0xFF9ED75B),
        ),
        CategoryModel(
          id: id++,
          name: 'Refunds, returns',
          icon: defaultIcons['replay']!,
          color: const Color(0xFF303F9F),
        ),
        CategoryModel(
          id: id++,
          name: 'Received gifts',
          icon: defaultIcons['redeem']!,
          color: const Color(0xFFD2546B),
        ),
        CategoryModel(
          id: id++,
          name: 'Investments',
          icon: defaultIcons['trending_up']!,
          color: const Color(0xFF827717),
        ),
      ]),
    CategoryModel(
      id: CategoryIds.other,
      name: 'Other',
      icon: defaultIcons['question_mark']!,
      color: const Color(0xFFBDBDBD),
    ),
  ]);

  _setOrderIndex(root);

  return root;
}

void _setOrderIndex(CategoryModel category) {
  for (var i = 0; i < category.children.length; i++) {
    final child = category.children[i];
    child.orderIndex = i;
    _setOrderIndex(child);
  }
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
  static const other = -1;
}
