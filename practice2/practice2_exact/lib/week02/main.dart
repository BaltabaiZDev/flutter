import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();

  for (final json in rawBooks) {
    library.add(Book.fromJson(json));
  }

  library.open();

  print('REPORT');
  print(library.report);

  print('\nTITLES');
  print(library.titles);

  print('\nBOOKS AFTER 2010');
  print(library.booksAfter2010);

  print('\nAVERAGE PAGES');
  print(library.averagePages);

  print('\nBOOKS PER AUTHOR');
  print(library.booksPerAuthor);

  print('\nUNIQUE AUTHORS');
  print(library.uniqueAuthors);

  print('\nPRESENT GENRES');
  print(library.presentGenres);

  print('\nDISPLAY LIST');
  for (final line in library.displayList) {
    print(line);
  }

  final books = library.items.whereType<Book>().toList();
  final stats = statsOf(books);

  print('\nSTATS');
  print(stats);

  print('\nSHELF STATES');
  print(describe(Empty()));
  print(describe(Ready(books)));
  print(describe(Broken('shelf overloaded')));
}
