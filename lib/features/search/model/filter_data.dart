class FilterData {
  List<String> categories;
  double minRating;
  String sortBy;
  String priceRange;
  String mood;

  FilterData({
    required this.categories,
    required this.minRating,
    required this.sortBy,
    required this.priceRange,
    this.mood = 'all',
  });

  factory FilterData.defaults() => FilterData(
    categories: [],
    minRating: 0,
    sortBy: 'popular',
    priceRange: 'all',
    mood: 'all',
  );

  factory FilterData.from(FilterData other) => FilterData(
    categories: List.from(other.categories),
    minRating: other.minRating,
    sortBy: other.sortBy,
    priceRange: other.priceRange,
    mood: other.mood,
  );
}
