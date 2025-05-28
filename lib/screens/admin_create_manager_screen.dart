import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math'; // Added for Random

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
  final _managerNumberController = TextEditingController(); // Replaced _emailController
  final _passwordController = TextEditingController();
  String _generatedManagerNumber = ''; // Added state for generated number

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
      final managerNumber = _managerNumberController.text.trim();
      if (managerNumber.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Пожалуйста, сгенерируйте номер менеджера.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      if (managerNumber.length != 6) {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Номер менеджера должен состоять из 6 цифр.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      final String managerEmail = 'manager_$managerNumber@example.com';

      // Create user in Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: managerEmail, // Use generated email
        password: _passwordController.text.trim(),
      );

      // Store manager details in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'managerNumber': managerNumber, // Store manager number
        'email': managerEmail, // Store generated email
        'role': 'manager',
        'createdAt': Timestamp.now(),
      });

      // Clear fields and show success message
      _nameController.clear();
      _managerNumberController.clear(); // Clear manager number
      _generatedManagerNumber = ''; // Reset generated number state
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
    _managerNumberController.dispose(); // Dispose manager number controller
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
                controller: _managerNumberController,
                decoration: const InputDecoration(labelText: 'Номер Менеджера (6 цифр)'),
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, сгенерируйте номер менеджера';
                  }
                  if (value.length != 6) {
                    return 'Номер менеджера должен состоять из 6 цифр';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  final random = Random();
                  _generatedManagerNumber = (random.nextInt(900000) + 100000).toString();
                  _managerNumberController.text = _generatedManagerNumber;
                  // Trigger validation display if form was already validated once
                  _formKey.currentState?.validate();
                },
                child: const Text('Сгенерировать номер'),
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
