import 'dart:async';
import 'dart:convert';

import 'package:finances/bank_sync/go_cardless_http_client.dart';
import 'package:finances/utils/shared_prefs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

final _missingSecretsError = GoCardlessError(
  summary: 'Missing secrets',
  detail: 'You can generate them by clicking on "Open GoCardless user secrets" in the secrets tab',
);

class GoCardlessToken {
  static final instance = GoCardlessToken._ctor();

  var error = ValueNotifier<GoCardlessError?>(null);

  String _secretId = '';
  String _secretKey = '';
  String _access = '';
  String _refresh = '';
  DateTime _accessExpires = DateTime.utc(0);
  DateTime _refreshExpires = DateTime.utc(0);

  GoCardlessToken._ctor();

  Future<String> get accessToken async {
    if (_now.isAfter(_accessExpires)) {
      print('Access token expired. Refreshing');
      await _refreshToken();
    }

    return _access;
  }

  String get secretId => _secretId;
  String get secretKey => _secretKey;
  DateTime get _now => DateTime.now().toUtc();

  Future<void> initialize() async {
    var secretId = await secureStorage.read(key: StorageKeys.secretId);
    if (secretId != null) {
      _secretId = secretId;
    }

    var secretKey = await secureStorage.read(key: StorageKeys.secretKey);
    if (secretKey != null) {
      _secretKey = secretKey;
    }

    var accessToken = await secureStorage.read(key: StorageKeys.accessToken);
    if (accessToken != null) {
      _access = accessToken;
    }

    var refreshToken = await secureStorage.read(key: StorageKeys.refreshToken);
    if (refreshToken != null) {
      _refresh = refreshToken;
    }

    var s = await storage;

    var accessMs = s.getInt(StorageKeys.accessTimestamp);
    if (accessMs != null) {
      _accessExpires = DateTime.fromMillisecondsSinceEpoch(accessMs);
    }

    var refreshMs = s.getInt(StorageKeys.refreshTimestamp);
    if (refreshMs != null) {
      _refreshExpires = DateTime.fromMillisecondsSinceEpoch(refreshMs);
    }

    // To have some error when opening the config page
    if (_secretId.isNotEmpty && _secretKey.isNotEmpty) {
      this.accessToken.ignore();
    } else {
      error.value = _missingSecretsError;
    }
  }

  Future<void> setSecrets(String secretId, String secretKey) async {
    _secretId = secretId;
    _secretKey = secretKey;
    await secureStorage.write(key: StorageKeys.secretId, value: _secretId);
    await secureStorage.write(key: StorageKeys.secretKey, value: _secretKey);
    await _getNewToken();
  }

  Future<void> _getNewToken() async {
    var uri = goCardressUri.replace(
      path: '/api/v2/token/new/',
    );

    var response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'secret_id': _secretId,
        'secret_key': _secretKey,
      }),
    );

    var json = jsonDecode(response.body);

    if (response.statusCode != 200) {
      var error = switch (response.statusCode) {
        400 => _missingSecretsError,
        _ => GoCardlessError.fromJson(json),
      };
      this.error.value = error;
      throw error;
    }

    _access = json['access'];
    _refresh = json['refresh'];
    _accessExpires = _now.add(Duration(seconds: json['access_expires']));
    _refreshExpires = _now.add(Duration(seconds: json['refresh_expires']));
    await _saveToStorage();
    error.value = null;
  }

  Future<void> _refreshToken() async {
    if (_now.isAfter(_refreshExpires)) {
      print('Refresh token expired. Requesting a new one');
      await _getNewToken();
      return;
    }

    var uri = goCardressUri.replace(
      path: '/api/v2/token/refresh/',
    );

    var response = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'refresh': _refresh,
      }),
    );

    var json = jsonDecode(response.body);

    if (response.statusCode != 200) {
      var error = switch (response.statusCode) {
        400 => GoCardlessError(
            summary: 'Bad request',
            detail: 'User secrets must be provided',
          ),
        _ => GoCardlessError.fromJson(json),
      };
      this.error.value = error;
      throw error;
    }

    _access = json['access'];
    _accessExpires = _now.add(Duration(seconds: json['access_expires']));
    await _saveToStorage();
    error.value = null;
  }

  Future<void> _saveToStorage() async {
    await secureStorage.write(key: StorageKeys.accessToken, value: _access);
    await secureStorage.write(key: StorageKeys.refreshToken, value: _refresh);

    var s = await storage;

    await s.setInt(
      StorageKeys.accessTimestamp,
      _accessExpires.millisecondsSinceEpoch,
    );
    await s.setInt(
      StorageKeys.refreshTimestamp,
      _refreshExpires.millisecondsSinceEpoch,
    );
  }
}
