import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added import
import 'admin_create_manager_screen.dart'; // Import create manager screen
import 'admin_manager_screen.dart'; // Import manager reports screen
import 'admin_products_screen.dart'; // Placeholder for products screen
import 'admin_settings_screen.dart'; // Import admin settings screen
import 'login_screen.dart'; // Import login screen for logout
import 'package:pos_app/screens/general_revenue_report_screen.dart'; // Import general revenue report screen

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
            onPressed: () async { // Made callback async
              // TODO: Implement logout logic
              await FirebaseAuth.instance.signOut(); // Added sign out call
              if (Navigator.of(context).mounted) { // Check if widget is mounted
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
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
                  MaterialPageRoute(builder: (context) => const AdminProductsScreen()),
                );
              },
              child: const Text('Управление Товарами'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminManagerScreen()),
                );
              },
              child: const Text('Менеджер'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GeneralRevenueReportScreen()),
                );
              },
              child: const Text('Общий отчет по выручке'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminSettingsScreen()),
                );
              },
              child: const Text('Настройки'),
            ),
            // TODO: Add more admin options like Analytics, etc.
          ],
        ),
      ),
    );
  }
}
