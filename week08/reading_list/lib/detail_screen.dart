import 'package:flutter/material.dart';

import 'models/book.dart';

enum BookAction { toggleRead, delete }

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(leading: const Text('Title'), title: Text(book.title)),
            ListTile(leading: const Text('Author'), title: Text(book.author)),
            ListTile(
              leading: const Text('Pages'),
              title: Text(book.pages.toString()),
            ),
            ListTile(
              leading: const Text('Year'),
              title: Text(
                book.year == null ? 'Year unknown' : book.year.toString(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(BookAction.toggleRead);
                  },
                  child: Text(book.read ? 'Mark as unread' : 'Mark as read'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    final bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Delete ${book.title}?'),
                          actions: [
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );

                    if (!context.mounted || confirmed == false) return;

                    Navigator.of(context).pop(BookAction.delete);
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
