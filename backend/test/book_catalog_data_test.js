'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { BookCatalogService } = require('../src/services/bookCatalogService');
const { MongoStore } = require('../src/services/mongoStore');
const { cleanExternalBook } = require('../src/services/dataAutoCleaner');
const { registerMongooseCentralBookModel } = require('../src/models/CentralBook');

const emptyStore = { getAllBooks: async () => [] };
const FORGED_LEGACY_BOOK = {
  id: 'api_forged_seed',
  externalSource: 'central_seed',
  title: 'Forged Seed Book',
  author: 'A. Author',
  description:
    'A. Author-ийн "Forged Seed Book" бүтээл. ReadPack төвлөрсөн номын санд автоматаар цэвэрлэгдэж бүртгэгдсэн дижитал хувилбар.',
  rating: 4.6,
  reviewsCount: 85,
  pages: 210,
  readTimeMinutes: 231,
  image: 'assets/public/books/atomic_habits.png',
  tags: ['Curated', 'business'],
  keyTakeaways: ['Forged Seed Book номын гол үзэл санаа ба практик хэрэглээ.'],
  chapters: [
    {
      id: 'api_forged_seed_c1',
      title: 'Part 1: The Beginning',
      content: 'Generated chapter prose.',
    },
  ],
};

function captureBookUpserts(store) {
  const upsertedBooks = [];
  const originalUpsertBook = store.upsertBook.bind(store);
  store.upsertBook = async (bookDoc) => {
    upsertedBooks.push(structuredClone(bookDoc));
    return originalUpsertBook(bookDoc);
  };
  return upsertedBooks;
}

function assertLegacyGeneratedContentRemoved(book) {
  assert.equal(book.externalSource, 'user_sync');
  assert.equal(book.rating, 0);
  assert.equal(book.reviewsCount, 0);
  assert.equal(book.pages, 0);
  assert.equal(book.readTimeMinutes, 0);
  assert.equal(book.image, null);
  assert.equal(book.description, '');
  assert.deepEqual(book.chapters, []);
  assert.deepEqual(book.keyTakeaways, []);
  assert.deepEqual(book.tags, []);
}

async function withMockFetch(mockFetch, run) {
  const originalFetch = global.fetch;
  global.fetch = mockFetch;
  try {
    await run();
  } finally {
    global.fetch = originalFetch;
  }
}

function assertUnknownCatalogFields(book, expectedTags = []) {
  assert.equal(book.rating, 0);
  assert.equal(book.reviewsCount, 0);
  assert.equal(book.pages, 0);
  assert.equal(book.readTimeMinutes, 0);
  assert.equal(book.image, null);
  assert.equal(book.audioUrl, null);
  assert.equal(book.description, '');
  assert.equal(book.chapters.length, 0);
  assert.equal(book.reviews.length, 0);
  assert.equal(book.keyTakeaways.length, 0);
  assert.equal(book.hasAudio, false);
  assert.equal(book.audioDurationMinutes, 0);
  assert.deepEqual(book.tags, expectedTags);
}

test('sparse Google Books records do not acquire invented catalog content', async () => {
  const service = new BookCatalogService({ store: emptyStore });
  const mockFetch = async () => ({
    ok: true,
    json: async () => ({
      items: [
        {
          id: 'sparse-google-book',
          volumeInfo: {
            title: 'Sparse Google Book',
            authors: ['A. Author'],
          },
        },
      ],
    }),
  });

  await withMockFetch(mockFetch, async () => {
    const result = await service.searchBooks('Sparse Google Book');

    assert.equal(result.source, 'external_api');
    assert.equal(result.results.length, 1);
    assertUnknownCatalogFields(result.results[0]);
  });
});

test('sparse Gutendex records do not turn downloads into reviews or audio', async () => {
  const service = new BookCatalogService({ store: emptyStore });
  const mockFetch = async (url) => {
    if (url.includes('googleapis.com')) {
      return { ok: true, json: async () => ({ items: [] }) };
    }
    return {
      ok: true,
      json: async () => ({
        results: [
          {
            id: 1342,
            title: 'Sparse Gutendex Book',
            authors: [{ name: 'Austen, Jane' }],
            subjects: ['Love stories'],
            download_count: 54200,
            formats: {},
          },
        ],
      }),
    };
  };

  await withMockFetch(mockFetch, async () => {
    const result = await service.searchBooks('Sparse Gutendex Book');

    assert.equal(result.source, 'external_api');
    assert.equal(result.results.length, 1);
    assertUnknownCatalogFields(result.results[0], ['Love stories']);
    assert.equal(result.results[0].category, 'book.categories.romance');
    assert.deepEqual(result.results[0].tags, ['Love stories']);
  });
});

test('real page counts and audio URLs remain source-backed', () => {
  const book = cleanExternalBook(
    {
      id: 'gbooks_real_metadata',
      title: 'Book With Supplied Metadata',
      author: 'A. Author',
      description: 'Source description',
      pageCount: 100,
      rating: 4.3,
      reviewsCount: 8,
      formats: {
        'audio/mpeg': 'https://www.gutenberg.org/audio/book.mp3',
      },
      chapters: [
        {
          id: 'source-chapter-1',
          title: 'Source chapter',
          estimatedMinutes: 7,
          content: 'Verified source text',
        },
        { id: 'untitled-source-chapter', content: 'Unlabeled text' },
      ],
      keyTakeaways: ['Provided source takeaway'],
      reviews: [
        {
          id: 'source-review-1',
          userName: 'Catalog Reader',
          rating: 4.1,
          comment: 'Provided source review',
          createdAt: '2026-11-12T00:00:00.000Z',
        },
      ],
    },
    'google_books',
  );

  assert.equal(book.pages, 100);
  assert.equal(book.readTimeMinutes, 110);
  assert.equal(book.rating, 4.3);
  assert.equal(book.reviewsCount, 8);
  assert.equal(book.description, 'Source description');
  assert.equal(book.audioUrl, 'https://www.gutenberg.org/audio/book.mp3');
  assert.equal(book.hasAudio, true);
  assert.equal(book.audioDurationMinutes, 0);
  assert.equal(book.chapters.length, 1);
  assert.equal(book.chapters[0].content, 'Verified source text');
  assert.deepEqual(book.keyTakeaways, ['Provided source takeaway']);
  assert.equal(book.reviews[0].comment, 'Provided source review');
});

test('Google fields are mapped without fallback ratings or counts', async () => {
  const service = new BookCatalogService({ store: emptyStore });
  const mockFetch = async () => ({
    ok: true,
    json: async () => ({
      items: [
        {
          id: 'google-metadata-book',
          volumeInfo: {
            title: 'Google Metadata Book',
            authors: ['A. Author'],
            pageCount: 100,
            averageRating: 4.3,
            ratingsCount: 8,
            description: 'Source description',
          },
        },
      ],
    }),
  });

  await withMockFetch(mockFetch, async () => {
    const result = await service.searchBooks('Google Metadata Book');
    const [book] = result.results;

    assert.equal(book.rating, 4.3);
    assert.equal(book.reviewsCount, 8);
    assert.equal(book.pages, 100);
    assert.equal(book.readTimeMinutes, 110);
    assert.equal(book.description, 'Source description');
  });
});

test('unknown metadata survives Mongoose and fallback catalog storage', async () => {
  const book = cleanExternalBook(
    { id: 'api_storage_sparse', title: 'Storage Sparse Book', author: 'A. Author' },
    'gutendex',
  );
  const mongoose = require('mongoose');
  const CentralBook = registerMongooseCentralBookModel(mongoose);

  try {
    const mongooseBook = new CentralBook(book).toObject();
    assertUnknownCatalogFields(mongooseBook);

    const tempDirectory = fs.mkdtempSync(path.join(os.tmpdir(), 'readpack-book-store-test-'));
    try {
      const store = new MongoStore({
        storageFilePath: path.join(tempDirectory, 'store.json'),
      });
      await store.init({ forceFallback: true });
      await store.upsertBook(book);
      const savedBook = (await store.getAllBooks()).find(
        (entry) => entry.id === book.id,
      );
      assertUnknownCatalogFields(savedBook);
    } finally {
      fs.rmSync(tempDirectory, { recursive: true, force: true });
    }
  } finally {
    mongoose.deleteModel('CentralBook');
  }
});

test('catalog sync never exposes user reading state to global search', async () => {
  const tempDirectory = fs.mkdtempSync(path.join(os.tmpdir(), 'readpack-catalog-test-'));
  const store = new MongoStore({
    storageFilePath: path.join(tempDirectory, 'store.json'),
  });
  await store.init({ forceFallback: true });
  const service = new BookCatalogService({ store, externalFetcher: async () => [] });

  try {
    await service.syncBookToCentralCatalog({
      id: 'synced-private-state-book',
      title: 'Synced Private State Book',
      author: 'Catalog Author',
      progress: 0.75,
      currentPage: 180,
      currentChapterIndex: 4,
      isSaved: true,
      isFavorite: true,
    });

    const result = await service.searchBooks('Synced Private State Book');
    const [book] = result.results;
    assert.equal(result.source, 'central_db');
    for (const field of [
      'progress',
      'currentPage',
      'currentChapterIndex',
      'isSaved',
      'isFavorite',
    ]) {
      assert.equal(Object.hasOwn(book, field), false);
    }
  } finally {
    fs.rmSync(tempDirectory, { recursive: true, force: true });
  }
});

test('sparse user sync preserves richer shared catalog fields', async () => {
  const tempDirectory = fs.mkdtempSync(path.join(os.tmpdir(), 'readpack-catalog-test-'));
  const store = new MongoStore({
    storageFilePath: path.join(tempDirectory, 'store.json'),
  });
  await store.init({ forceFallback: true });
  const service = new BookCatalogService({ store, externalFetcher: async () => [] });

  try {
    await store.upsertBook({
      id: 'sparse-sync-book',
      externalId: 'source-rich-book',
      externalSource: 'google_books',
      title: 'Sparse Sync Book',
      author: 'Catalog Author',
      normalizedTitle: 'sparse sync book',
      normalizedAuthor: 'catalog author',
      description: 'Source-backed description.',
      pages: 240,
      rating: 4.5,
      reviewsCount: 31,
      category: 'book.categories.business',
      colorHex: 0xff314159,
      image: 'https://example.test/cover.jpg',
      chapters: [{ id: 'chapter-1', title: 'Chapter One', content: 'Text.' }],
      reviews: [{ id: 'review-1', comment: 'Verified review.' }],
      keyTakeaways: ['Verified takeaway.'],
    });

    const savedBook = await service.syncBookToCentralCatalog({
      id: 'sparse-sync-book',
      title: 'Sparse Sync Book',
      author: 'Catalog Author',
    });

    assert.equal(savedBook.description, 'Source-backed description.');
    assert.equal(savedBook.pages, 240);
    assert.equal(savedBook.rating, 4.5);
    assert.equal(savedBook.reviewsCount, 31);
    assert.equal(savedBook.category, 'book.categories.business');
    assert.equal(savedBook.colorHex, 0xff314159);
    assert.equal(savedBook.image, 'https://example.test/cover.jpg');
    assert.equal(savedBook.chapters.length, 1);
    assert.equal(savedBook.reviews.length, 1);
    assert.deepEqual(savedBook.keyTakeaways, ['Verified takeaway.']);
  } finally {
    fs.rmSync(tempDirectory, { recursive: true, force: true });
  }
});

test('catalog sync ignores a forged seed source and sanitizes legacy generated content', async () => {
  const tempDirectory = fs.mkdtempSync(path.join(os.tmpdir(), 'readpack-catalog-test-'));
  const store = new MongoStore({
    storageFilePath: path.join(tempDirectory, 'store.json'),
  });
  await store.init({ forceFallback: true });
  const upsertedBooks = captureBookUpserts(store);
  const service = new BookCatalogService({ store, externalFetcher: async () => [] });

  try {
    await service.syncBookToCentralCatalog(FORGED_LEGACY_BOOK);
    assert.equal(upsertedBooks.length, 1);
    const [bookAtUpsert] = upsertedBooks;
    assertLegacyGeneratedContentRemoved(bookAtUpsert);
    const result = await service.searchBooks('Forged Seed Book');
    assertLegacyGeneratedContentRemoved(result.results[0]);
  } finally {
    fs.rmSync(tempDirectory, { recursive: true, force: true });
  }
});

test('catalog responses sanitize legacy remote data without mutating seeds or storage', async () => {
  const legacyBook = {
    id: 'api_legacy_external',
    externalSource: 'gutendex',
    externalId: 'gutendex_1342',
    title: 'Legacy External Book',
    normalizedTitle: 'legacy external book',
    author: 'Jane Austen',
    normalizedAuthor: 'jane austen',
    description:
      'Jane Austen-ийн "Legacy External Book" бүтээл. ReadPack төвлөрсөн номын санд автоматаар цэвэрлэгдэж бүртгэгдсэн дижитал хувилбар.',
    rating: 4.6,
    reviewsCount: 120,
    pages: 220,
    readTimeMinutes: 242,
    image: 'assets/public/books/atomic_habits.png',
    category: 'book.categories.business',
    hasAudio: true,
    audioDurationMinutes: 242,
    keyTakeaways: [
      'Legacy External Book номын гол үзэл санаа ба практик хэрэглээ.',
      'Jane Austen-ийн дэвшүүлсэн суурь зарчмууд.',
      'Verified takeaway',
    ],
    tags: ['Curated', 'business'],
    chapters: [
      {
        id: 'api_legacy_external_c1',
        title: 'Part 1: The Beginning',
        content: 'A remarkable work by Jane Austen generated by ReadPack.',
      },
      {
        id: 'source-chapter-1',
        title: 'Source chapter',
        content: 'Verified source text',
      },
    ],
    reviews: [
      {
        id: 'source-review-1',
        userName: 'Catalog Reader',
        rating: 4.2,
        comment: 'Verified source review',
        createdAt: '2026-11-12T00:00:00.000Z',
      },
    ],
  };
  const curatedSeed = {
    id: '1',
    externalSource: 'central_seed',
    title: 'Atomic Habits',
    normalizedTitle: 'atomic habits',
    author: 'James Clear',
    normalizedAuthor: 'james clear',
    rating: 4.9,
    reviewsCount: 3420,
    pages: 320,
    readTimeMinutes: 280,
    image: 'assets/public/books/atomic_habits.png',
    hasAudio: true,
    chapters: [{ id: '1_c1', title: 'Curated chapter', content: 'Curated text' }],
    progress: 0.5,
    currentPage: 40,
    currentChapterIndex: 1,
    isSaved: true,
    isFavorite: true,
  };
  const store = { getAllBooks: async () => [legacyBook, curatedSeed] };
  const service = new BookCatalogService({ store });

  const result = await service.searchBooks();
  const normalizedLegacy = result.results.find((book) => book.id === legacyBook.id);
  const normalizedSeed = result.results.find((book) => book.id === curatedSeed.id);

  assert.equal(normalizedLegacy.rating, 0);
  assert.equal(normalizedLegacy.reviewsCount, 0);
  assert.equal(normalizedLegacy.pages, 0);
  assert.equal(normalizedLegacy.readTimeMinutes, 0);
  assert.equal(normalizedLegacy.description, '');
  assert.equal(normalizedLegacy.image, null);
  assert.equal(normalizedLegacy.hasAudio, false);
  assert.equal(normalizedLegacy.audioDurationMinutes, 0);
  assert.deepEqual(normalizedLegacy.chapters.map((chapter) => chapter.id), [
    'source-chapter-1',
  ]);
  assert.deepEqual(normalizedLegacy.keyTakeaways, ['Verified takeaway']);
  assert.deepEqual(normalizedLegacy.tags, []);
  assert.equal(normalizedLegacy.reviews[0].id, 'source-review-1');

  assert.equal(normalizedSeed.rating, 4.9);
  assert.equal(normalizedSeed.pages, 320);
  assert.equal(normalizedSeed.hasAudio, true);
  assert.equal(normalizedSeed.chapters[0].content, 'Curated text');
  for (const book of result.results) {
    for (const field of [
      'progress',
      'currentPage',
      'currentChapterIndex',
      'isSaved',
      'isFavorite',
    ]) {
      assert.equal(Object.hasOwn(book, field), false);
    }
  }
  assert.equal(legacyBook.rating, 4.6);
  assert.equal(legacyBook.chapters[0].id, 'api_legacy_external_c1');
  assert.equal(curatedSeed.progress, 0.5);
});
