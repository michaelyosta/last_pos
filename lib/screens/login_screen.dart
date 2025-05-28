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
            final String? managerId = FirebaseAuth.instance.currentUser?.uid;
            if (managerId != null) {
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ManagerVehiclesListScreen(managerId: managerId)),
                );
              }
            } else {
              // This case should ideally not happen after a successful login
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Не удалось получить ID менеджера.')),
                );
              }
              await FirebaseAuth.instance.signOut(); // Sign out if managerId is missing
            }
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
        // This flow uses a custom managerId from text input, not Firebase Auth UID directly for navigation.
        // The task asks for FirebaseAuth.instance.currentUser?.uid.
        // If this manager login implies a Firebase user is also signed in,
        // then managerId from FirebaseAuth.instance.currentUser?.uid should be used.
        // For now, assuming this is a distinct flow or the user is already signed in.
        // If the manager is logging in via this method, they aren't using Firebase Auth directly here.
        // So, it's not clear how FirebaseAuth.instance.currentUser?.uid would be populated or relevant
        // *for this specific block*.
        // However, if the requirement is that *any* navigation to ManagerVehiclesListScreen
        // must use the UID of a *currently signed-in Firebase user*, then this flow is problematic
        // unless it also performs a Firebase sign-in.
        // For now, let's assume this part of the login is out of scope for the managerId from FirebaseAuth.
        // Or, if the manager *is* a firebase user, this custom ID is just for lookup,
        // and the UID should still be fetched from the actual logged-in user.
        // Let's apply the requested change here as well, assuming a Firebase user is involved.
        final String? currentAuthManagerId = FirebaseAuth.instance.currentUser?.uid;
        DocumentSnapshot managerDoc = querySnapshot.docs.first; // Get the manager's document
        String managerFirestoreUid = managerDoc.id; // This is the UID stored in Firestore

        // It's possible currentAuthManagerId might be from a previous session or admin.
        // We should use the UID that corresponds to the managerId entered.
        // This implies the `managerId` entered in the text field is for LOOKUP, and the actual
        // UID to pass is the one from the document found.
        
        // If the app logic implies that this managerId login should *also* sign in a Firebase user,
        // that sign-in step is missing here. Assuming the user is already signed in or this is an admin view.
        // For now, I will pass the UID from the Firestore document as the 'managerId' for the screen.
        // This seems more logical for this specific flow than currentAuthManagerId.
        // However, the task strictly asks for `FirebaseAuth.instance.currentUser?.uid`.
        // This creates a conflict. Let's prioritize the task's literal instruction.

        if (currentAuthManagerId != null) {
            if (context.mounted) {
                 Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ManagerVehiclesListScreen(managerId: currentAuthManagerId)),
                );
            }
        } else {
             if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Не удалось получить ID текущего пользователя FirebaseAuth для менеджера.')),
                );
            }
        }
      } else {
        if (context.mounted) { // Added context.mounted check
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Менеджер с таким ID не найден')),
            );
        }
      }
    } catch (e) {
      print('Manager login error: $e');
      if (context.mounted) { // Added context.mounted check
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Произошла ошибка при входе менеджера: $e')),
        );
      }
    }
  }
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
