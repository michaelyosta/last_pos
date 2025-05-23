import 'package:flutter/material.dart';
import 'admin_pending_orders_screen.dart'; // Import pending orders screen
import 'admin_products_screen.dart'; // Placeholder for products screen
import 'login_screen.dart'; // Import login screen for logout

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Администратор Панель'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout logic
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPendingOrdersScreen()), // Navigate to pending orders list
                );
              },
              child: const Text('Проверка Заказов'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminProductsScreen()),
                );
              },
              child: const Text('Управление Товарами'),
            ),
            // TODO: Add more admin options like Analytics, Settings, etc.
          ],
        ),
      ),
    );
  }
}
