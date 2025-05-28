import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pos_app/screens/admin_dashboard_screen.dart';
import 'package:pos_app/screens/admin_manager_screen.dart'; // Target screen

// Mock NavigatorObserver
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  group('AdminDashboardScreen Tests', () {
    late MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockNavigatorObserver = MockNavigatorObserver();
    });

    Future<void> pumpAdminDashboardScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const AdminDashboardScreen(),
          navigatorObservers: [mockNavigatorObserver],
          // Define routes if AdminManagerScreen constructor or its children require it
          // or if there are specific named routes being pushed.
          // For direct navigation like MaterialPageRoute, this might not be strictly necessary
          // unless AdminManagerScreen itself has dependencies that need routing.
          routes: {
            // Example if AdminManagerScreen had a routeName and was pushed by name
            // AdminManagerScreen.routeName: (context) => const AdminManagerScreen(),
          },
        ),
      );
    }

    testWidgets('finds "Менеджер" button', (WidgetTester tester) async {
      await pumpAdminDashboardScreen(tester);
      expect(find.widgetWithText(ElevatedButton, 'Менеджер'), findsOneWidget);
    });

    testWidgets('tapping "Менеджер" button navigates to AdminManagerScreen', (WidgetTester tester) async {
      await pumpAdminDashboardScreen(tester);

      final managerButtonFinder = find.widgetWithText(ElevatedButton, 'Менеджер');
      expect(managerButtonFinder, findsOneWidget);

      await tester.tap(managerButtonFinder);
      await tester.pumpAndSettle(); // Wait for navigation to complete

      // Verify that a push transition to AdminManagerScreen happened
      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.byType(AdminManagerScreen), findsOneWidget);
    });

    testWidgets('finds "Управление Товарами" button', (WidgetTester tester) async {
      await pumpAdminDashboardScreen(tester);
      expect(find.widgetWithText(ElevatedButton, 'Управление Товарами'), findsOneWidget);
    });

    testWidgets('finds "Общий отчет по выручке" button', (WidgetTester tester) async {
      await pumpAdminDashboardScreen(tester);
      expect(find.widgetWithText(ElevatedButton, 'Общий отчет по выручке'), findsOneWidget);
    });

    testWidgets('finds "Настройки" button', (WidgetTester tester) async {
      await pumpAdminDashboardScreen(tester);
      expect(find.widgetWithText(ElevatedButton, 'Настройки'), findsOneWidget);
    });

  });
}
