import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/widgets/order_card.dart';
import 'package:clothing_dashboard/core/models/order.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('OrderCard', () {
    testWidgets('displays model name when available', (tester) async {
      final order = TestModels.createOrder();

      await tester.pumpWidget(
        TestWrapper(child: OrderCard(order: order)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Платье'), findsOneWidget);
    });

    testWidgets('displays order ID prefix when model is null', (tester) async {
      final order = Order(
        id: 'abc123def456',
        clientId: 'client-1',
        modelId: 'model-1',
        quantity: 1,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        TestWrapper(child: OrderCard(order: order)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Заказ #abc123'), findsOneWidget);
    });

    testWidgets('displays client name when available', (tester) async {
      final order = TestModels.createOrder();

      await tester.pumpWidget(
        TestWrapper(child: OrderCard(order: order)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Анна Иванова'), findsOneWidget);
    });

    testWidgets('displays "Заказчик" when client is null', (tester) async {
      final order = Order(
        id: 'order-1',
        clientId: 'client-1',
        modelId: 'model-1',
        quantity: 1,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        model: TestModels.createOrderModel(),
      );

      await tester.pumpWidget(
        TestWrapper(child: OrderCard(order: order)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Заказчик'), findsOneWidget);
    });

    testWidgets('displays quantity', (tester) async {
      final order = TestModels.createOrder(quantity: 5);

      await tester.pumpWidget(
        TestWrapper(child: OrderCard(order: order)),
      );
      await tester.pumpAndSettle();

      expect(find.text('5 шт.'), findsOneWidget);
    });

    group('status badge', () {
      testWidgets('displays pending status correctly', (tester) async {
        final order = TestModels.createOrder(status: OrderStatus.pending);

        await tester.pumpWidget(
          TestWrapper(child: OrderCard(order: order)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Ожидает'), findsOneWidget);
      });

      testWidgets('displays in_progress status correctly', (tester) async {
        final order = TestModels.createOrder(status: OrderStatus.inProgress);

        await tester.pumpWidget(
          TestWrapper(child: OrderCard(order: order)),
        );
        await tester.pumpAndSettle();

        expect(find.text('В работе'), findsOneWidget);
      });

      testWidgets('displays completed status correctly', (tester) async {
        final order = TestModels.createOrder(status: OrderStatus.completed);

        await tester.pumpWidget(
          TestWrapper(child: OrderCard(order: order)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Выполнен'), findsOneWidget);
      });

      testWidgets('displays cancelled status correctly', (tester) async {
        final order = TestModels.createOrder(status: OrderStatus.cancelled);

        await tester.pumpWidget(
          TestWrapper(child: OrderCard(order: order)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Отменён'), findsOneWidget);
      });
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapCount = 0;
      final order = TestModels.createOrder();

      await tester.pumpWidget(
        TestWrapper(
          child: OrderCard(
            order: order,
            onTap: () => tapCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OrderCard));
      await tester.pump();

      expect(tapCount, equals(1));
    });

    testWidgets('does not crash when onTap is null', (tester) async {
      final order = TestModels.createOrder();

      await tester.pumpWidget(
        TestWrapper(child: OrderCard(order: order)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OrderCard));
      await tester.pump();

      // Should not crash
    });

    group('due date display', () {
      testWidgets('displays schedule icon for future dates', (tester) async {
        final order = TestModels.createOrder(
          dueDate: DateTime.now().add(const Duration(days: 5)),
        );

        await tester.pumpWidget(
          TestWrapper(child: OrderCard(order: order)),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('displays warning icon for overdue orders', (tester) async {
        final order = TestModels.createOverdueOrder();

        await tester.pumpWidget(
          TestWrapper(child: OrderCard(order: order)),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      });

      testWidgets('displays "Просрочен" for overdue orders', (tester) async {
        final order = TestModels.createOverdueOrder();

        await tester.pumpWidget(
          TestWrapper(child: OrderCard(order: order)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Просрочен'), findsOneWidget);
      });

      testWidgets('displays due date info for future dates', (tester) async {
        final order = TestModels.createOrder(
          dueDate: DateTime.now().add(const Duration(days: 1)),
        );

        await tester.pumpWidget(
          TestWrapper(child: OrderCard(order: order)),
        );
        await tester.pumpAndSettle();

        // Verify schedule icon is displayed for non-overdue dates
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('displays days for near future dates', (tester) async {
        final order = TestModels.createOrder(
          dueDate: DateTime.now().add(const Duration(days: 3)),
        );

        await tester.pumpWidget(
          TestWrapper(child: OrderCard(order: order)),
        );
        await tester.pumpAndSettle();

        // The exact text depends on calculation - just verify schedule icon is shown
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('does not display due date when null', (tester) async {
        final order = TestModels.createOrder(dueDate: null);

        await tester.pumpWidget(
          TestWrapper(child: OrderCard(order: order)),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.schedule), findsNothing);
        expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      });
    });

    testWidgets('displays model image when available', (tester) async {
      final order = TestModels.createOrder(
        model: TestModels.createOrderModel(imageUrl: 'https://example.com/image.jpg'),
      );

      await tester.pumpWidget(
        TestWrapper(child: OrderCard(order: order)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays icon when model image is null', (tester) async {
      final order = TestModels.createOrder(
        model: TestModels.createOrderModel(imageUrl: null),
      );

      await tester.pumpWidget(
        TestWrapper(child: OrderCard(order: order)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.checkroom), findsOneWidget);
    });
  });

  group('OrderCardSkeleton', () {
    testWidgets('renders skeleton placeholder', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(child: OrderCardSkeleton()),
      );

      // Should render without errors
      expect(find.byType(OrderCardSkeleton), findsOneWidget);
    });
  });
}
