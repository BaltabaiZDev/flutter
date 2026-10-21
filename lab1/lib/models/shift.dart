import 'cause.dart';
import 'countdown.dart';

/// One volunteer shift: a fixed number of slots and the people who took them.
class Shift {
  const Shift({
    required this.id,
    required this.title,
    required this.cause,
    required this.startsAt,
    required this.slots,
    List<String> volunteers = const [],
    this.isRemote = false,
    required this.location,
    this.notes,
    this.favourite = false,
  }) : _volunteers = volunteers;

  /// Defaults for the "new shift" form; the form still makes the user pick
  /// a cause and a date before it saves.
  Shift.empty()
    : id = '',
      title = '',
      cause = Cause.values.first,
      startsAt = DateTime.now().add(const Duration(days: 1)),
      slots = 10,
      _volunteers = const [],
      isRemote = false,
      location = '',
      notes = null,
      favourite = false;

  /// Every shift lasts two hours.
  static const length = Duration(hours: 2);

  final String id;
  final String title;
  final Cause cause;
  final DateTime startsAt;
  final int slots;
  final List<String> _volunteers;

  /// Remote shifts take place online: [location] is then a meeting link.
  final bool isRemote;
  final String location;
  final String? notes;
  final bool favourite;

  /// A read-only view: callers cannot add or remove names.
  List<String> get volunteers => List.unmodifiable(_volunteers);

  int get count => _volunteers.length;
  int get freePlaces => slots - count;
  bool get isFull => count >= slots;
  bool get isPast => startsAt.add(length).isBefore(DateTime.now());

  bool contains(String name) => _volunteers.contains(name);

  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Countdown countdown(DateTime now) =>
      Countdown.of(startsAt, length, now);

  Shift join(String name) =>
      contains(name) ? this : copyWith(volunteers: [..._volunteers, name]);

  Shift leave(String name) =>
      copyWith(volunteers: [..._volunteers.where((v) => v != name)]);

  /// [notes] is a getter so that `notes: () => null` can clear it.
  Shift copyWith({
    String? id,
    String? title,
    Cause? cause,
    DateTime? startsAt,
    int? slots,
    List<String>? volunteers,
    bool? isRemote,
    String? location,
    String? Function()? notes,
    bool? favourite,
  }) => Shift(
    id: id ?? this.id,
    title: title ?? this.title,
    cause: cause ?? this.cause,
    startsAt: startsAt ?? this.startsAt,
    slots: slots ?? this.slots,
    volunteers: volunteers ?? _volunteers,
    isRemote: isRemote ?? this.isRemote,
    location: location ?? this.location,
    notes: notes != null ? notes() : this.notes,
    favourite: favourite ?? this.favourite,
  );
}
