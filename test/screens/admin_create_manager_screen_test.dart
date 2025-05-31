import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_app/screens/admin_create_manager_screen.dart';

// --- Mocks (from existing file, slightly adapted for clarity and needs) ---

class MockFirebaseAuth implements FirebaseAuth {
  MockUser? mockUser;
  String? lastEmailUsed;
  String? lastPasswordUsed;
  Future<UserCredential> Function({required String email, required String password})? mockCreateUserFunction;

  MockFirebaseAuth({this.mockUser});

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    lastEmailUsed = email;
    lastPasswordUsed = password;
    if (mockCreateUserFunction != null) {
      return mockCreateUserFunction!(email: email, password: password);
    }
    if (mockUser != null) {
      return MockUserCredential(user: mockUser!);
    }
    throw FirebaseAuthException(code: 'test-error-auth', message: 'Default mock auth error');
  }

  @override User? get currentUser => mockUser;
  @override Future<void> signOut() async {}
  @override Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) { throw UnimplementedError(); }
  @override late final FirebaseApp app;
  @override Future<void> applyActionCode(String code) { throw UnimplementedError(); }
  @override Future<ActionCodeInfo> checkActionCode(String code) { throw UnimplementedError(); }
  @override Future<void> confirmPasswordReset({required String code, required String newPassword}) { throw UnimplementedError(); }
  @override Future<List<String>> fetchSignInMethodsForEmail(String email) { throw UnimplementedError(); }
  @override Future<UserCredential> getRedirectResult() { throw UnimplementedError(); }
  @override bool isSignInWithEmailLink(String emailLink) { throw UnimplementedError(); }
  @override Stream<User?> authStateChanges() { throw UnimplementedError(); }
  @override Stream<User?> idTokenChanges() { throw UnimplementedError(); }
  @override Stream<User?> userChanges() { throw UnimplementedError(); }
  @override Future<void> sendPasswordResetEmail({required String email, ActionCodeSettings? actionCodeSettings}) { throw UnimplementedError(); }
  @override Future<void> sendSignInLinkToEmail({required String email, required ActionCodeSettings actionCodeSettings}) { throw UnimplementedError(); }
  @override Future<void> setLanguageCode(String? languageCode) { throw UnimplementedError(); }
  @override Future<void> setPersistence(Persistence persistence) { throw UnimplementedError(); }
  @override Future<void> setSettings({bool? appVerificationDisabledForTesting, String? userAccessGroup, String? phoneNumber, RecaptchaVerifier? recaptchaVerifier}) { throw UnimplementedError(); }
  @override Future<UserCredential> signInAnonymously() { throw UnimplementedError(); }
  @override Future<UserCredential> signInWithCredential(AuthCredential credential) { throw UnimplementedError(); }
  @override Future<UserCredential> signInWithCustomToken(String token) { throw UnimplementedError(); }
  @override Future<UserCredential> signInWithPopup(AuthProvider provider) { throw UnimplementedError(); }
  @override Future<void> signInWithRedirect(AuthProvider provider) { throw UnimplementedError(); }
  @override Future<UserCredential> signInWithEmailLink({required String email, required String emailLink}) { throw UnimplementedError(); }
  @override Future<String> verifyPasswordResetCode(String code) { throw UnimplementedError(); }
  @override Future<void> verifyPhoneNumber({String? phoneNumber, PhoneVerificationCompleted? verificationCompleted, PhoneVerificationFailed? verificationFailed, PhoneCodeSent? codeSent, PhoneCodeAutoRetrievalTimeout? codeAutoRetrievalTimeout, String? autoRetrievedSmsCodeForTesting, Duration timeout = const Duration(seconds: 30), int? forceResendingToken, RecaptchaVerifier? verifier}) { throw UnimplementedError(); }
  @override Future<void> useAuthEmulator(String host, int port, {bool? automaticHostMapping}) { throw UnimplementedError(); }
  @override Future<UserCredential> linkWithCredential(AuthCredential credential) { throw UnimplementedError(); }
  @override Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) { throw UnimplementedError(); }
  @override Future<ConfirmationResult> signInWithPhoneNumber(String phoneNumber, {RecaptchaVerifier? verifier}) { throw UnimplementedError(); }
  @override Future<void> updateCurrentUser(User user) { throw UnimplementedError(); }
}

class MockUser implements User {
  @override final String uid;
  MockUser({this.uid = 'test_uid'});

  @override bool get emailVerified => true;
  @override bool get isAnonymous => false;
  @override UserMetadata get metadata => MockUserMetadata();
  @override List<UserInfo> get providerData => [];
  @override Future<void> delete() async {}
  @override Future<String> getIdToken([bool forceRefresh = false]) async => 'test_token';
  @override Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) async => MockIdTokenResult();
  @override Future<UserCredential> linkWithCredential(AuthCredential credential) { throw UnimplementedError(); }
  @override Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) { throw UnimplementedError(); }
  @override Future<void> reload() async {}
  @override Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) async {}
  @override Future<User> unlink(String providerId) { throw UnimplementedError(); }
  @override Future<void> updateDisplayName(String? displayName) async {}
  @override Future<void> updateEmail(String newEmail) async {}
  @override Future<void> updatePassword(String newPassword) async {}
  @override Future<void> updatePhoneNumber(PhoneAuthCredential credential) { throw UnimplementedError(); }
  @override Future<void> updatePhotoURL(String? photoURL) async {}
  @override Future<void> updateProfile({String? displayName, String? photoURL}) async {}
  @override String? get displayName => 'Test User';
  @override String? get email => 'test@example.com'; // Default, will be manager_XXXXXX@example.com in practice
  @override String? get photoURL => null;
  @override String? get phoneNumber => null;
  @override String? get tenantId => null;
  @override Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) { throw UnimplementedError(); }
  @override MultiFactor get multiFactor => MockMultiFactor();
}

class MockUserMetadata implements UserMetadata {
  @override int get creationTime => DateTime.now().millisecondsSinceEpoch;
  @override int get lastSignInTime => DateTime.now().millisecondsSinceEpoch;
}

class MockIdTokenResult implements IdTokenResult {
  @override Map<String, dynamic> get claims => {};
  @override String? get token => 'test_id_token';
  @override DateTime? get expirationTime => DateTime.now().add(const Duration(hours: 1));
  @override DateTime? get authTime => DateTime.now();
  @override String? get signInProvider => 'email';
  @override DateTime? get issuedAtTime => DateTime.now();
  @override String? get signInSecondFactor => null;
}


class MockUserCredential implements UserCredential {
  @override final User user;
  MockUserCredential({required this.user});
  @override AuthCredential? get credential => null;
  @override UserAdditionalInfo? get additionalUserInfo => null;
}

class MockFirebaseFirestore implements FirebaseFirestore {
  Map<String, dynamic>? lastSetData;
  String? lastSetDocumentPath;
  Function(Map<String, dynamic> data, String docId)? onSetData;


  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return MockCollectionReference(this, collectionPath);
  }

  @override DocumentReference<Map<String, dynamic>> doc(String documentPath) {
    // Simplified: just capture path for verification in set
    lastSetDocumentPath = documentPath;
    return MockDocumentReference(this, documentPath.split('/').last, collectionPath: documentPath.split('/').first);
  }

  // Store data passed to set, used by MockDocumentReference
  void recordSet(Map<String,dynamic> data, String path) {
    lastSetData = data;
    lastSetDocumentPath = path; // path here is like 'users/UID'
    if (onSetData != null) {
      onSetData!(data, path.split('/').last);
    }
  }

  @override late final FirebaseApp app;
  @override void useFirestoreEmulator(String host, int port, {bool sslEnabled = false, bool automaticHostMapping = true}) { }
  @override Future<void> clearPersistence() { throw UnimplementedError(); }
  @override Future<void> disableNetwork() { throw UnimplementedError(); }
  @override Future<void> enableNetwork() { throw UnimplementedError(); }
  @override Stream<void> snapshotsInSync() { throw UnimplementedError(); }
  @override Future<T> runTransaction<T>(TransactionHandler<T> transactionHandler, {Duration timeout = const Duration(seconds: 30), int maxAttempts = 5}) { throw UnimplementedError(); }
  @override Future<void> terminate() { throw UnimplementedError(); }
  @override Future<void> waitForPendingWrites() { throw UnimplementedError(); }
  @override WriteBatch batch() => MockWriteBatch(this);
  @override LoadBundleTask loadBundle(Stream<List<int>> bundle) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> collectionGroup(String collectionPath) { throw UnimplementedError(); }
  @override Future<QuerySnapshot<Map<String,dynamic>>> namedQueryGet(String name, {GetOptions options = const GetOptions()}) { throw UnimplementedError(); }
  @override void setLoggingEnabled(bool enabled) { }
  @override FirebaseFirestoreSettings get settings { throw UnimplementedError(); }
  @override set settings(FirebaseFirestoreSettings settings) { throw UnimplementedError(); }
  @override Future<void> addSnapshotsInSyncListener(void Function() listener) { throw UnimplementedError(); }
  @override Future<void> removeSnapshotsInSyncListener(void Function() listener) { throw UnimplementedError(); }
}

class MockCollectionReference<T extends Object?> implements CollectionReference<Map<String, dynamic>> {
  final MockFirebaseFirestore firestore;
  final String collectionPath;
  MockCollectionReference(this.firestore, this.collectionPath);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final docId = path ?? 'test_doc_${DateTime.now().millisecondsSinceEpoch}';
    return MockDocumentReference(firestore, docId, collectionPath: collectionPath);
  }
  @override Future<DocumentReference<Map<String, dynamic>>> add(Map<String, dynamic> data) { throw UnimplementedError(); }
  @override String get id => collectionPath;
  @override String get path => collectionPath;
  @override DocumentReference<Map<String, dynamic>>? get parent => null;
  @override Stream<QuerySnapshot<Map<String, dynamic>>> snapshots({bool includeMetadataChanges = false, ListenSource source = ListenSource.defaultSource}) { throw UnimplementedError(); }
  @override Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> limit(int limit) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> where(Object field, {Object? isEqualTo, Object? isNotEqualTo, Object? isLessThan, Object? isLessThanOrEqualTo, Object? isGreaterThan, Object? isGreaterThanOrEqualTo, Object? arrayContains, List<Object?>? arrayContainsAny, List<Object?>? whereIn, List<Object?>? whereNotIn, bool? isNull}) { return this; }
  @override Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) { return this; }
  @override CollectionReference<R> withConverter<R extends Object?>({required FromFirestore<R> fromFirestore, required ToFirestore<R> toFirestore}) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> endAt(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> endAtDocument(DocumentSnapshot<Object?> documentSnapshot) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> endBefore(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> endBeforeDocument(DocumentSnapshot<Object?> documentSnapshot) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> limitToLast(int limit) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> startAfter(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> startAfterDocument(DocumentSnapshot<Object?> documentSnapshot) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> startAt(Iterable<Object?> values) { throw UnimplementedError(); }
  @override Query<Map<String, dynamic>> startAtDocument(DocumentSnapshot<Object?> documentSnapshot) { throw UnimplementedError(); }
  @override Future<bool> snapshotsInSync() { throw UnimplementedError(); }
  @override AggregateQuery count() { throw UnimplementedError(); }
  @override AggregateQuery aggregate(AggregateField field1, [AggregateField? field2, AggregateField? field3, AggregateField? field4, AggregateField? field5]) { throw UnimplementedError(); }
}

class MockDocumentReference<T extends Object?> implements DocumentReference<T> {
  final MockFirebaseFirestore firestore;
  @override final String id;
  final String collectionPath;

  MockDocumentReference(this.firestore, this.id, {required this.collectionPath});

  String get path => '$collectionPath/$id';

  @override
  Future<void> set(T data, [SetOptions? options]) async {
    firestore.recordSet(data as Map<String,dynamic>, path);
  }
  @override CollectionReference<T> get parent => MockCollectionReference(firestore, collectionPath) as CollectionReference<T>; // Simplified
  @override Future<void> update(Map<Object, Object?> data) { throw UnimplementedError(); }
  @override Future<void> delete() { throw UnimplementedError(); }
  @override Future<DocumentSnapshot<T>> get([GetOptions? options]) async => MockDocumentSnapshot<T>(id, null); // Data not stored in this mock for get
  @override Stream<DocumentSnapshot<T>> snapshots({bool includeMetadataChanges = false, ListenSource source = ListenSource.defaultSource}) { throw UnimplementedError(); }
  @override DocumentReference<R> withConverter<R extends Object?>({required FromFirestore<R> fromFirestore, required ToFirestore<R> toFirestore}) { throw UnimplementedError(); }
}

class MockDocumentSnapshot<T extends Object?> implements DocumentSnapshot<T> {
  @override final String id;
  final T? _data;
  MockDocumentSnapshot(this.id, this._data);
  @override T? data() => _data;
  @override bool get exists => _data != null;
  @override SnapshotMetadata get metadata => MockSnapshotMetadata();
  @override dynamic get(Object field) { if (_data is Map) { return (_data as Map)[field]; } return null; }
  @override String get referencePath => 'test_path/$id';
}

class MockSnapshotMetadata implements SnapshotMetadata {
  @override bool get hasPendingWrites => false;
  @override bool get isFromCache => false;
}

class MockWriteBatch implements WriteBatch {
  final MockFirebaseFirestore firestore;
  MockWriteBatch(this.firestore);
  @override Future<void> commit() async {}
  @override void delete(DocumentReference<Object?> document) {}
  @override void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) {
    firestore.recordSet(data as Map<String,dynamic>, document.path);
  }
  @override void update(DocumentReference<Object?> document, Map<String, dynamic> data) {}
}

class MockMultiFactor implements MultiFactor {
  @override Future<void> enroll(MultiFactorAssertion multiFactorAssertion, {String? displayName}) { throw UnimplementedError(); }
  @override Future<MultiFactorSession> getSession() { throw UnimplementedError(); }
  @override List<MultiFactorInfo> get enrolledFactors => [];
  @override Future<void> unenroll(String factorUid) { throw UnimplementedError(); }
}


void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;

  setUp(() {
    mockUser = MockUser(uid: 'new_manager_uid_123');
    mockAuth = MockFirebaseAuth(mockUser: mockUser);
    mockFirestore = MockFirebaseFirestore();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminCreateManagerScreen(
          firebaseAuthInstanceForTest: mockAuth,
          firebaseFirestoreInstanceForTest: mockFirestore,
        ),
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(), // For SnackBar testing
      ),
    );
  }

  group('AdminCreateManagerScreen New Tests', () {
    testWidgets('Initial UI elements are correct', (WidgetTester tester) async {
      await pumpScreen(tester);

      expect(find.widgetWithText(AppBar, 'Создать Менеджера'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Имя'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Номер Менеджера (6 цифр)'), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Пароль'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Сгенерировать номер'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Создать Менеджера'), findsOneWidget);

      // Verify "Номер Менеджера" is read-only
      final managerNumberField = tester.widget<TextFormField>(
        find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Номер Менеджера (6 цифр)')
      );
      expect(managerNumberField.readOnly, isTrue);
    });

    testWidgets('Tapping "Сгенерировать номер" populates field with 6 digits', (WidgetTester tester) async {
      await pumpScreen(tester);

      final generateButton = find.widgetWithText(ElevatedButton, 'Сгенерировать номер');
      await tester.tap(generateButton);
      await tester.pump(); // Rebuild after state change

      final managerNumberField = tester.widget<TextFormField>(
        find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Номер Менеджера (6 цифр)')
      );
      expect(managerNumberField.controller?.text.length, 6);
      expect(RegExp(r'^\d{6}$').hasMatch(managerNumberField.controller!.text), isTrue);
    });

    group('Form Validation (New)', () {
      testWidgets('Empty name shows error', (WidgetTester tester) async {
        await pumpScreen(tester);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();
        expect(find.text('Пожалуйста, введите имя'), findsOneWidget);
      });

      testWidgets('Submitting without generating number shows error', (WidgetTester tester) async {
        await pumpScreen(tester);
        await tester.enterText(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Имя'), 'Test Name');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();
        expect(find.text('Пожалуйста, сгенерируйте номер менеджера'), findsOneWidget);
      });

      testWidgets('Generated number with less than 6 digits (if possible by error) shows error', (WidgetTester tester) async {
        await pumpScreen(tester);
        await tester.enterText(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Имя'), 'Test Name');
        // Manually set an invalid number (though UI doesn't allow this directly)
        final managerNumberController = tester.widget<TextFormField>(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Номер Менеджера (6 цифр)')).controller!;
        managerNumberController.text = "123";

        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();
        expect(find.text('Номер менеджера должен состоять из 6 цифр'), findsOneWidget);
      });


      testWidgets('Empty password shows error', (WidgetTester tester) async {
        await pumpScreen(tester);
        await tester.enterText(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Имя'), 'Test Name');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Сгенерировать номер'));
        await tester.pump();
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();
        expect(find.text('Пожалуйста, введите пароль'), findsOneWidget);
      });
    });

    testWidgets('Successful Manager Creation (New)', (WidgetTester tester) async {
      const managerName = 'New Manager Dave';
      const managerPassword = 'securePassword123';
      String? generatedManagerNumber;

      mockAuth.mockCreateUserFunction = ({required String email, required String password}) async {
        expect(email, startsWith('manager_'));
        expect(email, endsWith('@example.com'));
        expect(email.length, 'manager_'.length + 6 + '@example.com'.length);
        expect(password, managerPassword);
        return MockUserCredential(user: mockUser);
      };

      mockFirestore.onSetData = (data, docId) {
        expect(docId, mockUser.uid);
        expect(data['name'], managerName);
        expect(data['managerNumber'], generatedManagerNumber);
        expect(data['email'], 'manager_${generatedManagerNumber}@example.com');
        expect(data['role'], 'manager');
        expect(data['createdAt'], isA<Timestamp>());
      };
      
      await pumpScreen(tester);

      // Fill name
      await tester.enterText(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Имя'), managerName);

      // Generate number
      await tester.tap(find.widgetWithText(ElevatedButton, 'Сгенерировать номер'));
      await tester.pump();
      final managerNumberField = tester.widget<TextFormField>(
        find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Номер Менеджера (6 цифр)')
      );
      generatedManagerNumber = managerNumberField.controller?.text;
      expect(generatedManagerNumber, isNotNull);
      expect(generatedManagerNumber?.length, 6);

      // Fill password
      await tester.enterText(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Пароль'), managerPassword);

      // Create manager
      await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
      await tester.pumpAndSettle(); // For SnackBar and async operations

      // Verify calls (done in mock callbacks)
      expect(mockAuth.lastEmailUsed, 'manager_${generatedManagerNumber}@example.com');
      expect(mockAuth.lastPasswordUsed, managerPassword);
      expect(mockFirestore.lastSetData, isNotNull);
      expect(mockFirestore.lastSetDocumentPath, 'users/${mockUser.uid}');


      // Verify fields are cleared
      expect(tester.widget<TextFormField>(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Имя')).controller!.text, isEmpty);
      expect(tester.widget<TextFormField>(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Номер Менеджера (6 цифр)')).controller!.text, isEmpty);
      expect(tester.widget<TextFormField>(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Пароль')).controller!.text, isEmpty);

      // Verify success SnackBar
      expect(find.text('Менеджер успешно создан.'), findsOneWidget);
    });

    testWidgets('Handles email-already-in-use for generated email', (WidgetTester tester) async {
      mockAuth.mockCreateUserFunction = ({required String email, required String password}) async {
        throw FirebaseAuthException(code: 'email-already-in-use');
      };

      await pumpScreen(tester);
      await tester.enterText(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Имя'), 'Test User');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Сгенерировать номер'));
      await tester.pump();
      await tester.enterText(find.byWidgetPredicate((w) => w is TextFormField && w.decoration?.labelText == 'Пароль'), 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
      await tester.pumpAndSettle();

      expect(find.text('Аккаунт с таким email уже существует.'), findsOneWidget);
    });
  });
}
