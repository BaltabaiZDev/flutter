import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'routes.dart';
import 'tabs.dart';

const Color seedColor = Colors.teal;

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<ThemeMode> _themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  @override
  void dispose() {
    _themeMode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: _themeMode,
    builder: (context, mode, child) => MaterialApp(
      title: 'Campus events',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seedColor)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: mode,
      routes: {
        Routes.shell: (context) => Shell(
          themeMode: _themeMode,
          onThemeModeChanged: (value) => _themeMode.value = value,
        ),
      },
      onGenerateRoute: generateRoute,
      onUnknownRoute: unknownRoute,
    ),
  );
}

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ValueListenable<ThemeMode> themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const List<String> _titles = [
    'Campus events',
    'Favourites',
    'Profile',
  ];

  List<CampusEvent> _events = buildSeed();
  Profile _profile = const Profile.empty();
  int _index = 0;

  void _goToTab(int index) {
    setState(() => _index = index);
  }

  void _setProfile(Profile profile) {
    setState(() => _profile = profile);
  }

  void _toggleFavourite(CampusEvent event) {
    setState(() {
      _events = [
        for (final CampusEvent e in _events)
          e.id == event.id ? e.copyWith(favourite: !e.favourite) : e,
      ];
    });
  }

  void _replace(CampusEvent updated) {
    setState(() {
      _events = [
        for (final CampusEvent e in _events) e.id == updated.id ? updated : e,
      ];
    });
  }

  void _remove(CampusEvent event) {
    setState(() {
      _events = _events.where((e) => e.id != event.id).toList();
    });
  }

  void _open(CampusEvent event) {
    Navigator.of(context).pushNamed(
      Routes.detail,
      arguments: DetailArgs(
        event: event,
        profile: _profile,
        onChanged: _replace,
        onDelete: () => _remove(event),
        onOpenProfile: () => _goToTab(2),
      ),
    );
  }

  void _notYet() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Coming in the next step')));
  }

  void _about() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Campus events'),
        content: const Text(
          'Browse, register for and organise events on campus. '
          'All data lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'Events return to the seed list and the profile is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _events = buildSeed();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_titles[_index])),
    drawer: Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Campus events',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.of(context).pop();

              _about();
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Reset data'),
            onTap: () {
              Navigator.of(context).pop();

              _reset();
            },
          ),
        ],
      ),
    ),
    body: IndexedStack(
      index: _index,
      children: [
        EventsTab(
          events: _events,
          onOpen: _open,
          onToggleFavourite: _toggleFavourite,
          onAdd: _notYet,
        ),
        FavouritesTab(
          events: _events,
          onOpen: _open,
          onToggleFavourite: _toggleFavourite,
          onBrowse: () => _goToTab(0),
        ),
        ProfileTab(
          profile: _profile,
          events: _events,
          themeMode: widget.themeMode,
          onProfileChanged: _setProfile,
          onThemeModeChanged: widget.onThemeModeChanged,
        ),
      ],
    ),
    floatingActionButton: _index == 0
        ? FloatingActionButton(
            tooltip: 'New event',
            onPressed: _notYet,
            child: const Icon(Icons.add),
          )
        : null,
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: _goToTab,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.event_outlined),
          selectedIcon: Icon(Icons.event),
          label: 'Events',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favourites',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
  );
}
