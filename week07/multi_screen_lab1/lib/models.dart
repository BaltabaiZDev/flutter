import 'dart:collection';

import 'package:flutter/material.dart';

enum EventCategory {
  tech('Tech', Icons.computer),
  music('Music', Icons.music_note),
  sports('Sports', Icons.sports_soccer),
  career('Career', Icons.work_outline),
  arts('Arts', Icons.palette_outlined),
  social('Social', Icons.groups_outlined);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primary,
    EventCategory.music => scheme.tertiary,
    EventCategory.sports => scheme.secondary,
    EventCategory.career => scheme.inversePrimary,
    EventCategory.arts => scheme.tertiaryContainer,
    EventCategory.social => scheme.secondaryContainer,
  };
}

const Duration eventLength = Duration(hours: 2);

sealed class Countdown {
  const Countdown();

  factory Countdown.at(DateTime startsAt, DateTime now) {
    final Duration diff = startsAt.difference(now);

    if (diff > Duration.zero) {
      return Upcoming(diff);
    }

    final Duration elapsed = -diff;

    return elapsed < eventLength ? Started(elapsed) : const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.timeLeft);

  final Duration timeLeft;
}

final class Started extends Countdown {
  const Started(this.elapsed);

  final Duration elapsed;
}

final class Ended extends Countdown {
  const Ended();
}

class CampusEvent {
  const CampusEvent({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.location,
    required this.capacity,
    this.online = false,
    this.description,
    this.favourite = false,
    List<String> attendees = const [],
  }) : _attendees = attendees;

  CampusEvent.empty()
    : this(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '',
        category: EventCategory.tech,
        startsAt: _defaultStart(),
        location: '',
        capacity: 30,
      );

  static DateTime _defaultStart() {
    final DateTime now = DateTime.now();

    return DateTime(now.year, now.month, now.day + 1, 10);
  }

  final String id;
  final String title;
  final EventCategory category;
  final DateTime startsAt;
  final String location;
  final int capacity;
  final bool online;
  final String? description;
  final bool favourite;
  final List<String> _attendees;

  List<String> get attendees => UnmodifiableListView<String>(_attendees);

  int get count => _attendees.length;

  int get freePlaces => capacity - count;

  bool get isFull => count >= capacity;

  bool get isPast => startsAt.isBefore(DateTime.now());

  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Countdown get countdown => Countdown.at(startsAt, DateTime.now());

  bool contains(String name) => _attendees.contains(name);

  CampusEvent withAttendee(String name) =>
      copyWith(attendees: [..._attendees, name]);

  CampusEvent withoutAttendee(String name) =>
      copyWith(attendees: _attendees.where((n) => n != name).toList());

  CampusEvent copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? startsAt,
    String? location,
    int? capacity,
    bool? online,
    String? description,
    bool clearDescription = false,
    bool? favourite,
    List<String>? attendees,
  }) => CampusEvent(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    startsAt: startsAt ?? this.startsAt,
    location: location ?? this.location,
    capacity: capacity ?? this.capacity,
    online: online ?? this.online,
    description: clearDescription ? null : (description ?? this.description),
    favourite: favourite ?? this.favourite,
    attendees: List<String>.of(attendees ?? _attendees),
  );
}

class Profile {
  const Profile({required this.name, required this.group});

  const Profile.empty() : this(name: '', group: '');

  final String name;
  final String group;

  bool get hasName => name.trim().isNotEmpty;

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);
}

List<CampusEvent> filterEvents(
  List<CampusEvent> events, {
  String query = '',
  EventCategory? category,
  bool showPast = false,
}) {
  final String q = query.trim().toLowerCase();

  return events.where((e) {
    if (!showPast && e.isPast) return false;
    if (category != null && e.category != category) return false;

    return q.isEmpty || e.title.toLowerCase().contains(q);
  }).toList();
}

List<CampusEvent> sortedByDate(List<CampusEvent> events) {
  final List<CampusEvent> copy = List<CampusEvent>.of(events);

  copy.sort((a, b) {
    if (a.isPast != b.isPast) return a.isPast ? 1 : -1;

    return a.isPast
        ? b.startsAt.compareTo(a.startsAt)
        : a.startsAt.compareTo(b.startsAt);
  });

  return copy;
}

List<CampusEvent> favouritesOf(List<CampusEvent> events) =>
    events.where((e) => e.favourite).toList();

bool hasFavourites(List<CampusEvent> events) => events.any((e) => e.favourite);

int listsContaining(List<CampusEvent> events, String name) =>
    events.where((e) => e.contains(name)).length;

int totalAttendees(List<CampusEvent> events) =>
    events.fold<int>(0, (sum, e) => sum + e.count);

DateTime _at(int days, int hour, [int minute = 0]) {
  final DateTime today = DateTime.now();

  return DateTime(today.year, today.month, today.day + days, hour, minute);
}

List<CampusEvent> buildSeed() => <CampusEvent>[
  CampusEvent(
    id: 'e01',
    title: 'Annual Interdisciplinary Student Research and Innovation Day',
    category: EventCategory.tech,
    startsAt: _at(5, 10),
    location: 'Main Hall, Block A',
    capacity: 120,
    description: 'Posters, demos and short talks from every faculty.',
    attendees: const ['Aigerim S.', 'Daniyar K.', 'Madina T.'],
  ),
  CampusEvent(
    id: 'e02',
    title: 'Flutter Hackathon',
    category: EventCategory.tech,
    startsAt: _at(2, 9),
    location: 'Lab 301',
    capacity: 8,
    description: 'Build a small app in six hours. Bring a laptop.',
    favourite: true,
    attendees: const [
      'Arman B.',
      'Zhanna O.',
      'Timur A.',
      'Alina N.',
      'Nurlan E.',
    ],
  ),
  CampusEvent(
    id: 'e03',
    title: 'Jazz Night',
    category: EventCategory.music,
    startsAt: _at(7, 19),
    location: 'Student Club',
    capacity: 60,
    description: 'Live quartet and an open jam session after the break.',
    attendees: const ['Dana M.', 'Ruslan Z.', 'Aruzhan T.', 'Bekzat O.'],
  ),
  CampusEvent(
    id: 'e04',
    title: 'Inter-Faculty Football Cup',
    category: EventCategory.sports,
    startsAt: _at(3, 16),
    location: 'Campus Stadium',
    capacity: 22,
    attendees: const ['Yerlan S.', 'Marat K.', 'Askar D.'],
  ),
  CampusEvent(
    id: 'e05',
    title: 'Career Fair',
    category: EventCategory.career,
    startsAt: _at(10, 11),
    location: 'Sports Hall',
    capacity: 200,
    description: 'Thirty companies, internships and CV reviews on the spot.',
    attendees: const ['Laura N.', 'Sanzhar B.'],
  ),
  CampusEvent(
    id: 'e06',
    title: 'Open Mic Evening',
    category: EventCategory.arts,
    startsAt: _at(1, 18, 30),
    location: 'Cafeteria',
    capacity: 5,
    description: 'Poetry, stand-up and songs. Five minutes per performer.',
    attendees: const [
      'Kamila R.',
      'Dias A.',
      'Aliya B.',
      'Temirlan G.',
      'Inkar S.',
    ],
  ),
  CampusEvent(
    id: 'e07',
    title: 'Welcome Week Party',
    category: EventCategory.social,
    startsAt: _at(-4, 20),
    location: 'Dormitory Yard',
    capacity: 100,
    description: 'Music, food and games for first-year students.',
    attendees: const ['Madi K.', 'Assel T.', 'Olzhas M.'],
  ),
  CampusEvent(
    id: 'e08',
    title: 'Python Workshop',
    category: EventCategory.tech,
    startsAt: _at(-10, 14),
    location: 'Lab 105',
    capacity: 25,
    attendees: const ['Gulnaz E.', 'Rustem Y.', 'Diana P.'],
  ),
  CampusEvent(
    id: 'e09',
    title: 'Machine Learning Seminar',
    category: EventCategory.tech,
    startsAt: _at(4, 17),
    location: 'https://meet.example.com/ml-seminar',
    capacity: 150,
    online: true,
    description: 'An online talk on training small models on a laptop.',
    attendees: const ['Nazerke U.', 'Samat L.'],
  ),
  CampusEvent(
    id: 'e10',
    title: 'Photography Walk',
    category: EventCategory.arts,
    startsAt: _at(6, 8, 30),
    location: 'Botanical Garden',
    capacity: 15,
    attendees: const ['Zarina H.', 'Eldar V.', 'Ayana K.', 'Medet J.'],
  ),
  CampusEvent(
    id: 'e11',
    title: 'Startup Pitch Night',
    category: EventCategory.career,
    startsAt: _at(9, 18),
    location: 'Innovation Hub',
    capacity: 10,
    description: 'Teams pitch for three minutes, then answer questions.',
    favourite: true,
    attendees: const [
      'Alikhan R.',
      'Symbat D.',
      'Yeldos F.',
      'Moldir S.',
      'Nursultan I.',
      'Togzhan A.',
      'Adil Z.',
    ],
  ),
  CampusEvent(
    id: 'e12',
    title: 'Chess Tournament',
    category: EventCategory.sports,
    startsAt: _at(12, 13),
    location: 'Library Hall',
    capacity: 32,
    description: 'Swiss system, five rounds, rapid time control.',
    attendees: const ['Ilyas B.'],
  ),
];
