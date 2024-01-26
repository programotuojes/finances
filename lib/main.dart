import 'package:finances/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        inputDecorationTheme:
            const InputDecorationTheme(border: OutlineInputBorder()),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
