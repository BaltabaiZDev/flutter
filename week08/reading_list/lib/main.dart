import 'package:flutter/material.dart';
import 'library_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo)),
    home: const LibraryScreen(),
  );
}

class Book {
  Book({
    required this.title,
    required this.author,
    required this.pages,
    this.year,
    this.read = false,
  });

  final String title;
  final String author;
  final int pages;
  final int? year;
  bool read;
}

final seed = <Book>[
  Book(title: 'Widgets All the Way Down', author: 'A. Nurmagambetova',
      pages: 288, year: 2021, read: true),
  Book(title: 'Null Safety for Humans', author: 'B. Seitkali',
      pages: 196, year: 2022),
  Book(title: 'Constraints Go Down, Sizes Go Up', author: 'C. Tashimova',
      pages: 320),
  Book(title: 'The Navigator Is a Stack', author: 'D. Alibekov',
      pages: 240, year: 2020),
  Book(title: 'A Very Long Title About Forms, Focus, the Keyboard '
      'and Everything That Overflows', author: 'E. Omarova',
      pages: 176, year: 2023),
];
