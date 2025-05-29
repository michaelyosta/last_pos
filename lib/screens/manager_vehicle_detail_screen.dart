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
import 'package:pos_app/core/constants.dart'; // Import constants

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

class _ManagerVehicleDetailScreenState extends State<ManagerVehicleDetailScreen> {
  // Helper method for Vehicle Header
  Widget _buildVehicleHeader(Vehicle vehicle, double pricePerMinute, BuildContext context) {
    return Center(
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
          vehicle.status == VehicleStatuses.active
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TimerWidget(entryTime: vehicle.entryTime),
                    const SizedBox(width: 16.0),
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(FirestoreCollections.serverTime)
                          .doc('current') 
                          .snapshots(),
                      builder: (context, serverTimeSnapshot) {
                        if (!serverTimeSnapshot.hasData) {
                          return const Text('ИТОГО: Calculating...');
                        }
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
    );
  }

  // Helper method for Category Selection Section
  Widget _buildCategorySelectionSection(Vehicle vehicle, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ДОБАВИТЬ ТОВАРЫ/УСЛУГИ:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8.0),
        StreamBuilder<List<Category>>(
          stream: FirebaseFirestore.instance
              .collection(FirestoreCollections.categories)
              .orderBy('displayName')
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
      ],
    );
  }

  // Helper method for Added Items Section
  Widget _buildAddedItemsSection(Vehicle vehicle, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ТЕКУЩИЙ ЗАКАЗ:', // Changed text
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8.0),
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
      ],
    );
  }

  // Helper method for Price Summary Section
  Widget _buildPriceSummarySection(Vehicle vehicle, double pricePerMinute, BuildContext context) {
    return Column(
      children: [
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
                'Стоимость за время (${pricePerMinute.toStringAsFixed(0)} тнг/мин):', // Ensure pricePerMinute is formatted if it can have decimals
                style: Theme.of(context).textTheme.titleMedium,
              ),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(FirestoreCollections.serverTime)
                    .doc('current')
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
              StreamBuilder<Object>(
                stream: vehicle.status == VehicleStatuses.active
                    ? Stream.periodic(const Duration(seconds: 1), (int i) => i)
                    : Stream.value(Object()), // For non-active, emit a valid Object
                builder: (context, timerSnapshot) {
                  if (vehicle.status == VehicleStatuses.active) {
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
                    return Text(
                      '${vehicle.totalAmount.toStringAsFixed(2)} тнг',
                      style: Theme.of(context).textTheme.titleLarge,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method for Complete Button
  Widget _buildCompleteButton(Vehicle vehicle, double pricePerMinute, BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          DateTime now = DateTime.now();
          Duration difference = now.difference(vehicle.entryTime.toDate());
          int totalMinutes = difference.inMinutes;
          double timeBasedCost = totalMinutes * pricePerMinute;
          double finalTotalAmount = vehicle.totalAmount + timeBasedCost;

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
                        Navigator.pop(context, PaymentMethods.qr);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.money),
                      title: const Text('Оплата Наличными'),
                      onTap: () {
                        Navigator.pop(context, PaymentMethods.cash);
                      },
                    ),
                  ],
                ),
              );
            },
          );

          if (paymentMethod != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentQrScreen(
                  vehicleId: vehicle.id,
                  totalAmount: finalTotalAmount,
                  qrImagePath: 'qr_code/photo_2025-05-27_18-33-18.jpg',
                  paymentMethod: paymentMethod,
                ),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            print('Error completing service: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка при завершении обслуживания: ${e.toString()}')),
            );
          }
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
      ),
      child: const Text('ЗАВЕРШИТЬ'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали Машины'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestoreCollections.vehicles) // Use constant
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
            stream: FirebaseFirestore.instance.collection(FirestoreCollections.settings).doc(FirestoreDocuments.globalSettings).snapshots(), // Use constants
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
                    _buildVehicleHeader(vehicle, pricePerMinute, context),
                    const SizedBox(height: 24.0),
                    _buildCategorySelectionSection(vehicle, context),
                    const SizedBox(height: 24.0),
                    _buildAddedItemsSection(vehicle, context),
                    _buildPriceSummarySection(vehicle, pricePerMinute, context),
                    const SizedBox(height: 24.0),
                    _buildCompleteButton(vehicle, pricePerMinute, context),
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
