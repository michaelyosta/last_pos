import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart'; // Using mockito for NavigatorObserver
import 'package:pos_app/screens/admin_manager_screen.dart'; // Updated import
import 'package:pos_app/screens/admin_view_manager_report_screen.dart';
import 'package:pos_app/screens/admin_create_manager_screen.dart'; // For FAB navigation

// --- Mocks from the original test file (simplified for brevity if possible, but keeping functionality) ---

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

class MockCollectionReference<T extends Object?> implements CollectionReference<T> {
  final MockQuery<T> mockQuery;
  MockCollectionReference({required this.mockQuery});

  @override
  Query<T> where(Object field, {Object? isEqualTo, Object? isNotEqualTo, Object? isLessThan, Object? isLessThanOrEqualTo, Object? isGreaterThan, Object? isGreaterThanOrEqualTo, Object? arrayContains, List<Object?>? arrayContainsAny, List<Object?>? whereIn, List<Object?>? whereNotIn, bool? isNull}) {
    if (field == 'role' && isEqualTo == 'manager') {
      return mockQuery;
    }
    throw UnimplementedError('Query for field "$field" with isEqualTo "$isEqualTo" not mocked. Field: $field');
  }
  @override Future<DocumentReference<T>> add(T data) { throw UnimplementedError(); }
  @override String get id => 'users';
  @override String get path => 'users';
  @override DocumentReference<T> doc([String? path]) { throw UnimplementedError(); }
  @override DocumentReference<T>? get parent => null;
  @override Stream<QuerySnapshot<T>> snapshots({bool includeMetadataChanges = false, ListenSource source = ListenSource.defaultSource}) { throw UnimplementedError(); }
  @override Future<QuerySnapshot<T>> get([GetOptions? options]) => mockQuery.get(options);
  @override Query<T> limit(int limit) { return mockQuery.limit(limit); } // Delegate to mockQuery
  @override Query<T> limitToLast(int limit) { throw UnimplementedError(); }
  @override Query<T> orderBy(Object field, {bool descending = false}) { return mockQuery.orderBy(field, descending: descending); } // Delegate
  @override Query<T> startAfter(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<T> startAfterDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override Query<T> startAt(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<T> startAtDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override Query<T> endAt(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<T> endAtDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override Query<T> endBefore(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<T> endBeforeDocument(DocumentSnapshot documentSnapshot) { throw UnimplementedError(); }
  @override CollectionReference<R> withConverter<R extends Object?>({required FromFirestore<R> fromFirestore, required ToFirestore<R> toFirestore}) { throw UnimplementedError(); }
  @override Future<bool> snapshotsInSync() { throw UnimplementedError(); }
  @override AggregateQuery count() { throw UnimplementedError(); }
  @override AggregateQuery aggregate(AggregateField field1, [AggregateField? field2, AggregateField? field3, AggregateField? field4, AggregateField? field5]) { throw UnimplementedError(); }
}

class MockQuery<T extends Object?> implements Query<T> {
  Future<QuerySnapshot<T>> Function()? mockGetHandler;
  MockQuery<T> Function(Object, {bool descending})? mockOrderByHandler;
  MockQuery<T> Function(int)? mockLimitHandler;


  @override
  Future<QuerySnapshot<T>> get([GetOptions? options]) async {
    if (mockGetHandler != null) {
      return mockGetHandler!();
    }
    // Return an empty snapshot by default if no specific handler
    return MockQuerySnapshot<T>(docs: []);
  }

  @override
  Query<T> orderBy(Object field, {bool descending = false}) {
    if (mockOrderByHandler != null) {
      return mockOrderByHandler!(field, descending: descending);
    }
    return this; // Default: return self
  }
  
  @override
  Query<T> limit(int limit) {
    if (mockLimitHandler != null) {
      return mockLimitHandler!(limit);
    }
    return this; // Default: return self
  }

  @override Query<T> where(Object field, {Object? isEqualTo, Object? isNotEqualTo, Object? isLessThan, Object? isLessThanOrEqualTo, Object? isGreaterThan, Object? isGreaterThanOrEqualTo, Object? arrayContains, List<Object?>? arrayContainsAny, List<Object?>? whereIn, List<Object?>? whereNotIn, bool? isNull}) { return this; }
  @override Stream<QuerySnapshot<T>> snapshots({bool includeMetadataChanges = false, ListenSource source = ListenSource.defaultSource}) { throw UnimplementedError(); }
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
  @override AggregateQuery count() { throw UnimplementedError(); }
  @override AggregateQuery aggregate(AggregateField field1, [AggregateField? field2, AggregateField? field3, AggregateField? field4, AggregateField? field5]) { throw UnimplementedError(); }
  @override FirebaseFirestore get firestore => throw UnimplementedError();
}

class MockQuerySnapshot<T extends Object?> implements QuerySnapshot<T> {
  @override
  final List<QueryDocumentSnapshot<T>> docs;
  MockQuerySnapshot({required this.docs});

  @override List<DocumentChange<T>> get docChanges => throw UnimplementedError();
  @override SnapshotMetadata get metadata => throw UnimplementedError();
  @override int get size => docs.length;
}

class MockQueryDocumentSnapshot<T extends Object?> implements QueryDocumentSnapshot<T> {
  @override
  final String id;
  final T _data;

  MockQueryDocumentSnapshot({required this.id, required T data}) : _data = data;

  @override T data() => _data;
  @override bool get exists => true;
  @override dynamic get(Object field) {
    if (_data is Map) {
      return (_data as Map)[field];
    }
    return null;
  }
  @override SnapshotMetadata get metadata => throw UnimplementedError();
  @override String get referencePath => 'users/$id'; // Corrected: Added referencePath
}

// Mock NavigatorObserver using mockito
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

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

    // Default behavior for mockQuery.get() to return an empty list
    mockQuery.mockGetHandler = () async => MockQuerySnapshot<Map<String, dynamic>>(docs: []);
    // Default behavior for orderBy and limit to return the same mockQuery instance
    mockQuery.mockOrderByHandler = (field, {descending = false}) => mockQuery;
    mockQuery.mockLimitHandler = (limit) => mockQuery;
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminManagerScreen(firestoreInstanceForTest: mockFirestore), // Updated class name
        navigatorObservers: [mockNavigatorObserver],
        routes: { // Define routes for expected navigation targets
          AdminViewManagerReportScreen.routeName: (context) => const Scaffold(body: Text('Mock View Report Screen')),
          AdminCreateManagerScreen.routeName: (context) => const Scaffold(body: Text('Mock Create Manager Screen')),
        },
      ),
    );
  }

  group('AdminManagerScreen Tests', () {
    testWidgets('Screen title is "Управление Менеджерами"', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.text('Управление Менеджерами'), findsOneWidget);
    });

    testWidgets('FloatingActionButton is present', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Tapping FloatingActionButton navigates to AdminCreateManagerScreen', (WidgetTester tester) async {
      await pumpScreen(tester);
      
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
      expect(find.byType(AdminCreateManagerScreen), findsOneWidget); // Check if the screen is pushed
    });

    testWidgets('Loading State - Shows CircularProgressIndicator', (WidgetTester tester) async {
      mockQuery.mockGetHandler = () async {
        await Future.delayed(const Duration(milliseconds: 50));
        return MockQuerySnapshot<Map<String, dynamic>>(docs: []);
      };

      await pumpScreen(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('Displaying Managers - Shows list of managers', (WidgetTester tester) async {
      final managersData = [
        {'name': 'Manager Alice', 'email': 'alice@example.com'},
        {'name': 'Manager Bob', 'email': 'bob@example.com'},
      ];
      final mockDocs = managersData.map((data) =>
        MockQueryDocumentSnapshot<Map<String, dynamic>>(id: data['email']!, data: data)
      ).toList();

      mockQuery.mockGetHandler = () async => MockQuerySnapshot<Map<String, dynamic>>(docs: mockDocs);

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Manager Alice'), findsOneWidget);
      expect(find.text('Manager Bob'), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsNWidgets(managersData.length));
    });

    testWidgets('Empty List - Shows "Менеджеры не найдены."', (WidgetTester tester) async {
      // mockQuery.mockGetHandler is already set to return empty list in setUp
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Менеджеры не найдены.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Error Handling - Shows error message', (WidgetTester tester) async {
      mockQuery.mockGetHandler = () async => throw FirebaseException(plugin: 'firestore', message: 'Test error');

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Произошла ошибка при загрузке менеджеров.'), findsOneWidget);
    });

    testWidgets('Tapping manager item navigates to AdminViewManagerReportScreen', (WidgetTester tester) async {
      final managerData = {'name': 'Manager Charlie', 'email': 'charlie@example.com'};
      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>(id: 'charlie_id', data: managerData);
      mockQuery.mockGetHandler = () async => MockQuerySnapshot<Map<String, dynamic>>(docs: [mockDoc]);

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      final reportButton = find.byIcon(Icons.bar_chart);
      expect(reportButton, findsOneWidget);

      await tester.tap(reportButton);
      await tester.pumpAndSettle();

      verify(mockNavigatorObserver.didPush(any, any));
      // Check if AdminViewManagerReportScreen is pushed by verifying its unique content or type
      expect(find.byType(AdminViewManagerReportScreen), findsOneWidget);
    });
  });
}
