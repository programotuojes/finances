import 'package:finances/account/models/account.dart';
import 'package:finances/account/service.dart';
import 'package:finances/category/models/category.dart';
import 'package:finances/category/service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BankBackgroundSyncService {
  static final instance = BankBackgroundSyncService._ctor();
  final _storage = SharedPreferences.getInstance();

  late bool _enabled;
  late TimeOfDay _time;
  late Account _account;
  late CategoryModel _defaultCategory;
  late bool _remittanceInfoAsDescription;

  BankBackgroundSyncService._ctor();

  bool get enabled => _enabled;
  TimeOfDay get time => _time;
  Account get account => _account;
  CategoryModel get defaultCategory => _defaultCategory;
  bool get remittanceInfoAsDescription => _remittanceInfoAsDescription;

  Future<void> initialize() async {
    var storage = await _storage;

    var enabled = storage.getBool(_Keys.enabled) ?? false;
    _enabled = enabled;

    var hour = storage.getInt(_Keys.hour) ?? 20;
    var minute = storage.getInt(_Keys.minute) ?? 0;
    _time = TimeOfDay(hour: hour, minute: minute);

    var accountId = storage.getInt(_Keys.accountId);
    if (accountId != null) {
      _account = AccountService.instance.accounts.firstWhere((element) => element.id == accountId);
    } else {
      _account = AccountService.instance.lastSelection;
    }

    var categoryId = storage.getInt(_Keys.categoryId);
    if (categoryId != null) {
      _defaultCategory = CategoryService.instance.findById(categoryId) ?? other;
    } else {
      _defaultCategory = other;
    }

    var remittanceInfoAsDescription = storage.getBool(_Keys.remittanceInfoAsDescription) ?? false;
    _remittanceInfoAsDescription = remittanceInfoAsDescription;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    var storage = await _storage;
    await storage.setBool(_Keys.enabled, value);
  }

  Future<void> setTime(TimeOfDay value) async {
    _time = value;
    var storage = await _storage;
    await storage.setInt(_Keys.hour, value.hour);
    await storage.setInt(_Keys.minute, value.minute);
  }

  Future<void> setAccount(Account value) async {
    _account = value;
    var storage = await _storage;
    await storage.setInt(_Keys.accountId, value.id);
  }

  Future<void> setDefaultCategory(CategoryModel value) async {
    _defaultCategory = value;
    var storage = await _storage;
    await storage.setInt(_Keys.categoryId, value.id);
  }

  Future<void> setRemittanceInfoAsDescription(bool value) async {
    _remittanceInfoAsDescription = value;
    var storage = await _storage;
    await storage.setBool(_Keys.remittanceInfoAsDescription, value);
  }
}

class _Keys {
  static const enabled = 'enabled';
  static const hour = 'hour';
  static const minute = 'minute';
  static const accountId = 'accountId';
  static const categoryId = 'categoryId';
  static const remittanceInfoAsDescription = 'remittanceInfoAsDescription';
}
