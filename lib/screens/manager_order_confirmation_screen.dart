import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:pos_app/models/vehicle.dart'; // Import Vehicle model
import 'manager_vehicle_detail_screen.dart'; // Import detail screen for cancellation
import 'manager_vehicles_list_screen.dart'; // Import vehicle list screen for navigation
import 'package:pos_app/core/constants.dart'; // Import constants

class ManagerOrderConfirmationScreen extends StatelessWidget {
  final String vehicleId;

  const ManagerOrderConfirmationScreen({Key? key, required this.vehicleId}) : super(key: key);

  // Function to confirm the order (sends to admin for review)
  Future<void> _confirmOrder(BuildContext context) async {
    try {
      // Update vehicle status to 'pending' (already done in detail screen, but good to be explicit)
      // This step might involve sending a notification to the admin
      // For now, we just navigate back to the list or show a success message
      await FirebaseFirestore.instance.collection(FirestoreCollections.vehicles).doc(vehicleId).update({ // Use constant
         'paymentStatus': PaymentStatuses.pendingAdminReview, // Use constant // More specific status
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заказ отправлен на проверку администратору')),
      );

      // Navigate back to the active vehicles list
      final String? managerId = FirebaseAuth.instance.currentUser?.uid;
      if (managerId != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManagerVehiclesListScreen(managerId: managerId)),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось получить ID менеджера для навигации.')),
        );
      }

    } catch (e) {
      print('Error confirming order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при подтверждении заказа: ${e.toString()}')),
      );
    }
  }

  // Function to cancel the order confirmation
  Future<void> _cancelConfirmation(BuildContext context) async {
     try {
      // Revert vehicle status back to 'active'
      await FirebaseFirestore.instance.collection(FirestoreCollections.vehicles).doc(vehicleId).update({ // Use constant
         'status': VehicleStatuses.active, // Use constant
         'exitTime': null, // Clear exit time
         'totalTime': 0, // Reset total time
         'paymentStatus': PaymentStatuses.pending, // Use constant // Reset payment status
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Подтверждение заказа отменено')),
      );

      // Navigate back to the vehicle detail screen
      final String? managerId = FirebaseAuth.instance.currentUser?.uid;
      if (managerId != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManagerVehicleDetailScreen(vehicleId: vehicleId, managerId: managerId)),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось получить ID менеджера для навигации.')),
        );
      }

    } catch (e) {
      print('Error canceling confirmation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отмене подтверждения: ${e.toString()}')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подтверждение Заказа'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestoreCollections.vehicles) // Use constant
            .doc(vehicleId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки заказа: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Заказ не найден'));
          }

          final vehicle = Vehicle.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🚗 ${vehicle.licensePlate}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8.0),
                 Text(
                  'Время обслуживания: ${(vehicle.totalTime / 60).floor()}h ${vehicle.totalTime % 60}m',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24.0),
                Text(
                  'СПИСОК ТОВАРОВ И УСЛУГ:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8.0),
                // Display list of added items
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vehicle.items.length,
                  itemBuilder: (context, index) {
                    final item = vehicle.items[index];
                    return ListTile(
                      title: Text('${item['name']} x${item['quantity']}'),
                      trailing: Text('${item['price'] * item['quantity']} тнг'),
                    );
                  },
                ),
                 const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Стоимость товаров/услуг:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${(vehicle.totalAmount - (vehicle.timeBasedCost ?? 0.0)).toStringAsFixed(2)} тнг', // Subtract timeBasedCost to get original product total
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Стоимость за время:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${(vehicle.timeBasedCost ?? 0.0).toStringAsFixed(2)} тнг',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ИТОГО:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${vehicle.totalAmount.toStringAsFixed(2)} тнг',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                // Confirmation buttons
                ElevatedButton(
                  onPressed: () => _confirmOrder(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('ПОДТВЕРДИТЬ'),
                ),
                const SizedBox(height: 16.0),
                 OutlinedButton(
                  onPressed: () => _cancelConfirmation(context),
                   style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('ОТМЕНИТЬ'),
                ),
              ],
            ),
          );
        },
      ),
      // No bottom navigation bar on this screen based on the wireframe
    );
  }
}
