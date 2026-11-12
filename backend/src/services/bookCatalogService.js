'use strict';

const {
  normalizeKey,
  cleanExternalBook,
  deduplicateBooks,
  readAudioUrl,
  upgradeCoverUrl,
} = require('./dataAutoCleaner');

const PRIVATE_BOOK_FIELDS = [
  'progress',
  'currentPage',
  'currentChapterIndex',
  'isSaved',
  'isFavorite',
];
const LEGACY_FALLBACK_COVER = 'assets/public/books/atomic_habits.png';

/**
 * Central Books Catalog & Smart Read-Through Caching Service.
 *
 * Flow:
 * 1. `searchBooks(query)`:
 *    - Searches the central `books` collection first.
 *    - If matches are found -> returns immediately with `{ source: 'central_db', results }`.
 *    - If not found in central DB (Cache Miss) -> queries external API (Google Books / Gutendex / custom fetcher),
 *      runs `/data-autocleaning` (`cleanExternalBook` + `deduplicateBooks`), and returns `{ source: 'external_api', results }`.
 * 2. `syncBookToCentralCatalog(rawBook)`:
 *    - When a user selects a book to read, saves it, or adds it to a challenge, cleans and upserts the book
 *      into the central `books` database so future searches by any user hit `central_db` directly.
 */
class BookCatalogService {
  constructor({ store, externalFetcher } = {}) {
    this.store = store;
    this.externalFetcher = externalFetcher || this._defaultExternalFetcher.bind(this);
  }

  async searchBooks(rawQuery = '') {
    const query = String(rawQuery || '').trim();
    const storedBooks = await this.store.getAllBooks();
    const allCentralBooks = storedBooks.map(normalizeCatalogResponseBook);

    if (!query) {
      return {
        source: 'central_db',
        count: allCentralBooks.length,
        results: allCentralBooks,
      };
    }

    const normQuery = normalizeKey(query);
    const localMatches = allCentralBooks.filter((b) => {
      const titleMatch =
        (b.normalizedTitle && b.normalizedTitle.includes(normQuery)) ||
        String(b.title || '').toLowerCase().includes(query.toLowerCase());
      const authorMatch =
        (b.normalizedAuthor && b.normalizedAuthor.includes(normQuery)) ||
        String(b.author || '').toLowerCase().includes(query.toLowerCase());
      const tagMatch =
        Array.isArray(b.tags) &&
        b.tags.some((t) => String(t).toLowerCase().includes(query.toLowerCase()));
      const isbnMatch = b.isbn13 && String(b.isbn13).includes(query);
      return titleMatch || authorMatch || tagMatch || isbnMatch;
    });

    if (localMatches.length > 0) {
      return {
        source: 'central_db',
        count: localMatches.length,
        results: localMatches,
      };
    }

    // Cache Miss in Central DB -> Query External API + Run Data Auto-Cleaning
    const rawExternal = await this.externalFetcher(query);
    const cleaned = deduplicateBooks(
      (Array.isArray(rawExternal) ? rawExternal : [])
        .map((item) => cleanExternalBook(item, 'external_api'))
        .filter(Boolean)
    );

    return {
      source: 'external_api',
      count: cleaned.length,
      results: cleaned,
    };
  }

  async syncBookToCentralCatalog(rawBook) {
    const syncPayload = withUserSyncSource(rawBook);
    const cleaned = cleanExternalBook(syncPayload, 'user_sync');
    if (!cleaned) {
      throw new Error('Invalid book payload for central catalog sync');
    }
    const normalized = normalizeCatalogResponseBook(cleaned);
    const saved = await this.store.upsertBook(normalized);
    return saved;
  }

  async _defaultExternalFetcher(query) {
    // 1. Try Google Books API first
    try {
      const googleUrl = `https://www.googleapis.com/books/v1/volumes?q=${encodeURIComponent(
        query
      )}&maxResults=8`;
      const res = await fetch(googleUrl, {
        signal: AbortSignal.timeout(4500),
      });
      if (res.ok) {
        const data = await res.json();
        if (Array.isArray(data.items) && data.items.length > 0) {
          return data.items.map((item) => {
            const info = item.volumeInfo || {};
            const identifiers = Array.isArray(info.industryIdentifiers)
              ? info.industryIdentifiers
              : [];
            const isbn13Obj = identifiers.find((i) => i.type === 'ISBN_13');
            return {
              externalId: `gbooks_${item.id}`,
              externalSource: 'google_books',
              isbn13: isbn13Obj?.identifier,
              title: info.title,
              authors: info.authors || [],
              description: info.description,
              pages: info.pageCount,
              rating: info.averageRating,
              reviewsCount: info.ratingsCount,
              categories: info.categories || [],
              imageLinks: info.imageLinks || {},
            };
          });
        }
      }
    } catch (_) {}

    // 2. Fallback to Gutendex Open Catalog API
    try {
      const gutendexUrl = `https://gutendex.com/books/?search=${encodeURIComponent(
        query
      )}`;
      const res = await fetch(gutendexUrl, {
        signal: AbortSignal.timeout(4500),
      });
      if (res.ok) {
        const data = await res.json();
        if (Array.isArray(data.results)) {
          return data.results.slice(0, 8).map((item) => ({
            ...item,
            externalId: `gutendex_${item.id}`,
            externalSource: 'gutendex',
          }));
        }
      }
    } catch (_) {}

    return [];
  }
}

function withUserSyncSource(rawBook) {
  if (!rawBook || typeof rawBook !== 'object' || Array.isArray(rawBook)) {
    return rawBook;
  }
  return { ...rawBook, externalSource: 'user_sync' };
}

function normalizeCatalogResponseBook(book) {
  if (!book || typeof book !== 'object' || Array.isArray(book)) return book;
  const catalogBook = withoutPrivateBookState(book);
  if (book.externalSource === 'central_seed') return catalogBook;

  const audioUrl = readAudioUrl(book);
  const normalizedBook = {
    ...catalogBook,
    image:
      book.image === LEGACY_FALLBACK_COVER ? null : upgradeCoverUrl(book.image),
    audioUrl,
    hasAudio: audioUrl !== null,
    audioDurationMinutes: audioUrl
      ? readPositiveInteger(book.audioDurationMinutes)
      : 0,
  };
  if (!hasLegacyGeneratedContent(book)) return normalizedBook;
  return removeLegacyGeneratedContent(normalizedBook, book);
}

function withoutPrivateBookState(book) {
  const catalogBook = { ...book };
  for (const field of PRIVATE_BOOK_FIELDS) delete catalogBook[field];
  return catalogBook;
}

function readPositiveInteger(value) {
  const number = Number(value);
  return Number.isFinite(number) && number > 0 ? Math.floor(number) : 0;
}

function hasLegacyGeneratedContent(book) {
  return (
    hasLegacyGeneratedChapter(book) ||
    hasLegacyGeneratedTakeaway(book) ||
    isLegacyGeneratedDescription(book) ||
    isLegacyGeneratedTags(book)
  );
}

function hasLegacyGeneratedChapter(book) {
  const bookId = String(book.id ?? '');
  return Array.isArray(book.chapters) &&
      book.chapters.some((chapter) => isLegacyGeneratedChapter(chapter, bookId));
}

function hasLegacyGeneratedTakeaway(book) {
  if (!Array.isArray(book.keyTakeaways)) return false;
  const generatedTakeaways = legacyGeneratedTakeaways(book);
  return book.keyTakeaways.some((takeaway) => generatedTakeaways.has(takeaway));
}

function legacyGeneratedTakeaways(book) {
  return new Set([
    `${book.title} номын гол үзэл санаа ба практик хэрэглээ.`,
    `${book.author}-ийн дэвшүүлсэн суурь зарчмууд.`,
  ]);
}

function isLegacyGeneratedDescription(book) {
  const description = `${book.author}-ийн "${book.title}" бүтээл. ReadPack төвлөрсөн номын санд автоматаар цэвэрлэгдэж бүртгэгдсэн дижитал хувилбар.`;
  return book.description === description;
}

function isLegacyGeneratedTags(book) {
  const tags = book.tags;
  return (
    Array.isArray(tags) &&
    tags.length === 2 &&
    tags[0] === 'Curated' &&
    tags[1] === String(book.category || 'book.categories.all').replace(
      'book.categories.',
      ''
    )
  );
}

function removeLegacyGeneratedContent(normalizedBook, originalBook) {
  return {
    ...normalizedBook,
    ...unknownLegacyMetrics(),
    ...withoutLegacyGeneratedFields(normalizedBook, originalBook),
  };
}

function unknownLegacyMetrics() {
  return {
    rating: 0,
    reviewsCount: 0,
    pages: 0,
    readTimeMinutes: 0,
    audioDurationMinutes: 0,
  };
}

function withoutLegacyGeneratedFields(normalizedBook, originalBook) {
  return {
    description: isLegacyGeneratedDescription(originalBook)
      ? ''
      : normalizedBook.description,
    tags: isLegacyGeneratedTags(originalBook) ? [] : normalizedBook.tags,
    chapters: sourceChapters(originalBook),
    keyTakeaways: sourceTakeaways(originalBook),
  };
}

function sourceChapters(book) {
  const chapters = Array.isArray(book.chapters) ? book.chapters : [];
  const bookId = String(book.id ?? '');
  return chapters.filter((chapter) => !isLegacyGeneratedChapter(chapter, bookId));
}

function sourceTakeaways(book) {
  const takeaways = Array.isArray(book.keyTakeaways) ? book.keyTakeaways : [];
  const generatedTakeaways = legacyGeneratedTakeaways(book);
  return takeaways.filter((takeaway) => !generatedTakeaways.has(takeaway));
}

function isLegacyGeneratedChapter(chapter, bookId) {
  if (!chapter || typeof chapter !== 'object') return false;
  return (
    (chapter.id === `${bookId}_c1` && chapter.title === 'Part 1: The Beginning') ||
    (chapter.id === `${bookId}_c2` && chapter.title === 'Part 2: Deeper Horizons')
  );
}

module.exports = { BookCatalogService };
