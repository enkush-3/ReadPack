import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readpack/core/themes/themes.dart';
import 'package:readpack/shared/widgets/animated_button.dart';
import 'package:readpack/shared/widgets/animated_pressable.dart';
import 'package:readpack/shared/widgets/empty_state_view.dart';
import 'package:readpack/shared/widgets/error_state_view.dart';
import 'package:readpack/shared/widgets/skeleton_loader.dart';

void main() {
  Widget themed(Widget child, {bool disableAnimations = false}) {
    return MaterialApp(
      theme: BookTheme.lightTheme(),
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: Scaffold(body: child),
      ),
    );
  }

  group('shared motion and state widgets', () {
    testWidgets(
      'animated button exposes a 48dp target and invokes its action',
      (tester) async {
        var tapCount = 0;
        await tester.pumpWidget(
          themed(
            AnimatedButton(
              onPressed: () => tapCount++,
              semanticLabel: 'Continue',
              child: const Text('Continue'),
            ),
          ),
        );

        final button = find.byType(AnimatedButton);
        expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        expect(tapCount, 1);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics && widget.properties.label == 'Continue',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('disabled pressable cannot invoke its action', (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        themed(
          const AnimatedPressable(
            onTap: null,
            child: SizedBox(width: 80, height: 48, child: Text('Disabled')),
          ),
        ),
      );

      await tester.tap(find.text('Disabled'));
      await tester.pump();
      expect(tapCount, 0);
      expect(tester.getSize(find.text('Disabled')).height, 48);
    });

    testWidgets(
      'skeleton respects reduce motion and hides decorative semantics',
      (tester) async {
        await tester.pumpWidget(
          themed(
            const SkeletonLoader(width: 120, height: 24),
            disableAnimations: true,
          ),
        );

        expect(
          find.descendant(
            of: find.byType(SkeletonLoader),
            matching: find.byType(ExcludeSemantics),
          ),
          findsOneWidget,
        );
        expect(
          tester.getSize(find.byType(SkeletonLoader)),
          const Size(120, 24),
        );
      },
    );

    testWidgets('empty and error states provide working actions', (
      tester,
    ) async {
      var emptyActionCount = 0;
      await tester.pumpWidget(
        themed(
          EmptyStateView(
            icon: Icons.book_outlined,
            title: 'Nothing saved',
            message: 'Save a book to see it here.',
            actionLabel: 'Browse books',
            onAction: () => emptyActionCount++,
          ),
        ),
      );
      await tester.tap(find.text('Browse books'));
      await tester.pumpAndSettle();
      expect(emptyActionCount, 1);

      var retryCount = 0;
      await tester.pumpWidget(
        themed(
          ErrorStateView(
            errorMessage: 'Please try again.',
            onRetry: () => retryCount++,
          ),
        ),
      );
      await tester.tap(find.text('Дахин оролдох'));
      await tester.pumpAndSettle();
      expect(retryCount, 1);
    });
  });
}
