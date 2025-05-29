import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for createdBy
import 'package:pos_app/core/constants.dart'; // Import constants

class AdminAddCategoryScreen extends StatefulWidget { // Converted to StatefulWidget
  const AdminAddCategoryScreen({Key? key}) : super(key: key);

  @override
  _AdminAddCategoryScreenState createState() => _AdminAddCategoryScreenState();
}

class _AdminAddCategoryScreenState extends State<AdminAddCategoryScreen> { // Added State class
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Function to add the new category to Firestore
  Future<void> _addCategory() async {
    if (_formKey.currentState!.validate()) {
      try {
        String adminId = FirebaseAuth.instance.currentUser!.uid; // Get current admin ID

        await FirebaseFirestore.instance.collection(FirestoreCollections.categories).add({
          'name': _nameController.text.trim(),
          'displayName': _displayNameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'createdBy': adminId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Категория успешно добавлена')),
        );

        // Navigate back to the products screen
        Navigator.pop(context);

      } catch (e) {
        print('Error adding category: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при добавлении категории: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _displayNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить Категорию'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Системное имя (например, instruments)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите системное имя';
                  }
                   // Basic validation for system name (no spaces, lowercase)
                  if (value.contains(' ') || value.toLowerCase() != value) {
                     return 'Используйте строчные буквы без пробелов';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Отображаемое имя (например, Инструменты)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите отображаемое имя';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание (необязательно)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _addCategory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('ДОБАВИТЬ КАТЕГОРИЮ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
