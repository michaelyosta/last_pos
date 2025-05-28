import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_app/screens/admin_create_manager_screen.dart'; // Make sure this path is correct

// --- Manual Mocks ---

// Mock FirebaseAuth
class MockFirebaseAuth implements FirebaseAuth {
  final MockUser? mockUser;
  String? lastEmail;
  String? lastPassword;
  Function? mockCreateUserWithEmailAndPassword;

  MockFirebaseAuth({this.mockUser});

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;
    if (mockCreateUserWithEmailAndPassword != null) {
      return mockCreateUserWithEmailAndPassword!(email: email, password: password);
    }
    if (mockUser != null) {
      return MockUserCredential(user: mockUser!);
    }
    throw FirebaseAuthException(code: 'test-error', message: 'Default mock error in createUserWithEmailAndPassword');
  }

  // Implement other methods and properties as needed, returning default values or throwing UnimplementedError
  @override
  User? get currentUser => mockUser;
  @override
  Future<void> signOut() async {}
  @override
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) {
    throw UnimplementedError();
  }
  // Add all other required overrides from FirebaseAuth with default implementations or UnimplementedError
  @override
  late final FirebaseApp app;
  @override
  Future<void> applyActionCode(String code) { throw UnimplementedError(); }
  @override
  Future<ActionCodeInfo> checkActionCode(String code) { throw UnimplementedError(); }
  @override
  Future<void> confirmPasswordReset({required String code, required String newPassword}) { throw UnimplementedError(); }
  @override
  Future<UserCredential> createUserWithPhoneNumber(String phoneNumber, RecaptchaVerifier verifier) { throw UnimplementedError(); }
  @override
  Future<List<String>> fetchSignInMethodsForEmail(String email) { throw UnimplementedError(); }
  @override
  Future<UserCredential> getRedirectResult() { throw UnimplementedError(); }
  @override
  bool isSignInWithEmailLink(String emailLink) { throw UnimplementedError(); }
  @override
  Stream<User?> authStateChanges() { throw UnimplementedError(); }
  @override
  Stream<User?> idTokenChanges() { throw UnimplementedError(); }
  @override
  Stream<User?> userChanges() { throw UnimplementedError(); }
  @override
  Future<void> sendPasswordResetEmail({required String email, ActionCodeSettings? actionCodeSettings}) { throw UnimplementedError(); }
  @override
  Future<void> sendSignInLinkToEmail({required String email, required ActionCodeSettings actionCodeSettings}) { throw UnimplementedError(); }
  @override
  Future<void> setLanguageCode(String? languageCode) { throw UnimplementedError(); }
  @override
  Future<void> setPersistence(Persistence persistence) { throw UnimplementedError(); }
  @override
  Future<void> setSettings({bool? appVerificationDisabledForTesting, String? userAccessGroup, String? phoneNumber, RecaptchaVerifier? recaptchaVerifier}) { throw UnimplementedError(); }
  @override
  Future<UserCredential> signInAnonymously() { throw UnimplementedError(); }
  @override
  Future<UserCredential> signInWithAuthProvider(AuthProvider provider) { throw UnimplementedError(); }
  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) { throw UnimplementedError(); }
  @override
  Future<UserCredential> signInWithCustomToken(String token) { throw UnimplementedError(); }
  @override
  Future<UserCredential> signInWithPhoneNumber(String phoneNumber, RecaptchaVerifier verifier) { throw UnimplementedError(); }
  @override
  Future<UserCredential> signInWithPopup(AuthProvider provider) { throw UnimplementedError(); }
  @override
  Future<UserCredential> signInWithProvider(AuthProvider provider) { throw UnimplementedError(); }
  @override
  Future<void> signInWithRedirect(AuthProvider provider) { throw UnimplementedError(); }
  @override
  Future<UserCredential> signInWithEmailLink({required String email, required String emailLink}) { throw UnimplementedError(); }
  @override
  Future<void> updateCurrentUser(User user) { throw UnimplementedError(); }
  @override
  Future<String> verifyPasswordResetCode(String code) { throw UnimplementedError(); }
  @override
  Future<void> verifyPhoneNumber({String? phoneNumber, PhoneVerificationCompleted? verificationCompleted, PhoneVerificationFailed? verificationFailed, PhoneCodeSent? codeSent, PhoneCodeAutoRetrievalTimeout? codeAutoRetrievalTimeout, String? autoRetrievedSmsCodeForTesting, Duration timeout = const Duration(seconds: 30), int? forceResendingToken, RecaptchaVerifier? verifier}) { throw UnimplementedError(); }
  @override
  Future<void> useAuthEmulator(String host, int port, {bool? automaticHostMapping}) { throw UnimplementedError(); }
   @override
  Future<void> sendPasswordResetEmailVerification(String email, ActionCodeSettings actionCodeSettings) {
    throw UnimplementedError();
  }
  @override
  Future<void> sendSmsCode({required String phoneNumber, RecaptchaVerifier? verifier}) {
    throw UnimplementedError();
  }
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) {
    throw UnimplementedError();
  }
  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) {
    throw UnimplementedError();
  }
  @override
  Future<ConfirmationResult> signInWithPhoneNumberAndRecaptchaVerifier(
      String phoneNumber, RecaptchaVerifier verifier) {
    throw UnimplementedError();
  }
  @override
  Future<void> verifyPhoneNumberWithSmsRetriever({
    required String phoneNumber,
    required PhoneVerificationCompleted verificationCompleted,
    required PhoneVerificationFailed verificationFailed,
    required PhoneCodeSent codeSent,
    required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) {
    throw UnimplementedError();
  }
}

// Mock User
class MockUser implements User {
  final String _uid;
  MockUser({String uid = 'test_uid'}) : _uid = uid;

  @override
  String get uid => _uid;

  // Implement other User properties and methods as needed, returning default values or throwing UnimplementedError
  @override
  bool get emailVerified => true;
  @override
  bool get isAnonymous => false;
  @override
  UserMetadata get metadata => MockUserMetadata();
  @override
  List<UserInfo> get providerData => [];
  @override
  Future<void> delete() { throw UnimplementedError(); }
  @override
  Future<String> getIdToken([bool forceRefresh = false]) { throw UnimplementedError(); }
  @override
  Future<IdTokenResult> getIdTokenResult([bool forceRefresh = false]) { throw UnimplementedError(); }
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) { throw UnimplementedError(); }
  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) { throw UnimplementedError(); }
  @override
  Future<void> reload() { throw UnimplementedError(); }
  @override
  Future<void> sendEmailVerification([ActionCodeSettings? actionCodeSettings]) { throw UnimplementedError(); }
  @override
  Future<User> unlink(String providerId) { throw UnimplementedError(); }
  @override
  Future<void> updateDisplayName(String? displayName) { throw UnimplementedError(); }
  @override
  Future<void> updateEmail(String newEmail) { throw UnimplementedError(); }
  @override
  Future<void> updatePassword(String newPassword) { throw UnimplementedError(); }
  @override
  Future<void> updatePhoneNumber(PhoneAuthCredential credential) { throw UnimplementedError(); }
  @override
  Future<void> updatePhotoURL(String? photoURL) { throw UnimplementedError(); }
  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) { throw UnimplementedError(); }
  @override
  String? get displayName => 'Test User';
  @override
  String? get email => 'test@example.com';
  @override
  String? get photoURL => null;
  @override
  String? get phoneNumber => null;
  @override
  String? get tenantId => null;
  @override
  Future<void> verifyBeforeUpdateEmail(String newEmail, [ActionCodeSettings? actionCodeSettings]) {
    throw UnimplementedError();
  }
  @override
  MultiFactor get multiFactor => throw UnimplementedError();
}

class MockUserMetadata implements UserMetadata {
 @override
 int get creationTime => DateTime.now().millisecondsSinceEpoch;
 @override
 int get lastSignInTime => DateTime.now().millisecondsSinceEpoch;
}

// Mock UserCredential
class MockUserCredential implements UserCredential {
  @override
  final User user;
  MockUserCredential({required this.user});

  @override
  AuthCredential? get credential => null;
  @override
  List<UserInfo> get additionalUserInfo => [];
}

// Mock FirebaseFirestore
class MockFirebaseFirestore implements FirebaseFirestore {
  final Map<String, MockCollectionReference> collections = {};
  Function? mockCollectionSet;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    if (!collections.containsKey(collectionPath)) {
      collections[collectionPath] = MockCollectionReference(collectionPath, mockCollectionSetCallback: (data, docId) {
        if (mockCollectionSet != null) {
          mockCollectionSet!(data, docId);
        }
      });
    }
    return collections[collectionPath]!;
  }
  // Implement other methods and properties as needed
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
class MockCollectionReference<T extends Object?> implements CollectionReference<Map<String, dynamic>> {
  final String path;
  final Map<String, MockDocumentReference<Map<String, dynamic>>> documents = {};
  final Function(Map<String, dynamic> data, String docId)? mockCollectionSetCallback;


  MockCollectionReference(this.path, {this.mockCollectionSetCallback});

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final docId = path ?? 'test_doc_id_${documents.length}';
    if (!documents.containsKey(docId)) {
      documents[docId] = MockDocumentReference<Map<String, dynamic>>(docId, mockCollectionSetCallback: (data) {
        if (mockCollectionSetCallback != null) {
          mockCollectionSetCallback!(data, docId);
        }
      });
    }
    return documents[docId]!;
  }
  // Implement other methods and properties as needed
  @override
  Future<DocumentReference<Map<String, dynamic>>> add(Map<String, dynamic> data) { throw UnimplementedError(); }
  @override
  String get id => path;
  @override
  DocumentReference<Map<String, dynamic>>? get parent => null;
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots({bool includeMetadataChanges = false, ListenSource source = ListenSource.defaultSource}) { throw UnimplementedError(); }
  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) { throw UnimplementedError(); }
  @override
  Query<Map<String, dynamic>> limit(int limit) { throw UnimplementedError(); }
  // ... many more Query methods to override ...
  @override
  Query<Map<String, dynamic>> where(Object field, {Object? isEqualTo, Object? isNotEqualTo, Object? isLessThan, Object? isLessThanOrEqualTo, Object? isGreaterThan, Object? isGreaterThanOrEqualTo, Object? arrayContains, List<Object?>? arrayContainsAny, List<Object?>? whereIn, List<Object?>? whereNotIn, bool? isNull}) { return this; }
  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) { return this; }
  @override
  CollectionReference<R> withConverter<R extends Object?>({required FromFirestore<R> fromFirestore, required ToFirestore<R> toFirestore}) { throw UnimplementedError(); }
  @override
  Query<Map<String, dynamic>> endAt(Iterable<Object?> values) { throw UnimplementedError(); }
  @override
  Query<Map<String, dynamic>> endAtDocument(DocumentSnapshot<Object?> documentSnapshot) { throw UnimplementedError(); }
  @override
  Query<Map<String, dynamic>> endBefore(Iterable<Object?> values) { throw UnimplementedError(); }
  @override
  Query<Map<String, dynamic>> endBeforeDocument(DocumentSnapshot<Object?> documentSnapshot) { throw UnimplementedError(); }
  @override
  Query<Map<String, dynamic>> limitToLast(int limit) { throw UnimplementedError(); }
  @override
  Query<Map<String, dynamic>> startAfter(Iterable<Object?> values) { throw UnimplementedError(); }
  @override
  Query<Map<String, dynamic>> startAfterDocument(DocumentSnapshot<Object?> documentSnapshot) { throw UnimplementedError(); }
  @override
  Query<Map<String, dynamic>> startAt(Iterable<Object?> values) { throw UnimplementedError(); }
  @override
  Query<Map<String, dynamic>> startAtDocument(DocumentSnapshot<Object?> documentSnapshot) { throw UnimplementedError(); }
  @override
  Future<bool> snapshotsInSync() { throw UnimplementedError(); }
   @override
  AggregateQuery count() { throw UnimplementedError(); }
  @override
  AggregateQuery aggregate(AggregateField field1, [AggregateField? field2, AggregateField? field3, AggregateField? field4, AggregateField? field5]) { throw UnimplementedError(); }
}

// Mock DocumentReference
class MockDocumentReference<T extends Object?> implements DocumentReference<T> {
  final String _id;
  final Function(T data)? mockCollectionSetCallback;
  T? _data;

  MockDocumentReference(this._id, {this.mockCollectionSetCallback});

  @override
  String get id => _id;

  @override
  Future<void> set(T data, [SetOptions? options]) async {
    _data = data;
     if (mockCollectionSetCallback != null) {
      mockCollectionSetCallback!(data);
    }
  }
  // Implement other methods and properties as needed
  @override CollectionReference<T> get parent => throw UnimplementedError();
  @override String get path => 'test_path/$_id';
  @override Future<void> update(Map<Object, Object?> data) { throw UnimplementedError(); }
  @override Future<void> delete() { throw UnimplementedError(); }
  @override Future<DocumentSnapshot<T>> get([GetOptions? options]) async => MockDocumentSnapshot<T>(_id, _data);
  @override Stream<DocumentSnapshot<T>> snapshots({bool includeMetadataChanges = false, ListenSource source = ListenSource.defaultSource}) { throw UnimplementedError(); }
  @override DocumentReference<R> withConverter<R extends Object?>({required FromFirestore<R> fromFirestore, required ToFirestore<R> toFirestore}) { throw UnimplementedError(); }
}

// Mock DocumentSnapshot
class MockDocumentSnapshot<T extends Object?> implements DocumentSnapshot<T> {
  @override
  final String id;
  final T? _data;

  MockDocumentSnapshot(this.id, this._data);

  @override
  T? data() => _data;
  @override
  bool get exists => _data != null;
  @override
  SnapshotMetadata get metadata => throw UnimplementedError();
  @override
  dynamic get(Object field) {
    if (_data is Map) {
      return (_data as Map)[field];
    }
    return null;
  }
  @override
  String get referencePath => 'test_path/$id';
}


void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;

  // Helper to pump the widget
  Future<void> pumpAdminCreateManagerScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminCreateManagerScreen(
          // Overriding Firebase instances for testing
          firebaseAuthInstanceForTest: mockAuth,
          firebaseFirestoreInstanceForTest: mockFirestore,
        ),
        // Needed for SnackBar
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
      ),
    );
  }

  setUp(() {
    mockUser = MockUser(uid: 'new_manager_uid');
    mockAuth = MockFirebaseAuth(mockUser: mockUser);
    mockFirestore = MockFirebaseFirestore();
  });

  group('AdminCreateManagerScreen Tests', () {
    testWidgets('Initial State - Renders correctly', (WidgetTester tester) async {
      await pumpAdminCreateManagerScreen(tester);

      expect(find.widgetWithText(AppBar, 'Создать Менеджера'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Имя'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Пароль'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Создать Менеджера'), findsOneWidget);
    });

    group('Form Validation', () {
      testWidgets('Empty name shows error', (WidgetTester tester) async {
        await pumpAdminCreateManagerScreen(tester);
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle(); // For SnackBar or error text animations

        expect(find.text('Пожалуйста, введите имя'), findsOneWidget);
        expect(mockAuth.lastEmail, isNull); // Verify no auth call
      });

      testWidgets('Empty email shows error', (WidgetTester tester) async {
        await pumpAdminCreateManagerScreen(tester);
        await tester.enterText(find.widgetWithText(TextFormField, 'Имя'), 'Test Name');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();

        expect(find.text('Пожалуйста, введите email'), findsOneWidget);
        expect(mockAuth.lastEmail, isNull);
      });

      testWidgets('Invalid email format shows error', (WidgetTester tester) async {
        await pumpAdminCreateManagerScreen(tester);
        await tester.enterText(find.widgetWithText(TextFormField, 'Имя'), 'Test Name');
        await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalidemail');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();
        
        expect(find.text('Пожалуйста, введите корректный email'), findsOneWidget);
        expect(mockAuth.lastEmail, isNull);
      });

      testWidgets('Empty password shows error', (WidgetTester tester) async {
        await pumpAdminCreateManagerScreen(tester);
        await tester.enterText(find.widgetWithText(TextFormField, 'Имя'), 'Test Name');
        await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'valid@email.com');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();

        expect(find.text('Пожалуйста, введите пароль'), findsOneWidget);
        expect(mockAuth.lastEmail, isNull);
      });

      testWidgets('Short password shows error', (WidgetTester tester) async {
        await pumpAdminCreateManagerScreen(tester);
        await tester.enterText(find.widgetWithText(TextFormField, 'Имя'), 'Test Name');
        await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'valid@email.com');
        await tester.enterText(find.widgetWithText(TextFormField, 'Пароль'), '123'); // Short password
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();

        expect(find.text('Пароль должен содержать не менее 6 символов'), findsOneWidget);
        expect(mockAuth.lastEmail, isNull);
      });
    });

    testWidgets('Successful Manager Creation', (WidgetTester tester) async {
      String managerName = 'New Manager';
      String managerEmail = 'manager@example.com';
      String managerPassword = 'password123';
      Map<String, dynamic>? capturedFirestoreData;
      String? capturedDocId;

      // Setup successful auth and firestore calls
      mockAuth.mockCreateUserWithEmailAndPassword = ({required String email, required String password}) async {
        return MockUserCredential(user: mockUser);
      };
      mockFirestore.mockCollectionSet = (Map<String, dynamic> data, String docId) {
        capturedFirestoreData = data;
        capturedDocId = docId;
      };

      await pumpAdminCreateManagerScreen(tester);

      await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Имя'), managerName);
      await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Email'), managerEmail);
      await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Пароль'), managerPassword);
      
      await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
      await tester.pumpAndSettle(); // For SnackBar and async operations

      // Verify FirebaseAuth call
      expect(mockAuth.lastEmail, managerEmail);
      expect(mockAuth.lastPassword, managerPassword);

      // Verify Firestore call
      expect(capturedDocId, mockUser.uid);
      expect(capturedFirestoreData, isNotNull);
      expect(capturedFirestoreData!['name'], managerName);
      expect(capturedFirestoreData!['email'], managerEmail);
      expect(capturedFirestoreData!['role'], 'manager');
      expect(capturedFirestoreData!['createdAt'], isA<Timestamp>());

      // Verify fields are cleared
      expect(find.widgetWithText(TextFormField, managerName), findsNothing); // Name field should be empty
      expect(find.widgetWithText(TextFormField, managerEmail), findsNothing); // Email field should be empty
      // Password field is obscured, check its controller's text
      final passwordField = tester.widget<TextFormField>(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Пароль'));
      expect(passwordField.controller!.text, isEmpty);


      // Verify success SnackBar
      expect(find.text('Менеджер успешно создан.'), findsOneWidget);
    });

    group('Error Handling (FirebaseAuthException)', () {
      testWidgets('Handles email-already-in-use', (WidgetTester tester) async {
        mockAuth.mockCreateUserWithEmailAndPassword = ({required String email, required String password}) async {
          throw FirebaseAuthException(code: 'email-already-in-use', message: 'Email already in use.');
        };

        await pumpAdminCreateManagerScreen(tester);
        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Имя'), 'Test User');
        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Email'), 'existing@example.com');
        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Пароль'), 'password123');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();

        expect(find.text('Аккаунт с таким email уже существует.'), findsOneWidget);
      });

      testWidgets('Handles weak-password', (WidgetTester tester) async {
        mockAuth.mockCreateUserWithEmailAndPassword = ({required String email, required String password}) async {
          throw FirebaseAuthException(code: 'weak-password', message: 'Password is too weak.');
        };
        await pumpAdminCreateManagerScreen(tester);

        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Имя'), 'Test User');
        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Email'), 'new@example.com');
        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Пароль'), 'weak');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();
        
        expect(find.text('Предоставленный пароль слишком слабый.'), findsOneWidget);
      });

       testWidgets('Handles generic FirebaseAuthException', (WidgetTester tester) async {
        mockAuth.mockCreateUserWithEmailAndPassword = ({required String email, required String password}) async {
          throw FirebaseAuthException(code: 'unknown-error', message: 'An unknown error occurred.');
        };
        await pumpAdminCreateManagerScreen(tester);

        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Имя'), 'Test User');
        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Email'), 'new@example.com');
        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Пароль'), 'password123');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();
        
        expect(find.text('Произошла ошибка при создании менеджера.'), findsOneWidget); // Generic message
      });

      testWidgets('Handles generic Exception during creation', (WidgetTester tester) async {
        mockAuth.mockCreateUserWithEmailAndPassword = ({required String email, required String password}) async {
          throw Exception('Some generic error'); // Not FirebaseAuthException
        };
        await pumpAdminCreateManagerScreen(tester);

        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Имя'), 'Test User');
        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Email'), 'new@example.com');
        await tester.enterText(find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Пароль'), 'password123');
        await tester.tap(find.widgetWithText(ElevatedButton, 'Создать Менеджера'));
        await tester.pumpAndSettle();
        
        expect(find.text('Произошла ошибка при создании менеджера.'), findsOneWidget); // Generic message
      });
    });
  });
}

// Helper extension to find TextFormField by labelText more reliably
extension TextFormFieldFinder on CommonFinders {
  Finder byTextFormFieldLabel(String labelText) {
    return find.byWidgetPredicate((Widget widget) {
      if (widget is TextFormField) {
        return widget.decoration?.labelText == labelText;
      }
      return false;
    });
  }
}

// Note: The AdminCreateManagerScreen needs to be modified to accept
// FirebaseAuth and FirebaseFirestore instances for testing.
// Example modification in AdminCreateManagerScreen:
//
// final FirebaseAuth? firebaseAuthInstanceForTest;
// final FirebaseFirestore? firebaseFirestoreInstanceForTest;
//
// const AdminCreateManagerScreen({
//   super.key,
//   this.firebaseAuthInstanceForTest,
//   this.firebaseFirestoreInstanceForTest,
// });
//
// Then in the _createManager method:
// FirebaseAuth auth = widget.firebaseAuthInstanceForTest ?? FirebaseAuth.instance;
// FirebaseFirestore firestore = widget.firebaseFirestoreInstanceForTest ?? FirebaseFirestore.instance;
//
// UserCredential userCredential = await auth.createUserWithEmailAndPassword(...);
// await firestore.collection('users').doc(userCredential.user!.uid).set({...});
//
// This change is crucial for injecting mocks.
// The provided test code assumes this modification has been made.
// If not, the tests will use the real Firebase instances.
//
// I will apply this modification to AdminCreateManagerScreen in the next step.
// For now, the test file is created.
//
// Also, added a helper extension `TextFormFieldFinder` for more robust finding
// of TextFormFields by their labelText. This is not strictly necessary but can
// make tests less brittle than `find.widgetWithText(TextFormField, 'Label')`.
// Updated tests to use a more robust way to find TextFormFields by labelText.
// e.g., `find.byWidgetPredicate((widget) => widget is TextFormField && widget.decoration?.labelText == 'Имя')`
//
// The MockUser class was missing some overrides, I've added them.
// The MockCollectionReference and MockDocumentReference were also missing some overrides.
// Added a GlobalKey<ScaffoldMessengerState> to MaterialApp for SnackBar testing.
// Corrected field clearing check for password field.
// Added test for generic FirebaseAuthException and generic Exception.
// Ensured mockUser.uid is used in the "Successful Manager Creation" test for Firestore doc ID.
// Added more required overrides to MockFirebaseAuth and MockFirebaseFirestore for stricter typing.
// Added missing overrides for `AggregateQuery` in `MockCollectionReference`.
// Added `useFirestoreEmulator` to `MockFirebaseFirestore`.
// Added `sendPasswordResetEmailVerification`, `sendSmsCode`, `linkWithCredential`, `reauthenticateWithCredential`, `signInWithPhoneNumberAndRecaptchaVerifier`, `verifyPhoneNumberWithSmsRetriever` to `MockFirebaseAuth`.
// Added `verifyBeforeUpdateEmail` and `multiFactor` to `MockUser`.
// Added `creationTime` and `lastSignInTime` to `MockUserMetadata`.
// Added `count` and `aggregate` to `MockCollectionReference`.

// Added missing `settings` getter and setter to `MockFirebaseFirestore`.
// Added `addSnapshotsInSyncListener` and `removeSnapshotsInSyncListener` to `MockFirebaseFirestore`.The test file `test/screens/admin_create_manager_screen_test.dart` has been created with manual mocks for `FirebaseAuth` and `FirebaseFirestore`, and a comprehensive set of widget tests.

The tests cover:
1.  **Initial State**: Verifies that all UI elements (AppBar, TextFormFields for name, email, password, and the submit button) are rendered correctly.
2.  **Form Validation**:
    *   Checks for error messages when submitting with empty name, email, or password.
    *   Checks for error messages with an invalid email format.
    *   Checks for error messages with a password shorter than 6 characters.
    *   Ensures no Firebase calls are made during validation failures.
3.  **Successful Manager Creation (Mocked)**:
    *   Mocks `FirebaseAuth.createUserWithEmailAndPassword` to return a mock `UserCredential`.
    *   Mocks `FirebaseFirestore.instance.collection().doc().set()` to capture the data being set.
    *   Enters valid data into the form.
    *   Verifies that `createUserWithEmailAndPassword` is called with the correct email and password.
    *   Verifies that the Firestore `set` method is called with the correct manager details (name, email, role: 'manager', and a `Timestamp`).
    *   Verifies that input fields are cleared after successful creation.
    *   Verifies that a success `SnackBar` is displayed.
4.  **Error Handling (Mocked)**:
    *   Mocks `FirebaseAuth.createUserWithEmailAndPassword` to throw `FirebaseAuthException` with codes 'email-already-in-use', 'weak-password', and a generic 'unknown-error'.
    *   Mocks `FirebaseAuth.createUserWithEmailAndPassword` to throw a generic `Exception`.
    *   Verifies that the appropriate error `SnackBar` messages are displayed for each case.

The test setup includes a helper function `pumpAdminCreateManagerScreen` to wrap the `AdminCreateManagerScreen` in a `MaterialApp` and provide mock instances. The mocks are designed to be basic but sufficient for these tests.

**Crucial Next Step (Mentioned in the generated code comments):**
The `AdminCreateManagerScreen` itself needs to be modified to accept `FirebaseAuth` and `FirebaseFirestore` instances as optional parameters. This allows the tests to inject the mock instances. Without this modification, the tests would attempt to use the real Firebase services.

Example of the required modification in `lib/screens/admin_create_manager_screen.dart`:
```dart
// Add these fields to the StatefulWidget
final FirebaseAuth? firebaseAuthInstanceForTest;
final FirebaseFirestore? firebaseFirestoreInstanceForTest;

const AdminCreateManagerScreen({
  super.key,
  this.firebaseAuthInstanceForTest,
  this.firebaseFirestoreInstanceForTest,
});

// In the _AdminCreateManagerScreenState, when using Firebase:
FirebaseAuth auth = widget.firebaseAuthInstanceForTest ?? FirebaseAuth.instance;
FirebaseFirestore firestore = widget.firebaseFirestoreInstanceForTest ?? FirebaseFirestore.instance;
// ... use auth and firestore ...
```
This next step is essential for these tests to function correctly in a CI environment or locally without hitting actual Firebase. I will perform this modification in a subsequent step if requested.

The current subtask of creating the widget tests is complete.
