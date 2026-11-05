'use strict';

/**
 * Automated Data Quality & Transformation Pipeline (`/data-autocleaning`)
 * for external book records (Google Books API, Open Library API, Gutendex API, and client sync).
 */

function stripHtmlAndCollapseWhitespace(raw) {
  if (!raw || typeof raw !== 'string') return '';
  return raw
    .replace(/<[^>]*>/g, ' ')
    .replace(/&nbsp;/gi, ' ')
    .replace(/&amp;/gi, '&')
    .replace(/&quot;/gi, '"')
    .replace(/&#39;/gi, "'")
    .replace(/\s+/g, ' ')
    .trim();
}

function normalizeKey(raw) {
  if (!raw || typeof raw !== 'string') return '';
  return stripHtmlAndCollapseWhitespace(raw)
    .toLowerCase()
    .replace(/[^\p{L}\p{N}\s]/gu, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function canonicalizeAuthor(rawAuthor) {
  const cleaned = stripHtmlAndCollapseWhitespace(rawAuthor || 'Unknown Author')
    .replace(/\(\d{3,4}\s*-\s*\d{0,4}\)/g, '')
    .trim();
  if (!cleaned) return 'Unknown Author';

  // Convert "Lastname, Firstname" -> "Firstname Lastname"
  if (cleaned.includes(',')) {
    const parts = cleaned.split(',').map((p) => p.trim()).filter(Boolean);
    if (parts.length === 2) {
      return `${parts[1]} ${parts[0]}`.replace(/\s+/g, ' ').trim();
    }
  }
  return cleaned;
}

function upgradeCoverUrl(rawUrl) {
  if (!rawUrl || typeof rawUrl !== 'string' || !rawUrl.trim()) {
    return 'assets/public/books/atomic_habits.png';
  }
  let url = rawUrl.trim();
  if (url.startsWith('http://')) {
    url = 'https://' + url.slice('http://'.length);
  }
  // Remove Google Books edge curl artifact
  url = url.replace('&edge=curl', '');
  return url;
}

function mapSubjectsToCategory(subjects = [], fallbackCategory = 'book.categories.all') {
  if (
    typeof fallbackCategory === 'string' &&
    fallbackCategory.startsWith('book.categories.') &&
    fallbackCategory !== 'book.categories.all'
  ) {
    return fallbackCategory;
  }
  const lower = (Array.isArray(subjects) ? subjects : [subjects])
    .map((s) => String(s || '').toLowerCase())
    .join(' ');
  if (/science|physics|nature|biology|psychology|thinking/.test(lower)) {
    return 'book.categories.science';
  }
  if (/history|war|biography|revolution|civilization|sapiens/.test(lower)) {
    return 'book.categories.history';
  }
  if (/business|economy|finance|money|habit|management|leadership/.test(lower)) {
    return 'book.categories.business';
  }
  if (/love|romance|marriage|courtship|fiction/.test(lower)) {
    return 'book.categories.romance';
  }
  if (/adventure|voyage|travel|journey|sea/.test(lower)) {
    return 'book.categories.adventure';
  }
  return fallbackCategory || 'book.categories.all';
}

function cleanExternalBook(raw, source = 'external_api') {
  if (!raw || typeof raw !== 'object') return null;

  const rawTitle = stripHtmlAndCollapseWhitespace(raw.title || 'Untitled');
  if (!rawTitle) return null;

  let rawAuthor = raw.author;
  if (!rawAuthor && Array.isArray(raw.authors) && raw.authors.length > 0) {
    const first = raw.authors[0];
    rawAuthor = typeof first === 'string' ? first : first?.name;
  }
  const author = canonicalizeAuthor(rawAuthor || 'Unknown Author');
  const normalizedTitle = normalizeKey(rawTitle);
  const normalizedAuthor = normalizeKey(author);

  const externalId = String(
    raw.externalId || raw.id || `${normalizedTitle.replace(/\s+/g, '_')}`
  );
  const id = String(
    raw.id ||
      (externalId.startsWith('api_') || externalId.startsWith('ext_')
        ? externalId
        : `api_${externalId}`)
  );

  const isbn13 = raw.isbn13
    ? String(raw.isbn13).replace(/[^0-9X]/gi, '')
    : undefined;

  const rawCover =
    raw.image ||
    raw.coverUrl ||
    raw.formats?.['image/jpeg'] ||
    raw.imageLinks?.thumbnail;
  const image = upgradeCoverUrl(rawCover);

  const subjects = raw.subjects || raw.categories || raw.tags || [];
  const category = mapSubjectsToCategory(subjects, raw.category);

  const pages = Math.max(40, Number(raw.pages || raw.pageCount || 220));
  const readTimeMinutes = Math.max(
    20,
    Number(raw.readTimeMinutes || Math.round(pages * 1.1))
  );
  const rating = Number(
    Math.min(5.0, Math.max(3.5, Number(raw.rating || 4.6))).toFixed(1)
  );
  const reviewsCount = Math.max(1, Number(raw.reviewsCount || raw.download_count || 120));

  const description =
    stripHtmlAndCollapseWhitespace(raw.description) ||
    `${author}-ийн "${rawTitle}" бүтээл. ReadPack төвлөрсөн номын санд автоматаар цэвэрлэгдэж бүртгэгдсэн дижитал хувилбар.`;

  const chapters =
    Array.isArray(raw.chapters) && raw.chapters.length > 0
      ? raw.chapters.map((c, idx) => ({
          id: String(c.id || `${id}_c${idx + 1}`),
          title: stripHtmlAndCollapseWhitespace(c.title || `Бүлэг ${idx + 1}`),
          estimatedMinutes: Math.max(5, Number(c.estimatedMinutes || 12)),
          content: stripHtmlAndCollapseWhitespace(
            c.content || `${rawTitle} — ${author}.`
          ),
        }))
      : [
          {
            id: `${id}_c1`,
            title: 'Part 1: The Beginning',
            estimatedMinutes: 12,
            content: `A remarkable work by ${author} exploring the depths of human nature, philosophy, and discovery.\n\n"The foundation of knowledge begins with an open mind and relentless curiosity."\n\nThis volume, titled ${rawTitle}, has been curated and cleaned for ReadPack readers.`,
          },
          {
            id: `${id}_c2`,
            title: 'Part 2: Deeper Horizons',
            estimatedMinutes: 15,
            content: `Continuing through ${rawTitle} by ${author}.\n\nEvery turning page reveals new insights into human character and timeless wisdom preserved in the ReadPack central catalog.`,
          },
        ];

  const keyTakeaways =
    Array.isArray(raw.keyTakeaways) && raw.keyTakeaways.length > 0
      ? raw.keyTakeaways.map((k) => stripHtmlAndCollapseWhitespace(k))
      : [
          `${rawTitle} номын гол үзэл санаа ба практик хэрэглээ.`,
          `${author}-ийн дэвшүүлсэн суурь зарчмууд.`,
        ];

  return {
    id,
    externalSource: raw.externalSource || source,
    externalId,
    isbn13,
    title: rawTitle,
    normalizedTitle,
    author,
    normalizedAuthor,
    description,
    rating,
    reviewsCount,
    category,
    pages,
    readTimeMinutes,
    image,
    colorHex: Number(raw.colorHex || 0xFF2C3E50),
    progress: Number(raw.progress || 0.0),
    currentPage: Number(raw.currentPage || 0),
    currentChapterIndex: Number(raw.currentChapterIndex || 0),
    isSaved: Boolean(raw.isSaved || false),
    isFavorite: Boolean(raw.isFavorite || false),
    hasAudio: raw.hasAudio !== undefined ? Boolean(raw.hasAudio) : true,
    audioDurationMinutes: Number(raw.audioDurationMinutes || readTimeMinutes),
    keyTakeaways,
    tags: Array.isArray(raw.tags) && raw.tags.length > 0
      ? raw.tags
      : ['Curated', category.replace('book.categories.', '')],
    chapters,
    reviews: Array.isArray(raw.reviews) ? raw.reviews : [],
  };
}

function deduplicateBooks(books) {
  const seenIds = new Set();
  const seenIsbns = new Set();
  const seenTitleAuthors = new Set();
  const unique = [];

  for (const b of books) {
    if (!b) continue;
    const taKey = `${b.normalizedTitle}::${b.normalizedAuthor}`;
    if (seenIds.has(b.id) || seenTitleAuthors.has(taKey)) continue;
    if (b.isbn13 && seenIsbns.has(b.isbn13)) continue;

    seenIds.add(b.id);
    seenTitleAuthors.add(taKey);
    if (b.isbn13) seenIsbns.add(b.isbn13);
    unique.push(b);
  }
  return unique;
}

module.exports = {
  stripHtmlAndCollapseWhitespace,
  normalizeKey,
  canonicalizeAuthor,
  upgradeCoverUrl,
  mapSubjectsToCategory,
  cleanExternalBook,
  deduplicateBooks,
};
