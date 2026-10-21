import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/cause.dart';
import '../models/shift.dart';
import '../utils/format.dart';

/// New and edit in one screen. Receives a Shift? and pops the saved Shift.
class FormScreen extends StatefulWidget {
  const FormScreen({super.key, this.initial});

  final Shift? initial;

  @override
  State<FormScreen> createState() => _FormScreenState();
}

typedef _Values = ({
  String title,
  Cause? cause,
  DateTime? day,
  TimeOfDay? time,
  bool remote,
  String location,
  String slots,
  String notes,
});

class _FormScreenState extends State<FormScreen> {
  static const maxNotes = 300;

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _slots;
  late final TextEditingController _notes;
  final _date = TextEditingController();
  final _time = TextEditingController();

  final _titleFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _slotsFocus = FocusNode();
  final _notesFocus = FocusNode();

  Cause? _cause;
  DateTime? _day;
  TimeOfDay? _timeOfDay;
  late bool _remote;
  bool _saving = false;

  /// What the form opened with; PopScope compares against it.
  late final _Values _initialValues;

  bool get _isNew => widget.initial == null;

  @override
  void initState() {
    super.initState();
    final shift = widget.initial ?? Shift.empty();
    _title = TextEditingController(text: shift.title);
    _location = TextEditingController(text: shift.location);
    _slots = TextEditingController(text: '${shift.slots}');
    _notes = TextEditingController(text: shift.notes ?? '');
    _remote = shift.isRemote;
    // A new shift starts with no cause and no date: the user must pick them.
    if (!_isNew) {
      _cause = shift.cause;
      _day = shift.startsAt;
      _timeOfDay = TimeOfDay.fromDateTime(shift.startsAt);
    }
    _syncDateTimeText();
    _initialValues = _values;
  }

  @override
  void dispose() {
    for (final c in [_title, _location, _slots, _notes, _date, _time]) {
      c.dispose();
    }
    for (final f in [_titleFocus, _locationFocus, _slotsFocus, _notesFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  _Values get _values => (
    title: _title.text,
    cause: _cause,
    day: _day,
    time: _timeOfDay,
    remote: _remote,
    location: _location.text,
    slots: _slots.text,
    notes: _notes.text,
  );

  bool get _isDirty => _values != _initialValues;

  DateTime? get _startsAt {
    final day = _day;
    final time = _timeOfDay;
    if (day == null || time == null) return null;
    return DateTime(day.year, day.month, day.day, time.hour, time.minute);
  }

  void _syncDateTimeText() {
    final day = _day;
    final time = _timeOfDay;
    _date.text = day == null ? '' : formatDate(day);
    _time.text = time == null
        ? ''
        : formatTime(DateTime(0, 1, 1, time.hour, time.minute));
  }

  // ---- validators -------------------------------------------------------

  String? _validateTitle(String? value) {
    final v = value?.trim() ?? '';
    if (v.length < 3) return 'At least 3 characters';
    if (v.length > 60) return 'At most 60 characters';
    return null;
  }

  String? _validateCause(Cause? value) => value == null ? 'Pick a cause' : null;

  String? _validateDate(String? _) {
    if (_day == null) return 'Pick a date';
    final start = _startsAt;
    if (_isNew && start != null && !start.isAfter(DateTime.now())) {
      return 'Must be in the future';
    }
    return null;
  }

  String? _validateTime(String? _) => _timeOfDay == null ? 'Pick a time' : null;

  String? _validateLocation(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return _remote ? 'Enter the meeting link' : 'Enter a place';
    if (_remote && !v.contains('://')) return 'A link looks like https://…';
    return null;
  }

  String? _validateSlots(String? value) {
    final n = int.tryParse(value?.trim() ?? '');
    if (n == null) return 'Enter a whole number';
    if (n < 1 || n > 500) return 'Between 1 and 500';
    final taken = widget.initial?.count ?? 0;
    if (n < taken) return '$taken people already signed up';
    return null;
  }

  String? _validateNotes(String? value) =>
      (value?.length ?? 0) > maxNotes ? 'At most $maxNotes characters' : null;

  // ---- pickers ----------------------------------------------------------

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = _day ?? today;
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(today) ? today : current,
      firstDate: current.isBefore(today) ? current : today,
      lastDate: today.add(const Duration(days: 365)),
    );
    // Cancel returns null and keeps the old value.
    if (picked == null || !mounted) return;
    setState(() {
      _day = picked;
      _syncDateTimeText();
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDay ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _timeOfDay = picked;
      _syncDateTimeText();
    });
  }

  // ---- save / leave -----------------------------------------------------

  Future<void> _save() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cause = _cause;
    final startsAt = _startsAt;
    // validate() has just checked both; this only convinces the type system.
    if (cause == null || startsAt == null) return;

    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final base = widget.initial ?? Shift.empty();
    final notes = _notes.text.trim();
    final shift = base.copyWith(
      id: _isNew ? '${DateTime.now().microsecondsSinceEpoch}' : base.id,
      title: _title.text.trim(),
      cause: cause,
      startsAt: startsAt,
      slots: int.parse(_slots.text.trim()),
      isRemote: _remote,
      location: _location.text.trim(),
      notes: () => notes.isEmpty ? null : notes,
    );
    Navigator.pop(context, shift);
  }

  Future<void> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your edits to this shift will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (discard != true || !mounted) return;
    Navigator.pop(context);
  }

  void _unfocus(PointerDownEvent _) => FocusScope.of(context).unfocus();

  @override
  Widget build(BuildContext context) {
    return PopScope<Shift>(
      canPop: _saving || !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New shift' : 'Edit shift')),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: () => setState(() {}),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _title,
                  focusNode: _titleFocus,
                  validator: _validateTitle,
                  maxLength: 60,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  onTapOutside: _unfocus,
                  onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Cause>(
                  initialValue: _cause,
                  validator: _validateCause,
                  onChanged: (v) => setState(() => _cause = v),
                  decoration: const InputDecoration(
                    labelText: 'Cause',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final cause in Cause.values)
                      DropdownMenuItem(
                        value: cause,
                        child: Row(
                          children: [
                            Icon(cause.icon),
                            const SizedBox(width: 12),
                            Text(cause.label),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _date,
                        readOnly: true,
                        validator: _validateDate,
                        onTap: _pickDate,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _time,
                        readOnly: true,
                        validator: _validateTime,
                        onTap: _pickTime,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          prefixIcon: Icon(Icons.schedule),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _remote,
                  onChanged: (v) => setState(() => _remote = v ?? false),
                  title: const Text('Online shift'),
                  subtitle: const Text('The place becomes a meeting link'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _location,
                  focusNode: _locationFocus,
                  validator: _validateLocation,
                  textInputAction: TextInputAction.next,
                  keyboardType: _remote
                      ? TextInputType.url
                      : TextInputType.streetAddress,
                  onTapOutside: _unfocus,
                  onFieldSubmitted: (_) => _slotsFocus.requestFocus(),
                  decoration: InputDecoration(
                    labelText: _remote ? 'Meeting link' : 'Place',
                    prefixIcon: Icon(_remote ? Icons.link : Icons.place),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _slots,
                  focusNode: _slotsFocus,
                  validator: _validateSlots,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onTapOutside: _unfocus,
                  onFieldSubmitted: (_) => _notesFocus.requestFocus(),
                  decoration: const InputDecoration(
                    labelText: 'Places',
                    helperText: '1 to 500',
                    prefixIcon: Icon(Icons.groups),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notes,
                  focusNode: _notesFocus,
                  validator: _validateNotes,
                  minLines: 2,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  onTapOutside: _unfocus,
                  onFieldSubmitted: (_) => _notesFocus.unfocus(),
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
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
}
