import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pos_app/models/vehicle.dart'; // Import Vehicle model
import 'package:pos_app/widgets/vehicle_list_item.dart'; // Reuse VehicleListItem
import 'admin_order_review_screen.dart'; // Import order review screen

class AdminPendingOrdersScreen extends StatelessWidget {
  const AdminPendingOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказы на Проверке'),
      ),
      body: StreamBuilder<List<Vehicle>>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .where('paymentStatus', isEqualTo: 'pending_admin_review') // Filter for pending review
            .orderBy('exitTime', descending: true) // Order by completion time
            .snapshots()
            .map((snapshot) => snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки заказов: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет заказов на проверке'));
          }

          final vehicles = snapshot.data!;

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              // Reuse VehicleListItem, maybe customize appearance for pending status later
              return VehicleListItem(
                vehicle: vehicle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminOrderReviewScreen(vehicleId: vehicle.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
