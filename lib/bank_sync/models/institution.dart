import 'dart:convert';
import 'dart:ui';

class Institution {
  String id;
  String name;
  String? bic;
  int? transactionDays;
  List<String> countries;
  String logo;

  Color? backgroundColor;
  Color? textColor;

  Institution({
    required this.id,
    required this.name,
    required this.countries,
    required this.logo,
    this.bic,
    this.transactionDays,
  });

  static Institution? fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': String id,
          'name': String name,
          'bic': String? bic,
          'transaction_total_days': String? days,
          'countries': List<dynamic> countries,
          'logo': String logo,
        }) {
      return Institution(
        id: id,
        name: name,
        countries: countries.cast<String>(),
        logo: logo,
        bic: bic,
        transactionDays: int.tryParse(days ?? ''),
      );
    }

    return null;
  }

  static Institution? fromString(String? json) {
    if (json == null) {
      return null;
    }

    return fromJson(jsonDecode(json));
  }
}
