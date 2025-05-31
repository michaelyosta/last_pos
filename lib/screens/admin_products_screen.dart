import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pos_app/models/category.dart'; // Import Category model
import 'admin_product_list_screen.dart'; // Import product list screen
import 'admin_add_category_screen.dart'; // Import add category screen
import 'package:pos_app/core/constants.dart'; // Import constants

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  _AdminProductsScreenState createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  Future<List<Category>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
  }

  Future<List<Category>> _fetchCategories() {
    return FirebaseFirestore.instance
        .collection(FirestoreCollections.categories) // Use constant
        .orderBy('displayName')
        .get()
        .then((snapshot) => snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList());
  }

  void _refreshCategories() {
    setState(() {
      _categoriesFuture = _fetchCategories();
    });
  }

  // Function to delete a category
  Future<void> _deleteCategory(BuildContext context, String categoryId, String categoryName) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтвердить удаление'),
          content: Text('Вы уверены, что хотите удалить категорию "$categoryName"? Товары в этой категории не будут удалены, но останутся без категории и могут потребовать ручного переназначения в будущем.'),
          actions: <Widget>[
            TextButton(
              child: const Text('ОТМЕНА'),
              onPressed: () {
                Navigator.of(context).pop(false); // Dismiss dialog and return false
              },
            ),
            TextButton(
              child: const Text('УДАЛИТЬ'),
              onPressed: () {
                Navigator.of(context).pop(true); // Dismiss dialog and return true
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await FirebaseFirestore.instance.collection(FirestoreCollections.categories).doc(categoryId).delete(); // Use constant
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Категория успешно удалена')),
        );
      } catch (e) {
        print('Error deleting category: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при удалении категории: ${e.toString()}')),
        );
      }
    }
  }

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
              child: const Text('ДОБАВИТЬ НОВУЮ КАТЕГОРИЮ'),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _categoriesFuture = _fetchCategories();
                });
                await _categoriesFuture; // Await the completion of the new future
              },
              child: FutureBuilder<List<Category>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Ошибка загрузки категорий: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Нет доступных категорий. Потяните вниз для обновления.')); // Updated message
                  }

                  final categories = snapshot.data!;

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ListTile(
                        title: Text(category.displayName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              onPressed: () {
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
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteCategory(context, category.id, category.displayName);
                              },
                            ),
                          ],
                        ),
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
          ),
        ],
      ),
    );
  }
}
