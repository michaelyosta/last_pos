import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pos_app/models/product.dart'; // Import Product model
import 'package:pos_app/core/constants.dart'; // Import constants

class AdminEditProductScreen extends StatefulWidget { // Converted to StatefulWidget
  final String productId;

  const AdminEditProductScreen({Key? key, required this.productId}) : super(key: key);

  @override
  _AdminEditProductScreenState createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> { // Added State class
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  // Function to load existing product data
  Future<void> _loadProductData() async {
    try {
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection(FirestoreCollections.products) // Use constant
          .doc(widget.productId)
          .get();

      if (productDoc.exists) {
        Product product = Product.fromFirestore(productDoc);
        _nameController.text = product.name;
        _descriptionController.text = product.description;
        _priceController.text = product.price.toString();
      } else {
        // Handle case where product is not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Товар не найден')),
        );
        Navigator.pop(context); // Go back if product not found
      }
    } catch (e) {
      print('Error loading product data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке данных товара: ${e.toString()}')),
      );
      Navigator.pop(context); // Go back on error
    }
  }

  // Function to update the product in Firestore
  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection(FirestoreCollections.products).doc(widget.productId).update({ // Use constant
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': double.parse(_priceController.text.trim()), // Parse price as double
          'updatedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Товар успешно обновлен')),
        );

        // Navigate back to the product list screen
        Navigator.pop(context);

      } catch (e) {
        print('Error updating product: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при обновлении товара: ${e.toString()}')),
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
        title: const Text('Редактировать Товар'),
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
                onPressed: _updateProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('СОХРАНИТЬ ИЗМЕНЕНИЯ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
