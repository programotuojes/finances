import 'dart:async';
import 'dart:io';

import 'package:finances/account/service.dart';
import 'package:finances/pages/first_run.dart';
import 'package:finances/pages/home_page.dart';
import 'package:finances/transaction/pages/edit_transaction.dart';
import 'package:finances/transaction/pages/edit_transfer.dart';
import 'package:finances/utils/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_actions/quick_actions.dart';

final logger = Logger(
  printer: PrettyPrinter(
    colors: false,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPaths.init();

  runApp(const MainApp());

  await _preventMlKitPhoningHome();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _getThemeData(Brightness.light),
      darkTheme: _getThemeData(Brightness.dark),
      home: ListenableBuilder(
        listenable: AppPaths.listenable,
        builder: (context, child) {
          if (AccountService.instance.accounts.isEmpty) {
            return const FirstRunPage();
          }

          _setupQuickActions(context);
          return const HomePage();
        },
      ),
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

/// Google ML Kit sends analytics and there's no good way to disable it.
/// https://github.com/juliansteenbakker/mobile_scanner/issues/553#issuecomment-1691387214
Future<void> _preventMlKitPhoningHome() async {
  if (Platform.isAndroid) {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.parent.path}/databases/com.google.android.datatransport.events');
    await file.create(recursive: true);
    await file.writeAsString('No');
  }
}

void _setupQuickActions(BuildContext context) {
  final supportsQuickActions = Platform.isAndroid;
  if (!supportsQuickActions) {
    return;
  }

  const newTransaction = 'new_transaction';
  const newTransfer = 'new_transfer';
  const quickActions = QuickActions();

  quickActions.initialize((shortcutType) async {
    logger.i('Handling $shortcutType quick action');

    // if (_currentQuickAction == shortcutType) {
    //   // https://github.com/flutter/flutter/issues/131121
    //   return;
    // }
    //
    // _currentQuickAction = shortcutType;

    Widget page;
    if (shortcutType == newTransaction) {
      page = const TransactionEditPage();
    } else if (shortcutType == newTransfer) {
      page = const EditTransferPage();
    } else {
      return;
    }

    await Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    unawaited(SystemNavigator.pop()); // Cleaner exit screen
  });

  quickActions.setShortcutItems(const [
    ShortcutItem(type: newTransaction, localizedTitle: 'New transaction', icon: 'add'),
    ShortcutItem(type: newTransfer, localizedTitle: 'New transfer', icon: 'swap_horiz'),
  ]);
}
