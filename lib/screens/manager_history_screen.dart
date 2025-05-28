import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pos_app/models/vehicle.dart'; // Import Vehicle model
import 'package:pos_app/widgets/bottom_navigation_bar.dart'; // Import bottom navigation bar
import 'package:pos_app/widgets/vehicle_list_item.dart'; // Import VehicleListItem (will reuse)
import 'manager_vehicles_list_screen.dart'; // Import vehicle list screen
import 'manager_scan_vehicle_screen.dart'; // Import scan screen
import 'manager_vehicle_detail_screen.dart'; // Import detail screen
import 'package:pos_app/models/app_settings.dart'; // Import AppSettings model

class ManagerHistoryScreen extends StatefulWidget { // Changed to StatefulWidget to use widget.managerId
  final String managerId;

  const ManagerHistoryScreen({Key? key, required this.managerId}) : super(key: key);

  @override
  _ManagerHistoryScreenState createState() => _ManagerHistoryScreenState();
}

class _ManagerHistoryScreenState extends State<ManagerHistoryScreen> { // Created State class
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История Обслуживания'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
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
                .where('status', isEqualTo: 'completed') // Filter for completed vehicles
                .orderBy('exitTime', descending: true) // Order by exit time
                .snapshots()
                .map((snapshot) => snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList()),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Ошибка загрузки истории: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('История обслуживания пуста'));
              }

              final vehicles = snapshot.data!;

              return ListView.builder(
                itemCount: vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];
                  // Reuse VehicleListItem, it handles displaying total time for non-active status
                  return VehicleListItem(
                    vehicle: vehicle,
                    pricePerMinute: pricePerMinute, // Pass pricePerMinute
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) => ManagerVehicleDetailScreen(
                          vehicleId: vehicle.id,
                          managerId: widget.managerId, // Pass managerId here
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
        currentIndex: 2, // 'История' is the third item
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ManagerVehiclesListScreen(managerId: widget.managerId)),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ManagerScanVehicleScreen()),
            );
          } else if (index == 2) {
            // Already on this screen
          }
        },
      ),
    );
  }
}
