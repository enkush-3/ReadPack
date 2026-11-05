import 'package:readpack/models/book.dart';

class BookFilterHelper {
  static List<Book> sortSavedBooks(List<Book> books, String sortBy) {
    final list = books.where((b) => b.isSaved).toList();
    switch (sortBy) {
      case 'title':
        list.sort((a, b) =>
            a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'author':
        list.sort((a, b) =>
            a.author.toLowerCase().compareTo(b.author.toLowerCase()));
        break;
      case 'progress':
        list.sort((a, b) => b.progress.compareTo(a.progress));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'recent':
      default:
        break;
    }
    return list;
  }

  static List<Book> filterCategory(List<Book> books, String category) {
    return books.where((b) {
      if (category == 'book.categories.all') return true;
      return b.category == category;
    }).toList();
  }

  static void commitQuery(List<String> searches, String query) {
    final trimmed = query.trim();
    if (trimmed.length >= 2) {
      searches.remove(trimmed);
      searches.insert(0, trimmed);
      if (searches.length > 10) {
        searches.removeRange(10, searches.length);
      }
    }
  }
}
