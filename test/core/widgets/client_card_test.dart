import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/widgets/client_card.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ClientCard', () {
    testWidgets('displays client name', (tester) async {
      final client = TestModels.createClient(name: 'Мария Петрова');

      await tester.pumpWidget(
        TestWrapper(child: ClientCard(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Мария Петрова'), findsOneWidget);
    });

    testWidgets('displays client phone when available', (tester) async {
      final client = TestModels.createClient(phone: '+79001234567');

      await tester.pumpWidget(
        TestWrapper(child: ClientCard(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('+79001234567'), findsOneWidget);
    });

    testWidgets('does not display phone when null', (tester) async {
      final client = TestModels.createClient(phone: null);

      await tester.pumpWidget(
        TestWrapper(child: ClientCard(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('+79001234567'), findsNothing);
    });

    testWidgets('displays orders count', (tester) async {
      final client = TestModels.createClient(ordersCount: 7);

      await tester.pumpWidget(
        TestWrapper(child: ClientCard(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('7 заказов'), findsOneWidget);
    });

    testWidgets('displays total spent formatted', (tester) async {
      final client = TestModels.createClient(totalSpent: 25000);

      await tester.pumpWidget(
        TestWrapper(child: ClientCard(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('25K сом'), findsOneWidget);
    });

    testWidgets('displays large amounts in millions', (tester) async {
      final client = TestModels.createClient(totalSpent: 1500000);

      await tester.pumpWidget(
        TestWrapper(child: ClientCard(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('1.5M сом'), findsOneWidget);
    });

    testWidgets('displays small amounts without suffix', (tester) async {
      final client = TestModels.createClient(totalSpent: 500);

      await tester.pumpWidget(
        TestWrapper(child: ClientCard(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('500 сом'), findsOneWidget);
    });

    testWidgets('displays VIP badge for VIP clients', (tester) async {
      final client = TestModels.createVipClient();

      await tester.pumpWidget(
        TestWrapper(child: ClientCard(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('VIP'), findsOneWidget);
    });

    testWidgets('does not display VIP badge for regular clients', (tester) async {
      final client = TestModels.createClient(ordersCount: 5, totalSpent: 10000);

      await tester.pumpWidget(
        TestWrapper(child: ClientCard(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('VIP'), findsNothing);
    });

    testWidgets('displays client initials in avatar', (tester) async {
      final client = TestModels.createClient(name: 'Анна Иванова');

      await tester.pumpWidget(
        TestWrapper(child: ClientCard(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('АИ'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapCount = 0;
      final client = TestModels.createClient();

      await tester.pumpWidget(
        TestWrapper(
          child: ClientCard(
            client: client,
            onTap: () => tapCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Perform tap down and up to trigger the GestureDetector
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ClientCard)),
      );
      await tester.pump(const Duration(milliseconds: 50));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tapCount, equals(1));
    });

    testWidgets('displays chevron icon', (tester) async {
      final client = TestModels.createClient();

      await tester.pumpWidget(
        TestWrapper(child: ClientCard(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });

  group('ClientCardCompact', () {
    testWidgets('displays client name', (tester) async {
      final client = TestModels.createClient(name: 'Иван Сидоров');

      await tester.pumpWidget(
        TestWrapper(child: ClientCardCompact(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Иван Сидоров'), findsOneWidget);
    });

    testWidgets('displays client initials', (tester) async {
      final client = TestModels.createClient(name: 'Иван Сидоров');

      await tester.pumpWidget(
        TestWrapper(child: ClientCardCompact(client: client)),
      );
      await tester.pumpAndSettle();

      expect(find.text('ИС'), findsOneWidget);
    });

    testWidgets('displays check icon when selected', (tester) async {
      final client = TestModels.createClient();

      await tester.pumpWidget(
        TestWrapper(
          child: ClientCardCompact(
            client: client,
            isSelected: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('does not display check icon when not selected', (tester) async {
      final client = TestModels.createClient();

      await tester.pumpWidget(
        TestWrapper(
          child: ClientCardCompact(
            client: client,
            isSelected: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapCount = 0;
      final client = TestModels.createClient();

      await tester.pumpWidget(
        TestWrapper(
          child: ClientCardCompact(
            client: client,
            onTap: () => tapCount++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ClientCardCompact));
      await tester.pump();

      expect(tapCount, equals(1));
    });
  });
}
