import 'dart:io';

import 'package:finances/account/service.dart';
import 'package:finances/automation/service.dart';
import 'package:finances/bank_sync/services/bank_background_sync_service.dart';
import 'package:finances/bank_sync/services/go_cardless_service.dart';
import 'package:finances/budget/service.dart';
import 'package:finances/category/service.dart';
import 'package:finances/main.dart';
import 'package:finances/recurring/service.dart';
import 'package:finances/transaction/service.dart';
import 'package:finances/utils/db.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'appPath';

sealed class AppPaths {
  static late SharedPreferences storage;
  static late String _attachments;
  static late String _base;
  static late String _baseDefault;
  static late String _db;
  static final _listenable = ValueNotifier(false);

  static String get attachments => _attachments;
  static String get base => _base;
  static String get baseDefault => _baseDefault;
  static String get db => _db;
  static Listenable get listenable => _listenable;

  static Future<void> init() async {
    storage = await SharedPreferences.getInstance();
    _baseDefault = (await getApplicationSupportDirectory()).path;
    var path = storage.getString(_key) ?? _baseDefault;

    try {
      await _setPaths(path);
    } catch (e) {
      logger.e('''
Failed to set $path as the app path.
Will use the default path $_baseDefault.''', error: e);
      await _setPaths(_baseDefault);
    }
  }

  static Future<void> setAppPath(String path) async {
    await storage.setString(_key, path);
    await _setPaths(path);
  }

  static Future<void> _initializeServices() async {
    try {
      await database.close();
    } catch (e) {
      // Ignored
      // On first run, database hasn't been initialized yet
    }

    try {
      await initializeDatabase();
      await AccountService.instance.initialize();
      await CategoryService.instance.initialize();
      await AutomationService.instance.init();
      await BudgetService.instance.init();
      await RecurringService.instance.init();
      await TransactionService.instance.init();

      await GoCardlessSerivce.instance.initialize();
      await BankBackgroundSyncService.instance.initialize();
    } catch (e) {
      if (kDebugMode) {
        logger.w('Failed to initialize the database. Deleting, since in debug mode');
        await File(_db).delete();
      }
      rethrow;
    }
  }

  static Future<void> _setPaths(String path) async {
    _base = path;
    _attachments = join(_base, 'attachments');
    _db = join(_base, 'finances.db');

    logger.i('Base app path = $_base');

    await _initializeServices();

    _listenable.value = !_listenable.value;
  }
}
