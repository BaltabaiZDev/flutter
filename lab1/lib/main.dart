import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/shell.dart';
import 'theme.dart';

void main() => runApp(const MyApp());

/// Holds the ThemeMode above MaterialApp so a change rebuilds the theme.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Helping Hands',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: _themeMode,
      initialRoute: Routes.home,
      routes: {
        Routes.home: (_) =>
            Shell(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
      },
      onGenerateRoute: onGenerateRoute,
      onUnknownRoute: onUnknownRoute,
    );
  }
}
