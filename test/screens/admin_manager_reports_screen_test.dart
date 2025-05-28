import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_app/screens/admin_manager_reports_screen.dart';
import 'package:pos_app/screens/admin_view_manager_report_screen.dart'; // For navigation verification

// --- Manual Mocks (Simplified for this test focus) ---

// Mock FirebaseFirestore
class MockFirebaseFirestore implements FirebaseFirestore {
  final MockCollectionReference<Map<String, dynamic>> mockCollectionReference;

  MockFirebaseFirestore({required this.mockCollectionReference});

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    if (collectionPath == 'users') {
      return mockCollectionReference;
    }
    throw UnimplementedError('Collection "$collectionPath" not mocked');
  }

  // Implement other methods and properties as needed, returning default values or throwing UnimplementedError
  @override late final FirebaseApp app;
  @override void useFirestoreEmulator(String host, int port, {bool sslEnabled = false, bool automaticHostMapping = true}) { }
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

  MockCollectionReference({required this.mockQuery});

  @override
  Query<T> where(Object field, {Object? isEqualTo, Object? isNotEqualTo, Object? isLessThan, Object? isLessThanOrEqualTo, Object? isGreaterThan, Object? isGreaterThanOrEqualTo, Object? arrayContains, List<Object?>? arrayContainsAny, List<Object?>? whereIn, List<Object?>? whereNotIn, bool? isNull}) {
    if (field == 'role' && isEqualTo == 'manager') {
      return mockQuery;
    }
    throw UnimplementedError('Query for field "$field" not mocked');
  }
  // Implement other methods and properties as needed
  @override
  Future<DocumentReference<T>> add(T data) { throw UnimplementedError(); }
  @override
  String get id => 'users';
  @override
  String get path => 'users';
  @override
  DocumentReference<T> doc([String? path]) { throw UnimplementedError(); }
  @override
  DocumentReference<T>? get parent => null;
  @override
  Stream<QuerySnapshot<T>> snapshots({bool includeMetadataChanges = false, ListenSource source = ListenSource.defaultSource}) { throw UnimplementedError(); }
  @override
  Future<QuerySnapshot<T>> get([GetOptions? options]) => mockQuery.get(options);
  @override
  Query<T> limit(int limit) { throw UnimplementedError(); }
  @override
  Query<T> limitToLast(int limit) { throw UnimplementedError(); }
  @override
  Query<T> orderBy(Object field, {bool descending = false}) { throw UnimplementedError(); }
  @override
  Query<T> startAfter(Iterable<Object?> values) { throw UnimplementedError(); }
  @override
  Query<T> startAfterDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override
  Query<T> startAt(Iterable<Object?> values) { throw UnimplementedError(); }
  @override
  Query<T> startAtDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override
  Query<T> endAt(Iterable<Object?> values) { throw UnimplementedError(); }
  @override
  Query<T> endAtDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override
  Query<T> endBefore(Iterable<Object?> values) { throw UnimplementedError(); }
  @override
  Query<T> endBeforeDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override
  CollectionReference<R> withConverter<R extends Object?>({required FromFirestore<R> fromFirestore, required ToFirestore<R> toFirestore}) { throw UnimplementedError(); }
  @override
  Future<bool> snapshotsInSync() { throw UnimplementedError(); }
  @override
  AggregateQuery count() { throw UnimplementedError(); }
  @override
  AggregateQuery aggregate(AggregateField field1, [AggregateField? field2, AggregateField? field3, AggregateField? field4, AggregateField? field5]) { throw UnimplementedError(); }
}

// Mock Query
class MockQuery<T extends Object?> implements Query<T> {
  Future<QuerySnapshot<T>> Function()? mockGet;

  @override
  Future<QuerySnapshot<T>> get([GetOptions? options]) async {
    if (mockGet != null) {
      return mockGet!();
    }
    throw UnimplementedError('get() not mocked for Query');
  }
  // Implement other methods and properties as needed
  @override Query<T> where(Object field, {Object? isEqualTo, Object? isNotEqualTo, Object? isLessThan, Object? isLessThanOrEqualTo, Object? isGreaterThan, Object? isGreaterThanOrEqualTo, Object? arrayContains, List<Object?>? arrayContainsAny, List<Object?>? whereIn, List<Object?>? whereNotIn, bool? isNull}) { return this; }
  @override Query<T> orderBy(Object field, {bool descending = false}) { return this; }
  @override Stream<QuerySnapshot<T>> snapshots({bool includeMetadataChanges = false, ListenSource source = ListenSource.defaultSource}) { throw UnimplementedError(); }
  @override Query<T> limit(int limit) { throw UnimplementedError(); }
  @override Query<T> limitToLast(int limit) { throw UnimplementedError(); }
  @override Query<T> startAfter(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<T> startAfterDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override Query<T> startAt(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<T> startAtDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override Query<T> endAt(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<T> endAtDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override Query<T> endBefore(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<T> endBeforeDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override Query<R> withConverter<R extends Object?>({required FromFirestore<R> fromFirestore, required ToFirestore<R> toFirestore}) { throw UnimplementedError(); }
  @override Future<bool> snapshotsInSync() { throw UnimplementedError(); }
  @override
  AggregateQuery count() { throw UnimplementedError(); }
  @override
  AggregateQuery aggregate(AggregateField field1, [AggregateField? field2, AggregateField? field3, AggregateField? field4, AggregateField? field5]) { throw UnimplementedError(); }
  @override
  FirebaseFirestore get firestore => throw UnimplementedError();
}

// Mock QuerySnapshot
class MockQuerySnapshot<T extends Object?> implements QuerySnapshot<T> {
  @override
  final List<QueryDocumentSnapshot<T>> docs;
  MockQuerySnapshot({required this.docs});

  @override
  List<DocumentChange<T>> get docChanges => throw UnimplementedError();
  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
  @override
  int get size => docs.length;
}

// Mock QueryDocumentSnapshot
class MockQueryDocumentSnapshot<T extends Object?> implements QueryDocumentSnapshot<T> {
  @override
  final String id;
  final T _data;

  MockQueryDocumentSnapshot({required this.id, required T data}) : _data = data;

  @override
  T data() => _data;
  @override
  bool get exists => true;
  @override
  dynamic get(Object field) {
    if (_data is Map) {
      return (_data as Map)[field];
    }
    return null;
  }
  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
  @override
  String get referencePath => 'users/$id';
}

// Mock NavigatorObserver
class MockNavigatorObserver extends NavigatorObserver {
  Route? lastPushedRoute;
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastPushedRoute = route;
  }
}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockCollection = MockCollectionReference<Map<String, dynamic>>(mockQuery: mockQuery);
    mockFirestore = MockFirebaseFirestore(mockCollectionReference: mockCollection);
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminManagerReportsScreen(firestoreInstanceForTest: mockFirestore),
        navigatorObservers: [mockNavigatorObserver],
        // Required for AdminViewManagerReportScreen if it uses routeName
        routes: {
          AdminViewManagerReportScreen.routeName: (context) => const Scaffold(body: Text('Mock Report Screen')),
        },
      ),
    );
  }

  group('AdminManagerReportsScreen Tests', () {
    testWidgets('Loading State - Shows CircularProgressIndicator', (WidgetTester tester) async {
      // Setup mock to delay response
      mockQuery.mockGet = () async {
        await Future.delayed(const Duration(milliseconds: 50)); // Simulate delay
        return MockQuerySnapshot<Map<String, dynamic>>(docs: []);
      };

      await pumpScreen(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget); // Initial state before future completes
      await tester.pumpAndSettle(); // Wait for future to complete
    });

    testWidgets('Displaying Managers - Shows list of managers', (WidgetTester tester) async {
      final managersData = [
        {'name': 'Manager Alice', 'email': 'alice@example.com'},
        {'name': 'Manager Bob', 'email': 'bob@example.com'},
      ];
      final mockDocs = managersData.map((data) => 
        MockQueryDocumentSnapshot<Map<String, dynamic>>(
          id: data['email']!, // Using email as ID for simplicity in test
          data: data
        )
      ).toList();

      mockQuery.mockGet = () async => MockQuerySnapshot<Map<String, dynamic>>(docs: mockDocs);

      await pumpScreen(tester);
      await tester.pumpAndSettle(); // Wait for FutureBuilder

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Manager Alice'), findsOneWidget);
      expect(find.text('alice@example.com'), findsOneWidget);
      expect(find.text('Manager Bob'), findsOneWidget);
      expect(find.text('bob@example.com'), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsNWidgets(managersData.length));
    });

    testWidgets('Empty List - Shows "Менеджеры не найдены."', (WidgetTester tester) async {
      mockQuery.mockGet = () async => MockQuerySnapshot<Map<String, dynamic>>(docs: []);

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Менеджеры не найдены.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Error Handling - Shows error message', (WidgetTester tester) async {
      mockQuery.mockGet = () async => throw FirebaseException(plugin: 'firestore', message: 'Test error');

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Произошла ошибка при загрузке менеджеров.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Navigation to Report Screen - Navigator.push called', (WidgetTester tester) async {
      final managerData = {'name': 'Manager Charlie', 'email': 'charlie@example.com'};
      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>(
        id: 'charlie_id',
        data: managerData
      );
      mockQuery.mockGet = () async => MockQuerySnapshot<Map<String, dynamic>>(docs: [mockDoc]);

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Manager Charlie'), findsOneWidget);
      final reportButton = find.byIcon(Icons.bar_chart);
      expect(reportButton, findsOneWidget);

      await tester.tap(reportButton);
      await tester.pumpAndSettle(); // Allow navigation to process

      expect(mockNavigatorObserver.lastPushedRoute, isNotNull);
      expect(mockNavigatorObserver.lastPushedRoute!.settings.name, isNull); // Navigating by MaterialPageRoute, not named route
      expect(mockNavigatorObserver.lastPushedRoute, isA<MaterialPageRoute>());
      final pushedRoute = mockNavigatorObserver.lastPushedRoute as MaterialPageRoute;
      expect(pushedRoute.builder(GlobalKey<ScaffoldState>().currentContext!), isA<AdminViewManagerReportScreen>());

      // Verify arguments passed to AdminViewManagerReportScreen
      final AdminViewManagerReportScreen reportScreen = pushedRoute.builder(GlobalKey<ScaffoldState>().currentContext!) as AdminViewManagerReportScreen;
      expect(reportScreen.managerId, 'charlie_id');
      expect(reportScreen.managerName, 'Manager Charlie');
    });
  });
}

// Note: The mock setup for Firestore is simplified. 
// A more robust solution might involve a more complete mock implementation 
// or a library like `fake_cloud_firestore`.
// Added a MockNavigatorObserver for testing navigation calls.
// The navigation test verifies that Navigator.push is called and the correct screen type
// with correct arguments is pushed.
// Added `firestore` to MockQuery for completeness of the interface.
// Added `path` to MockCollectionReference.
// Added route for AdminViewManagerReportScreen to MaterialApp for navigation test to work,
// even if we are mostly checking the push action itself and not the destination screen's content.
// Corrected the navigation test to properly extract and check arguments passed to AdminViewManagerReportScreen.The widget test file `test/screens/admin_manager_reports_screen_test.dart` has been created.

Here's a summary of what's included:

1.  **Refactoring Confirmation**: The associated screen `lib/screens/admin_manager_reports_screen.dart` was already refactored in the previous step to accept an optional `FirebaseFirestore? firestoreInstanceForTest` parameter, which is used by these tests.

2.  **Mocks**:
    *   Manual mocks for `FirebaseFirestore`, `CollectionReference`, `Query`, `QuerySnapshot`, and `QueryDocumentSnapshot` are implemented. These are simplified to focus on the `collection('users').where('role', isEqualTo: 'manager').get()` call chain.
    *   A `MockNavigatorObserver` is included to verify navigation events.

3.  **Test Setup**:
    *   `setUp` initializes the mock Firebase instances and the `MockNavigatorObserver`.
    *   A `pumpScreen` helper function wraps `AdminManagerReportsScreen` in a `MaterialApp`, provides the mock Firestore instance, and registers the `MockNavigatorObserver`. It also includes a mock route for `AdminViewManagerReportScreen` to ensure navigation tests can resolve the route if needed (though the primary check is for `Navigator.push`).

4.  **Test Scenarios Implemented**:
    *   **Loading State**:
        *   Verifies that a `CircularProgressIndicator` is displayed while the `FutureBuilder` is waiting for data.
    *   **Displaying Managers**:
        *   Mocks Firestore to return a list of manager documents (id, name, email).
        *   Verifies that a `ListView` is shown.
        *   Verifies that manager names and emails are rendered correctly in `ListTile`s.
        *   Verifies that each `ListTile` has an `IconButton` (using `Icons.bar_chart`).
    *   **Empty List**:
        *   Mocks Firestore to return an empty list.
        *   Verifies that the "Менеджеры не найдены." message is displayed.
    *   **Error Handling**:
        *   Mocks Firestore's `get()` call to throw a `FirebaseException`.
        *   Verifies that the "Произошла ошибка при загрузке менеджеров." error message is displayed.
    *   **Navigation to Report Screen**:
        *   Mocks Firestore to return a single manager.
        *   Taps the "View Report" `IconButton` for that manager.
        *   Uses `MockNavigatorObserver` to verify that `Navigator.push` was called.
        *   Verifies that the pushed route is a `MaterialPageRoute` and its builder creates an `AdminViewManagerReportScreen`.
        *   Crucially, verifies that the `managerId` and `managerName` passed to `AdminViewManagerReportScreen` are correct.

The tests cover the main functionalities of the `AdminManagerReportsScreen`, including its interaction with Firestore (via mocks) and navigation. The mocks are tailored for this screen's specific Firebase query.
