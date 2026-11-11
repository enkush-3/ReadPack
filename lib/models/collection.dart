class BookCollection {
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> bookIds;
  final DateTime createdAt;

  const BookCollection({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = 'bookmark',
    this.bookIds = const [],
    required this.createdAt,
  });

  BookCollection copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    List<String>? bookIds,
    DateTime? createdAt,
  }) {
    return BookCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      bookIds: bookIds ?? this.bookIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'bookIds': bookIds,
    'createdAt': createdAt.toIso8601String(),
  };

  factory BookCollection.fromJson(Map<String, dynamic> json) => BookCollection(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    icon: json['icon'] as String? ?? 'bookmark',
    bookIds:
        (json['bookIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now(),
  );
}
