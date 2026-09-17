# Lab 2 — Dart OOP and Collections

Simple Lab 2 project for Mobile Development.

## Topics used

- classes and objects
- nullable types
- enum
- abstract class
- inheritance
- mixin
- implements
- factory constructor
- getters
- copyWith
- List / Map / Set
- map / where / whereType / fold
- late final
- private field
- null-aware operators
- collection for / spread / collection if
- sealed class
- switch pattern matching
- records

## Run

```bash
dart pub get
dart run lib/week02/main.dart
```

## Structure

```text
lab2_practice/
├── pubspec.yaml
├── README.md
└── lib/
    └── week02/
        ├── main.dart
        ├── data.dart
        ├── models.dart
        ├── catalogue.dart
        └── shelf_state.dart
```

## Short defense explanation

The project represents a small library catalogue.

`data.dart` contains raw book data.

`models.dart` contains the main OOP models:
`Author`, `Genre`, `LibraryItem`, `Book`, `Magazine`, `Ghost`.

`catalogue.dart` manages the collection and calculates statistics.

`shelf_state.dart` demonstrates sealed classes, switch pattern matching and records.

`main.dart` creates the library, converts raw maps to Book objects and tests all functions.
