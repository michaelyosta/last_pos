import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pos_app/models/category.dart'; // Import Category model
import 'admin_product_list_screen.dart'; // Import product list screen
import 'admin_add_category_screen.dart'; // Import add category screen

class AdminProductsScreen extends StatelessWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление Товарами'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminAddCategoryScreen()),
                );
              },
              child: const Text('Добавить Новую Категорию'),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Category>>(
              stream: FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('displayName') // Order categories alphabetically
                  .snapshots()
                  .map((snapshot) => snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList()),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка загрузки категорий: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Нет доступных категорий'));
                }

                final categories = snapshot.data!;

                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return ListTile(
                      title: Text(category.displayName),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdminProductListScreen(
                              categoryId: category.id,
                              categoryDisplayName: category.displayName,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
