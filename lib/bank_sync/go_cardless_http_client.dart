import 'dart:convert';
import 'dart:typed_data';

import 'package:finances/bank_sync/models/bank_transaction.dart';
import 'package:finances/bank_sync/models/go_cardless_token.dart';
import 'package:finances/bank_sync/models/requisition.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

final goCardressUri = Uri.https('bankaccountdata.gocardless.com');

class GoCardlessHttpClient {
  static Future<Either<GoCardlessError, BankTransactions>> getTransactions(
    String accountId,
  ) async {
    var uri = goCardressUri.replace(
      path: '/api/v2/accounts/$accountId/transactions/',
    );

    var response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${await GoCardlessToken.instance.accessToken}',
      },
    );

    var json = _parseJson(response.bodyBytes);

    if (response.statusCode != 200) {
      return Either.left(GoCardlessError.fromJson(json));
    }

    var bookedJson = json['transactions']['booked'] as List<dynamic>;
    var booked = bookedJson.map((x) => BankTransaction.fromJson(x)).cast<BankTransaction>().toList();

    var pendingJson = json['transactions']['pending'] as List<dynamic>;
    var pending = pendingJson.map((x) => BankTransaction.fromJson(x)).cast<BankTransaction>().toList();

    return Either.right(BankTransactions(
      booked: booked,
      pending: pending,
    ));
  }

  /// This also removes end user agreements associated with this requisition.
  static Future<Either<GoCardlessError, None>> deleteRequisition(
    String requisitionId,
  ) async {
    var uri = goCardressUri.replace(
      path: '/api/v2/requisitions/$requisitionId/',
    );

    var response = await http.delete(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${await GoCardlessToken.instance.accessToken}',
      },
    );

    var json = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return Either.left(GoCardlessError.fromJson(json));
    }

    return Either.right(const None());
  }

  static Future<Either<GoCardlessError, Requisition>> getRequisition(String requisitionId) async {
    var uri = goCardressUri.replace(
      path: '/api/v2/requisitions/$requisitionId/',
    );

    var response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${await GoCardlessToken.instance.accessToken}',
      },
    );

    var json = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return Either.left(
        GoCardlessError.fromJson(json),
      );
    }

    return Either.right(
      Requisition.fromJson(json),
    );
  }

  /// GoCardless does not respond with `charset` in the `Content-Type` header.
  /// By default it uses `latin1` encoding, which breaks with accented letters.
  /// Manually decoding to utf8 fixes this.
  static Map<String, dynamic> _parseJson(Uint8List bytes) {
    return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  }
}

class GoCardlessError {
  String summary;
  String detail;

  GoCardlessError({
    required this.summary,
    required this.detail,
  });

  factory GoCardlessError.fromJson(Map<String, dynamic> json) {
    return GoCardlessError(
      summary: json['summary'],
      detail: json['detail'],
    );
  }

  @override
  String toString() {
    return '$summary\n$detail';
  }
}
