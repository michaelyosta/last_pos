import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pos_app/models/product.dart'; // Import Product model
import 'admin_add_product_screen.dart'; // Import add product screen
import 'admin_edit_product_screen.dart'; // Import edit product screen
import 'package:pos_app/core/constants.dart'; // Import constants

class AdminProductListScreen extends StatelessWidget {
  final String categoryId;
  final String categoryDisplayName;

  const AdminProductListScreen({Key? key, required this.categoryId, required this.categoryDisplayName}) : super(key: key);

  // Function to delete a product
  Future<void> _deleteProduct(BuildContext context, String productId) async {
    try {
      await FirebaseFirestore.instance.collection(FirestoreCollections.products).doc(productId).delete(); // Use constant
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар удален')),
      );
    } catch (e) {
      print('Error deleting product: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении товара: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Товары в категории: $categoryDisplayName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminAddProductScreen(categoryId: categoryId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: FirebaseFirestore.instance
            .collection(FirestoreCollections.products) // Use constant
            .where('categoryId', isEqualTo: categoryId) // Filter products by category
            .orderBy('name') // Order products alphabetically
            .snapshots()
            .map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки товаров: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет товаров в этой категории'));
          }

          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text('${product.price} тнг'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminEditProductScreen(productId: product.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteProduct(context, product.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
