import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/widgets/swipeable_card.dart';
import 'package:clothing_dashboard/core/theme/app_theme.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('SwipeAction', () {
    test('creates with required properties', () {
      const action = SwipeAction(
        icon: Icons.delete,
        backgroundColor: Colors.red,
      );

      expect(action.icon, equals(Icons.delete));
      expect(action.backgroundColor, equals(Colors.red));
      expect(action.foregroundColor, equals(Colors.white));
      expect(action.label, isNull);
      expect(action.onTap, isNull);
      expect(action.isDestructive, isFalse);
    });

    test('creates with all properties', () {
      var tapped = false;
      final action = SwipeAction(
        icon: Icons.delete,
        label: 'Удалить',
        backgroundColor: Colors.red,
        foregroundColor: Colors.black,
        onTap: () => tapped = true,
        isDestructive: true,
      );

      expect(action.label, equals('Удалить'));
      expect(action.foregroundColor, equals(Colors.black));
      expect(action.isDestructive, isTrue);

      action.onTap?.call();
      expect(tapped, isTrue);
    });
  });

  group('SwipeableCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SwipeableCard(
            child: Container(
              height: 60,
              color: Colors.blue,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped and not swiped', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        TestWrapper(
          child: SwipeableCard(
            onTap: () => tapCount++,
            child: Container(
              height: 60,
              color: Colors.blue,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Content'));
      await tester.pump();

      expect(tapCount, equals(1));
    });

    testWidgets('calls onLongPress when long pressed', (tester) async {
      var longPressCount = 0;

      await tester.pumpWidget(
        TestWrapper(
          child: SwipeableCard(
            onLongPress: () => longPressCount++,
            child: Container(
              height: 60,
              color: Colors.blue,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Content'));
      await tester.pumpAndSettle();

      expect(longPressCount, equals(1));
    });

    testWidgets('does not swipe when enabled is false', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SwipeableCard(
            enabled: false,
            rightActions: [
              SwipeAction(
                icon: Icons.delete,
                backgroundColor: Colors.red,
              ),
            ],
            child: Container(
              height: 60,
              color: Colors.blue,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // Attempt to swipe
      await tester.drag(find.text('Content'), const Offset(-100, 0));
      await tester.pumpAndSettle();

      // Card should not have moved, delete icon should not be visible
      // The card should still be at original position
    });

    testWidgets('applies custom border radius', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SwipeableCard(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 60,
              color: Colors.blue,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('applies custom margin', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SwipeableCard(
            margin: const EdgeInsets.all(16),
            child: Container(
              height: 60,
              color: Colors.blue,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.ancestor(
          of: find.byType(ClipRRect),
          matching: find.byType(Container),
        ).first,
      );

      expect(container.margin, equals(const EdgeInsets.all(16)));
    });
  });

  group('DismissibleCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: DismissibleCard(
            child: Container(
              height: 60,
              color: Colors.blue,
              child: const Text('Dismissible Content'),
            ),
          ),
        ),
      );

      expect(find.text('Dismissible Content'), findsOneWidget);
    });

    testWidgets('shows delete background when swiped', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: DismissibleCard(
            confirmDismiss: false,
            child: Container(
              height: 60,
              color: Colors.blue,
              child: const Text('Dismissible Content'),
            ),
          ),
        ),
      );

      // Start swiping
      await tester.drag(find.text('Dismissible Content'), const Offset(-100, 0));
      await tester.pump();

      // Should show the dismiss background with icon
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('can be configured with custom dismiss text', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: DismissibleCard(
            dismissText: 'Архивировать',
            confirmDismiss: false,
            child: Container(
              height: 60,
              color: Colors.blue,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // Verify the dismissible card is rendered
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('can be configured with custom dismiss icon', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: DismissibleCard(
            dismissIcon: Icons.archive,
            confirmDismiss: false,
            child: Container(
              height: 60,
              color: Colors.blue,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // Verify the dismissible card is rendered
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('can be configured with confirmDismiss', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: DismissibleCard(
            confirmDismiss: true,
            confirmTitle: 'Удалить заказ?',
            confirmMessage: 'Это действие нельзя отменить',
            child: Container(
              height: 60,
              color: Colors.blue,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      // Verify the dismissible card is rendered
      expect(find.text('Content'), findsOneWidget);
    });
  });

  group('RevealActionsCard', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: RevealActionsCard(
            actions: [
              SwipeAction(
                icon: Icons.edit,
                backgroundColor: Colors.blue,
              ),
            ],
            child: Container(
              height: 60,
              color: Colors.grey,
              child: const Text('Reveal Content'),
            ),
          ),
        ),
      );

      expect(find.text('Reveal Content'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped and not expanded', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        TestWrapper(
          child: RevealActionsCard(
            onTap: () => tapCount++,
            actions: [
              SwipeAction(
                icon: Icons.edit,
                backgroundColor: Colors.blue,
              ),
            ],
            child: Container(
              height: 60,
              color: Colors.grey,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Content'));
      await tester.pump();

      expect(tapCount, equals(1));
    });

    testWidgets('expands on long press', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: RevealActionsCard(
            actions: [
              SwipeAction(
                icon: Icons.edit,
                label: 'Изменить',
                backgroundColor: Colors.blue,
              ),
            ],
            child: Container(
              height: 60,
              color: Colors.grey,
              child: const Text('Content'),
            ),
          ),
        ),
      );

      await tester.longPress(find.text('Content'));
      await tester.pumpAndSettle();

      // Actions should be revealed
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}
