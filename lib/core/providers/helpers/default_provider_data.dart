import 'package:readpack/models/bookmark.dart';
import 'package:readpack/models/collection.dart';
import 'package:readpack/models/notification_model.dart';

class DefaultProviderData {
  static List<Bookmark> defaultBookmarks() {
    return [
      Bookmark(
        id: 'bm_default_1',
        bookId: 'book_1',
        bookTitle: '1984',
        chapterTitle: 'Part 1: The Clock Strikes Thirteen',
        pageNumber: 2,
        quote: 'War is peace. Freedom is slavery. Ignorance is strength.',
        note: 'The party’s primary paradox slogan.',
        colorHex: 0xFFFFD54F,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Bookmark(
        id: 'bm_default_2',
        bookId: 'book_2',
        bookTitle: 'Clear Thinking',
        chapterTitle: 'Chapter 1: The Enemies of Clear Thinking',
        pageNumber: 15,
        quote:
            'Between stimulus and response lies a space. In that space is our power to choose our response.',
        note: 'Fundamental to pausing default emotional reactions.',
        colorHex: 0xFF81C784,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Bookmark(
        id: 'bm_default_3',
        bookId: 'book_3',
        bookTitle: 'Atomic Habits',
        chapterTitle: 'Chapter 1: The Surprising Power of Atomic Habits',
        pageNumber: 27,
        quote:
            'You do not rise to the level of your goals. You fall to the level of your systems.',
        note: 'Зорилго биш өдөр тутмын систем, зуршил амжилтыг шийддэг.',
        colorHex: 0xFF64B5F6,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Bookmark(
        id: 'bm_default_4',
        bookId: 'book_4',
        bookTitle: 'Sapiens',
        chapterTitle: 'Part 1: The Cognitive Revolution',
        pageNumber: 42,
        quote:
            'We study history not in order to know the future, but to widen our horizons.',
        note: 'Түүх бидний сэтгэлгээний хүрээг тэлдэг.',
        colorHex: 0xFFBA68C8,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  static List<NotificationItem> defaultNotifications() {
    return [
      NotificationItem(
        id: 'notif_1',
        title: 'Шинэ ном нэмэгдлээ',
        message:
            '"Atomic Habits" ном таны сан руу нэмэгдлээ. Одоо уншиж эхлээрэй!',
        time: '5 мин',
        isRead: false,
        type: 'new_book',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationItem(
        id: 'notif_2',
        title: 'Өдрийн зөвлөмж',
        message: 'Таны уншдаг төрөлд тохирох 3 шинэ ном санал болгож байна.',
        time: '1 цаг',
        isRead: false,
        type: 'recommendation',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationItem(
        id: 'notif_3',
        title: 'Амжилт!',
        message:
            'Та 7 өдөр дараалан уншсаны төлөө "Номын хорхойтон" badge авлаа.',
        time: 'Өчигдөр',
        isRead: true,
        type: 'achievement',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationItem(
        id: 'notif_4',
        title: 'Аппликейшн шинэчлэгдсэн',
        message:
            'Шинэ функц: Одоо та номоо аудио хэлбэрээр сонсож, эшлэлээ тэмдэглэх боломжтой боллоо.',
        time: '2 өдөр',
        isRead: true,
        type: 'system',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      NotificationItem(
        id: 'notif_5',
        title: 'Дуртай зохиолч',
        message: 'Paulo Coelho-ийн шинэ ном гарлаа. Шалгаад үзээрэй!',
        time: '3 өдөр',
        isRead: true,
        type: 'author',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  static List<BookCollection> defaultCollections() {
    return [
      BookCollection(
        id: 'c_2026',
        name: '2026 онд унших зорилт',
        description: 'Энэ онд заавал дуусгах шилдэг номууд',
        icon: 'emoji_events',
        bookIds: ['book_1', 'book_3'],
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      BookCollection(
        id: 'c_growth',
        name: 'Хувь хүний хөгжил ба Зуршил',
        description: 'Дадал зуршил, сэтгэлгээний чадварууд',
        icon: 'lightbulb',
        bookIds: ['book_2', 'book_4'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      BookCollection(
        id: 'c_favorites',
        name: 'Шилдэг сонгодог бүтээлүүд',
        description: 'Дахин дахин эргэцүүлэн унших бүтээлүүд',
        icon: 'bookmark',
        bookIds: ['book_1', 'book_5'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}
