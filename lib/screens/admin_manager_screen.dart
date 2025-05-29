import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_view_manager_report_screen.dart'; // Import the new screen
import 'admin_create_manager_screen.dart'; // Import create manager screen
import 'package:pos_app/core/constants.dart'; // Import constants

class AdminManagerScreen extends StatefulWidget {
  static const String routeName = '/admin/manager';
  final FirebaseFirestore? firestoreInstanceForTest;

  const AdminManagerScreen({super.key, this.firestoreInstanceForTest});

  @override
  State<AdminManagerScreen> createState() => _AdminManagerScreenState();
}

class _AdminManagerScreenState extends State<AdminManagerScreen> {
  late FirebaseFirestore _firestore;
  late Future<QuerySnapshot<Map<String, dynamic>>> _managersFuture;

  @override
  void initState() {
    super.initState();
    _firestore = widget.firestoreInstanceForTest ?? FirebaseFirestore.instance;
    _managersFuture = _firestore
        .collection(FirestoreCollections.users) // Use constant
        .where('role', isEqualTo: UserRoles.manager) // Use constant
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление Менеджерами'), // Updated title
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: _managersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            // print('Error fetching managers: ${snapshot.error}');
            return const Center(child: Text('Произошла ошибка при загрузке менеджеров.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Менеджеры не найдены.'));
          }

          final managers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: managers.length,
            itemBuilder: (context, index) {
              final manager = managers[index];
              final managerData = manager.data();
              final String managerName = managerData['name'] ?? 'Имя не указано';
              final String managerEmail = managerData['email'] ?? 'Email не указан';
              final String managerId = manager.id;

              return ListTile(
                title: Text(managerName),
                subtitle: Text(managerEmail),
                trailing: IconButton(
                  icon: const Icon(Icons.bar_chart),
                  tooltip: 'Посмотреть отчет',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminViewManagerReportScreen(
                          managerId: managerId,
                          managerName: managerName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminCreateManagerScreen()),
          );
        },
        tooltip: 'Создать Менеджера',
        child: const Icon(Icons.add),
      ),
    );
  }
}
