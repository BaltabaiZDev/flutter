import 'package:flutter/material.dart';

import 'models/shift.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';

abstract final class Routes {
  static const home = '/';
  static const detail = '/shift';
  static const form = '/shift/edit';
}

/// What the detail screen needs: the shift, who "you" are, and how to tell
/// the shell about changes. The shell owns the list, so the detail cannot
/// return a value for every possible change; it calls back instead.
class DetailArgs {
  const DetailArgs({
    required this.shift,
    required this.userName,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Shift shift;
  final String userName;
  final ValueChanged<Shift> onChanged;
  final ValueChanged<Shift> onDelete;
  final VoidCallback onOpenProfile;
}

/// null means "new shift"; the form pops the saved shift.
class FormArgs {
  const FormArgs([this.shift]);
  final Shift? shift;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final args = settings.arguments;
  return switch ((settings.name, args)) {
    (Routes.detail, DetailArgs args) => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => DetailScreen(args: args),
    ),
    (Routes.form, FormArgs args) => MaterialPageRoute<Shift>(
      settings: settings,
      builder: (_) => FormScreen(initial: args.shift),
    ),
    _ => null,
  };
}

Route<dynamic> onUnknownRoute(RouteSettings settings) => MaterialPageRoute<void>(
  settings: settings,
  builder: (_) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: Center(child: Text('Not found: ${settings.name}')),
  ),
);
