'use strict';

const assert = require('node:assert/strict');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');
const { MongoStore } = require('../src/services/mongoStore');

test('preserves an unreadable fallback store and fails initialization', async (t) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'readpack-store-'));
  const storageFilePath = path.join(directory, 'store.json');
  const originalContents = '{invalid json';
  fs.writeFileSync(storageFilePath, originalContents);
  t.after(() => fs.rmSync(directory, { recursive: true, force: true }));

  const store = new MongoStore({ storageFilePath });

  await assert.rejects(store.init({ forceFallback: true }));
  assert.equal(fs.readFileSync(storageFilePath, 'utf8'), originalContents);
});

test('rejects fallback writes without changing the in-memory catalog', async (t) => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'readpack-store-'));
  const storageFilePath = path.join(directory, 'store.json');
  t.after(() => fs.rmSync(directory, { recursive: true, force: true }));

  const store = new MongoStore({ storageFilePath });
  await store.init({ forceFallback: true });
  const existingBooks = await store.getAllBooks();

  fs.rmSync(storageFilePath);
  fs.mkdirSync(storageFilePath);

  await assert.rejects(
    store.upsertBook({
      id: 'probe_book',
      title: 'Probe Book',
      author: 'Probe Author',
      normalizedTitle: 'probe book',
      normalizedAuthor: 'probe author',
    }),
  );
  assert.deepEqual(await store.getAllBooks(), existingBooks);
});
