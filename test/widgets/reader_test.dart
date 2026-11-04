import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/core/providers/theme_provider.dart';
import 'package:readpack/features/reader/presentation/page/reader_page.dart';
import 'package:readpack/models/book.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createTestReader(Book book) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => BookProvider()),
    ],
    child: MaterialApp(
      home: ReaderPage(book: book),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  const testBook = Book(
    id: 'test_1984',
    title: '1984',
    author: 'George Orwell',
    description: 'Dystopian novel',
    rating: 4.9,
    category: 'History',
    pages: 328,
    readTimeMinutes: 300,
    chapters: [
      BookChapter(
        id: 'c1',
        title: 'Part 1: The Clock Strikes Thirteen',
        content:
            'It was a bright cold day in April, and the clocks were striking thirteen.',
        estimatedMinutes: 5,
      ),
      BookChapter(
        id: 'c2',
        title: 'Part 2: The Telescreen',
        content:
            'Inside the flat a fruity voice was reading out a list of figures.',
        estimatedMinutes: 6,
      ),
    ],
  );

  group('ReaderPage Widget Tests', () {
    testWidgets('Renders book title, author, and chapter text', (tester) async {
      await tester.pumpWidget(createTestReader(testBook));
      await tester.pumpAndSettle();

      expect(find.text('1984'), findsOneWidget);
      expect(find.text('George Orwell'), findsOneWidget);
      expect(find.text('Part 1: The Clock Strikes Thirteen'), findsOneWidget);
      expect(
        find.text(
            'It was a bright cold day in April, and the clocks were striking thirteen.'),
        findsOneWidget,
      );
    });

    testWidgets('Appearance bottom sheet opens upon tapping typography icon', (tester) async {
      await tester.pumpWidget(createTestReader(testBook));
      await tester.pumpAndSettle();

      final textFormatBtn = find.byIcon(Icons.text_format_rounded);
      expect(textFormatBtn, findsOneWidget);

      await tester.tap(textFormatBtn);
      await tester.pumpAndSettle();

      expect(find.text('Унших тохиргоо'), findsOneWidget);
      expect(find.text('Үсгийн хэмжээ'), findsOneWidget);
      expect(find.text('Дэлгэцийн өнгө'), findsOneWidget);
      expect(find.text('Сепиа'), findsOneWidget);
    });

    testWidgets('Audio mode toggle displays audio playback control bar', (tester) async {
      await tester.pumpWidget(createTestReader(testBook));
      await tester.pumpAndSettle();

      final audioBtn = find.byIcon(Icons.headphones_outlined);
      expect(audioBtn, findsOneWidget);

      await tester.tap(audioBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('Сонсох горим'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    });
  });
}
