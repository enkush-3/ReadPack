import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/reader/presentation/page/reader_page.dart';
import 'package:readpack/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers/secure_storage_mock.dart';

late BookProvider _provider;

Widget createTestReader(Book book) {
  _provider = BookProvider();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider<BookProvider>.value(value: _provider),
    ],
    child: MaterialApp(home: ReaderPage(book: book)),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockSecureStorage();
  });

  const emptyBook = Book(
    id: 'empty_book_0',
    title: 'Empty Chapters Book',
    author: 'Unknown Author',
    description: 'A book with no loaded chapters yet',
    rating: 4.0,
    category: 'General',
    pages: 100,
    readTimeMinutes: 50,
    chapters: [],
  );

  group('ReaderPage Empty Chapters Edge Case', () {
    testWidgets(
      'Renders safely with zero chapters without throwing RangeError',
      (tester) async {
        await tester.pumpWidget(createTestReader(emptyBook));
        addTearDown(_provider.dispose);
        await tester.runAsync(() => _provider.initialized);
        await tester.pumpAndSettle();

        expect(find.text('Empty Chapters Book'), findsOneWidget);
        expect(find.text('Unknown Author'), findsOneWidget);
        expect(find.text('Агуулга'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping bookmark icon on empty chapters book does not throw RangeError',
      (tester) async {
        await tester.pumpWidget(createTestReader(emptyBook));
        addTearDown(_provider.dispose);
        await tester.runAsync(() => _provider.initialized);
        await tester.pumpAndSettle();

        final bookmarkBtn = find.byIcon(Icons.bookmark_add_rounded);
        expect(bookmarkBtn, findsOneWidget);

        await tester.tap(bookmarkBtn);
        await tester.pumpAndSettle();

        // Bookmark sheet opens safely
        expect(find.text('Ишлэл & Тэмдэглэл хадгалах'), findsOneWidget);
      },
    );

    testWidgets('Table of contents sheet handles zero chapters safely', (
      tester,
    ) async {
      await tester.pumpWidget(createTestReader(emptyBook));
      addTearDown(_provider.dispose);
      await tester.runAsync(() => _provider.initialized);
      await tester.pumpAndSettle();

      final tocBtn = find.byIcon(Icons.format_list_bulleted_rounded);
      expect(tocBtn, findsOneWidget);

      await tester.tap(tocBtn);
      await tester.pumpAndSettle();

      expect(find.text('Гарчиг'), findsOneWidget);
      expect(find.text('Бүлгийн гарчиг байхгүй байна'), findsOneWidget);
    });
  });
}
