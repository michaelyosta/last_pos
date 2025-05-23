import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pos_app/models/vehicle.dart'; // Import Vehicle model
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth for admin ID
import 'admin_pending_orders_screen.dart'; // Import pending orders screen for navigation

class AdminOrderReviewScreen extends StatefulWidget { // Converted to StatefulWidget
  final String vehicleId;

  const AdminOrderReviewScreen({Key? key, required this.vehicleId}) : super(key: key);

  @override
  _AdminOrderReviewScreenState createState() => _AdminOrderReviewScreenState();
}

class _AdminOrderReviewScreenState extends State<AdminOrderReviewScreen> { // Added State class
  final TextEditingController _commentController = TextEditingController();

  // Function to approve the order
  Future<void> _approveOrder() async {
    try {
      String adminId = FirebaseAuth.instance.currentUser!.uid; // Get current admin ID
      await FirebaseFirestore.instance.collection('vehicles').doc(widget.vehicleId).update({
        'paymentStatus': 'approved', // Mark as approved
        'adminId': adminId, // Record admin who approved
        'adminComment': null, // Clear any previous comment
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заказ подтвержден')),
      );

      // Navigate back to the pending orders list
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPendingOrdersScreen()),
      );

    } catch (e) {
      print('Error approving order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при подтверждении заказа: ${e.toString()}')),
      );
    }
  }

  // Function to reject the order
  Future<void> _rejectOrder() async {
    try {
      String adminId = FirebaseAuth.instance.currentUser!.uid; // Get current admin ID
      String comment = _commentController.text.trim();

      await FirebaseFirestore.instance.collection('vehicles').doc(widget.vehicleId).update({
        'paymentStatus': 'rejected', // Mark as rejected
        'adminId': adminId, // Record admin who rejected
        'adminComment': comment.isNotEmpty ? comment : 'Без комментария', // Add admin comment
        'status': 'active', // Revert status to active
        'exitTime': null, // Clear exit time
        'totalTime': 0, // Reset total time
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заказ отклонен')),
      );

      // Navigate back to the pending orders list
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPendingOrdersScreen()),
      );

    } catch (e) {
      print('Error rejecting order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отклонении заказа: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Проверка Заказа'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.vehicleId)
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
                        'ИТОГО:',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${vehicle.totalAmount} тнг',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                // Admin comment field for rejection
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Комментарий при отклонении (необязательно)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),
                // Approve and Reject buttons
                ElevatedButton(
                  onPressed: _approveOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('ПОДТВЕРДИТЬ'),
                ),
                const SizedBox(height: 16.0),
                 OutlinedButton(
                  onPressed: _rejectOrder,
                   style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text('ОТКЛОНИТЬ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
