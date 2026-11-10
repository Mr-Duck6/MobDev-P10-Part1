import 'package:flutter/material.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';
import 'add_book_screen.dart';

enum BookFilter { all, read, unread }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookRepository _repository = BookRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Book> _books = [];
  Map<String, int> _statistics = {'total': 0, 'read': 0};
  BookFilter _filter = BookFilter.all;
  bool _newestFirst = true;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_loadBooks);
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.removeListener(_loadBooks);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final query = _searchController.text.trim();
      List<Book> result;

      if (query.isNotEmpty) {
        result = await _repository.searchByAuthor(query);
        if (_filter != BookFilter.all) {
          result = result
              .where((book) => book.isRead == (_filter == BookFilter.read))
              .toList();
        }
      } else {
        result = await _repository.filterByReadStatus(
          _filter == BookFilter.all ? null : _filter == BookFilter.read,
        );
      }

      if (!_newestFirst) result = result.reversed.toList();
      final stats = await _repository.getStatistics();

      if (!mounted) return;
      setState(() {
        _books = result;
        _statistics = stats;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _addBook() async {
    final book = await Navigator.push<Book>(
      context,
      MaterialPageRoute(builder: (_) => const AddBookScreen()),
    );
    if (book == null) return;

    try {
      await _repository.insert(book);
      await _loadBooks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Книгу додано до бібліотеки')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $e')),
      );
    }
  }

  Future<void> _toggleRead(Book book) async {
    try {
      await _repository.updateReadStatus(book.id!, !book.isRead);
      await _loadBooks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не вдалося змінити статус: $e')),
      );
    }
  }

  Future<void> _deleteBook(Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити книгу'),
        content: Text('Ви справді хочете видалити «${book.title}»?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await _repository.delete(book.id!);
      await _loadBooks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не вдалося видалити книгу: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _statistics['total'] ?? 0;
    final read = _statistics['read'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Книжкова бібліотека',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Змінити порядок сортування',
            onPressed: () {
              setState(() => _newestFirst = !_newestFirst);
              _loadBooks();
            },
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Усього книг: $total',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text('Прочитано: $read',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Пошук за автором',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Очистити пошук',
                  onPressed: _searchController.clear,
                  icon: const Icon(Icons.close),
                ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const Text('Показати:'),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<BookFilter>(
                    value: _filter,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: BookFilter.all, child: Text('Усі книги')),
                      DropdownMenuItem(
                          value: BookFilter.read, child: Text('Прочитані')),
                      DropdownMenuItem(
                          value: BookFilter.unread,
                          child: Text('Не прочитані')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _filter = value);
                      _loadBooks();
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              _newestFirst
                  ? 'Сортування: спочатку новіші'
                  : 'Сортування: спочатку старіші',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildBookList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBook,
        tooltip: 'Додати книгу',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBookList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_error!, textAlign: TextAlign.center),
        ),
      );
    }
    if (_books.isEmpty) {
      return const Center(
        child: Text('Список порожній. Додайте першу книгу.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
      itemCount: _books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final book = _books[index];
        final date =
            '${book.addedDate.day.toString().padLeft(2, '0')}.'
            '${book.addedDate.month.toString().padLeft(2, '0')}.'
            '${book.addedDate.year}';

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Checkbox(
              value: book.isRead,
              onChanged: (_) => _toggleRead(book),
            ),
            title: Text(
              book.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration:
                    book.isRead ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text(
              '${book.author}\n${book.genre} • ${book.pages} стор. • $date',
            ),
            isThreeLine: true,
            trailing: IconButton(
              tooltip: 'Видалити книгу',
              onPressed: () => _deleteBook(book),
              icon: const Icon(Icons.delete_outline),
            ),
          ),
        );
      },
    );
  }
}
