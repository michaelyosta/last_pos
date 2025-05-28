import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pos_app/models/vehicle.dart'; // Import Vehicle model
import 'package:pos_app/widgets/bottom_navigation_bar.dart'; // Import bottom navigation bar
import 'package:pos_app/widgets/timer_widget.dart'; // Import TimerWidget
import 'manager_vehicles_list_screen.dart'; // Import vehicle list screen
import 'manager_scan_vehicle_screen.dart'; // Import scan screen
import 'manager_history_screen.dart'; // Import history screen
import 'package:pos_app/models/category.dart'; // Import Category model
import 'product_selection_screen.dart'; // Import ProductSelectionScreen
import 'manager_order_confirmation_screen.dart'; // Import order confirmation screen
import 'package:pos_app/models/app_settings.dart'; // Import AppSettings model
import 'package:pos_app/screens/payment_qr_screen.dart'; // Import PaymentQrScreen

class ManagerVehicleDetailScreen extends StatefulWidget {
  final String vehicleId;
  final String managerId; // Added managerId

  const ManagerVehicleDetailScreen({
    Key? key,
    required this.vehicleId,
    required this.managerId, // Added managerId
  }) : super(key: key);

  @override
  _ManagerVehicleDetailScreenState createState() => _ManagerVehicleDetailScreenState();
}

class _ManagerVehicleDetailScreenState extends State<ManagerVehicleDetailScreen> { // Added State class
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали Машины'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.vehicleId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки деталей машины: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Машина не найдена'));
          }

          final vehicle = Vehicle.fromFirestore(snapshot.data!);

          return StreamBuilder<DocumentSnapshot>(
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

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display vehicle photo and license plate
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: vehicle.photoUrl.isNotEmpty
                                ? NetworkImage(vehicle.photoUrl)
                                : null,
                            child: vehicle.photoUrl.isEmpty
                                ? const Icon(Icons.directions_car, size: 50)
                                : null,
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            vehicle.licensePlate,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8.0),
                          // Display timer for active vehicles, or total time for completed
                          vehicle.status == 'active'
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TimerWidget(entryTime: vehicle.entryTime),
                                    const SizedBox(width: 16.0),
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('serverTime')
                                          .doc('current') // Assuming a document to get server time
                                          .snapshots(),
                                      builder: (context, serverTimeSnapshot) {
                                        if (!serverTimeSnapshot.hasData) {
                                          return const Text('ИТОГО: Calculating...');
                                        }
                                        // Use current local time for calculation if server time is not readily available or for more responsive UI
                                        DateTime now = DateTime.now();
                                        DateTime entryDateTime = vehicle.entryTime.toDate();
                                        Duration difference = now.difference(entryDateTime);
                                        int totalMinutes = difference.inMinutes;
                                        double timeBasedCost = totalMinutes * pricePerMinute;

                                        return Text(
                                          'ИТОГО: ${timeBasedCost.toStringAsFixed(2)} тнг',
                                          style: Theme.of(context).textTheme.titleMedium,
                                        );
                                      },
                                    ),
                                  ],
                                )
                              : Text('Время обслуживания: ${(vehicle.totalTime / 60).floor()}h ${vehicle.totalTime % 60}m'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Sections for adding items (ИНСТРУМЕНТЫ, МАГАЗИН, РАСХОДНИКИ, ШТРАФЫ)
                    Text(
                      'ДОБАВИТЬ ТОВАРЫ/УСЛУГИ:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8.0),
                    StreamBuilder<List<Category>>(
                      stream: FirebaseFirestore.instance
                          .collection('categories')
                          .orderBy('displayName') // Order categories alphabetically
                          .snapshots()
                          .map((snapshot) => snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList()),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Ошибка загрузки категорий: ${snapshot.error}'));
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('Нет доступных категорий'));
                        }

                        final categories = snapshot.data!;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return ListTile(
                              title: Text(category.displayName),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductSelectionScreen(
                                      vehicleId: vehicle.id,
                                      categoryId: category.id,
                                      categoryDisplayName: category.displayName,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24.0),
                    Text(
                      'ДОБАВИТЬ ТОВАРЫ/УСЛУГИ:',
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
                            '${vehicle.totalAmount} тнг',
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
                            'Стоимость за время (${pricePerMinute} тнг/мин):',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('serverTime')
                                .doc('current') // Assuming a document to get server time
                                .snapshots(),
                            builder: (context, serverTimeSnapshot) {
                              if (!serverTimeSnapshot.hasData) {
                                return const Text('Calculating...');
                              }
                              DateTime now = DateTime.now();
                              DateTime entryDateTime = vehicle.entryTime.toDate();
                              Duration difference = now.difference(entryDateTime);
                              int totalMinutes = difference.inMinutes;
                              double timeBasedCost = totalMinutes * pricePerMinute;

                              return Text(
                                '${timeBasedCost.toStringAsFixed(2)} тнг',
                                style: Theme.of(context).textTheme.titleMedium,
                              );
                            },
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
                          StreamBuilder<Object>( // Using StreamBuilder to update total for active vehicles
                            stream: vehicle.status == 'active' 
                                  ? Stream.periodic(const Duration(seconds: 1), (int i) => i) 
                                  : Stream.value(null), // For non-active, a single value stream
                            builder: (context, timerSnapshot) {
                              if (vehicle.status == 'active') {
                                DateTime now = DateTime.now();
                                DateTime entryDateTime = vehicle.entryTime.toDate();
                                Duration difference = now.difference(entryDateTime);
                                int totalMinutes = difference.inMinutes;
                                double liveTimeBasedCost = totalMinutes * pricePerMinute;
                                double displayTotal = vehicle.totalAmount + liveTimeBasedCost;
                                return Text(
                                  '${displayTotal.toStringAsFixed(2)} тнг',
                                  style: Theme.of(context).textTheme.titleLarge,
                                );
                              } else {
                                // For 'completed' or other non-active statuses, vehicle.totalAmount is the grand total
                                return Text(
                                  '${vehicle.totalAmount.toStringAsFixed(2)} тнг',
                                  style: Theme.of(context).textTheme.titleLarge,
                                );
                              }
                            }
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    // "ЗАВЕРШИТЬ" button
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          // Calculate final total amount including time-based cost
                          DateTime now = DateTime.now();
                          Duration difference = now.difference(vehicle.entryTime.toDate());
                          int totalMinutes = difference.inMinutes;
                          double timeBasedCost = totalMinutes * pricePerMinute;
                          double finalTotalAmount = vehicle.totalAmount + timeBasedCost;

                          // Show payment method selection dialog
                          String? paymentMethod = await showDialog<String>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Выберите способ оплаты'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: const Icon(Icons.qr_code),
                                      title: const Text('Оплата QR'),
                                      onTap: () {
                                        Navigator.pop(context, 'qr');
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.money),
                                      title: const Text('Оплата Наличными'),
                                      onTap: () {
                                        Navigator.pop(context, 'cash');
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );

                          if (paymentMethod != null) {
                            // Navigate to PaymentQrScreen regardless of method
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentQrScreen(
                                  vehicleId: vehicle.id,
                                  totalAmount: finalTotalAmount,
                                  qrImagePath: 'qr_code/photo_2025-05-27_18-33-18.jpg',
                                  paymentMethod: paymentMethod, // Pass selected method
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          print('Error completing service: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ошибка при завершении обслуживания: ${e.toString()}')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text('ЗАВЕРШИТЬ'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: ManagerBottomNavigationBar(
        currentIndex: 0, // Stay on 'Выбор машины' section conceptually
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ManagerHistoryScreen(managerId: widget.managerId)),
            );
          }
        },
      ),
    );
  }
}
