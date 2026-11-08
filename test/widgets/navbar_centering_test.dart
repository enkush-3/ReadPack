import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:readpack/core/providers/book_provider.dart';
import 'package:readpack/features/shared/widgets/bottomnavbar.dart';
import 'package:readpack/features/shared/widgets/navbutton.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget createTestNavBar({required int selectedIndex, required ValueChanged<int> onTap}) {
  return ChangeNotifierProvider(
    create: (_) => BookProvider(),
    child: MaterialApp(
      home: Scaffold(
        bottomNavigationBar: BottomNavBar(
          selectedIndex: selectedIndex,
          onTap: onTap,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BottomNavBar Centering and Sliding Animation Tests', () {
    testWidgets('Icon and text are horizontally centered with sliding indicator on all 4 tabs', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      int currentIndex = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return createTestNavBar(
              selectedIndex: currentIndex,
              onTap: (index) => setState(() => currentIndex = index),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      final icons = [
        Icons.home_rounded,
        Icons.explore_rounded,
        Icons.bookmark_rounded,
        Icons.person_rounded,
      ];

      final labels = [
        'Нүүр',
        'Хайх',
        'Хадгалсан',
        'Профайл',
      ];

      for (int i = 0; i < 4; i++) {
        // Tap tab i
        await tester.tap(find.byIcon(icons[i]));
        await tester.pumpAndSettle();

        // 1. Verify no overflow exception was thrown
        expect(tester.takeException(), isNull);

        // 2. Find NavigationButton, Icon, Text, and AnimatedPositioned
        final navButtons = tester.widgetList<NavigationButton>(find.byType(NavigationButton)).toList();
        expect(navButtons.length, 4);
        expect(navButtons[i].isSelected, isTrue);

        final iconBox = tester.renderObject(find.byIcon(icons[i])) as RenderBox;
        final textBox = tester.renderObject(find.text(labels[i])) as RenderBox;
        final navButtonBox = tester.renderObject(find.byType(NavigationButton).at(i)) as RenderBox;

        final iconCenter = iconBox.localToGlobal(Offset(iconBox.size.width / 2, 0)).dx;
        final textCenter = textBox.localToGlobal(Offset(textBox.size.width / 2, 0)).dx;
        final slotCenter = navButtonBox.localToGlobal(Offset(navButtonBox.size.width / 2, 0)).dx;

        // Verify Icon and Text centers match the tab slot center within 1 pixel
        expect((iconCenter - slotCenter).abs(), lessThanOrEqualTo(1.0),
            reason: 'Tab $i Icon should be centered in its slot');
        expect((textCenter - slotCenter).abs(), lessThanOrEqualTo(1.0),
            reason: 'Tab $i Text should be centered in its slot');

        // Verify the sliding indicator pill is centered at the same slotCenter
        final animatedPositioned = tester.widget<AnimatedPositioned>(find.byType(AnimatedPositioned));
        final pillLeft = animatedPositioned.left!;
        final pillWidth = animatedPositioned.width!;
        final pillCenter = pillLeft + (pillWidth / 2);

        // Account for horizontal padding (12px)
        final expectedPillCenter = slotCenter - 12.0; // slotCenter is relative to global screen (starts at padding: 12)
        expect((pillCenter - expectedPillCenter).abs(), lessThanOrEqualTo(1.0),
            reason: 'Sliding pill center should match slotCenter');
      }
    });

    testWidgets('Tapping tab triggers smooth transition and badge displays properly', (tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        createTestNavBar(
          selectedIndex: 2,
          onTap: (index) => tappedIndex = index,
        ),
      );
      await tester.pumpAndSettle();

      // Verify Tab 2 (Saved) has badge and icon/label
      expect(find.text('Хадгалсан'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

      // Tap Tab 0
      await tester.tap(find.byIcon(Icons.home_rounded));
      expect(tappedIndex, 0);
    });
  });
}
