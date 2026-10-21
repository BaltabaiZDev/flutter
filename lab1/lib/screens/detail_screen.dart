import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/shift.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';
import '../widgets/icon_row.dart';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Shift _shift = widget.args.shift;
  DateTime _now = DateTime.now();
  late final Timer _timer;

  String get _me => widget.args.userName;
  bool get _joined => _me.isNotEmpty && _shift.contains(_me);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _update(Shift shift) {
    setState(() => _shift = shift);
    widget.args.onChanged(shift);
  }

  Future<void> _join() async {
    if (_me.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () {
              Navigator.pop(context);
              widget.args.onOpenProfile();
            },
          ),
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign up?'),
        content: Text('Put "$_me" on the list for "${_shift.title}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign up'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _update(_shift.join(_me));
  }

  void _leave() => _update(_shift.leave(_me));

  Future<void> _edit() async {
    final edited = await Navigator.pushNamed<Shift>(
      context,
      Routes.form,
      arguments: FormArgs(_shift),
    );
    if (edited == null || !mounted) return;
    _update(edited);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete shift?'),
        content: Text('"${_shift.title}" will be removed for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    widget.args.onDelete(_shift);
    Navigator.pop(context);
  }

  /// null disables the button: full and you are not on the list.
  VoidCallback? get _primaryAction {
    if (_joined) return _leave;
    if (_shift.isFull || _shift.isPast) return null;
    return _join;
  }

  String get _primaryLabel {
    if (_joined) return 'Withdraw';
    if (_shift.isPast) return 'Ended';
    if (_shift.isFull) return 'Full';
    return 'Sign up';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _shift.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: (action) => switch (action) {
                _MenuAction.edit => _edit(),
                _MenuAction.delete => _delete(),
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _MenuAction.edit,
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _MenuAction.delete,
                  child: Row(
                    children: [
                      Icon(Icons.delete),
                      SizedBox(width: 12),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(shift: _shift, countdown: _shift.countdown(_now)),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Volunteers (${_shift.count})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(shift: _shift),
                  _NamesTab(shift: _shift, me: _me),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _joined
                ? OutlinedButton.icon(
                    onPressed: _primaryAction,
                    icon: const Icon(Icons.logout),
                    label: Text(_primaryLabel),
                  )
                : FilledButton.icon(
                    onPressed: _primaryAction,
                    icon: const Icon(Icons.volunteer_activism),
                    label: Text(_primaryLabel),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.shift, required this.countdown});

  final Shift shift;
  final Countdown countdown;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = switch (countdown) {
      Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
      Started(:final elapsed) => 'Started ${formatDuration(elapsed)} ago',
      Ended() => 'Ended',
    };

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/header.jpg', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.surface,
              child: Icon(
                shift.cause.icon,
                size: 40,
                color: shift.cause.color(scheme),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Chip(
              avatar: Icon(shift.cause.icon),
              label: Text(shift.cause.label),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Chip(
              avatar: const Icon(Icons.timer_outlined),
              label: Text(text),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.shift});

  final Shift shift;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (:taken, :free) = shift.places;
    final notes = shift.notes;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        IconRow(
          icon: const Icon(Icons.event),
          title: formatDateTime(shift.startsAt),
          subtitle: 'until ${formatTime(shift.startsAt.add(Shift.length))}',
        ),
        IconRow(
          icon: Icon(shift.isRemote ? Icons.videocam : Icons.place),
          title: shift.location,
          subtitle: shift.isRemote ? 'Online meeting link' : 'Place',
        ),
        IconRow(
          icon: const Icon(Icons.groups),
          title: '$taken of ${shift.slots} places taken',
          subtitle: free > 0 ? '$free free' : 'No places left',
        ),
        if (notes != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Text(notes, style: theme.textTheme.bodyLarge),
          ),
      ],
    );
  }
}

class _NamesTab extends StatelessWidget {
  const _NamesTab({required this.shift, required this.me});

  final Shift shift;
  final String me;

  @override
  Widget build(BuildContext context) {
    final names = shift.volunteers;
    if (names.isEmpty) {
      return const EmptyState(
        icon: Icons.person_off_outlined,
        message: 'Nobody has signed up yet.',
      );
    }
    return ListView(
      children: [
        for (final name in names)
          IconRow(
            highlighted: name == me,
            icon: CircleAvatar(child: Text(name.characters.first)),
            title: name,
            trailing: name == me ? const Chip(label: Text('You')) : null,
          ),
      ],
    );
  }
}
