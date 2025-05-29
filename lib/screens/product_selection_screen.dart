import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_app/models/product.dart';
import 'package:pos_app/models/vehicle.dart'; // Import Vehicle model to update items
import 'package:pos_app/core/constants.dart'; // Import constants

class ProductSelectionScreen extends StatelessWidget {
  final String vehicleId;
  final String categoryId;
  final String categoryDisplayName;

  const ProductSelectionScreen({
    Key? key,
    required this.vehicleId,
    required this.categoryId,
    required this.categoryDisplayName,
  }) : super(key: key);

  // Function to add an item to the vehicle's items list in Firestore
  Future<void> _addItemToVehicle(BuildContext context, Product product) async {
    try {
      // Get the current vehicle document
      DocumentReference vehicleRef = FirebaseFirestore.instance.collection(FirestoreCollections.vehicles).doc(vehicleId); // Use constant
      DocumentSnapshot vehicleDoc = await vehicleRef.get();

      if (vehicleDoc.exists) {
        // Get current items and total amount
        List<dynamic> currentItems = vehicleDoc.get('items') ?? [];
        double currentTotal = (vehicleDoc.get('totalAmount') ?? 0.0).toDouble(); // Ensure currentTotal is always double

        // Check if the item already exists in the list
        int existingItemIndex = currentItems.indexWhere((item) => item['id'] == product.id);

        if (existingItemIndex != -1) {
          // If item exists, increment quantity
          currentItems[existingItemIndex]['quantity']++;
        } else {
          // If item does not exist, add it with quantity 1
          currentItems.add({
            'id': product.id,
            'name': product.name,
            'category': product.categoryId, // Store category ID
            'price': product.price,
            'quantity': 1,
          });
        }

        // Update total amount
        double newTotal = currentTotal + product.price;

        // Update the vehicle document in Firestore
        await vehicleRef.update({
          'items': currentItems,
          'totalAmount': newTotal,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} добавлен')),
        );
      }
    } catch (e) {
      print('Error adding item to vehicle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении товара: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryDisplayName),
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
                trailing: Text('${product.price} тнг'),
                onTap: () {
                  _addItemToVehicle(context, product);
                },
              );
            },
          );
        },
      ),
    );
  }
}
