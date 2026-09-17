import 'models.dart';

sealed class ShelfState {}

final class Empty extends ShelfState {}

final class Ready extends ShelfState {
  final List<Book> books;

  Ready(this.books);
}

final class Broken extends ShelfState {
  final String message;

  Broken(this.message);
}

String describe(ShelfState state) => switch (state) {
      Empty() => 'Shelf is empty',
      Ready(:final books) => 'Shelf is ready with ${books.length} books',
      Broken(:final message) => 'Shelf is broken: $message',
    };

({int count, double avgPages}) statsOf(List<Book> books) {
  if (books.isEmpty) {
    return (count: 0, avgPages: 0.0);
  }

  final totalPages =
      books.fold<int>(0, (sum, book) => sum + book.pages);

  return (
    count: books.length,
    avgPages: totalPages / books.length,
  );
}
