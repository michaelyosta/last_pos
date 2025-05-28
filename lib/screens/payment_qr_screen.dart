import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pos_app/models/vehicle.dart'; // Import Vehicle model
import 'manager_vehicles_list_screen.dart'; // Import vehicle list screen for navigation
import 'package:pos_app/models/app_settings.dart'; // Import AppSettings model

class PaymentQrScreen extends StatelessWidget {
  final String vehicleId;
  final double totalAmount;
  final String qrImagePath;
  final String paymentMethod;

  const PaymentQrScreen({
    Key? key,
    required this.vehicleId,
    required this.totalAmount,
    required this.qrImagePath,
    required this.paymentMethod,
  }) : super(key: key);

  // Function to finalize the payment and complete the order
  Future<void> _completePayment(BuildContext context) async {
    try {
      // Get current server time
      DateTime serverTime = await FirebaseFirestore.instance.collection('serverTime').add({'timestamp': FieldValue.serverTimestamp()}).then((ref) => ref.get()).then((snapshot) => snapshot.get('timestamp').toDate());

      // Fetch the vehicle to get its entry time and current total amount
      DocumentSnapshot vehicleDoc = await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).get();
      Vehicle vehicle = Vehicle.fromFirestore(vehicleDoc);

      // Calculate total time in minutes
      int totalMinutes = serverTime.difference(vehicle.entryTime.toDate()).inMinutes;

      // Fetch app settings to get price per minute
      DocumentSnapshot settingsDoc = await FirebaseFirestore.instance.collection('settings').doc('global_settings').get();
      AppSettings appSettings = AppSettings.fromFirestore(settingsDoc);
      double pricePerMinute = appSettings.pricePerMinute;

      // Calculate time-based cost
      double timeBasedCost = totalMinutes * pricePerMinute;

      // Calculate new total amount (should be consistent with what was passed)
      double newTotalAmount = vehicle.totalAmount + timeBasedCost;


      await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).update({
        'paymentStatus': 'completed',
        'status': 'completed', // Mark vehicle as completed
        'paymentMethod': paymentMethod, // Set payment method from passed argument
        'exitTime': Timestamp.fromDate(serverTime),
        'totalTime': totalMinutes,
        'timeBasedCost': timeBasedCost, // Save time-based cost
        'totalAmount': newTotalAmount, // Update total amount
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
        title: const Text('Оплата'), // Changed title to be more general
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Removed vehicle.licensePlate display as it's not passed directly
            // Text(
            //   '🚗 ${vehicle.licensePlate}',
            //   style: Theme.of(context).textTheme.headlineSmall,
            //   textAlign: TextAlign.center,
            // ),
            const SizedBox(height: 8.0),
            Text(
              'Сумма к оплате: ${totalAmount.toStringAsFixed(2)} тнг', // Use passed totalAmount
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: Center(
                // Display QR code image
                child: Image.asset(
                  qrImagePath,
                  fit: BoxFit.contain,
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
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text('ОТМЕНИТЬ'),
            ),
          ],
        ),
      ),
    );
  }
}
