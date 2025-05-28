import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCreateManagerScreen extends StatefulWidget {
  static const String routeName = '/admin/create-manager';

  final FirebaseAuth? firebaseAuthInstanceForTest;
  final FirebaseFirestore? firebaseFirestoreInstanceForTest;

  const AdminCreateManagerScreen({
    super.key,
    this.firebaseAuthInstanceForTest,
    this.firebaseFirestoreInstanceForTest,
  });

  @override
  State<AdminCreateManagerScreen> createState() => _AdminCreateManagerScreenState();
}

class _AdminCreateManagerScreenState extends State<AdminCreateManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _auth = widget.firebaseAuthInstanceForTest ?? FirebaseAuth.instance;
    _firestore = widget.firebaseFirestoreInstanceForTest ?? FirebaseFirestore.instance;
  }

  Future<void> _createManager() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Store manager details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': 'manager',
        'createdAt': Timestamp.now(),
      });

      // Clear fields and show success message
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Менеджер успешно создан.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Произошла ошибка при создании менеджера.';
      if (e.code == 'weak-password') {
        errorMessage = 'Предоставленный пароль слишком слабый.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'Аккаунт с таким email уже существует.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Неверный формат email.';
      }
      // print('FirebaseAuthException: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      // print('Error creating manager: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Произошла ошибка при создании менеджера.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать Менеджера'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Пожалуйста, введите корректный email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите пароль';
                  }
                  if (value.length < 6) {
                    return 'Пароль должен содержать не менее 6 символов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _createManager,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : const Text('Создать Менеджера'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
