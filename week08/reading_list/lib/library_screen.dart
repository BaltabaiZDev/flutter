import 'package:flutter/material.dart';
import 'models/book.dart';
import 'widgets/book_tile.dart';
import 'detail_screen.dart';

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
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Books',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${_books.length}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Pages',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${totalPages(_books)}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Unread',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${unread(_books).length}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                  return InkWell(
                    onTap: () async {
                      final action = await Navigator.of(context).push<BookAction>(MaterialPageRoute(builder: (context) => DetailScreen(book: _visible[index])));

                      if (!context.mounted || action == null) return;

                      switch (action) {
                        case BookAction.toggleRead:
                          setState(() => _visible[index].read = !_visible[index].read);
                        case BookAction.delete:
                          setState(() => _books.remove(_visible[index]));
                      }
                    },
                    child: BookTile(
                      book: _visible[index],
                      onToggle: () => setState(() => _visible[index].read = !_visible[index].read),
                    ),
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