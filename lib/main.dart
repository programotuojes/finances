import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:finances/bank_sync/pages/settings.dart';
import 'package:finances/bank_sync/services/bank_background_sync_service.dart';
import 'package:finances/bank_sync/services/go_cardless_service.dart';
import 'package:finances/pages/home_page.dart';
import 'package:finances/utils/app_paths.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppPaths.init();

  runApp(const MainApp());

  await GoCardlessSerivce.instance.initialize();
  await BankBackgroundSyncService.instance.initialize();

  if (Platform.isAndroid || Platform.isIOS) {
    await _preventMlKitPhoningHome();
    await Workmanager().initialize(backgroundMain, isInDebugMode: kDebugMode);
    _listenForBackgroundJobs();
  }
}

const backgroundIsolatePort = 'backgroundIsolatePort';

final logger = Logger(
  printer: PrettyPrinter(
    colors: false,
    printTime: true,
  ),
);

@pragma('vm:entry-point')
void backgroundMain() {
  Workmanager().executeTask((task, inputData) async {
    if (task != backgroundBankSyncTaskName) {
      return true;
    }

    logger.i('Starting background task');

    await GoCardlessSerivce.instance.initialize();
    await BankBackgroundSyncService.instance.initialize();

    var account = BankBackgroundSyncService.instance.account;
    var remittanceInfoAsDescription = BankBackgroundSyncService.instance.remittanceInfoAsDescription;
    var defaultCategory = BankBackgroundSyncService.instance.defaultCategory;

    logger.i('Staring import process');

    await GoCardlessSerivce.instance.importTransactions(
      account: account,
      remittanceInfoAsDescription: remittanceInfoAsDescription,
      defaultCategory: defaultCategory,
    );

    var sendPort = IsolateNameServer.lookupPortByName(backgroundIsolatePort);
    sendPort?.send(null);

    logger.i('Finished background task');
    return true;
  });
}

void _listenForBackgroundJobs() {
  var receivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(receivePort.sendPort, backgroundIsolatePort);
  receivePort.listen((message) async {
    logger.i('Bank import message received, reloading all transactions');

    // TODO refresh from the db
    var account = BankBackgroundSyncService.instance.account;
    var remittanceInfoAsDescription = BankBackgroundSyncService.instance.remittanceInfoAsDescription;
    var defaultCategory = BankBackgroundSyncService.instance.defaultCategory;

    await GoCardlessSerivce.instance.importTransactions(
      account: account,
      remittanceInfoAsDescription: remittanceInfoAsDescription,
      defaultCategory: defaultCategory,
    );
  });
}

/// Google ML Kit sends analytics and there's no good way to disable it.
/// https://github.com/juliansteenbakker/mobile_scanner/issues/553#issuecomment-1691387214
Future<void> _preventMlKitPhoningHome() async {
  if (Platform.isAndroid) {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.parent.path}/databases/com.google.android.datatransport.events');
    await file.writeAsString('No');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _getThemeData(Brightness.light),
      darkTheme: _getThemeData(Brightness.dark),
      home: const HomePage(),
    );
  }

  ThemeData _getThemeData(Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      appBarTheme: const AppBarTheme(
        shape: RoundedRectangleBorder(),
      ),
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF869962),
    );
  }
}
