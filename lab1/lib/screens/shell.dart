import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/profile.dart';
import '../models/shift.dart';
import '../routes.dart';
import '../widgets/app_drawer.dart';
import 'favourites_tab.dart';
import 'profile_tab.dart';
import 'shifts_tab.dart';

/// Owns the shifts and the profile. Tabs and pushed screens get them as
/// parameters and report changes through the callbacks below.
class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  static const _titles = ['Shifts', 'Favourites', 'Profile'];
  static const profileTab = 2;

  List<Shift> _shifts = seedShifts();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  /// Bumped by "Reset data" so the profile tab rebuilds its controllers.
  int _resets = 0;

  void _selectTab(int index) {
    setState(() => _tab = index);
  }

  void _replace(Shift shift) {
    final updated = [for (final s in _shifts) s.id == shift.id ? shift : s];
    setState(() => _shifts = updated);
  }

  void _remove(Shift shift) {
    final updated = [..._shifts.where((s) => s.id != shift.id)];
    setState(() => _shifts = updated);
  }

  void _toggleFavourite(Shift shift) =>
      _replace(shift.copyWith(favourite: !shift.favourite));

  void _open(Shift shift) {
    Navigator.pushNamed(
      context,
      Routes.detail,
      arguments: DetailArgs(
        shift: shift,
        userName: _profile.name.trim(),
        onChanged: _replace,
        onDelete: _remove,
        onOpenProfile: () => _selectTab(profileTab),
      ),
    );
  }

  Future<void> _create() async {
    final shift = await Navigator.pushNamed<Shift>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (shift == null || !mounted) return;
    setState(() => _shifts = [..._shifts, shift]);
  }

  void _about() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.volunteer_activism),
        title: const Text('Helping Hands'),
        content: const Text(
          'Find volunteer shifts, sign up with one tap and keep your '
          'favourites close. Lab 1 for the Flutter course; all data '
          'lives in memory.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'All shifts go back to the original twelve and your profile '
          'is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final seed = seedShifts();
    setState(() {
      _shifts = seed;
      _profile = const Profile.empty();
      _resets++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: AppDrawer(onAbout: _about, onReset: _reset),
      body: IndexedStack(
        index: _tab,
        children: [
          ShiftsTab(
            shifts: _shifts,
            onOpen: _open,
            onToggleFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            shifts: _shifts,
            onOpen: _open,
            onToggleFavourite: _toggleFavourite,
            onBrowse: () => _selectTab(0),
          ),
          ProfileTab(
            key: ValueKey(_resets),
            profile: _profile,
            shifts: _shifts,
            onProfileChanged: (p) => setState(() => _profile = p),
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: const Text('New shift'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Shifts',
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
}
