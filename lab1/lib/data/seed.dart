import '../models/cause.dart';
import '../models/shift.dart';

/// Twelve shifts, all dated relative to the moment the app starts.
List<Shift> seedShifts() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  DateTime at(int days, int hour, [int minute = 0]) =>
      today.add(Duration(days: days, hours: hour, minutes: minute));

  return [
    // Mandatory: a title of exactly 60 characters.
    Shift(
      id: 's1',
      title: 'Riverbank clean-up and plastic sorting along the city canals',
      cause: Cause.environment,
      startsAt: at(2, 9),
      slots: 30,
      volunteers: const ['Aigerim', 'Dana', 'Nursultan'],
      location: 'Esentai river, north bridge',
      notes: 'Gloves and bags are provided. Wear boots.',
    ),
    // Mandatory: at its limit.
    Shift(
      id: 's2',
      title: 'Dog walking at the city shelter',
      cause: Cause.animals,
      startsAt: at(1, 10),
      slots: 4,
      volunteers: const ['Arman', 'Madina', 'Timur', 'Zarina'],
      location: 'Happy Paws shelter, Raiymbek 12',
      notes: 'Bring a water bottle; leashes are at the gate.',
      favourite: true,
    ),
    // Mandatory: in the past.
    Shift(
      id: 's3',
      title: 'Saturday soup kitchen',
      cause: Cause.foodBank,
      startsAt: at(-3, 12),
      slots: 12,
      volunteers: const ['Dana', 'Erlan', 'Kamila', 'Olzhas', 'Sanzhar'],
      location: 'Community centre, Abay 45',
      notes: 'Thank you to everyone who came!',
    ),
    // Mandatory: mode on (remote, location is a link).
    Shift(
      id: 's4',
      title: 'Online maths tutoring for 7th grade',
      cause: Cause.education,
      startsAt: at(1, 18, 30),
      slots: 8,
      volunteers: const ['Alikhan', 'Asel'],
      isRemote: true,
      location: 'https://meet.example.org/maths-7',
      notes: 'Topic this week: fractions and percentages.',
      favourite: true,
    ),
    // Mandatory: no optional text.
    Shift(
      id: 's5',
      title: 'Blood donation day helpers',
      cause: Cause.health,
      startsAt: at(5, 8),
      slots: 10,
      volunteers: const ['Bekzat', 'Gulnara', 'Yerlan'],
      location: 'Main campus, Hall B',
    ),
    Shift(
      id: 's6',
      title: 'Tree planting in the botanical garden',
      cause: Cause.environment,
      startsAt: at(9, 9, 30),
      slots: 40,
      volunteers: const ['Aigerim', 'Ruslan'],
      location: 'Botanical garden, east gate',
      notes: 'Saplings and shovels on site.',
    ),
    Shift(
      id: 's7',
      title: 'Cat shelter cleaning',
      cause: Cause.animals,
      startsAt: at(3, 14),
      slots: 6,
      volunteers: const ['Aruzhan', 'Dias', 'Laura'],
      location: 'Whiskers home, Tole bi 101',
    ),
    Shift(
      id: 's8',
      title: 'English speaking club for kids',
      cause: Cause.education,
      startsAt: at(4, 16),
      slots: 15,
      volunteers: const [],
      isRemote: true,
      location: 'https://meet.example.org/speak-club',
      notes: 'Games and short stories, ages 9-12.',
    ),
    Shift(
      id: 's9',
      title: 'Food parcel packing',
      cause: Cause.foodBank,
      startsAt: at(6, 11),
      slots: 20,
      volunteers: const ['Erlan', 'Kamila', 'Miras', 'Nazerke', 'Saule'],
      location: 'Food bank warehouse, Suyunbay 2',
      notes: 'Closed shoes required.',
      favourite: true,
    ),
    Shift(
      id: 's10',
      title: 'Elderly care home visit',
      cause: Cause.health,
      startsAt: at(-10, 15),
      slots: 8,
      volunteers: const ['Gulnara', 'Madina'],
      location: 'Care home "Meyirim", Zhandosov 7',
    ),
    Shift(
      id: 's11',
      title: 'Library book sorting',
      cause: Cause.education,
      startsAt: at(12, 10),
      slots: 10,
      volunteers: const ['Asel', 'Dana', 'Islam', 'Nurlan', 'Tomiris', 'Zhan'],
      location: 'University library, 3rd floor',
      notes: 'We sort donated books for village schools.',
    ),
    Shift(
      id: 's12',
      title: 'First aid awareness webinar',
      cause: Cause.health,
      startsAt: at(7, 19),
      slots: 100,
      volunteers: const ['Bekzat'],
      isRemote: true,
      location: 'https://meet.example.org/first-aid',
    ),
  ];
}
