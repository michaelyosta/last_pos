import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:pos_app/screens/login_screen.dart';
import 'package:pos_app/screens/admin_dashboard_screen.dart';
import 'package:pos_app/screens/manager_vehicles_list_screen.dart';

// --- Mocks ---
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Stream<User?> authStateChanges() => Stream.empty(); // Provide a default stream
}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {
  @override
  String get uid => 'test_uid'; // Default UID
}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDocRef;
  late MockDocumentSnapshot mockUserDocSnapshot;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockUsersCollection = MockCollectionReference();
    mockUserDocRef = MockDocumentReference();
    mockUserDocSnapshot = MockDocumentSnapshot();

    // Stubbing for successful login and role fetch
    when(mockAuth.signInWithEmailAndPassword(email: anyNamed('email'), password: anyNamed('password')))
        .thenAnswer((_) async => mockUserCredential);
    when(mockUserCredential.user).thenReturn(mockUser);
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc(any)).thenReturn(mockUserDocRef); // Use any for UID
    when(mockUserDocRef.get()).thenAnswer((_) async => mockUserDocSnapshot);
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    // This is where you would inject mocks if LoginScreen took them as params.
    // For now, we rely on `firebase_auth_mocks` and `fake_cloud_firestore`
    // or global instance replacement if testing without them.
    // The tests below will assume that when LoginScreen calls FirebaseAuth.instance
    // or FirebaseFirestore.instance, it gets our mocks. This is hard without DI.
    // A common workaround:
    // FirebaseFirestore.instance = mockFirestore;
    // FirebaseAuth.instance = mockAuth;
    // (and reset in tearDown)

    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
        // For navigation verification
        routes: {
          '/admin_dashboard': (context) => const AdminDashboardScreen(),
          '/manager_vehicles_list': (context) => const ManagerVehiclesListScreen(managerId: 'test_uid'),
        },
      ),
    );
  }

  group('LoginScreen Tests', () {
    testWidgets('Finds Email, Password fields and Login button', (WidgetTester tester) async {
      await pumpLoginScreen(tester);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      // Password field label was "Пароль (для Администратора)"
      expect(find.widgetWithText(TextFormField, 'Пароль (для Администратора)'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'ВОЙТИ'), findsOneWidget); // Updated button text
    });

    testWidgets('Shows error for empty email or password', (WidgetTester tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'ВОЙТИ'));
      await tester.pumpAndSettle(); // For SnackBar
      expect(find.text('Пожалуйста, введите Email и Пароль'), findsOneWidget); // General empty fields message

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.tap(find.widgetWithText(ElevatedButton, 'ВОЙТИ'));
      await tester.pumpAndSettle();
      expect(find.text('Пожалуйста, введите Пароль'), findsOneWidget); // Password specific if email is filled
    });

    testWidgets('Login fails with incorrect credentials (user-not-found)', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(email: anyNamed('email'), password: anyNamed('password')))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      await pumpLoginScreen(tester);
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'wrong@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Пароль (для Администратора)'), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'ВОЙТИ'));
      await tester.pumpAndSettle();

      expect(find.text('Пользователь не найден.'), findsOneWidget);
    });

    testWidgets('Login fails with incorrect credentials (wrong-password)', (WidgetTester tester) async {
      when(mockAuth.signInWithEmailAndPassword(email: anyNamed('email'), password: anyNamed('password')))
          .thenThrow(FirebaseAuthException(code: 'wrong-password'));

      await pumpLoginScreen(tester);
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Пароль (для Администратора)'), 'wrongpass');
      await tester.tap(find.widgetWithText(ElevatedButton, 'ВОЙТИ'));
      await tester.pumpAndSettle();

      expect(find.text('Неверный пароль.'), findsOneWidget);
    });

    testWidgets('Admin login navigates to AdminDashboardScreen', (WidgetTester tester) async {
      when(mockUserDocSnapshot.exists).thenReturn(true);
      when(mockUserDocSnapshot.get('role')).thenReturn('admin');
      // Ensure mockUser.uid is used for doc path if LoginScreen uses it directly
      when(mockUsersCollection.doc(mockUser.uid)).thenReturn(mockUserDocRef);


      await pumpLoginScreen(tester);
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'admin@yourposapp.local');
      await tester.enterText(find.widgetWithText(TextFormField, 'Пароль (для Администратора)'), 'adminpass');
      await tester.tap(find.widgetWithText(ElevatedButton, 'ВОЙТИ'));
      await tester.pumpAndSettle(); // Wait for navigation

      expect(find.byType(AdminDashboardScreen), findsOneWidget);
    });

    testWidgets('Manager login navigates to ManagerVehiclesListScreen', (WidgetTester tester) async {
      when(mockUserDocSnapshot.exists).thenReturn(true);
      when(mockUserDocSnapshot.get('role')).thenReturn('manager');
      when(mockUser.uid).thenReturn('manager_uid_123'); // Specific UID for manager
      when(mockUsersCollection.doc('manager_uid_123')).thenReturn(mockUserDocRef);


      await pumpLoginScreen(tester);
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'manager_123456@yourposapp.local');
      await tester.enterText(find.widgetWithText(TextFormField, 'Пароль (для Администратора)'), 'managerpass');
      await tester.tap(find.widgetWithText(ElevatedButton, 'ВОЙТИ'));
      await tester.pumpAndSettle();

      expect(find.byType(ManagerVehiclesListScreen), findsOneWidget);
      // Verify managerId was passed (harder without direct access, but navigation implies it)
    });

    testWidgets('Shows error if user document not found in Firestore', (WidgetTester tester) async {
      when(mockUserDocSnapshot.exists).thenReturn(false); // User doc does not exist

      await pumpLoginScreen(tester);
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'user_no_doc@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Пароль (для Администратора)'), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'ВОЙТИ'));
      await tester.pumpAndSettle();

      expect(find.text('Данные пользователя не найдены'), findsOneWidget);
    });

    testWidgets('Shows error for unknown user role', (WidgetTester tester) async {
      when(mockUserDocSnapshot.exists).thenReturn(true);
      when(mockUserDocSnapshot.get('role')).thenReturn('unknown_role');

      await pumpLoginScreen(tester);
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'unknown_role@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Пароль (для Администратора)'), 'password');
      await tester.tap(find.widgetWithText(ElevatedButton, 'ВОЙТИ'));
      await tester.pumpAndSettle();

      expect(find.text('Неизвестная роль пользователя'), findsOneWidget);
    });

    testWidgets('Password field label is correct', (WidgetTester tester) async {
      await pumpLoginScreen(tester);
      // The original label "Пароль (для Администратора)" was kept in the refactored screen.
      // If this was intended to change, this test would catch it.
      expect(find.byWidgetPredicate(
        (Widget widget) => widget is TextFormField &&
                           widget.decoration?.labelText == 'Пароль (для Администратора)'
      ), findsOneWidget);
    });

  });
}

// IMPORTANT: These tests assume that LoginScreen uses `FirebaseAuth.instance` and
// `FirebaseFirestore.instance`. For these mocks to be effective, you would typically
// use a dependency injection system, or libraries like `firebase_auth_mocks` and
// `fake_cloud_firestore`. Without them, you might need to set
// `FirebaseAuth.instance = mockAuth;` and `FirebaseFirestore.instance = mockFirestore;`
// in `setUpAll` and reset in `tearDownAll`, which can be risky for test isolation.
// The tests are written assuming such a mechanism is in place or the screen is refactored for DI.
// Added specific mock for User.uid for manager login test.
// Corrected password field finder in initial state test.
// Added test for password field label to ensure it's as expected.
