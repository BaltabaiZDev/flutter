import 'package:flutter/material.dart';
import 'models/book.dart';

enum Filter {
  all,
  unread,
  read
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Book> _books = [...seed];

  Filter _filter = Filter.all;

  List<Book> get _visible {
    switch (_filter) {
      case Filter.all:
        return _books;
      case Filter.unread:
        return unread(_books);
      case Filter.read:
        return _books.where((book) => book.read).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reading list (${_visible.length})'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final Filter f in Filter.values)
                      ChoiceChip(
                        label: Text(switch (f) {
                          Filter.all => 'All',
                          Filter.unread => 'Unread',
                          Filter.read => 'Read',
                        }),
                        selected: _filter == f,
                        onSelected: (value) => setState(() {
                          _filter = f;
                        }),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _visible.length,
                itemBuilder: (BuildContext context, int index) {
                  return CheckboxListTile(
                    value: _visible[index].read,
                    title: Text(_visible[index].title),
                    subtitle: Text(_visible[index].author),
                    onChanged: (value) => setState(() => _visible[index].read = value ?? false),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}