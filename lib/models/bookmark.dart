class Bookmark {
  final String id;
  final String bookId;
  final String bookTitle;
  final String chapterTitle;
  final int pageNumber;
  final String quote;
  final String note;
  final int colorHex;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.chapterTitle,
    required this.pageNumber,
    required this.quote,
    this.note = '',
    this.colorHex = 0xFFFFD54F, // amber highlight
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'bookId': bookId,
    'bookTitle': bookTitle,
    'chapterTitle': chapterTitle,
    'pageNumber': pageNumber,
    'quote': quote,
    'note': note,
    'colorHex': colorHex,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
    id: json['id'] as String,
    bookId: json['bookId'] as String,
    bookTitle: json['bookTitle'] as String,
    chapterTitle: json['chapterTitle'] as String? ?? 'Chapter 1',
    pageNumber: json['pageNumber'] as int? ?? 1,
    quote: json['quote'] as String,
    note: json['note'] as String? ?? '',
    colorHex: json['colorHex'] as int? ?? 0xFFFFD54F,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}
