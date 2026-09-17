import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  late final DateTime openedAt;
  String? _cachedReport;

  void open() {
    openedAt = DateTime.now();
  }

  void add(LibraryItem item) {
    items.add(item);
    _cachedReport = null;
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book &&
          item.title.toLowerCase() == title.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) {
    return findByTitle(title)?.author.country ?? 'unknown';
  }

  List<String> get titles {
    return items.map((item) => item.title).toList();
  }

  List<Book> get booksAfter2010 {
    return items
        .whereType<Book>()
        .where((book) => book.year > 2010)
        .toList();
  }

  double get averagePages {
    final books = items.whereType<Book>().toList();

    if (books.isEmpty) {
      return 0;
    }

    final totalPages =
        books.fold<int>(0, (sum, book) => sum + book.pages);

    return totalPages / books.length;
  }

  Map<String, int> get booksPerAuthor {
    return items.whereType<Book>().fold<Map<String, int>>(
      {},
      (result, book) {
        result[book.author.name] =
            (result[book.author.name] ?? 0) + 1;
        return result;
      },
    );
  }

  Set<String> get uniqueAuthors {
    return items
        .whereType<Book>()
        .map((book) => book.author.name)
        .toSet();
  }

  Set<Genre> get presentGenres {
    return items
        .whereType<Book>()
        .map((book) => book.genre)
        .toSet();
  }

  List<String> get displayList => [
        'CATALOGUE',
        for (final book in items.whereType<Book>())
          '${book.title} (${book.year})',
        ...uniqueAuthors,
        if (items.whereType<Book>().any((book) => book.pages == 0))
          '(Incomplete data)',
      ];

  String get report {
    return _cachedReport ??=
        'Total items: ${items.length}';
  }
}
