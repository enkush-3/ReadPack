'use strict';

const {
  normalizeKey,
  cleanExternalBook,
  deduplicateBooks,
} = require('./dataAutoCleaner');

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
    const allCentralBooks = await this.store.getAllBooks();

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
    const cleaned = cleanExternalBook(rawBook, rawBook?.externalSource || 'user_sync');
    if (!cleaned) {
      throw new Error('Invalid book payload for central catalog sync');
    }
    const saved = await this.store.upsertBook(cleaned);
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
              authors: info.authors || ['Unknown Author'],
              description: info.description,
              pages: info.pageCount,
              rating: info.averageRating || 4.6,
              reviewsCount: info.ratingsCount || 85,
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

module.exports = { BookCatalogService };
