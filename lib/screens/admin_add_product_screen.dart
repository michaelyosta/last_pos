import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for createdBy

class AdminAddProductScreen extends StatefulWidget { // Converted to StatefulWidget
  final String categoryId;

  const AdminAddProductScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  _AdminAddProductScreenState createState() => _AdminAddProductScreenState();
}

class _AdminAddProductScreenState extends State<AdminAddProductScreen> { // Added State class
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Function to add the new product to Firestore
  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        String adminId = FirebaseAuth.instance.currentUser!.uid; // Get current admin ID

        await FirebaseFirestore.instance.collection('products').add({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': double.parse(_priceController.text.trim()), // Parse price as double
          'categoryId': widget.categoryId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'createdBy': adminId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Товар успешно добавлен')),
        );

        // Navigate back to the product list screen
        Navigator.pop(context);

      } catch (e) {
        print('Error adding product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при добавлении товара: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить Товар'),
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
                  labelText: 'Наименование',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите наименование';
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
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true), // Allow decimal input
                decoration: const InputDecoration(
                  labelText: 'Цена (тнг)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Пожалуйста, введите цену';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Пожалуйста, введите корректное число';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _addProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('ДОБАВИТЬ ТОВАР'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
