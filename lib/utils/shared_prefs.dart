import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const secureStorage = FlutterSecureStorage();
final storage = SharedPreferences.getInstance();

class StorageKeys {
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';
  static const String accessTimestamp = 'accessTimestamp';
  static const String refreshTimestamp = 'refreshTimestamp';
  static const String secretId = 'secretId';
  static const String secretKey = 'secretKey';
}
