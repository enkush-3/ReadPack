import 'package:readpack/models/book.dart';
import 'package:readpack/models/collection.dart';

class CollectionDownloadManager {
  static void createCollection({
    required List<BookCollection> collections,
    required String name,
    required String description,
    String icon = 'bookmark',
  }) {
    final newCollection = BookCollection(
      id: 'coll_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isNotEmpty ? name.trim() : 'Шинэ цуглуулга',
      description: description.trim(),
      icon: icon,
      createdAt: DateTime.now(),
      bookIds: [],
    );
    collections.insert(0, newCollection);
  }

  static void deleteCollection(List<BookCollection> collections, String id) {
    collections.removeWhere((c) => c.id == id);
  }

  static bool addBookToCollection({
    required List<BookCollection> collections,
    required String collectionId,
    required String bookId,
  }) {
    final index = collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      if (!collections[index].bookIds.contains(bookId)) {
        final updatedIds = [...collections[index].bookIds, bookId];
        collections[index] = collections[index].copyWith(bookIds: updatedIds);
        return true;
      }
    }
    return false;
  }

  static void removeBookFromCollection({
    required List<BookCollection> collections,
    required String collectionId,
    required String bookId,
  }) {
    final index = collections.indexWhere((c) => c.id == collectionId);
    if (index != -1) {
      final updatedIds =
          collections[index].bookIds.where((id) => id != bookId).toList();
      collections[index] = collections[index].copyWith(bookIds: updatedIds);
    }
  }

  static double getDownloadedSizeMb(List<Book> books, String bookId) {
    final book =
        books.firstWhere((b) => b.id == bookId, orElse: () => books.first);
    return double.parse((8.5 + (book.pages * 0.04)).toStringAsFixed(1));
  }

  static double totalDownloadedStorageMb(
      List<Book> books, Set<String> downloadedBookIds) {
    return double.parse(downloadedBookIds
        .fold<double>(
            0.0, (acc, id) => acc + getDownloadedSizeMb(books, id))
        .toStringAsFixed(1));
  }
}
