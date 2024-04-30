import 'dart:convert';

class Institution {
  String id;
  String name;
  String? bic;
  int transactionDays;
  List<String> countries;
  String logo;

  Institution({
    required this.id,
    required this.name,
    required this.countries,
    required this.logo,
    this.bic,
    required this.transactionDays,
  });

  static Institution? fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': String id,
          'name': String name,
          'bic': String? bic,
          'transaction_total_days': String days,
          'countries': List<dynamic> countries,
          'logo': String logo,
        }) {
      return Institution(
        id: id,
        name: name,
        countries: countries.cast<String>(),
        logo: logo,
        bic: bic,
        transactionDays: int.parse(days),
      );
    }

    return null;
  }

  String toJson() {
    var map = {
      'id': id,
      'name': name,
      'bic': bic,
      'transaction_total_days': transactionDays.toString(),
      'countries': countries,
      'logo': logo,
    };

    return jsonEncode(map);
  }

  static Institution? fromString(String? json) {
    if (json == null) {
      return null;
    }

    return fromJson(jsonDecode(json));
  }
}
