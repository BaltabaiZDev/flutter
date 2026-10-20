import 'package:flutter/material.dart';
import 'package:reading_list/models/book.dart';

class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book, required this.onToggle});

  final Book book;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  child: Text(book.title[0]),
                ),
                if (!book.read)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.error,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('${book.author} · ${book.pages} pp.'),
                ],
              ),
            ),
            Checkbox(
              value: book.read,
              onChanged: (_) => onToggle(),
            ),
          ],
        ),
      ),
    );
  }
}