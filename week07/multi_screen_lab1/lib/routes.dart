import 'package:flutter/material.dart';

import 'models.dart';
import 'screens.dart';
import 'widgets.dart';

class Routes {
  static const String shell = '/';
  static const String detail = '/event';
  static const String form = '/event/form';
}

class DetailArgs {
  const DetailArgs({
    required this.event,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final CampusEvent event;
  final Profile profile;
  final ValueChanged<CampusEvent> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onOpenProfile;
}

class FormArgs {
  const FormArgs({this.event});

  final CampusEvent? event;
}

Route<dynamic>? generateRoute(RouteSettings settings) {
  final Object? args = settings.arguments;

  if (settings.name == Routes.detail && args is DetailArgs) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (context) => DetailScreen(args: args),
    );
  }

  return null;
}

Route<dynamic> unknownRoute(RouteSettings settings) => MaterialPageRoute<void>(
  settings: settings,
  builder: (context) => Scaffold(
    appBar: AppBar(title: const Text('Not found')),
    body: const EmptyState(icon: Icons.error_outline, message: 'Not found'),
  ),
);
