import 'dart:convert';
import 'dart:io';

import 'package:finances/bank_sync/go_cardless_http_client.dart';
import 'package:finances/bank_sync/models/end_user_agreement.dart';
import 'package:finances/bank_sync/models/go_cardless_token.dart';
import 'package:finances/bank_sync/models/institution.dart';
import 'package:finances/bank_sync/models/requisition.dart';
import 'package:finances/utils/shared_prefs.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

const _endUserAgreementKey = 'endUserAgreement';
const _institutionKey = 'institution';
const _requisitionKey = 'requisition';
final sandboxFinance = Institution(
  id: 'SANDBOXFINANCE_SFIN0000',
  name: 'Sandbox Finance (test)',
  countries: ['lt'],
  logo: 'https://cdn-icons-png.flaticon.com/512/8943/8943102.png',
);

final _goCardressUri = Uri.https('bankaccountdata.gocardless.com');

// TODO disable auto backups of these sharedprefs in Android
// https://github.com/mogol/flutter_secure_storage/issues/43#issuecomment-674412687
// And in higher Android versions https://github.com/mogol/flutter_secure_storage/issues/43#issuecomment-1326487020
class GoCardlessSerivce with ChangeNotifier {
  static final instance = GoCardlessSerivce._ctor();

  var bankError = ValueNotifier<GoCardlessError?>(null);

  Institution? _institution;
  EndUserAgreement? endUserAgreement;
  Requisition? requisition;

  List<Institution> institutions = [sandboxFinance];

  GoCardlessSerivce._ctor();

  Institution? get institution => _institution;

  set institution(Institution? value) {
    _institution = value;
    notifyListeners();
  }

  Future<void> createEndUserAgreement() async {
    if (institution == null) {
      print('Select the institution first');
      return;
    }

    var uri = _goCardressUri.replace(path: '/api/v2/agreements/enduser/');
    var response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await GoCardlessToken.instance.accessToken}',
      },
      body: jsonEncode({
        'institution_id': institution!.id,
        'max_historical_days': 90,
        // 'max_historical_days': institution!.transactionDays.toString(),
        'access_valid_for_days': 180,
      }),
    );
    if (response.statusCode != 201) {
      print('Failed to create end user agreement');
      print(response.body);
      return;
    }
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    endUserAgreement = EndUserAgreement.fromJson(json);
    await secureStorage.write(key: _endUserAgreementKey, value: response.body);
    notifyListeners();
  }

  Future<void> createRequisition(String redirectUrl) async {
    assert(institution != null && endUserAgreement != null);

    var uri = _goCardressUri.replace(path: '/api/v2/requisitions/');
    var response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await GoCardlessToken.instance.accessToken}',
      },
      body: jsonEncode({
        'institution_id': institution!.id,
        'agreement': endUserAgreement!.id,
        'redirect': redirectUrl,
        'redirect_immediate': true,
      }),
    );

    var json = jsonDecode(response.body);

    if (response.statusCode != 201) {
      var error = GoCardlessError.fromJson(json);
      throw error;
    }

    requisition = Requisition.fromJson(json);
    await secureStorage.write(key: _requisitionKey, value: response.body);
    notifyListeners();
  }

  Future<void> deleteRequisition() async {
    if (requisition == null) {
      return;
    }

    var result = await GoCardlessHttpClient.deleteRequisition(requisition!.id);
    await result.match(
      (error) {
        // TODO handle error
        print('Failed to delete requisition - ${error.detail}');
      },
      (result) async {
        requisition = null;
        endUserAgreement = null;
        await secureStorage.delete(key: _requisitionKey);
        await secureStorage.delete(key: _endUserAgreementKey);
        notifyListeners();
      },
    );
  }

  Future<void> getInstitutions({String countryCode = 'lt'}) async {
    String accessToken;
    try {
      accessToken = await GoCardlessToken.instance.accessToken;
    } on GoCardlessError catch (e) {
      bankError.value = e;
      rethrow;
    }

    var uri = _goCardressUri.replace(
      path: '/api/v2/institutions/',
      queryParameters: {
        'country': countryCode,
      },
    );

    var response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    var json = jsonDecode(utf8.decode(response.bodyBytes));

    if (response.statusCode != 200) {
      var error = switch (response.statusCode) {
        400 => GoCardlessError(
            summary: json['country']['summary'],
            detail: json['country']['detail'],
          ),
        _ => GoCardlessError.fromJson(json),
      };
      bankError.value = error;
      throw error;
    }

    var castJson = json as List<dynamic>;
    institutions = castJson.map((x) => Institution.fromJson(x)!).toList();

    bankError.value = null;
    notifyListeners();
  }

  Future<void> getRequisition() async {
    if (institution == null) {
      print('institution is null');
      return;
    }
    if (endUserAgreement == null) {
      print('endUserAgreement is null');
      return;
    }
    if (requisition == null) {
      print('requisition is null');
      return;
    }

    var result = await GoCardlessHttpClient.getRequisition(requisition!.id);
    await result.match(
      (error) {
        // TODO handle error
        print('Error while gettting requisition - ${error.detail}');
      },
      (requisition) async {
        this.requisition = requisition;
        await secureStorage.write(
          key: _requisitionKey,
          value: requisition.toJson(),
        );
        notifyListeners();
      },
    );
  }

  Future<void> initialize() async {
    _institution = Institution.fromString(
      await secureStorage.read(key: _institutionKey),
    );
    endUserAgreement = EndUserAgreement.fromString(
      await secureStorage.read(key: _endUserAgreementKey),
    );
    requisition = Requisition.fromString(
      await secureStorage.read(key: _requisitionKey),
    );
    notifyListeners();
  }

  Future<void> linkWithBank() async {
    var server = await HttpServer.bind('127.0.0.1', 0);
    print('Listening on port ${server.port}');

    try {
      await createRequisition('http://127.0.0.1:${server.port}');
      await launchUrlString(requisition!.link);

      await for (var request in server) {
        request.response.headers.add('Content-Type', 'text/html');
        request.response.write('''
<!DOCTYPE html>
<html lang="en">
<head>
  <title>GoCardless callback</title>
  <script>
    window.onload = window.close;
  </script>
</head>
  <body>
    You can close this window.
  </body>
</html>
        ''');
        await request.response.flush();
        await request.response.close();
        await server.close();
      }
      await getRequisition();
    } finally {
      print('Closing server');
      await server.close();
    }
  }
}
