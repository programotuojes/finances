import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:finances/account/models/account.dart';
import 'package:finances/automation/service.dart';
import 'package:finances/bank_sync/go_cardless_http_client.dart';
import 'package:finances/bank_sync/models/bank_transaction.dart';
import 'package:finances/bank_sync/models/end_user_agreement.dart';
import 'package:finances/bank_sync/models/go_cardless_token.dart';
import 'package:finances/bank_sync/models/institution.dart';
import 'package:finances/bank_sync/models/requisition.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/extensions/money.dart';
import 'package:finances/main.dart';
import 'package:finances/transaction/models/expense.dart';
import 'package:finances/transaction/models/transaction.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

const _endUserAgreementKey = 'endUserAgreement';
const _institutionKey = 'institution';
const _requisitionKey = 'requisition';
final sandboxFinance = Institution(
  id: 'SANDBOXFINANCE_SFIN0000',
  name: 'Sandbox Finance (test)',
  countries: ['lt'],
  logo: 'https://cdn-icons-png.flaticon.com/512/8943/8943102.png',
  transactionDays: 90,
);

final _goCardressUri = Uri.https('bankaccountdata.gocardless.com');

// TODO disable auto backups of these shared preferences in Android
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

  Future<void> setInstitution(Institution bank) async {
    _institution = bank;
    var storage = await SharedPreferences.getInstance();
    await storage.setString(_institutionKey, bank.toJson());
    notifyListeners();
  }

  Future<void> createEndUserAgreement() async {
    if (institution == null) {
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
        'max_historical_days': institution!.transactionDays.toString(),
        'access_valid_for_days': 180,
      }),
    );
    if (response.statusCode != 201) {
      return;
    }
    var json = jsonDecode(response.body) as Map<String, dynamic>;
    endUserAgreement = EndUserAgreement.fromJson(json);

    var storage = await SharedPreferences.getInstance();
    await storage.setString(_endUserAgreementKey, response.body);

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
    var storage = await SharedPreferences.getInstance();
    await storage.setString(_requisitionKey, response.body);
    notifyListeners();
  }

  Future<void> deleteRequisition() async {
    if (requisition == null) {
      return;
    }

    var result = await GoCardlessHttpClient.deleteRequisition(requisition!.id);
    await result.match(
      (error) {
        // TODO notify the user
        logger.e('Failed to delete requisition', error: error);
      },
      (result) async {
        requisition = null;
        endUserAgreement = null;
        var storage = await SharedPreferences.getInstance();
        await storage.remove(_requisitionKey);
        await storage.remove(_endUserAgreementKey);
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
      logger.e('Failed to get banks', error: error);
      throw error;
    }

    var castJson = json as List<dynamic>;
    institutions = castJson.map((x) => Institution.fromJson(x)!).toList();

    bankError.value = null;
    notifyListeners();
  }

  Future<void> getRequisition() async {
    if (institution == null) {
      return;
    }
    if (endUserAgreement == null) {
      return;
    }
    if (requisition == null) {
      return;
    }

    var result = await GoCardlessHttpClient.getRequisition(requisition!.id);
    await result.match(
      (error) {
        // TODO notify the user
        logger.e('Failed to get requisition', error: error);
      },
      (requisition) async {
        this.requisition = requisition;
        var storage = await SharedPreferences.getInstance();
        await storage.setString(_requisitionKey, requisition.toJson());
        notifyListeners();
      },
    );
  }

  Future<void> initialize() async {
    await GoCardlessToken.instance.initialize();

    var storage = await SharedPreferences.getInstance();

    _institution = Institution.fromString(storage.getString(_institutionKey));
    endUserAgreement = EndUserAgreement.fromString(storage.getString(_endUserAgreementKey));
    requisition = Requisition.fromString(storage.getString(_requisitionKey));

    notifyListeners();
  }

  Future<void> linkWithBank() async {
    var server = await HttpServer.bind('127.0.0.1', 0);
    logger.i('HTTP server listening on port ${server.port}');

    try {
      await createRequisition('http://127.0.0.1:${server.port}');
      await launchUrlString(requisition!.link);

      var request = await server.first;
      request.response.headers.add('Content-Type', 'text/html');
      // TODO browsers forbid scripts from closing the tab when there are history items
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

      await getRequisition();
    } finally {
      logger.i('Closing HTTP server');
      await server.close();
    }
  }

  Future<void> importTransactions({
    required Account account,
    required bool remittanceInfoAsDescription,
    required CategoryModel defaultCategory,
  }) async {
    var accountId = requisition?.accounts.first;
    if (accountId == null) {
      logger.w('Requisition is null or it does not have accounts');
      return;
    }

    var transactions = await GoCardlessHttpClient.getTransactions(accountId);
    transactions.match((error) {
      // TODO notify the user
      logger.e('Failed to get transactions', error: error);
    }, (list) {
      for (var bankTr in list.booked) {
        var amount = bankTr.transactionAmount!.amount;
        var money = amount!.replaceFirst('-', '').toMoney();
        if (money == null) {
          logger.e('Failed to parse amount ($amount) for transaction ${bankTr.transactionId}');
          continue;
        }

        var bankInfo = BankSyncInfo(
          transactionId: bankTr.transactionId,
          receiverName: bankTr.creditorName,
          receiverIban: bankTr.creditorAccount?.iban,
          remittanceInfo: bankTr.remittanceInformationUnstructured,
        );

        var manualTransaction = _manualTransaction(bankTr, account);
        if (manualTransaction != null) {
          manualTransaction.bankInfo = bankInfo;
          continue;
        }

        var type = amount[0] == '-' ? TransactionType.expense : TransactionType.income;
        var category = AutomationService.instance.getCategory(
              remittanceInfo: bankTr.remittanceInformationUnstructured,
              creditorName: bankTr.creditorName,
              creditorIban: bankTr.creditorAccount?.iban,
            ) ??
            defaultCategory;

        var previousImport = TransactionService.instance.transactions
            .firstWhereOrNull((x) => x.bankInfo?.transactionId == bankTr.transactionId);

        if (previousImport != null) {
          if (previousImport.mainExpense.category == category) {
            continue;
          }
          TransactionService.instance.delete(previousImport);
        }

        var transaction = Transaction(
          account: account,
          dateTime: _getDateTime(bankTr),
          type: type,
          bankInfo: bankInfo,
        );
        var expense = Expense(
          transaction: transaction,
          money: money,
          category: category,
          description: remittanceInfoAsDescription ? bankTr.remittanceInformationUnstructured : null,
        );
        TransactionService.instance.add(
          transaction,
          expenses: [expense],
        );
      }
    });
  }

  Transaction? _manualTransaction(BankTransaction bankTransaction, Account targetAccount) {
    for (var transaction in TransactionService.instance.transactions) {
      var sameAccount = targetAccount == transaction.account;
      if (!sameAccount) {
        continue;
      }

      var sameDay = DateUtils.isSameDay(bankTransaction.bookingDateTime, transaction.dateTime);
      if (!sameDay) {
        continue;
      }

      var total = transaction.expenses.fold(zeroEur, (acc, x) => acc + x.signedMoney).amount.toString();
      var sameMoney = bankTransaction.transactionAmount?.amount == total;
      if (!sameMoney) {
        continue;
      }

      if (sameAccount && sameDay && sameMoney) {
        return transaction;
      }
    }

    return null;
  }

  DateTime _getDateTime(BankTransaction transaction) {
    if (transaction.remittanceInformationUnstructured == null) {
      return transaction.bookingDateTime;
    }

    var match = _remittanceDateRegex.firstMatch(transaction.remittanceInformationUnstructured!);
    if (match == null) {
      return transaction.bookingDateTime;
    }

    return DateTime(
      int.parse(match[1]!),
      int.parse(match[2]!),
      int.parse(match[3]!),
    );
  }
}

final _remittanceDateRegex = RegExp(r'\W(\d{4})\.(\d{2})\.(\d{2})\W');
