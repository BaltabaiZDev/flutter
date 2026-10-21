import 'package:flutter/material.dart';

import 'models.dart';
import 'tabs.dart';

const Color seedColor = Colors.teal;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Campus events',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seedColor)),
    darkTheme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
    ),
    home: const Shell(),
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  List<CampusEvent> _events = buildSeed();

  void _toggleFavourite(CampusEvent event) {
    setState(() {
      _events = [
        for (final CampusEvent e in _events)
          e.id == event.id ? e.copyWith(favourite: !e.favourite) : e,
      ];
    });
  }

  void _notYet() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Coming in the next step')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Campus events')),
    body: EventsTab(
      events: _events,
      onOpen: (_) => _notYet(),
      onToggleFavourite: _toggleFavourite,
      onAdd: _notYet,
    ),
    floatingActionButton: FloatingActionButton(
      tooltip: 'New event',
      onPressed: _notYet,
      child: const Icon(Icons.add),
    ),
  );
}
