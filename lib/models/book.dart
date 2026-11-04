class BookReview {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final int helpfulCount;
  final bool isHelpful;

  const BookReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.helpfulCount = 0,
    this.isHelpful = false,
  });

  BookReview copyWith({
    String? id,
    String? userName,
    double? rating,
    String? comment,
    DateTime? createdAt,
    int? helpfulCount,
    bool? isHelpful,
  }) {
    return BookReview(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      isHelpful: isHelpful ?? this.isHelpful,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'helpfulCount': helpfulCount,
    'isHelpful': isHelpful,
  };

  factory BookReview.fromJson(Map<String, dynamic> json) => BookReview(
    id: json['id'] as String,
    userName: json['userName'] as String? ?? 'Уншигч',
    rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    comment: json['comment'] as String? ?? '',
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
    helpfulCount: json['helpfulCount'] as int? ?? 0,
    isHelpful: json['isHelpful'] as bool? ?? false,
  );
}

class BookChapter {
  final String id;
  final String title;
  final String content;
  final int estimatedMinutes;

  const BookChapter({
    required this.id,
    required this.title,
    required this.content,
    required this.estimatedMinutes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'estimatedMinutes': estimatedMinutes,
  };

  factory BookChapter.fromJson(Map<String, dynamic> json) => BookChapter(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    estimatedMinutes: json['estimatedMinutes'] as int? ?? 5,
  );
}

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final double rating;
  final int reviewsCount;
  final String category;
  final int pages;
  final int readTimeMinutes;
  final String? image;
  final int colorHex;
  final List<BookChapter> chapters;
  final double progress;
  final int currentPage;
  final int currentChapterIndex;
  final bool isSaved;
  final bool isFavorite;
  final List<String> keyTakeaways;
  final List<BookReview> reviews;
  final List<String> tags;
  final bool hasAudio;
  final int audioDurationMinutes;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.rating,
    this.reviewsCount = 120,
    required this.category,
    required this.pages,
    required this.readTimeMinutes,
    this.image,
    this.colorHex = 0xFF182350,
    this.chapters = const [],
    this.progress = 0.0,
    this.currentPage = 0,
    this.currentChapterIndex = 0,
    this.isSaved = false,
    this.isFavorite = false,
    this.keyTakeaways = const [],
    this.reviews = const [],
    this.tags = const [],
    this.hasAudio = true,
    this.audioDurationMinutes = 15,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    double? rating,
    int? reviewsCount,
    String? category,
    int? pages,
    int? readTimeMinutes,
    String? image,
    int? colorHex,
    List<BookChapter>? chapters,
    double? progress,
    int? currentPage,
    int? currentChapterIndex,
    bool? isSaved,
    bool? isFavorite,
    List<String>? keyTakeaways,
    List<BookReview>? reviews,
    List<String>? tags,
    bool? hasAudio,
    int? audioDurationMinutes,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      category: category ?? this.category,
      pages: pages ?? this.pages,
      readTimeMinutes: readTimeMinutes ?? this.readTimeMinutes,
      image: image ?? this.image,
      colorHex: colorHex ?? this.colorHex,
      chapters: chapters ?? this.chapters,
      progress: progress ?? this.progress,
      currentPage: currentPage ?? this.currentPage,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      isSaved: isSaved ?? this.isSaved,
      isFavorite: isFavorite ?? this.isFavorite,
      keyTakeaways: keyTakeaways ?? this.keyTakeaways,
      reviews: reviews ?? this.reviews,
      tags: tags ?? this.tags,
      hasAudio: hasAudio ?? this.hasAudio,
      audioDurationMinutes:
          audioDurationMinutes ?? this.audioDurationMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'description': description,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'category': category,
    'pages': pages,
    'readTimeMinutes': readTimeMinutes,
    'image': image,
    'colorHex': colorHex,
    'progress': progress,
    'currentPage': currentPage,
    'currentChapterIndex': currentChapterIndex,
    'isSaved': isSaved,
    'isFavorite': isFavorite,
    'chapters': chapters.map((c) => c.toJson()).toList(),
    'keyTakeaways': keyTakeaways,
    'reviews': reviews.map((r) => r.toJson()).toList(),
    'tags': tags,
    'hasAudio': hasAudio,
    'audioDurationMinutes': audioDurationMinutes,
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String,
    title: json['title'] as String,
    author: json['author'] as String,
    description: json['description'] as String? ?? '',
    rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
    reviewsCount: json['reviewsCount'] as int? ?? 100,
    category: json['category'] as String? ?? 'General',
    pages: json['pages'] as int? ?? 200,
    readTimeMinutes: json['readTimeMinutes'] as int? ?? 120,
    image: json['image'] as String?,
    colorHex: json['colorHex'] as int? ?? 0xFF182350,
    progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    currentPage: json['currentPage'] as int? ?? 0,
    currentChapterIndex: json['currentChapterIndex'] as int? ?? 0,
    isSaved: json['isSaved'] as bool? ?? false,
    isFavorite: json['isFavorite'] as bool? ?? false,
    chapters: (json['chapters'] as List<dynamic>?)
            ?.map((c) => BookChapter.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [],
    keyTakeaways: (json['keyTakeaways'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    reviews: (json['reviews'] as List<dynamic>?)
            ?.map((r) => BookReview.fromJson(r as Map<String, dynamic>))
            .toList() ??
        [],
    tags: (json['tags'] as List<dynamic>?)
            ?.map((t) => t.toString())
            .toList() ??
        [],
    hasAudio: json['hasAudio'] as bool? ?? true,
    audioDurationMinutes: json['audioDurationMinutes'] as int? ?? 15,
  );
}
