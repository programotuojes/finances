import 'dart:io';

import 'package:finances/pages/home_page.dart';
import 'package:finances/utils/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

final logger = Logger(printer: PrettyPrinter(colors: false, printTime: true));

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

/// Google ML Kit sends analytics and there's no good way to disable it.
/// https://github.com/juliansteenbakker/mobile_scanner/issues/553#issuecomment-1691387214
Future<void> _preventMlKitPhoningHome() async {
  if (Platform.isAndroid) {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.parent.path}/databases/com.google.android.datatransport.events');
    await file.writeAsString('No');
  }
}
