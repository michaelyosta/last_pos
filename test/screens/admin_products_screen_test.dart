import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:pos_app/models/category.dart';
import 'package:pos_app/screens/admin_products_screen.dart';
import 'package:pos_app/screens/admin_add_category_screen.dart';
import 'package:pos_app/screens/admin_product_list_screen.dart';
import 'package:pos_app/core/constants.dart'; // For FirestoreCollections

// --- Mocks ---
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {
  final List<MockQueryDocumentSnapshot> _docs;
  MockQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;
}

class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic> _data;

  MockQueryDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic> data() => _data;

  @override
  bool get exists => true;
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// --- Test Data and Helpers ---
List<Category> getTestCategories() {
  return [
    Category(id: 'cat1', name: 'tools', displayName: 'Инструменты', description: ''),
    Category(id: 'cat2', name: 'consumables', displayName: 'Расходники', description: ''),
  ];
}

Map<String, dynamic> categoryToFirestore(Category c) => {
  'name': c.name, 'displayName': c.displayName, 'description': c.description,
  // Add other fields like createdBy, createdAt, updatedAt if your fromFirestore expects them
  // For simplicity, we'll assume they are handled or not strictly needed for this test's focus.
  'createdBy': 'test_admin', 'createdAt': Timestamp.now(), 'updatedAt': Timestamp.now(),
};

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCategoriesCollection;
  late MockQuery mockCategoriesQuery;
  late MockNavigatorObserver mockNavigatorObserver;

  // This function will be used to mock the behavior of _fetchCategories
  Future<List<Category>> mockFetchCategoriesImpl({bool error = false, List<Category>? categories}) async {
    if (error) {
      throw Exception('Simulated fetch error');
    }
    return categories ?? getTestCategories();
  }

  // We need a way to provide the mock _fetchCategories to the widget or mock its global call.
  // For now, we'll test UI states based on FutureBuilder's behavior.
  // Direct testing of _fetchCategories being called on refresh is harder without DI or more complex mocking.

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCategoriesCollection = MockCollectionReference();
    mockCategoriesQuery = MockQuery();
    mockNavigatorObserver = MockNavigatorObserver();

    when(mockFirestore.collection(FirestoreCollections.categories)).thenReturn(mockCategoriesCollection);
    when(mockCategoriesCollection.orderBy('displayName')).thenReturn(mockCategoriesQuery);
  });

  Future<void> pumpAdminProductsScreen(
    WidgetTester tester,
    Future<List<Category>> Function() fetchCategoriesMock // Allow passing a mock fetch function
  ) async {
    // The AdminProductsScreen internally calls _fetchCategories which uses FirebaseFirestore.instance.
    // To test this properly, we'd ideally inject the fetchCategories future or mock FirebaseFirestore.instance.
    // For this test, we'll assume the FutureBuilder receives its future correctly.
    // The key is to control the Future passed to FutureBuilder.

    // This is a simplified way, if AdminProductsScreen were refactored to take this Future:
    // await tester.pumpWidget(MaterialApp(
    //   home: AdminProductsScreen(categoriesFutureForTest: fetchCategoriesMock()),
    //   navigatorObservers: [mockNavigatorObserver],
    // ));

    // Since we can't easily inject the future without refactoring the widget itself,
    // we'll rely on setting up the global Firestore mock and triggering UI changes.
    // The actual call to _fetchCategories will use the mocked Firestore instance.

    // Replace global instance (use with caution, reset in tearDown or use a DI solution)
    final originalFirestore = FirebaseFirestore.instance;
    FirebaseFirestore.instance = mockFirestore;

    await tester.pumpWidget(MaterialApp(
      home: const AdminProductsScreen(),
      navigatorObservers: [mockNavigatorObserver],
      routes: { // Define routes if navigation is tested
        '/admin_add_category': (context) => const AdminAddCategoryScreen(),
        // AdminProductListScreen requires arguments, so direct route might be tricky
        // For testing navigation, we'd often just verify Navigator.pushNamed or similar
      },
    ));

    addTearDown(() {
      FirebaseFirestore.instance = originalFirestore;
    });
  }


  group('AdminProductsScreen with FutureBuilder Tests', () {
    testWidgets('Shows loading indicator initially', (WidgetTester tester) async {
      // Mock a delayed future
      when(mockCategoriesQuery.get()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        final mockSnapshot = MockQuerySnapshot(
          getTestCategories().map((c) => MockQueryDocumentSnapshot(c.id, categoryToFirestore(c))).toList()
        );
        return mockSnapshot;
      });

      await pumpAdminProductsScreen(tester, () => mockFetchCategoriesImpl());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle(); // Wait for future to complete
    });

    testWidgets('Displays categories after successful fetch', (WidgetTester tester) async {
      when(mockCategoriesQuery.get()).thenAnswer((_) async {
        final mockSnapshot = MockQuerySnapshot(
          getTestCategories().map((c) => MockQueryDocumentSnapshot(c.id, categoryToFirestore(c))).toList()
        );
        return mockSnapshot;
      });

      await pumpAdminProductsScreen(tester, () => mockFetchCategoriesImpl());
      await tester.pumpAndSettle(); // Complete the future

      expect(find.byType(ListView), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Инструменты'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Расходники'), findsOneWidget);
    });

    testWidgets('Displays error message if fetch fails', (WidgetTester tester) async {
      when(mockCategoriesQuery.get()).thenThrow(Exception('Simulated fetch error'));

      await pumpAdminProductsScreen(tester, () => mockFetchCategoriesImpl(error: true));
      await tester.pumpAndSettle();

      expect(find.text('Ошибка загрузки категорий: Exception: Simulated fetch error'), findsOneWidget);
    });

    testWidgets('Displays "Нет доступных категорий" message for empty list', (WidgetTester tester) async {
       when(mockCategoriesQuery.get()).thenAnswer((_) async {
        final mockSnapshot = MockQuerySnapshot([]); // Empty list
        return mockSnapshot;
      });

      await pumpAdminProductsScreen(tester, () => mockFetchCategoriesImpl(categories: []));
      await tester.pumpAndSettle();

      expect(find.text('Нет доступных категорий. Потяните вниз для обновления.'), findsOneWidget);
    });

    testWidgets('RefreshIndicator triggers categories fetch', (WidgetTester tester) async {
      // Initial fetch
      final initialCategories = [Category(id: 'cat1', name: 'tools', displayName: 'Инструменты', description: '')];
      when(mockCategoriesQuery.get()).thenAnswer((_) async {
         await Future.delayed(const Duration(milliseconds: 10)); // short delay
        final mockSnapshot = MockQuerySnapshot(
          initialCategories.map((c) => MockQueryDocumentSnapshot(c.id, categoryToFirestore(c))).toList()
        );
        return mockSnapshot;
      });

      await pumpAdminProductsScreen(tester, () => mockFetchCategoriesImpl(categories: initialCategories));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ListTile, 'Инструменты'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Новая Категория'), findsNothing);

      // Setup for refresh fetch
      final refreshedCategories = [
        Category(id: 'cat1', name: 'tools', displayName: 'Инструменты', description: ''),
        Category(id: 'cat_new', name: 'new_cat', displayName: 'Новая Категория', description: '')
      ];
      when(mockCategoriesQuery.get()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10)); // short delay
        final mockSnapshot = MockQuerySnapshot(
          refreshedCategories.map((c) => MockQueryDocumentSnapshot(c.id, categoryToFirestore(c))).toList()
        );
        return mockSnapshot;
      });

      // Simulate pull to refresh
      await tester.fling(find.byType(ListView), const Offset(0.0, 300.0), 1000.0);
      await tester.pumpAndSettle(); // Complete the refresh future and rebuild

      expect(find.widgetWithText(ListTile, 'Инструменты'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Новая Категория'), findsOneWidget);
    });

    testWidgets('Tapping "Добавить Новую Категорию" navigates to AdminAddCategoryScreen', (WidgetTester tester) async {
      when(mockCategoriesQuery.get()).thenAnswer((_) async {
        final mockSnapshot = MockQuerySnapshot(getTestCategories().map((c) => MockQueryDocumentSnapshot(c.id, categoryToFirestore(c))).toList());
        return mockSnapshot;
      });
      await pumpAdminProductsScreen(tester, () => mockFetchCategoriesImpl());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Добавить Новую Категорию'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.byType(AdminAddCategoryScreen), findsOneWidget);
    });

    testWidgets('Tapping a category navigates to AdminProductListScreen', (WidgetTester tester) async {
      final categories = getTestCategories();
       when(mockCategoriesQuery.get()).thenAnswer((_) async {
        final mockSnapshot = MockQuerySnapshot(categories.map((c) => MockQueryDocumentSnapshot(c.id, categoryToFirestore(c))).toList());
        return mockSnapshot;
      });

      await pumpAdminProductsScreen(tester, () => mockFetchCategoriesImpl(categories: categories));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Инструменты'));
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
      // We expect AdminProductListScreen, but since it takes params, it's harder to find by type directly
      // without defining it in routes with those params or using a more specific finder.
      // For now, verifying the push is a good step.
      // To be more precise, we'd check the route settings or the type of the pushed route's widget.
      final pushedRoute = verify(mockNavigatorObserver.didPush(captureAny, any)).captured.single as MaterialPageRoute;
      expect(pushedRoute.builder(GlobalKey<ScaffoldState>().currentContext!), isA<AdminProductListScreen>());
      final AdminProductListScreen productListScreen = pushedRoute.builder(GlobalKey<ScaffoldState>().currentContext!) as AdminProductListScreen;
      expect(productListScreen.categoryId, 'cat1');
      expect(productListScreen.categoryDisplayName, 'Инструменты');
    });

  });
}

// Note: Testing the actual call of `_fetchCategories` during `RefreshIndicator.onRefresh`
// is tricky without deeper mocking or refactoring the widget for easier testability
// (e.g., injecting a BLoC/Cubit or a service that handles fetching).
// The current test for RefreshIndicator verifies UI change after refresh,
// assuming the underlying Future is correctly updated and re-fetched.
// The global FirebaseFirestore.instance replacement is a simplified approach for these tests.
// More robust solutions involve dependency injection.
