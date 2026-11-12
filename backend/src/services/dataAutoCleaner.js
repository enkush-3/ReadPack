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
  if (typeof rawUrl !== 'string' || !rawUrl.trim()) return null;
  const url = rawUrl.trim();
  if (url.startsWith('assets/')) return url;
  return normalizeHttpUrl(url)?.replace('&edge=curl', '') || null;
}

function normalizeHttpUrl(rawUrl) {
  if (typeof rawUrl !== 'string' || !rawUrl.trim()) return null;
  try {
    const url = new URL(rawUrl.trim());
    if (url.protocol !== 'http:' && url.protocol !== 'https:') return null;
    if (url.protocol === 'http:') url.protocol = 'https:';
    return url.toString();
  } catch (error) {
    if (error instanceof TypeError) return null;
    throw error;
  }
}

function readNonNegativeNumber(rawNumber) {
  if (rawNumber === null || rawNumber === undefined) return 0;
  if (typeof rawNumber !== 'number' && typeof rawNumber !== 'string') return 0;
  if (typeof rawNumber === 'string' && !rawNumber.trim()) return 0;
  const number = Number(rawNumber);
  return Number.isFinite(number) && number >= 0 ? number : 0;
}

function readNonNegativeInteger(rawNumber) {
  return Math.floor(readNonNegativeNumber(rawNumber));
}

function readRating(rawRating) {
  if (typeof rawRating !== 'number' && typeof rawRating !== 'string') return 0;
  const rating = Number(rawRating);
  return Number.isFinite(rating) && rating >= 0 && rating <= 5 ? rating : 0;
}

function readExternalAuthor(raw) {
  let rawAuthor = raw.author;
  if (!rawAuthor && Array.isArray(raw.authors) && raw.authors.length > 0) {
    const firstAuthor = raw.authors[0];
    rawAuthor = typeof firstAuthor === 'string' ? firstAuthor : firstAuthor?.name;
  }
  return canonicalizeAuthor(rawAuthor || 'Unknown Author');
}

function readExternalIds(raw, normalizedTitle) {
  const externalId = String(
    raw.externalId ?? raw.id ?? normalizedTitle.replace(/\s+/g, '_')
  );
  const id = String(
    raw.id ??
      (externalId.startsWith('api_') || externalId.startsWith('ext_')
        ? externalId
        : `api_${externalId}`)
  );
  return { id, externalId };
}

function readExternalIdentity(raw, source) {
  const title = stripHtmlAndCollapseWhitespace(raw.title);
  if (!title) return null;
  const author = readExternalAuthor(raw);
  const normalizedTitle = normalizeKey(title);
  const normalizedAuthor = normalizeKey(author);
  const { id, externalId } = readExternalIds(raw, normalizedTitle);
  return {
    id,
    externalSource: raw.externalSource || source,
    externalId,
    isbn13: raw.isbn13
      ? String(raw.isbn13).replace(/[^0-9X]/gi, '')
      : undefined,
    title,
    normalizedTitle,
    author,
    normalizedAuthor,
  };
}

function readExternalMetadata(raw) {
  const subjects = raw.subjects ?? raw.categories ?? raw.tags ?? [];
  const colorHex = Number(raw.colorHex ?? 0xFF2C3E50);

  return {
    description: readDescription(raw.description),
    rating: readRating(raw.rating),
    reviewsCount: readNonNegativeInteger(raw.reviewsCount),
    category: mapSubjectsToCategory(subjects, raw.category),
    ...readExternalPageMetadata(raw),
    image: upgradeCoverUrl(
      raw.image ??
        raw.coverUrl ??
        raw.formats?.['image/jpeg'] ??
        raw.imageLinks?.thumbnail
    ),
    colorHex: Number.isFinite(colorHex) ? colorHex : 0xFF2C3E50,
    tags: cleanTextList(raw.tags ?? subjects),
  };
}

function readExternalPageMetadata(raw) {
  const pages = readNonNegativeInteger(raw.pages ?? raw.pageCount);
  const hasReadTime = raw.readTimeMinutes !== undefined && raw.readTimeMinutes !== null;
  return {
    pages,
    readTimeMinutes: hasReadTime
      ? readNonNegativeInteger(raw.readTimeMinutes)
      : pages > 0
        ? Math.round(pages * 1.1)
        : 0,
  };
}

function readDescription(rawDescription) {
  if (typeof rawDescription === 'object' && rawDescription !== null) {
    return stripHtmlAndCollapseWhitespace(rawDescription.value);
  }
  return stripHtmlAndCollapseWhitespace(rawDescription);
}

function cleanTextList(rawValues) {
  if (!Array.isArray(rawValues)) return [];
  return rawValues
    .map(stripHtmlAndCollapseWhitespace)
    .filter(Boolean);
}

function cleanExternalChapters(rawChapters, bookId) {
  if (!Array.isArray(rawChapters)) return [];
  return rawChapters.flatMap((rawChapter, index) => {
    if (!rawChapter || typeof rawChapter !== 'object' || Array.isArray(rawChapter)) {
      return [];
    }
    const content = stripHtmlAndCollapseWhitespace(rawChapter.content);
    const title = stripHtmlAndCollapseWhitespace(rawChapter.title);
    if (!title || !content) return [];
    return [{
      id: String(rawChapter.id ?? `${bookId}_c${index + 1}`),
      title,
      estimatedMinutes: readNonNegativeInteger(rawChapter.estimatedMinutes),
      content,
    }];
  });
}

function cleanExternalReviews(rawReviews) {
  if (!Array.isArray(rawReviews)) return [];
  return rawReviews.map(cleanExternalReview).filter(Boolean);
}

function cleanExternalReview(review) {
  if (!review || typeof review !== 'object' || Array.isArray(review)) return null;
  const id = stripHtmlAndCollapseWhitespace(review.id);
  const userName = stripHtmlAndCollapseWhitespace(review.userName);
  const comment = stripHtmlAndCollapseWhitespace(review.comment);
  const createdAt = typeof review.createdAt === 'string' ? review.createdAt : '';
  if (!id || !userName || !comment || !Number.isFinite(Date.parse(createdAt))) {
    return null;
  }
  return {
    id,
    userName,
    rating: readRating(review.rating),
    comment,
    createdAt,
    helpfulCount: readNonNegativeInteger(review.helpfulCount),
  };
}

function readAudioUrl(raw) {
  const formats = raw.formats && typeof raw.formats === 'object' ? raw.formats : {};
  const candidates = [
    raw.audioUrl,
    formats['audio/mpeg'],
    formats['audio/mp4'],
    formats['audio/ogg'],
  ];
  for (const candidate of candidates) {
    const audioUrl = normalizeHttpUrl(candidate);
    if (audioUrl) return audioUrl;
  }
  return null;
}

function readExternalAudio(raw) {
  const audioUrl = readAudioUrl(raw);
  return {
    audioUrl,
    hasAudio: audioUrl !== null,
    audioDurationMinutes: readNonNegativeInteger(raw.audioDurationMinutes),
  };
}

function cleanExternalContent(raw, bookId) {
  return {
    keyTakeaways: cleanTextList(raw.keyTakeaways),
    chapters: cleanExternalChapters(raw.chapters, bookId),
    reviews: cleanExternalReviews(raw.reviews),
  };
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
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return null;
  const identity = readExternalIdentity(raw, source);
  if (!identity) return null;
  return {
    ...identity,
    ...readExternalMetadata(raw),
    ...readExternalAudio(raw),
    ...cleanExternalContent(raw, identity.id),
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
  readAudioUrl,
};
