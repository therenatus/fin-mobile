import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/widgets/error_state.dart';
import '../../helpers/widget_test_helpers.dart';

void main() {
  group('ErrorState', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: ErrorState(title: 'Произошла ошибка'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Произошла ошибка'), findsOneWidget);
    });

    testWidgets('displays message when provided', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: ErrorState(
            title: 'Ошибка',
            message: 'Попробуйте позже',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Попробуйте позже'), findsOneWidget);
    });

    testWidgets('does not display message when null', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: ErrorState(title: 'Ошибка'),
        ),
      );
      await tester.pumpAndSettle();

      // Only title should be present
      expect(find.text('Ошибка'), findsOneWidget);
    });

    testWidgets('displays custom icon when provided', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: ErrorState(
            title: 'Ошибка',
            icon: Icons.wifi_off,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('displays default error icon when no custom icon', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: ErrorState(title: 'Ошибка'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('displays retry button when onRetry is provided', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: ErrorState(
            title: 'Ошибка',
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify retry button is displayed
      expect(find.text('Повторить'), findsOneWidget);
    });

    testWidgets('displays custom retry label', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: ErrorState(
            title: 'Ошибка',
            retryLabel: 'Попробовать снова',
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Попробовать снова'), findsOneWidget);
    });

    testWidgets('does not display retry button when onRetry is null', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: ErrorState(title: 'Ошибка'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Повторить'), findsNothing);
    });

    testWidgets('animation completes when animate is true', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: ErrorState(
            title: 'Ошибка',
            animate: true,
          ),
        ),
      );

      // Pump frames to let animation complete
      await tester.pumpAndSettle();

      // Title should be visible after animation
      expect(find.text('Ошибка'), findsOneWidget);
    });

    testWidgets('no animation when animate is false', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: ErrorState(
            title: 'Ошибка',
            animate: false,
          ),
        ),
      );
      await tester.pump();

      // Content should be immediately visible
      expect(find.text('Ошибка'), findsOneWidget);
    });
  });

  group('NetworkErrorState', () {
    testWidgets('displays network error content', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: NetworkErrorState(onRetry: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Нет подключения'), findsOneWidget);
      expect(find.text('Проверьте подключение к интернету и повторите попытку'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('displays retry button', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: NetworkErrorState(onRetry: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // Verify retry button is displayed
      expect(find.text('Повторить'), findsOneWidget);
    });
  });

  group('ServerErrorState', () {
    testWidgets('displays server error content', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: ServerErrorState(onRetry: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ошибка сервера'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('displays custom message', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: ServerErrorState(
            message: 'Сервер недоступен',
            onRetry: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Сервер недоступен'), findsOneWidget);
    });
  });

  group('NotFoundState', () {
    testWidgets('displays not found content', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: NotFoundState(onAction: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Не найдено'), findsOneWidget);
      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });

    testWidgets('displays custom title and message', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: NotFoundState(
            title: 'Заказ не найден',
            message: 'Заказ был удалён или не существует',
            onAction: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Заказ не найден'), findsOneWidget);
      expect(find.text('Заказ был удалён или не существует'), findsOneWidget);
    });
  });

  group('AnimatedEmptyState', () {
    testWidgets('displays empty state content', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: AnimatedEmptyState(
            icon: Icons.inbox_outlined,
            title: 'Нет заказов',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Нет заказов'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: AnimatedEmptyState(
            icon: Icons.inbox_outlined,
            title: 'Нет заказов',
            subtitle: 'Создайте первый заказ',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Создайте первый заказ'), findsOneWidget);
    });

    testWidgets('displays action button when provided', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: AnimatedEmptyState(
            icon: Icons.inbox_outlined,
            title: 'Нет заказов',
            actionLabel: 'Создать заказ',
            onAction: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify button is displayed
      expect(find.text('Создать заказ'), findsOneWidget);
    });
  });

  group('SuccessState', () {
    testWidgets('displays success content', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: SuccessState(title: 'Готово!'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Готово!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
    });

    testWidgets('displays message when provided', (tester) async {
      await tester.pumpWidget(
        const TestWrapper(
          child: SuccessState(
            title: 'Заказ создан',
            message: 'Номер заказа: #12345',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Номер заказа: #12345'), findsOneWidget);
    });

    testWidgets('displays continue button when provided', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SuccessState(
            title: 'Готово!',
            onContinue: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify button is displayed
      expect(find.text('Продолжить'), findsOneWidget);
    });

    testWidgets('displays custom continue label', (tester) async {
      await tester.pumpWidget(
        TestWrapper(
          child: SuccessState(
            title: 'Готово!',
            continueLabel: 'К заказам',
            onContinue: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('К заказам'), findsOneWidget);
    });
  });
}
