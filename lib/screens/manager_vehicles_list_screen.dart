import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_app/models/vehicle.dart';
import 'package:pos_app/widgets/vehicle_list_item.dart'; // We will create this widget next
import 'package:pos_app/widgets/bottom_navigation_bar.dart'; // We will create this widget next
import 'manager_scan_vehicle_screen.dart'; // Placeholder for scan screen
import 'manager_history_screen.dart'; // Placeholder for history screen
import 'manager_vehicle_detail_screen.dart'; // Placeholder for detail screen
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'login_screen.dart'; // Import LoginScreen
import 'package:pos_app/models/app_settings.dart'; // Import AppSettings model

class ManagerVehiclesListScreen extends StatefulWidget { // Changed to StatefulWidget
  final String managerId;
  const ManagerVehiclesListScreen({Key? key, required this.managerId}) : super(key: key);

  @override
  _ManagerVehiclesListScreenState createState() => _ManagerVehiclesListScreenState();
}

class _ManagerVehiclesListScreenState extends State<ManagerVehiclesListScreen> { // Created State class
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Активные Машины'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('settings').doc('global_settings').snapshots(),
        builder: (context, settingsSnapshot) {
          if (settingsSnapshot.hasError) {
            return Center(child: Text('Ошибка загрузки настроек: ${settingsSnapshot.error}'));
          }
          if (settingsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final AppSettings appSettings = AppSettings.fromFirestore(settingsSnapshot.data!);
          final double pricePerMinute = appSettings.pricePerMinute;

          return StreamBuilder<List<Vehicle>>(
            stream: FirebaseFirestore.instance
                .collection('vehicles')
                .where('status', isEqualTo: 'active')
                .orderBy('entryTime', descending: true)
                .snapshots()
                .map((snapshot) => snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList()),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Нет активных машин'));
              }

              final vehicles = snapshot.data!;

              return ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  return VehicleListItem(
                    vehicle: vehicle,
                    pricePerMinute: pricePerMinute, // Pass pricePerMinute
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManagerVehicleDetailScreen(
                            vehicleId: vehicle.id,
                            managerId: widget.managerId, // Pass managerId
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: ManagerBottomNavigationBar(
        currentIndex: 0, // 'Выбор машины' is the first item
        onTap: (index) {
          if (index == 0) {
            // Already on this screen
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ManagerScanVehicleScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ManagerHistoryScreen(managerId: widget.managerId)), // Pass managerId
            );
          }
        },
      ),
    );
  }
}
