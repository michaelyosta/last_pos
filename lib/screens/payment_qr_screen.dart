import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:pos_app/models/vehicle.dart'; // Import Vehicle model
import 'manager_vehicles_list_screen.dart'; // Import vehicle list screen for navigation
import 'package:pos_app/models/app_settings.dart'; // Import AppSettings model
import 'package:pos_app/core/constants.dart'; // Import constants
import 'package:pos_app/utils/time_cost_calculator.dart'; // Import TimeCostCalculator

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
      // Get current manager ID
      String? managerId = FirebaseAuth.instance.currentUser?.uid;

      if (managerId == null) {
        // print('Error: Manager ID is null. Cannot complete payment without manager ID.');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ошибка: ID менеджера не найден. Невозможно завершить платеж.')),
          );
        }
        return; // Do not proceed if managerId is null
      }

      // Fetch the vehicle to get its entry time and current total amount
      DocumentSnapshot vehicleDoc = await FirebaseFirestore.instance.collection(FirestoreCollections.vehicles).doc(vehicleId).get(); // Use constant
      Vehicle vehicle = Vehicle.fromFirestore(vehicleDoc);

      // Use client-side time for calculations
      DateTime finalizationTime = DateTime.now();
      // int totalMinutes = finalizationTime.difference(vehicle.entryTime.toDate()).inMinutes; // Old calculation

      // Fetch app settings to get price per minute
      DocumentSnapshot settingsDoc = await FirebaseFirestore.instance.collection(FirestoreCollections.settings).doc(FirestoreDocuments.globalSettings).get(); // Use constants
      AppSettings appSettings = AppSettings.fromFirestore(settingsDoc);
      double pricePerMinute = appSettings.pricePerMinute;

      // Calculate time-based cost using TimeCostCalculator
      Duration actualDifference = TimeCostCalculator.calculateDuration(vehicle.entryTime, finalizationTime);
      int totalMinutes = actualDifference.inMinutes; // This is correct for storing total service time
      double timeBasedCost = TimeCostCalculator.calculateTimeBasedCost(actualDifference, pricePerMinute);

      // Calculate new total amount. vehicle.totalAmount is the sum of item costs.
      // The passed `totalAmount` to this screen was already finalTotalAmount from detail screen.
      // However, for consistency and to ensure the final stored amount reflects this exact calculation:
      double newTotalAmount = vehicle.totalAmount + timeBasedCost;
      // It's important that vehicle.totalAmount here refers to the sum of *items* before time cost.
      // If vehicle.totalAmount from Firestore for an active vehicle already includes some preliminary time calc,
      // this might lead to double counting. Assuming vehicle.totalAmount for active is items only.

      Map<String, dynamic> updateData = {
        'paymentStatus': PaymentStatuses.completed, // Use constant
        'status': VehicleStatuses.completed, // Use constant // Mark vehicle as completed
        'paymentMethod': paymentMethod, // Set payment method from passed argument
        'exitTime': FieldValue.serverTimestamp(), // Use server timestamp
        'totalTime': totalMinutes, // Calculated using client-side time
        'timeBasedCost': timeBasedCost, // Calculated using client-side time
        'totalAmount': newTotalAmount, // Calculated using client-side time
        'orderCompletionTimestamp': FieldValue.serverTimestamp(), // Use server timestamp
      };

      if (managerId != null) {
        updateData['managerId'] = managerId; // Add manager ID
      }

      await FirebaseFirestore.instance.collection(FirestoreCollections.vehicles).doc(vehicleId).update(updateData); // Use constant

      if (context.mounted) { // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Оплата завершена, заказ выполнен')),
        );

        // Navigate back to the active vehicles list
        // managerId is already fetched and null-checked at the beginning of this method.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ManagerVehiclesListScreen(managerId: managerId!)), // managerId is confirmed not null here
        );
      }

    } catch (e) {
      // print('Error completing payment: $e');
      if (context.mounted) { // Check if the widget is still in the tree
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при завершении оплаты: ${e.toString()}')),
        );
      }
    }
  }

  // Removed extraneous SnackBar definition that was here

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
                // TODO: Implement dynamic QR code generation. Currently uses a static asset.
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
