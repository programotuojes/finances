import 'dart:convert';

class Requisition {
  String id;
  DateTime createdOn;
  String? redirect;
  String status;
  String institutionId;
  String agreementId;
  String reference;
  List<String> accounts;

  /// Link to initiate authorization with institution.
  String link;

  bool accountSelection;
  bool redirectImmediate;

  Requisition({
    required this.id,
    required this.createdOn,
    required this.redirect,
    required this.status,
    required this.institutionId,
    required this.agreementId,
    required this.reference,
    required this.accounts,
    required this.link,
    required this.accountSelection,
    required this.redirectImmediate,
  });

  String toJson() {
    var map = {
      'id': id,
      'created': createdOn.toString(),
      'redirect': redirect,
      'status': status,
      'institution_id': institutionId,
      'agreement': agreementId,
      'reference': reference,
      'accounts': accounts,
      'link': link,
      'accountSelection': accountSelection,
      'redirectImmediate': redirectImmediate,
    };
    return jsonEncode(map);
  }

  factory Requisition.fromJson(Map<String, dynamic> json) {
    return Requisition(
      id: json['id'],
      createdOn: DateTime.parse(json['created']),
      redirect: json['redirect'],
      status: json['status'],
      institutionId: json['institution_id'],
      agreementId: json['agreement'],
      reference: json['reference'],
      accounts: json['accounts'].cast<String>(),
      link: json['link'],
      accountSelection: json['account_selection'],
      redirectImmediate: json['redirect_immediate'],
    );
  }

  static Requisition? fromString(String? json) {
    if (json == null) {
      return null;
    }

    return Requisition.fromJson(jsonDecode(json));
  }
}
