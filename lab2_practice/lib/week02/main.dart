import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();
  library.open();

  for (final json in rawBooks) {
    library.add(Book.fromJson(json));
  }

  library.add(
    const Magazine(
      title: 'Dart Monthly',
      year: 2026,
      issue: 2,
    ),
  );

  print('ALL TITLES');
  print(library.titles);

  print('\nBOOKS AFTER 2010');
  for (final book in library.booksAfter2010) {
    print(book.title);
  }

  print('\nAVERAGE PAGES');
  print(library.averagePages.toStringAsFixed(1));

  print('\nBOOKS PER AUTHOR');
  print(library.booksPerAuthor);

  print('\nUNIQUE AUTHORS');
  print(library.uniqueAuthors);

  print('\nGENRES');
  print(library.presentGenres.map((genre) => genre.label).toList());

  print('\nSEARCH');
  print(library.findByTitle('Refactoring')?.describe());
  print('Country: ${library.countryOf('Design Patterns')}');

  print('\nDISPLAY LIST');
  for (final line in library.displayList) {
    print(line);
  }

  final books = library.items.whereType<Book>().toList();
  final stats = statsOf(books);

  print('\nSTATS');
  print('Count: ${stats.count}');
  print('Average pages: ${stats.averagePages.toStringAsFixed(1)}');

  print('\nSHELF STATES');
  print(describeShelf(Empty()));
  print(describeShelf(Ready(books)));
  print(describeShelf(Broken('too many books')));

  print('\nMIXIN EXAMPLE');
  print(books.first.borrowLabel());

  print('\nCOPY WITH EXAMPLE');
  final updatedBook = books.first.copyWith(pages: 500);
  print(updatedBook);
}
