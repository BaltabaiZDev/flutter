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

typedef _Snapshot = (
  String,
  String,
  bool,
  String,
  EventCategory?,
  DateTime?,
  String,
);

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _locationKey =
      GlobalKey<FormFieldState<String>>();

  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _capacity;
  late final TextEditingController _description;
  late final TextEditingController _dateText;
  late final TextEditingController _timeText;

  final FocusNode _titleFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _capacityFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  late final _Snapshot _initial;

  bool _online = false;
  EventCategory? _category;
  DateTime? _day;
  TimeOfDay? _time;
  bool _saving = false;

  bool get _isNew => widget.args.event == null;

  DateTime? get _startsAt {
    final DateTime? day = _day;
    final TimeOfDay? time = _time;

    if (day == null || time == null) return null;

    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  _Snapshot _snapshot() => (
    _title.text.trim(),
    _location.text.trim(),
    _online,
    _capacity.text.trim(),
    _category,
    _startsAt,
    _description.text.trim(),
  );

  bool get _dirty => _snapshot() != _initial;

  @override
  void initState() {
    super.initState();

    final CampusEvent? editing = widget.args.event;
    final CampusEvent base = editing ?? CampusEvent.empty();
    final DateTime? start = editing?.startsAt;

    _title = TextEditingController(text: base.title);
    _location = TextEditingController(text: base.location);
    _capacity = TextEditingController(text: base.capacity.toString());
    _description = TextEditingController(text: base.description ?? '');
    _dateText = TextEditingController(
      text: start == null ? '' : formatDate(start),
    );
    _timeText = TextEditingController(
      text: start == null ? '' : formatTime(start),
    );
    _online = base.online;
    _category = editing?.category;
    _day = start == null ? null : DateTime(start.year, start.month, start.day);
    _time = start == null ? null : TimeOfDay.fromDateTime(start);
    _initial = _snapshot();
  }

  @override
  void dispose() {
    for (final ChangeNotifier c in <ChangeNotifier>[
      _title,
      _location,
      _capacity,
      _description,
      _dateText,
      _timeText,
      _titleFocus,
      _locationFocus,
      _capacityFocus,
      _descriptionFocus,
    ]) {
      c.dispose();
    }

    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _day ?? DateTime(now.year, now.month, now.day),
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 3),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _day = picked;
      _dateText.text = formatDate(picked);
    });
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _time = picked;
      _timeText.text = formatTime(
        DateTime(2000, 1, 1, picked.hour, picked.minute),
      );
    });
  }

  CampusEvent _buildEvent() {
    final CampusEvent base = widget.args.event ?? CampusEvent.empty();
    final String description = _description.text.trim();

    return base.copyWith(
      title: _title.text.trim(),
      category: _category,
      startsAt: _startsAt,
      location: _location.text.trim(),
      capacity: int.parse(_capacity.text.trim()),
      online: _online,
      description: description.isEmpty ? null : description,
      clearDescription: description.isEmpty,
    );
  }

  Future<void> _save() async {
    if (_saving) return;

    final FormState? form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    setState(() => _saving = true);

    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    Navigator.of(context).pop(_buildEvent());
  }

  Future<void> _confirmDiscard() async {
    final bool? discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (!mounted || discard != true) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_dirty,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;

      _confirmDiscard();
    },
    child: Scaffold(
      appBar: AppBar(title: Text(_isNew ? 'New event' : 'Edit event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => setState(() {}),
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _title,
                focusNode: _titleFocus,
                maxLength: 60,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (value) {
                  final int length = (value ?? '').trim().length;

                  if (length < 3 || length > 60) {
                    return 'Title must be 3 to 60 characters';
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              DropdownButtonFormField<EventCategory>(
                initialValue: _category,
                isExpanded: true,
                items: [
                  for (final EventCategory c in EventCategory.values)
                    DropdownMenuItem<EventCategory>(
                      value: c,
                      child: Row(
                        children: [
                          Icon(c.icon),
                          const SizedBox(width: 12),
                          Text(c.label),
                        ],
                      ),
                    ),
                ],
                validator: (c) => c == null ? 'Choose a category' : null,
                onChanged: (c) => setState(() => _category = c),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateText,
                      readOnly: true,
                      onTap: _pickDate,
                      validator: (_) {
                        final DateTime? day = _day;

                        if (day == null) return 'Pick a date';

                        final DateTime now = DateTime.now();
                        final DateTime today = DateTime(
                          now.year,
                          now.month,
                          now.day,
                        );

                        if (_isNew && day.isBefore(today)) {
                          return 'Date is in the past';
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _timeText,
                      readOnly: true,
                      onTap: _pickTime,
                      validator: (_) {
                        final DateTime? start = _startsAt;

                        if (_time == null) return 'Pick a time';

                        if (start != null &&
                            _isNew &&
                            !start.isAfter(DateTime.now())) {
                          return 'Must be in the future';
                        }

                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        suffixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Online event'),
                value: _online,
                onChanged: (value) {
                  setState(() => _online = value ?? false);

                  if (_location.text.isNotEmpty) {
                    _locationKey.currentState?.validate();
                  }
                },
              ),
              TextFormField(
                key: _locationKey,
                controller: _location,
                focusNode: _locationFocus,
                keyboardType: _online ? TextInputType.url : TextInputType.text,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (value) {
                  final String location = (value ?? '').trim();

                  if (location.isEmpty) return 'Required';

                  if (_online && !location.contains('://')) {
                    return 'Enter a link like https://example.com';
                  }

                  return null;
                },
                decoration: InputDecoration(
                  labelText: _online ? 'Link' : 'Place',
                  border: const OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: _capacity,
                focusNode: _capacityFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (value) {
                  final int? n = int.tryParse((value ?? '').trim());

                  if (n == null || n < 1 || n > 500) {
                    return 'A whole number from 1 to 500';
                  }

                  final int taken = widget.args.event?.count ?? 0;

                  if (n < taken) return 'Not below $taken (already registered)';

                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
              ),
              TextFormField(
                controller: _description,
                focusNode: _descriptionFocus,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                validator: (value) => null,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
