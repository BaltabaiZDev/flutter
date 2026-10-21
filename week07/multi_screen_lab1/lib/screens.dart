import 'dart:async';

import 'package:flutter/material.dart';

import 'models.dart';
import 'routes.dart';
import 'utils/format.dart';
import 'widgets.dart';

enum _EventMenu { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late CampusEvent _event = widget.args.event;
  late final Timer _timer;

  String get _you => widget.args.profile.name;

  bool get _registered => _event.contains(_you);

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
  }

  Future<bool> _confirm(String title, String confirmLabel) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return result == true;
  }

  void _apply(CampusEvent updated) {
    setState(() => _event = updated);

    widget.args.onChanged(updated);
  }

  void _openProfile() {
    if (mounted) Navigator.of(context).pop();

    widget.args.onOpenProfile();
  }

  Future<void> _register() async {
    final Profile profile = widget.args.profile;

    if (!profile.hasName) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first'),
          action: SnackBarAction(label: 'Profile', onPressed: _openProfile),
        ),
      );

      return;
    }

    final bool confirmed = await _confirm(
      'Register for "${_event.title}"?',
      'Register',
    );

    if (!mounted || !confirmed) return;

    _apply(_event.withAttendee(profile.name));
  }

  void _unregister() {
    _apply(_event.withoutAttendee(_you));
  }

  Future<void> _edit() async {
    final CampusEvent? updated = await Navigator.of(
      context,
    ).pushNamed<CampusEvent>(Routes.form, arguments: FormArgs(event: _event));

    if (updated == null || !mounted) return;

    _apply(updated);
  }

  Future<void> _delete() async {
    final bool confirmed = await _confirm(
      'Delete "${_event.title}"?',
      'Delete',
    );

    if (!mounted || !confirmed) return;

    widget.args.onDelete();
    Navigator.of(context).pop();
  }

  void _onMenu(_EventMenu action) {
    switch (action) {
      case _EventMenu.edit:
        _edit();
      case _EventMenu.delete:
        _delete();
    }
  }

  Widget _primaryAction() {
    if (_registered) {
      return FilledButton.tonal(
        onPressed: _unregister,
        child: const Text('Unregister'),
      );
    }

    return FilledButton(
      onPressed: _event.isFull ? null : _register,
      child: Text(_event.isFull ? 'Event is full' : 'Register'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final (:taken, :free) = _event.places;
    final String? description = _event.description;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _event.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<_EventMenu>(
              onSelected: _onMenu,
              itemBuilder: (context) => const [
                PopupMenuItem<_EventMenu>(
                  value: _EventMenu.edit,
                  child: Text('Edit'),
                ),
                PopupMenuItem<_EventMenu>(
                  value: _EventMenu.delete,
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(event: _event),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_event.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.schedule),
                        title: Text(formatDateTime(_event.startsAt)),
                      ),
                      ListTile(
                        leading: Icon(
                          _event.online ? Icons.link : Icons.place_outlined,
                        ),
                        title: Text(_event.location),
                        subtitle: _event.online ? const Text('Online') : null,
                      ),
                      ListTile(
                        leading: const Icon(Icons.event_seat_outlined),
                        title: Text(
                          '$taken of ${_event.capacity} places taken',
                        ),
                        subtitle: Text('$free free'),
                      ),
                      if (description != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(description),
                        ),
                    ],
                  ),
                  _event.count == 0
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          message: 'Nobody has registered yet',
                        )
                      : ListView(
                          children: [
                            for (final String name in _event.attendees)
                              ListTile(
                                leading: CircleAvatar(
                                  child: Text(name.isEmpty ? '?' : name[0]),
                                ),
                                title: Text(
                                  name == _you ? '$name (You)' : name,
                                ),
                                selected: name == _you,
                                selectedTileColor: scheme.primaryContainer,
                                selectedColor: scheme.onPrimaryContainer,
                              ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(width: double.infinity, child: _primaryAction()),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.event});

  final CampusEvent event;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Countdown countdown = event.countdown;
    final IconData countdownIcon = switch (countdown) {
      Upcoming() => Icons.schedule,
      Started() => Icons.play_circle_outline,
      Ended() => Icons.event_busy,
    };

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/header.png', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: event.category.color(scheme),
              foregroundColor: event.category.onColor(scheme),
              child: Icon(event.category.icon, size: 40),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _Pill(label: event.category.label),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _Pill(
              icon: countdownIcon,
              label: formatCountdown(countdown),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final IconData? leading = icon;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              Icon(leading, size: 16, color: theme.colorScheme.onSurface),
              const SizedBox(width: 6),
            ],
            Text(label, style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
