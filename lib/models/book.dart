class Book {
  final int? id;
  final String title;
  final String author;
  final int pages;
  final String genre;
  final bool isRead;
  final DateTime addedDate;

  const Book({
    this.id,
    required this.title,
    required this.author,
    required this.pages,
    required this.genre,
    required this.isRead,
    required this.addedDate,
  });

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'author': author,
        'pages': pages,
        'genre': genre,
        'isRead': isRead ? 1 : 0,
        'addedDate': addedDate.toIso8601String(),
      };

  factory Book.fromMap(Map<String, Object?> map) => Book(
        id: map['id'] as int?,
        title: map['title'] as String,
        author: map['author'] as String,
        pages: map['pages'] as int,
        genre: map['genre'] as String,
        isRead: (map['isRead'] as int) == 1,
        addedDate: DateTime.parse(map['addedDate'] as String),
      );
}
