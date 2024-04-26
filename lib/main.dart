import 'package:finances/bank_sync/models/go_cardless_token.dart';
import 'package:finances/bank_sync/service.dart';
import 'package:finances/pages/home_page.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(const MainApp());
  await GoCardlessSerivce.instance.initialize();
  await GoCardlessToken.instance.initialize();
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
