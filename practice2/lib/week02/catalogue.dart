import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  late final DateTime openedAt;
  String? _cachedReport;

  void add(LibraryItem item) {
    items.add(item);
    _cachedReport = null;
  }

  void open() {
    openedAt = DateTime.now();
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

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  String get report =>
      _cachedReport ??= 'Total items: ${items.length}';

  List<String> get titles =>
      items.map((item) => item.title).toList();

  List<Book> get booksAfter2010 =>
      items.whereType<Book>().where((book) => book.year > 2010).toList();

  // fold is used instead of reduce because fold gives an initial value (0)
  // and safely builds the numeric total.
  double get averagePages => items.whereType<Book>().isEmpty
      ? 0.0
      : items
              .whereType<Book>()
              .fold<int>(0, (sum, book) => sum + book.pages) /
          items.whereType<Book>().length;

  Map<String, int> get booksPerAuthor =>
      items.whereType<Book>().fold<Map<String, int>>(
        <String, int>{},
        (counts, book) => {
          ...counts,
          book.author.name: (counts[book.author.name] ?? 0) + 1,
        },
      );

  Set<String> get uniqueAuthors =>
      items.whereType<Book>().map((book) => book.author.name).toSet();

  Set<Genre> get presentGenres =>
      items.whereType<Book>().map((book) => book.genre).toSet();

  List<String> get displayList => [
        'CATALOGUE',
        for (final book in items.whereType<Book>())
          '${book.title} (${book.year})',
        ...uniqueAuthors,
        if (items.whereType<Book>().any((book) => book.pages == 0))
          '(incomplete data)',
      ];
}
