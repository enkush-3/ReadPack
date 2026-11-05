'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { createReadPackApp } = require('../src/app');

test('ReadPack Express.js + MongoDB UserAccountTree & Smart Read-Through Book Catalog Suite', async (t) => {
  const tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'readpack-backend-test-'));
  const storageFilePath = path.join(tmpDir, 'test_mongodb_store.json');

  // Mock external API returning dirty raw book data to verify /data-autocleaning
  const mockExternalFetcher = async (query) => {
    if (query.toLowerCase().includes('deep work')) {
      return [
        {
          id: 'ext_deep_work_99',
          isbn13: '978-1455586691',
          title: '<b>Deep Work:</b>   Rules for Focused Success  ',
          authors: [{ name: 'Newport, Cal (1982-)' }],
          description: '<p>Rules for <b>focused success</b> in a distracted world.</p>',
          subjects: ['Business & Productivity', 'Focus'],
          imageLinks: {
            thumbnail: 'http://books.google.com/books/content?id=deepwork&zoom=1&edge=curl',
          },
          pageCount: 304,
          rating: 4.85,
        },
      ];
    }
    return [];
  };

  const { createServer } = await createReadPackApp({
    storageFilePath,
    forceFallback: true,
    externalFetcher: mockExternalFetcher,
  });

  const server = createServer();
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const { port } = server.address();
  const baseUrl = `http://127.0.0.1:${port}`;

  t.after(() => {
    server.close();
    fs.rmSync(tmpDir, { recursive: true, force: true });
  });

  await t.test('1. GET /api/v1/health reports express_mongodb_tree status', async () => {
    const res = await fetch(`${baseUrl}/api/v1/health`);
    assert.equal(res.status, 200);
    const body = await res.json();
    assert.equal(body.status, 'ok');
    assert.equal(body.engine, 'express_mongodb_tree');
    assert.ok(body.centralBooksCount >= 3);
  });

  await t.test(
    '2. POST /api/v1/auth/login creates/loads MongoDB Hierarchical UserAccountTree',
    async () => {
      const res = await fetch(`${baseUrl}/api/v1/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: 'bat@readpack.app',
          name: 'Bat-Erdene',
        }),
      });
      assert.equal(res.status, 200);
      const data = await res.json();
      const tree = data.userAccountTree;

      // Verify hierarchical tree structure nodes
      assert.equal(tree.email, 'bat@readpack.app');
      assert.ok(tree.authNode.passwordHash);
      assert.equal(tree.profileNode.displayName, 'Bat-Erdene');
      assert.equal(tree.profileNode.preferencesNode.dailyGoalMinutes, 30);
      assert.ok(Array.isArray(tree.readingTree.shelves));
      assert.equal(tree.readingTree.shelves.length, 4);
      assert.ok(tree.gamificationTree.xpNode.totalXp >= 100);
      assert.ok(tree.gamificationTree.streakNode.currentStreak >= 1);
      assert.equal(tree.gamificationTree.challengeNode.year, 2026);
    }
  );

  await t.test(
    '3. GET /api/v1/books/search returns Central DB hit first (source: central_db)',
    async () => {
      const res = await fetch(
        `${baseUrl}/api/v1/books/search?q=${encodeURIComponent('Atomic Habits')}`
      );
      assert.equal(res.status, 200);
      const data = await res.json();
      assert.equal(data.source, 'central_db');
      assert.equal(data.results[0].title, 'Atomic Habits');
      assert.equal(data.results[0].author, 'James Clear');
    }
  );

  await t.test(
    '4. GET /api/v1/books/search falls back to External API on Cache Miss and runs /data-autocleaning',
    async () => {
      const res = await fetch(
        `${baseUrl}/api/v1/books/search?q=${encodeURIComponent('Deep Work')}`
      );
      assert.equal(res.status, 200);
      const data = await res.json();
      assert.equal(data.source, 'external_api');
      assert.equal(data.results.length, 1);

      const cleanedBook = data.results[0];
      // HTML stripped and whitespace collapsed
      assert.equal(cleanedBook.title, 'Deep Work: Rules for Focused Success');
      // "Newport, Cal (1982-)" canonicalized to "Cal Newport"
      assert.equal(cleanedBook.author, 'Cal Newport');
      // http:// upgraded to https:// and &edge=curl stripped
      assert.ok(cleanedBook.image.startsWith('https://'));
      assert.ok(!cleanedBook.image.includes('edge=curl'));
      assert.equal(cleanedBook.category, 'book.categories.business');
    }
  );

  await t.test(
    '5. POST /api/v1/users/:userId/reading auto-syncs book into Central DB and updates MongoDB readingTree + gamificationTree',
    async () => {
      const searchRes = await fetch(
        `${baseUrl}/api/v1/books/search?q=${encodeURIComponent('Deep Work')}`
      );
      const searchData = await searchRes.json();
      const externalBook = searchData.results[0];

      // User selects "Deep Work" to read and adds a highlight & note
      const syncRes = await fetch(
        `${baseUrl}/api/v1/users/${encodeURIComponent('bat@readpack.app')}/reading`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            book: externalBook,
            shelfId: 'currently_reading',
            status: 'reading',
            progress: 0.45,
            currentChapter: 1,
            currentPage: 120,
            minutesRead: 20,
            highlight: {
              chapterIndex: 1,
              text: 'Clarity about what matters provides clarity about what does not.',
              color: 'yellow',
            },
            note: {
              content: 'Өглөө бүр 2 цаг Deep Work хийх.',
            },
          }),
        }
      );
      assert.equal(syncRes.status, 201);
      const syncData = await syncRes.json();

      // Verify user readingTree has the book, highlight node, and note node
      const currentlyReadingShelf =
        syncData.userAccountTree.readingTree.shelves.find(
          (s) => s.shelfId === 'currently_reading'
        );
      assert.equal(currentlyReadingShelf.childrenBooks.length, 1);
      const bookNode = currentlyReadingShelf.childrenBooks[0];
      assert.equal(bookNode.title, 'Deep Work: Rules for Focused Success');
      assert.equal(bookNode.progress, 0.45);
      assert.equal(bookNode.highlightsNodes.length, 1);
      assert.equal(bookNode.notesNodes.length, 1);

      // Now when ANY subsequent user searches for "Deep Work", it is served from central_db!
      const secondSearchRes = await fetch(
        `${baseUrl}/api/v1/books/search?q=${encodeURIComponent('Deep Work')}`
      );
      const secondSearchData = await secondSearchRes.json();
      assert.equal(secondSearchData.source, 'central_db');
      assert.equal(
        secondSearchData.results[0].title,
        'Deep Work: Rules for Focused Success'
      );
    }
  );
});
