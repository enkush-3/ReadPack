import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/reader/presentation/page/reader_page.dart';
import 'package:readpack/features/reader/widgets/reader_page_view.dart';
import 'package:readpack/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers/secure_storage_mock.dart';

late BookProvider _provider;

Widget createTestReader(Book book) {
  _provider = BookProvider();
  final themeProvider = ThemeProvider();
  themeProvider.setPaginated(true);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: themeProvider),
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

  const testLongBook = Book(
    id: 'test_swipe_book',
    title: 'Swipe Pagination Book',
    author: 'Author Name',
    description: 'A test book for verifying swipe gestures',
    rating: 4.8,
    category: 'Science',
    pages: 200,
    readTimeMinutes: 120,
    chapters: [
      BookChapter(
        id: 'c1',
        title: 'Chapter 1: The Beginning',
        content:
            'This is the very first page of the chapter with enough length to be divided into multiple pages.\n\n'
            'Here is the second paragraph of the content that provides substantial reading material for the reader.\n\n'
            'And here is another large chunk of text to guarantee that the content splits across at least two pages '
            'in paginated reading mode so that swipe pagination can be tested rigorously and reliably.',
        estimatedMinutes: 5,
      ),
      BookChapter(
        id: 'c2',
        title: 'Chapter 2: The Journey',
        content: 'This is the start of Chapter 2.',
        estimatedMinutes: 4,
      ),
    ],
  );

  group('Reader Swipe Pagination Tests', () {
    testWidgets(
      'Renders ReaderPageView and PageView when isPaginated is true',
      (tester) async {
        await tester.pumpWidget(createTestReader(testLongBook));
        addTearDown(_provider.dispose);
        await tester.runAsync(() => _provider.initialized);
        await tester.pumpAndSettle();

        expect(find.byType(ReaderPageView), findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);
      },
    );

    testWidgets('Swiping left and right on PageView navigates pages smoothly', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestReader(testLongBook));
      addTearDown(_provider.dispose);
      await tester.runAsync(() => _provider.initialized);
      await tester.pumpAndSettle();

      final pageViewFinder = find.byType(PageView);
      expect(pageViewFinder, findsOneWidget);

      // Perform a drag/swipe to turn page forward
      await tester.drag(pageViewFinder, const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Perform a drag/swipe to turn page backward
      await tester.drag(pageViewFinder, const Offset(400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Chapter 1: The Beginning'), findsOneWidget);
    });
  });
}
