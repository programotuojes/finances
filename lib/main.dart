import 'package:finances/bank_sync/pages/settings.dart';
import 'package:finances/bank_sync/services/bank_background_sync_service.dart';
import 'package:finances/bank_sync/services/go_cardless_service.dart';
import 'package:finances/pages/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:workmanager/workmanager.dart';

final logger = Logger(
  printer: PrettyPrinter(
    colors: false,
    printTime: true,
  ),
);

Future<void> main() async {
  runApp(const MainApp());
  await BankBackgroundSyncService.instance.initialize();
  await GoCardlessSerivce.instance.initialize();
  await Workmanager().initialize(
    backgroundMain,
    isInDebugMode: kDebugMode,
  );
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
    );
  }
}

@pragma('vm:entry-point')
void backgroundMain() {
  Workmanager().executeTask((task, inputData) async {
    if (task != backgroundBankSyncTaskName) {
      return true;
    }

    logger.i('Starting background task $task');

    await GoCardlessSerivce.instance.initialize();
    await BankBackgroundSyncService.instance.initialize();

    var account = BankBackgroundSyncService.instance.account;
    var remittanceInfoAsDescription = BankBackgroundSyncService.instance.remittanceInfoAsDescription;
    var defaultCategory = BankBackgroundSyncService.instance.defaultCategory;

    await GoCardlessSerivce.instance.importTransactions(
      account: account,
      remittanceInfoAsDescription: remittanceInfoAsDescription,
      defaultCategory: defaultCategory,
    );

    logger.i('Finished background task $task');
    return true;
  });
}
