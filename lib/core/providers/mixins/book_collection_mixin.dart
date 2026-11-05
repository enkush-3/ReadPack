import 'package:flutter/foundation.dart';
import 'package:readpack/core/providers/helpers/book_provider_persistence.dart';
import 'package:readpack/core/providers/helpers/collection_download_manager.dart';
import 'package:readpack/models/book.dart';
import 'package:readpack/models/collection.dart';

mixin BookCollectionMixin on ChangeNotifier {
  List<Book> get books;
  List<BookCollection> collections = [];
  Set<String> downloadedBookIds = {};

  void createCollection(String name, String description,
      {String icon = 'bookmark'}) {
    CollectionDownloadManager.createCollection(
      collections: collections,
      name: name,
      description: description,
      icon: icon,
    );
    notifyListeners();
    BookProviderPersistence.persistCollections(collections);
  }

  void deleteCollection(String id) {
    CollectionDownloadManager.deleteCollection(collections, id);
    notifyListeners();
    BookProviderPersistence.persistCollections(collections);
  }

  bool addBookToCollection(String collectionId, String bookId) {
    final added = CollectionDownloadManager.addBookToCollection(
      collections: collections,
      collectionId: collectionId,
      bookId: bookId,
    );
    if (added) {
      notifyListeners();
      BookProviderPersistence.persistCollections(collections);
    }
    return added;
  }

  void removeBookFromCollection(String collectionId, String bookId) {
    CollectionDownloadManager.removeBookFromCollection(
      collections: collections,
      collectionId: collectionId,
      bookId: bookId,
    );
    notifyListeners();
    BookProviderPersistence.persistCollections(collections);
  }

  void toggleDownload(String bookId, VoidCallback onAwardXp) {
    if (downloadedBookIds.contains(bookId)) {
      downloadedBookIds.remove(bookId);
    } else {
      downloadedBookIds.add(bookId);
      onAwardXp();
    }
    notifyListeners();
    BookProviderPersistence.persistDownloadedBooks(downloadedBookIds);
  }

  bool isBookDownloaded(String bookId) => downloadedBookIds.contains(bookId);

  double getDownloadedSizeMb(String bookId) =>
      CollectionDownloadManager.getDownloadedSizeMb(books, bookId);

  double get totalDownloadedStorageMb =>
      CollectionDownloadManager.totalDownloadedStorageMb(
          books, downloadedBookIds);
}
