import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'manager_vehicles_list_screen.dart'; // Import ManagerVehiclesListScreen
import 'admin_dashboard_screen.dart'; // Import placeholder admin screen

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _managerIdController = TextEditingController(); // Controller for manager ID

  void _login() async { // Make _login async
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, введите Email и Пароль')),
        );
        return;
      }

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Fetch user role from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc.get('role');
          if (role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
            );
          } else if (role == 'manager') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ManagerVehiclesListScreen()), // Navigate to Vehicle List Screen
            );
          } else {
            // Handle unknown role
            print('Unknown user role: $role');
            // Optionally sign out the user
            await FirebaseAuth.instance.signOut();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Неизвестная роль пользователя')),
            );
          }
        } else {
          // User document not found in Firestore
          print('User document not found for UID: ${userCredential.user!.uid}');
          await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Данные пользователя не найдены')),
          );
        }

      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'Пользователь не найден.';
        } else if (e.code == 'wrong-password') {
          message = 'Неверный пароль.';
        } else {
          message = 'Ошибка авторизации: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        print('Login error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Произошла ошибка: $e')),
        );
      }
    }
  }

  void _showManagerLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Вход для Менеджера'),
          content: TextField(
            controller: _managerIdController,
            decoration: const InputDecoration(
              labelText: 'ID Менеджера',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Войти'),
              onPressed: () {
                _loginManager();
              },
            ),
          ],
        );
      },
    );
  }

  void _loginManager() async {
    String managerId = _managerIdController.text.trim();
    if (managerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите ID Менеджера')),
      );
      return;
    }

    try {
      // Query Firestore for a manager with the given ID
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'manager')
          .where('managerId', isEqualTo: managerId) // Assuming 'managerId' is a field in user documents
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Manager found, navigate to manager dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ManagerVehiclesListScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Менеджер с таким ID не найден')),
        );
      }
    } catch (e) {
      print('Manager login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Произошла ошибка при входе менеджера: $e')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _managerIdController.dispose(); // Dispose manager ID controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Система'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'POS СИСТЕМА',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 48.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите Email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль (для Администратора)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty && _emailController.text.isNotEmpty) {
                      return 'Пожалуйста, введите Пароль';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('ВОЙТИ КАК АДМИНИСТРАТОР'),
                ),
                const SizedBox(height: 16.0),
                OutlinedButton(
                  onPressed: _showManagerLoginDialog,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('ВОЙТИ КАК МЕНЕДЖЕР'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
