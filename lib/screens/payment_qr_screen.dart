import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pos_app/models/vehicle.dart'; // Import Vehicle model
import 'manager_vehicles_list_screen.dart'; // Import vehicle list screen for navigation

class PaymentQrScreen extends StatelessWidget {
  final String vehicleId;

  const PaymentQrScreen({Key? key, required this.vehicleId}) : super(key: key);

  // Function to finalize the payment and complete the order
  Future<void> _completePayment(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).update({
        'paymentStatus': 'completed',
        'status': 'completed', // Mark vehicle as completed
        'paymentMethod': 'qr', // Set payment method
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оплата завершена, заказ выполнен')),
      );

      // Navigate back to the active vehicles list
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ManagerVehiclesListScreen()),
      );

    } catch (e) {
      print('Error completing payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при завершении оплаты: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оплата QR-кодом'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '🚗 ${vehicle.licensePlate}',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Сумма к оплате: ${vehicle.totalAmount} тнг',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24.0),
                Expanded(
                  child: Center(
                    // Placeholder for QR code image
                    child: Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[300], // Placeholder color
                      child: const Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () => _completePayment(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('ОПЛАТА ЗАВЕРШЕНА'),
                ),
                const SizedBox(height: 16.0),
                OutlinedButton(
                  onPressed: () {
                    // TODO: Implement cancel logic, maybe navigate back to confirmation or detail screen
                    Navigator.pop(context); // Simple pop for now
                  },
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
    );
  }
}
