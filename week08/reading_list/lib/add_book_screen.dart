import 'package:flutter/material.dart';

import 'models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _pages = TextEditingController();
  final _year = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    for (final controller in [_title, _author, _pages, _year]) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _title,
                    validator: (value) {
                      if ((value ?? '').trim().length < 2) {
                        return 'Title too short';
                      }

                      return null;
                    },
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: const InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _author,
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Author cannot be empty';
                      }

                      return null;
                    },
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: const InputDecoration(labelText: 'Author'),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _pages,
                    validator: (value) {
                      final num = int.tryParse(value ?? '');

                      if (num == null || num <= 0) {
                        return 'A whole number above 0';
                      }

                      return null;
                    },
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: const InputDecoration(labelText: 'Pages'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: TextFormField(
                    controller: _year,
                    validator: (value) {
                      final num = int.tryParse(value ?? '');

                      if (num != null &&
                          (num < 1450 || num > DateTime.now().year)) {
                        return 'Year must be between 1450 and ${DateTime.now().year}';
                      }

                      return null;
                    },
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: const InputDecoration(labelText: 'Year'),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final Book book = Book.fromMap({
                      'title': _title.text,
                      'author': _author.text,
                      'pages': int.parse(_pages.text),
                      'year': int.tryParse(_year.text),
                    });

                    Navigator.of(context).pop(book);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
