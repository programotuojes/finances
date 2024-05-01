import 'package:money2/money2.dart';

class Account {
  int id;
  String name;
  Money initialMoney;

  Account({
    required this.id,
    required this.name,
    required this.initialMoney,
  });
}
