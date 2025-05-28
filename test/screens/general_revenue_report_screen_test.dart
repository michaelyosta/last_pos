import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_app/models/category.dart'; // For creating mock Category data
import 'package:pos_app/screens/general_revenue_report_screen.dart';

// --- Manual Mocks ---

// Mock FirebaseFirestore
class MockFirebaseFirestore implements FirebaseFirestore {
  final MockCollectionReference<Map<String, dynamic>> mockCategoriesCollection;
  final MockCollectionReference<Map<String, dynamic>> mockVehiclesCollection;

  MockFirebaseFirestore({
    required this.mockCategoriesCollection,
    required this.mockVehiclesCollection,
  });

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    if (collectionPath == 'categories') {
      return mockCategoriesCollection;
    }
    if (collectionPath == 'vehicles') {
      return mockVehiclesCollection;
    }
    throw UnimplementedError('Collection "$collectionPath" not mocked. Available: categories, vehicles');
  }

  @override late final FirebaseApp app;
  @override void useFirestoreEmulator(String host, int port, {bool sslEnabled = false, bool automaticHostMapping = true}) {}
  @override Future<void> clearPersistence() { throw UnimplementedError(); }
  @override Future<void> disableNetwork() { throw UnimplementedError(); }
  @override DocumentReference<Map<String, dynamic>> doc(String documentPath) { throw UnimplementedError(); }
  @override Future<void> enableNetwork() { throw UnimplementedError(); }
  @override Stream<void> snapshotsInSync() { throw UnimplementedError(); }
  @override Future<T> runTransaction<T>(TransactionHandler<T> transactionHandler, {Duration timeout = const Duration(seconds: 30), int maxAttempts = 5}) { throw UnimplementedError(); }
  @override Future<void> terminate() { throw UnimplementedError(); }
  @override Future<void> waitForPendingWrites() { throw UnimplementedError(); }
  @override WriteBatch batch() { throw UnimplementedError(); }
  @override LoadBundleTask loadBundle(Stream<List<int>> bundle) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> collectionGroup(String collectionPath) { throw UnimplementedError(); }
  @override Future<QuerySnapshot<Map<String,dynamic>>> namedQueryGet(String name, {GetOptions options = const GetOptions()}) { throw UnimplementedError(); }
  @override void setLoggingEnabled(bool enabled) { }
  @override FirebaseFirestoreSettings get settings { throw UnimplementedError(); }
  @override set settings(FirebaseFirestoreSettings settings) { throw UnimplementedError(); }
  @override Future<void> addSnapshotsInSyncListener(void Function() listener) { throw UnimplementedError(); }
  @override Future<void> removeSnapshotsInSyncListener(void Function() listener) { throw UnimplementedError(); }
}

// Mock CollectionReference
class MockCollectionReference<T extends Object?> implements CollectionReference<T> {
  final MockQuery<T> mockQuery;
  final String collectionId;
  Future<QuerySnapshot<T>> Function()? mockGetDirectly; // For simple .get() calls like on categories

  MockCollectionReference({required this.collectionId, required this.mockQuery, this.mockGetDirectly});

  @override
  Future<QuerySnapshot<T>> get([GetOptions? options]) async {
    if (mockGetDirectly != null) {
      return mockGetDirectly!();
    }
    return mockQuery.get(options);
  }
  
  @override
  Query<T> where(Object field, {Object? isEqualTo, Object? isNotEqualTo, Object? isLessThan, Object? isLessThanOrEqualTo, Object? isGreaterThan, Object? isGreaterThanOrEqualTo, Object? arrayContains, List<Object?>? arrayContainsAny, List<Object?>? whereIn, List<Object?>? whereNotIn, bool? isNull}) {
    // This will be chained, the actual filter application is in MockQuery's get
    return mockQuery..addFilter(field, isEqualTo: isEqualTo, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo, isLessThanOrEqualTo: isLessThanOrEqualTo);
  }

  @override String get id => collectionId;
  @override String get path => collectionId;
  @override Future<DocumentReference<T>> add(T data) { throw UnimplementedError(); }
  @override DocumentReference<T> doc([String? path]) { throw UnimplementedError(); }
  @override DocumentReference<T>? get parent => null;
  @override Stream<QuerySnapshot<T>> snapshots({bool includeMetadataChanges = false, ListenSource source = ListenSource.defaultSource}) { throw UnimplementedError(); }
  @override Query<T> limit(int limit) { return mockQuery; }
  @override Query<T> limitToLast(int limit) { return mockQuery; }
  @override Query<T> orderBy(Object field, {bool descending = false}) { return mockQuery; }
  @override Query<T> startAfter(Iterable<Object?> values) { return mockQuery; }
  @override Query<T> startAfterDocument(DocumentSnapshot documentSnapshot) { return mockQuery; }
  @override Query<T> startAt(Iterable<Object?> values) { return mockQuery; }
  @override Query<T> startAtDocument(DocumentSnapshot documentSnapshot) { return mockQuery; }
  @override Query<T> endAt(Iterable<Object?> values) { return mockQuery; }
  @override Query<T> endAtDocument(DocumentSnapshot documentSnapshot) { return mockQuery; }
  @override Query<T> endBefore(Iterable<Object?> values) { return mockQuery; }
  @override Query<T> endBeforeDocument(DocumentSnapshot documentSnapshot) { return mockQuery; }
  @override CollectionReference<R> withConverter<R extends Object?>({required FromFirestore<R> fromFirestore, required ToFirestore<R> toFirestore}) { throw UnimplementedError(); }
  @override Future<bool> snapshotsInSync() { throw UnimplementedError(); }
  @override AggregateQuery count() { throw UnimplementedError(); }
  @override AggregateQuery aggregate(AggregateField field1, [AggregateField? field2, AggregateField? field3, AggregateField? field4, AggregateField? field5]) { throw UnimplementedError(); }
}

// Mock Query
class MockQuery<T extends Object?> implements Query<T> {
  Future<QuerySnapshot<T>> Function(Map<String, dynamic> filters)? mockGetWithFilters;
  final Map<String, dynamic> _filters = {};

  void addFilter(Object field, {Object? isEqualTo, Object? isGreaterThanOrEqualTo, Object? isLessThanOrEqualTo}) {
    if (field is String) {
      if (isEqualTo != null) _filters[field] = isEqualTo;
      // For simplicity, store range filters with a suffix; real implementation would be more complex
      if (isGreaterThanOrEqualTo != null) _filters['${field}_gte'] = isGreaterThanOrEqualTo;
      if (isLessThanOrEqualTo != null) _filters['${field}_lte'] = isLessThanOrEqualTo;
    }
  }

  @override
  Future<QuerySnapshot<T>> get([GetOptions? options]) async {
    if (mockGetWithFilters != null) {
      return mockGetWithFilters!(_filters);
    }
    throw UnimplementedError('get() not mocked for Query or no mockGetWithFilters provided.');
  }

  @override
  Query<T> where(Object field, {Object? isEqualTo, Object? isNotEqualTo, Object? isLessThan, Object? isLessThanOrEqualTo, Object? isGreaterThan, Object? isGreaterThanOrEqualTo, Object? arrayContains, List<Object?>? arrayContainsAny, List<Object?>? whereIn, List<Object?>? whereNotIn, bool? isNull}) {
    addFilter(field, isEqualTo: isEqualTo, isGreaterThanOrEqualTo: isGreaterThanOrEqualTo, isLessThanOrEqualTo: isLessThanOrEqualTo);
    return this;
  }
  
  @override FirebaseFirestore get firestore => throw UnimplementedError();
  @override Query<T> orderBy(Object field, {bool descending = false}) { return this; }
  @override Stream<QuerySnapshot<T>> snapshots({bool includeMetadataChanges = false, ListenSource source = ListenSource.defaultSource}) { throw UnimplementedError(); }
  @override Query<T> limit(int limit) { return this; }
  @override Query<T> limitToLast(int limit) { return this; }
  @override Query<T> startAfter(Iterable<Object?> values) { return this; }
  @override Query<T> startAfterDocument(DocumentSnapshot documentSnapshot) { return this; }
  @override Query<T> startAt(Iterable<Object?> values) { return this; }
  @override Query<T> startAtDocument(DocumentSnapshot documentSnapshot) { return this; }
  @override Query<T> endAt(Iterable<Object?> values) { return this; }
  @override Query<T> endAtDocument(DocumentSnapshot documentSnapshot) { return this; }
  @override Query<T> endBefore(Iterable<Object?> values) { return this; }
  @override Query<T> endBeforeDocument(DocumentSnapshot documentSnapshot) { return this; }
  @override Query<R> withConverter<R extends Object?>({required FromFirestore<R> fromFirestore, required ToFirestore<R> toFirestore}) { throw UnimplementedError(); }
  @override Future<bool> snapshotsInSync() { throw UnimplementedError(); }
  @override AggregateQuery count() { throw UnimplementedError(); }
  @override AggregateQuery aggregate(AggregateField field1, [AggregateField? field2, AggregateField? field3, AggregateField? field4, AggregateField? field5]) { throw UnimplementedError(); }
}

// Mock QuerySnapshot
class MockQuerySnapshot<T extends Object?> implements QuerySnapshot<T> {
  @override
  final List<QueryDocumentSnapshot<T>> docs;
  MockQuerySnapshot({required this.docs});

  @override List<DocumentChange<T>> get docChanges => throw UnimplementedError();
  @override SnapshotMetadata get metadata => throw UnimplementedError();
  @override int get size => docs.length;
}

// Mock QueryDocumentSnapshot
class MockQueryDocumentSnapshot<T extends Object?> implements QueryDocumentSnapshot<T> {
  @override
  final String id;
  final T _data;

  MockQueryDocumentSnapshot({required this.id, required T data}) : _data = data;

  @override T data() => _data;
  @override bool get exists => true;
  @override dynamic get(Object field) {
    if (_data is Map) { return (_data as Map)[field]; }
    return null;
  }
  @override SnapshotMetadata get metadata => throw UnimplementedError();
  @override String get referencePath => 'test_path/$id';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCategoriesCollection;
  late MockCollectionReference<Map<String, dynamic>> mockVehiclesCollection;
  late MockQuery<Map<String, dynamic>> mockCategoriesQuery;
  late MockQuery<Map<String, dynamic>> mockVehiclesQuery;

  // Test data
  final mockCategoryList = [
    Category(id: 'cat1', name: 'Еда', displayName: 'Еда'),
    Category(id: 'cat2', name: 'Напитки', displayName: 'Напитки'),
  ];
  final mockCategoryDocs = mockCategoryList.map((cat) => 
    MockQueryDocumentSnapshot<Map<String, dynamic>>(id: cat.id, data: cat.toMap())
  ).toList();

  setUp(() {
    mockCategoriesQuery = MockQuery<Map<String, dynamic>>();
    mockVehiclesQuery = MockQuery<Map<String, dynamic>>();
    
    mockCategoriesCollection = MockCollectionReference<Map<String, dynamic>>(
      collectionId: 'categories',
      mockQuery: mockCategoriesQuery,
      mockGetDirectly: () async => MockQuerySnapshot<Map<String, dynamic>>(docs: mockCategoryDocs) // For categories.get()
    );
    mockVehiclesCollection = MockCollectionReference<Map<String, dynamic>>(
      collectionId: 'vehicles',
      mockQuery: mockVehiclesQuery
    );
    mockFirestore = MockFirebaseFirestore(
      mockCategoriesCollection: mockCategoriesCollection,
      mockVehiclesCollection: mockVehiclesCollection,
    );
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GeneralRevenueReportScreen(firestoreInstanceForTest: mockFirestore),
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(), // For SnackBar
      ),
    );
    // Initial pump for category loading in initState
    await tester.pumpAndSettle(); 
  }

  Future<void> selectDates(WidgetTester tester, DateTime startDate, DateTime endDate) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Начальная дата'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(startDate.day.toString()));
    await tester.tap(find.text('Выбрать'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Конечная дата'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(endDate.day.toString()));
    await tester.tap(find.text('Выбрать'));
    await tester.pumpAndSettle();
  }

  String formatDate(DateTime date) => date.toString().substring(0, 10);

  group('GeneralRevenueReportScreen Tests', () {
    testWidgets('1. Initial State - Renders correctly, button disabled', (WidgetTester tester) async {
      await pumpScreen(tester);

      expect(find.widgetWithText(AppBar, 'Общий отчет по выручке'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Начальная дата'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Конечная дата'), findsOneWidget);
      expect(find.text('Не выбрано'), findsNWidgets(2));
      final generateReportButton = find.widgetWithText(ElevatedButton, 'Сформировать отчет');
      expect(generateReportButton, findsOneWidget);
      expect(tester.widget<ElevatedButton>(generateReportButton).enabled, isFalse);
      expect(find.text('Выберите период и сформируйте отчет.'), findsOneWidget);
      expect(find.byType(PieChart), findsNothing); // No pie chart initially
    });

    testWidgets('2. Date Selection - Enables button and displays dates', (WidgetTester tester) async {
      await pumpScreen(tester);
      final DateTime startDate = DateTime(2023, 1, 1);
      final DateTime endDate = DateTime(2023, 1, 10);
      await selectDates(tester, startDate, endDate);

      expect(find.text(formatDate(startDate)), findsOneWidget);
      expect(find.text(formatDate(endDate)), findsOneWidget);
      final generateReportButton = find.widgetWithText(ElevatedButton, 'Сформировать отчет');
      expect(tester.widget<ElevatedButton>(generateReportButton).enabled, isTrue);
    });

    testWidgets('3. Report Generation - Successful Case with PieChart', (WidgetTester tester) async {
      final DateTime startDate = DateTime(2023, 1, 1);
      final DateTime endDate = DateTime(2023, 1, 2);
      final DateTime queryEndDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      final vehicleDocs = [
        MockQueryDocumentSnapshot<Map<String, dynamic>>(id: 'v1', data: {
          'totalAmount': 150.0, 'timeBasedCost': 50.0,
          'status': 'completed', 'orderCompletionTimestamp': Timestamp.fromDate(DateTime(2023,1,1,10)),
          'items': [
            {'productName': 'Pizza', 'quantity': 1, 'price': 80.0, 'categoryId': 'cat1'}, // Еда
            {'productName': 'Coke', 'quantity': 1, 'price': 20.0, 'categoryId': 'cat2'},  // Напитки
          ]
        }),
        MockQueryDocumentSnapshot<Map<String, dynamic>>(id: 'v2', data: {
          'totalAmount': 100.0, 'timeBasedCost': 30.0,
          'status': 'completed', 'orderCompletionTimestamp': Timestamp.fromDate(DateTime(2023,1,2,15)),
          'items': [
            {'productName': 'Burger', 'quantity': 1, 'price': 70.0, 'categoryId': 'cat1'}, // Еда
          ]
        }),
      ];
      // Total Revenue: 250.0, Time-based: 80.0
      // Cat1 (Еда): 80 (Pizza) + 70 (Burger) = 150.0
      // Cat2 (Напитки): 20 (Coke) = 20.0
      // Item Revenue (non-time): 80+20+70 = 170. Total time-based: 50+30 = 80. Total: 170+80=250.

      mockVehiclesQuery.mockGetWithFilters = (filters) async {
        expect(filters['status'], 'completed');
        expect((filters['orderCompletionTimestamp_gte'] as Timestamp).toDate(), startDate);
        expect((filters['orderCompletionTimestamp_lte'] as Timestamp).toDate(), queryEndDate);
        return MockQuerySnapshot<Map<String, dynamic>>(docs: vehicleDocs);
      };
      
      await pumpScreen(tester);
      await selectDates(tester, startDate, endDate);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Сформировать отчет'));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('Период: ${formatDate(startDate)} - ${formatDate(endDate)}'), findsOneWidget);
      expect(find.textContaining('Общая сумма продаж: 250.00 тнг'), findsOneWidget);
      expect(find.text('Количество заказов: 2'), findsOneWidget);
      expect(find.text('Топ товаров:'), findsOneWidget);
      expect(find.widgetWithText(Card, 'Pizza'), findsOneWidget); // Check one top product

      // PieChart Test
      final pieChartFinder = find.byType(PieChart);
      expect(pieChartFinder, findsOneWidget);
      final PieChart pieChartWidget = tester.widget(pieChartFinder);
      final pieChartData = pieChartWidget.data;

      expect(pieChartData.sections.length, 3); // Time, Cat1, Cat2

      // Check Time section
      final timeSection = pieChartData.sections.firstWhere((s) => s.title.startsWith('Время'));
      expect(timeSection.value, 80.0);
      expect(timeSection.title, 'Время\n80');

      // Check Category 1 (Еда) section
      final cat1Section = pieChartData.sections.firstWhere((s) => s.title.startsWith('Еда'));
      expect(cat1Section.value, 150.0);
      expect(cat1Section.title, 'Еда\n150');
      
      // Check Category 2 (Напитки) section
      final cat2Section = pieChartData.sections.firstWhere((s) => s.title.startsWith('Напитки'));
      expect(cat2Section.value, 20.0);
      expect(cat2Section.title, 'Напитки\n20');
    });

    testWidgets('4. No Data - Shows "Нет данных"', (WidgetTester tester) async {
      mockVehiclesQuery.mockGetWithFilters = (filters) async => MockQuerySnapshot<Map<String, dynamic>>(docs: []);
      await pumpScreen(tester);
      await selectDates(tester, DateTime(2023,2,1), DateTime(2023,2,5));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Сформировать отчет'));
      await tester.pumpAndSettle();

      expect(find.text('Нет данных за выбранный период.'), findsOneWidget);
      expect(find.byType(PieChart), findsNothing);
    });

    testWidgets('5. Error Loading Categories - Shows SnackBar and error in chart area', (WidgetTester tester) async {
      mockCategoriesCollection.mockGetDirectly = () async => throw FirebaseException(plugin: 'firestore', message: 'Category load error');
      
      // Re-pump screen to trigger initState category load error
      await tester.pumpWidget(
        MaterialApp(
          home: GeneralRevenueReportScreen(firestoreInstanceForTest: mockFirestore),
          scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        ),
      );
      await tester.pumpAndSettle(); // For SnackBar from initState

      expect(find.text('Ошибка загрузки категорий: FirebaseException: [firestore/Category load error] Category load error'), findsOneWidget);
      
      // Try to generate report, should also fail due to categories
      await selectDates(tester, DateTime(2023,3,1), DateTime(2023,3,5));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Сформировать отчет'));
      await tester.pumpAndSettle(); // For SnackBar from generateReport attempt
      
      // SnackBar might appear twice, once from initState, once from button press
      expect(find.text('Ошибка загрузки категорий: FirebaseException: [firestore/Category load error] Category load error'), findsWidgets);
      expect(find.byType(PieChart), findsNothing);
      // Check if report area shows an error message as well
      expect(find.text('Ошибка загрузки категорий для диаграммы.'), findsOneWidget);
    });

    testWidgets('6. Error Loading Vehicles - Shows SnackBar and error message', (WidgetTester tester) async {
      mockVehiclesQuery.mockGetWithFilters = (filters) async => throw FirebaseException(plugin: 'firestore', message: 'Vehicle load error');
      await pumpScreen(tester);
      await selectDates(tester, DateTime(2023,4,1), DateTime(2023,4,5));
      await tester.tap(find.widgetWithText(ElevatedButton, 'Сформировать отчет'));
      await tester.pumpAndSettle();

      expect(find.text('Ошибка при формировании отчета: FirebaseException: [firestore/Vehicle load error] Vehicle load error'), findsOneWidget); // SnackBar
      expect(find.text('Ошибка: FirebaseException: [firestore/Vehicle load error] Vehicle load error'), findsOneWidget); // Report area
      expect(find.byType(PieChart), findsNothing);
    });
  });
}
// Added TestWidgetsFlutterBinding.ensureInitialized().
// Mock for categories.get() is now mockGetDirectly on MockCollectionReference.
// Mock for vehicles.where().get() is mockGetWithFilters on MockQuery.
// Corrected filter application in MockQuery and MockCollectionReference.
// Updated successful case to check PieChartData sections more thoroughly.
// Ensured category loading error test handles SnackBar from initState and then from button press.
// Added check for error message in chart area for category loading failure.
// Corrected PieChart section checks to use startsWith for titles, as formatting might vary slightly.
// Ensured `pumpScreen` calls `pumpAndSettle` for initial category load.The widget test file `test/screens/general_revenue_report_screen_test.dart` has been created.

Here's a summary of what's included:

1.  **Test File Structure**:
    *   Located at `test/screens/general_revenue_report_screen_test.dart`.
    *   Uses `TestWidgetsFlutterBinding.ensureInitialized()`.

2.  **Mocks**:
    *   **`MockFirebaseFirestore`**: Simulates Firestore, directing calls to `collection('categories')` and `collection('vehicles')` to their respective mock collections.
    *   **`MockCollectionReference`**: Simulates a Firestore collection.
        *   For the 'categories' collection, it uses a `mockGetDirectly` function to immediately return a `MockQuerySnapshot` of category data (as categories are fetched with a simple `.get()`).
        *   For the 'vehicles' collection, it forwards `where` calls to a `MockQuery` instance.
    *   **`MockQuery`**: Simulates Firestore queries.
        *   Its `where` method now correctly chains by adding filters to an internal `_filters` map.
        *   Its `get` method uses a `mockGetWithFilters` function that receives the accumulated filters, allowing tests to verify query parameters and return appropriate `MockQuerySnapshot` for vehicle data.
    *   **`MockQuerySnapshot` and `MockQueryDocumentSnapshot`**: Standard mocks to represent query results and individual documents.

3.  **Test Setup (`setUp`)**:
    *   Initializes `mockCategoriesQuery`, `mockVehiclesQuery`, `mockCategoriesCollection`, `mockVehiclesCollection`, and `mockFirestore` for each test.
    *   Prepares mock category data (`mockCategoryList`, `mockCategoryDocs`) that is used by the `mockCategoriesCollection`.

4.  **Helper Functions**:
    *   **`pumpScreen(WidgetTester tester)`**:
        *   Wraps `GeneralRevenueReportScreen` in a `MaterialApp`.
        *   Provides the `mockFirestore` instance via `firestoreInstanceForTest`.
        *   Includes a `GlobalKey<ScaffoldMessengerState>()` for `SnackBar` testing.
        *   Calls `tester.pumpAndSettle()` after the initial pump to allow for category loading in `initState`.
    *   **`selectDates(WidgetTester tester, DateTime startDate, DateTime endDate)`**: Simulates user interaction with date pickers.
    *   **`formatDate(DateTime date)`**: Utility for consistent date string formatting.

5.  **Test Scenarios Implemented**:

    *   **1. Initial State**:
        *   Verifies AppBar title ("Общий отчет по выручке").
        *   Checks for date selection buttons and "Сформировать отчет" button.
        *   Ensures "Сформировать отчет" is initially disabled.
        *   Confirms the report/chart area shows the initial prompt ("Выберите период...") and no `PieChart`.

    *   **2. Date Selection**:
        *   Uses `selectDates` to pick start and end dates.
        *   Verifies that selected dates are displayed.
        *   Confirms "Сформировать отчет" button becomes enabled.

    *   **3. Successful Report Generation (with PieChart)**:
        *   Sets up `mockVehiclesQuery.mockGetWithFilters` to return mock vehicle data based on expected filters (status, date range).
        *   Simulates date selection and tapping "Сформировать отчет".
        *   Checks for `CircularProgressIndicator`.
        *   Verifies correct display of period, total sales, order count, and at least one top product.
        *   **PieChart Testing**:
            *   Finds the `PieChart` widget.
            *   Extracts `PieChartData`.
            *   Asserts the correct number of sections (Time + categories with revenue).
            *   Verifies the `value` and `title` for the "Время" section and for each category section based on mocked data (e.g., "Еда", "Напитки").

    *   **4. No Data**:
        *   `mockVehiclesQuery.mockGetWithFilters` returns an empty list.
        *   Verifies "Нет данных за выбранный период." message and no `PieChart`.

    *   **5. Error Loading Categories**:
        *   `mockCategoriesCollection.mockGetDirectly` is set to throw a `FirebaseException`.
        *   The screen is re-pumped to trigger `initState` category loading failure.
        *   Verifies `SnackBar` with category error message.
        *   Attempts to generate a report, which should also fail due to missing categories, potentially showing another `SnackBar`.
        *   Checks for an error message in the chart area ("Ошибка загрузки категорий для диаграммы.").

    *   **6. Error Loading Vehicles**:
        *   `mockVehiclesQuery.mockGetWithFilters` throws a `FirebaseException`.
        *   Verifies `SnackBar` with vehicle loading error.
        *   Checks for an error message in the report display area.
        *   Ensures no `PieChart` is displayed.

The tests cover UI interactions, data processing logic (implicitly, by checking outputs), interaction with mocked Firestore (including filter verification), and various states of the report display, including the pie chart data.
