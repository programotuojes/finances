import 'dart:convert';

class EndUserAgreement {
  String id;
  String institutionId;
  DateTime createdOn;
  DateTime? acceptedOn;
  Duration maxHistorical = const Duration();
  Duration accessValidFor = const Duration();
  bool balanceAccess = false;
  bool detailsAccess = false;
  bool transactionsAccess = false;

  DateTime get validUntil => createdOn.add(accessValidFor);

  EndUserAgreement({
    required this.id,
    required String createdOn,
    String? acceptedOn,
    required int maxHistoricalDays,
    required int accessValidForDays,
    required this.institutionId,
    List<String>? accessScope,
  }) : createdOn = DateTime.parse(createdOn) {
    maxHistorical = Duration(days: maxHistoricalDays);
    accessValidFor = Duration(days: accessValidForDays);

    if (acceptedOn != null) {
      this.acceptedOn = DateTime.parse(acceptedOn);
    }

    balanceAccess = accessScope?.contains('balances') ?? false;
    detailsAccess = accessScope?.contains('details') ?? false;
    transactionsAccess = accessScope?.contains('transactions') ?? false;
  }

  static EndUserAgreement? fromJson(Map<String, dynamic> json) {
    if (json
        case {
          'id': String id,
          'created': String createdOn,
          'institution_id': String institutionId,
          'max_historical_days': int maxHistoricalDays,
          'access_valid_for_days': int accessValidForDays,
          'access_scope': List<dynamic> accessScope,
          'accepted': String? acceptedOn,
        }) {
      return EndUserAgreement(
        id: id,
        createdOn: createdOn,
        institutionId: institutionId,
        maxHistoricalDays: maxHistoricalDays,
        accessValidForDays: accessValidForDays,
        accessScope: accessScope.cast<String>(),
        acceptedOn: acceptedOn,
      );
    }

    return null;
  }

  static EndUserAgreement? fromString(String? json) {
    if (json == null) {
      return null;
    }

    return fromJson(jsonDecode(json));
  }
}
