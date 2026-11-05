import 'package:readpack/models/book.dart';

class SearchMatchingEngine {
  static int levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i <= t.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost]
            .reduce((a, b) => a < b ? a : b);
      }
      for (int j = 0; j <= t.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[t.length];
  }

  static String transliterateCyrillic(String input) {
    const map = {
      'а': 'a', 'б': 'b', 'в': 'v', 'г': 'g', 'д': 'd', 'е': 'e', 'ё': 'yo',
      'ж': 'j', 'з': 'z', 'и': 'i', 'й': 'i', 'к': 'k', 'л': 'l', 'м': 'm',
      'н': 'n', 'о': 'o', 'ө': 'u', 'п': 'p', 'р': 'r', 'с': 's', 'т': 't',
      'у': 'u', 'ү': 'u', 'ф': 'f', 'х': 'h', 'ц': 'ts', 'ч': 'ch', 'ш': 'sh',
      'щ': 'sh', 'ъ': '', 'ы': 'y', 'ь': '', 'э': 'e', 'ю': 'yu', 'я': 'ya',
    };
    final sb = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i].toLowerCase();
      sb.write(map[char] ?? char);
    }
    return sb.toString();
  }

  static bool matchesMood(Book book, String mood) {
    if (mood == 'all') return true;
    final cat = book.category.toLowerCase();
    final title = book.title.toLowerCase();
    final tags = book.tags.map((t) => t.toLowerCase()).toList();

    switch (mood) {
      case 'inspiring':
        return cat.contains('business') ||
            tags.contains('productivity') ||
            tags.contains('habits') ||
            tags.contains('success') ||
            title.contains('atomic') ||
            title.contains('thinking');
      case 'philosophical':
        return cat.contains('fiction') ||
            cat.contains('general') ||
            tags.contains('philosophy') ||
            tags.contains('dystopian') ||
            title.contains('1984') ||
            title.contains('sapiens');
      case 'light_reading':
        return book.pages <= 250 || book.readTimeMinutes <= 150;
      case 'deep_focus':
        return book.pages > 250 || book.readTimeMinutes > 150;
      default:
        return true;
    }
  }

  static String? computeSearchSuggestion(List<Book> books, String query) {
    if (query.trim().length < 3) return null;
    final q = query.toLowerCase().trim();
    final qTrans = transliterateCyrillic(q);
    final isCyrillic = RegExp(r'[а-яА-ЯёЁөӨүҮ]').hasMatch(q);

    final hasDirectMatch = books.any((b) =>
        b.title.toLowerCase().contains(q) ||
        b.author.toLowerCase().contains(q) ||
        (qTrans != q &&
            (b.title.toLowerCase().contains(qTrans) ||
                b.author.toLowerCase().contains(qTrans))));
    if (hasDirectMatch) return null;

    for (final b in books) {
      final title = b.title.toLowerCase();
      final titleWords = title
          .split(' ')
          .map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9а-яА-ЯёЁөӨүҮ]'), ''))
          .where((w) => w.isNotEmpty)
          .toList();

      final titleDistLimit = q.length <= 4 ? 1 : (q.length <= 6 ? 2 : 3);
      if (levenshtein(q, title) <= titleDistLimit ||
          levenshtein(qTrans, title) <= titleDistLimit) {
        if (isCyrillic &&
            (b.id == 'book_sapiens' || title.contains('sapiens'))) {
          return 'Сапиенс (${b.title})';
        }
        return b.title;
      }
      for (final word in titleWords) {
        if (const {'the', 'and', 'for', 'with', 'from', 'this', 'that'}
            .contains(word)) {
          continue;
        }
        final maxDist = word.length <= 4 ? 1 : 2;
        if (word.length >= 3 &&
            (levenshtein(q, word) <= maxDist ||
                levenshtein(qTrans, word) <= maxDist)) {
          if (isCyrillic && (word == 'sapiens' || b.id == 'book_sapiens')) {
            return 'Сапиенс (${b.title})';
          }
          return b.title;
        }
      }
      final author = b.author.toLowerCase();
      final authorWords = author
          .split(' ')
          .map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9а-яА-ЯёЁөӨүҮ]'), ''))
          .where((w) => w.isNotEmpty)
          .toList();

      if (levenshtein(q, author) <= titleDistLimit ||
          levenshtein(qTrans, author) <= titleDistLimit) {
        return b.author;
      }
      for (final word in authorWords) {
        if (const {'the', 'and', 'for', 'with', 'from', 'this', 'that'}
            .contains(word)) {
          continue;
        }
        final maxDist = word.length <= 4 ? 1 : 2;
        if (word.length >= 3 &&
            (levenshtein(q, word) <= maxDist ||
                levenshtein(qTrans, word) <= maxDist)) {
          return b.author;
        }
      }
    }
    return null;
  }

  static List<Map<String, dynamic>> findChapterMatches(
      List<Book> books, String bookId, String query) {
    if (query.trim().isEmpty) return [];
    final book =
        books.firstWhere((b) => b.id == bookId, orElse: () => books.first);
    final List<Map<String, dynamic>> matches = [];
    final q = query.toLowerCase();

    for (int i = 0; i < book.chapters.length; i++) {
      final ch = book.chapters[i];
      final titleIndex = ch.title.toLowerCase().indexOf(q);
      final contentIndex = ch.content.toLowerCase().indexOf(q);

      if (titleIndex != -1 || contentIndex != -1) {
        String snippet = ch.title;
        if (contentIndex != -1) {
          final start = (contentIndex - 25).clamp(0, ch.content.length);
          final end = (contentIndex + q.length + 45).clamp(0, ch.content.length);
          snippet =
              '...${ch.content.substring(start, end).replaceAll('\n', ' ')}...';
        }
        matches.add({
          'chapterIndex': i,
          'chapterTitle': ch.title,
          'snippet': snippet,
        });
      }
    }
    return matches;
  }

  static List<Book> filterAndSortBooks({
    required List<Book> books,
    required String query,
    required List<String> categories,
    required double minRating,
    required String selectedMood,
    required String sortBy,
  }) {
    final q = query.trim().toLowerCase();
    final qTrans = transliterateCyrillic(q);

    var result = books.where((book) {
      final titleLower = book.title.toLowerCase();
      final authorLower = book.author.toLowerCase();
      final titleWords = titleLower
          .split(' ')
          .map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9а-яА-ЯёЁөӨүҮ]'), ''))
          .where((w) => w.isNotEmpty)
          .toList();
      final authorWords = authorLower
          .split(' ')
          .map((w) => w.replaceAll(RegExp(r'[^a-zA-Z0-9а-яА-ЯёЁөӨүҮ]'), ''))
          .where((w) => w.isNotEmpty)
          .toList();

      final matchesQuery = q.isEmpty ||
          titleLower.contains(q) ||
          authorLower.contains(q) ||
          (qTrans != q &&
              (titleLower.contains(qTrans) || authorLower.contains(qTrans))) ||
          book.tags.any((t) =>
              t.toLowerCase().contains(q) ||
              (qTrans != q && t.toLowerCase().contains(qTrans))) ||
          (q.length >= 3 &&
              (levenshtein(q, titleLower) <= 2 ||
                  levenshtein(qTrans, titleLower) <= 2)) ||
          (q.length >= 3 &&
              titleWords.any((w) =>
                  w.length >= 3 &&
                  (levenshtein(q, w) <= 1 || levenshtein(qTrans, w) <= 1))) ||
          (q.length >= 3 &&
              (levenshtein(q, authorLower) <= 2 ||
                  levenshtein(qTrans, authorLower) <= 2)) ||
          (q.length >= 3 &&
              authorWords.any((w) =>
                  w.length >= 3 &&
                  (levenshtein(q, w) <= 1 || levenshtein(qTrans, w) <= 1))) ||
          book.chapters.any((c) =>
              c.title.toLowerCase().contains(q) ||
              c.content.toLowerCase().contains(q) ||
              (qTrans != q &&
                  (c.title.toLowerCase().contains(qTrans) ||
                      c.content.toLowerCase().contains(qTrans))));

      final matchesCategory =
          categories.isEmpty || categories.contains(book.category);

      final matchesRating = book.rating >= minRating;
      final matchesMoodFilter = matchesMood(book, selectedMood);

      return matchesQuery &&
          matchesCategory &&
          matchesRating &&
          matchesMoodFilter;
    }).toList();

    if (sortBy == 'rating') {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sortBy == 'title') {
      result.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortBy == 'newest') {
      result.sort((a, b) => b.pages.compareTo(a.pages));
    } else {
      result.sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount));
    }

    return result;
  }
}
