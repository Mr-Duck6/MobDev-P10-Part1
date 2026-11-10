import 'package:flutter/material.dart';
import '../models/book.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _pagesController = TextEditingController();
  final _genreController = TextEditingController();
  bool _isRead = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final book = Book(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      pages: int.parse(_pagesController.text.trim()),
      genre: _genreController.text.trim(),
      isRead: _isRead,
      addedDate: DateTime.now(),
    );
    Navigator.pop(context, book);
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Це поле обов’язкове' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Нова книга')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Назва книги',
                prefixIcon: Icon(Icons.menu_book),
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Автор',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pagesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Кількість сторінок',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final pages = int.tryParse(value ?? '');
                if (pages == null || pages <= 0) {
                  return 'Вкажіть додатну кількість сторінок';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _genreController,
              decoration: const InputDecoration(
                labelText: 'Жанр',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Книгу вже прочитано'),
              value: _isRead,
              onChanged: (value) => setState(() => _isRead = value),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Зберегти книгу'),
            ),
          ],
        ),
      ),
    );
  }
}
