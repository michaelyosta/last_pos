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
import 'package:pos_app/core/constants.dart'; // Import constants

class ManagerVehiclesListScreen extends StatefulWidget { // Changed to StatefulWidget
  final String managerId;
  const ManagerVehiclesListScreen({Key? key, required this.managerId}) : super(key: key);

  @override
  _ManagerVehiclesListScreenState createState() => _ManagerVehiclesListScreenState();
}

class _ManagerVehiclesListScreenState extends State<ManagerVehiclesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildAppBarTitle() {
    if (_isSearching) {
      return TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Поиск по гос. номеру...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white, fontSize: 16.0),
      );
    } else {
      return const Text('Активные Машины');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear(); // Also clears _searchQuery via listener
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) { // Added mounted check
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
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

          return StreamBuilder<List<Vehicle>>(
            stream: FirebaseFirestore.instance
                .collection(FirestoreCollections.vehicles) // Use constant
                .where('status', isEqualTo: VehicleStatuses.active) // Use constant
                .where('managerId', isEqualTo: widget.managerId) // Added this line
                .orderBy('entryTime', descending: true)
                .limit(FIRESTORE_PAGE_LIMIT) // Basic pagination: Load more functionality not yet implemented.
                .snapshots()
                .map((snapshot) => snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList()),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Vehicle> allVehicles = snapshot.data ?? [];
              List<Vehicle> displayedVehicles = allVehicles;

              if (_searchQuery.isNotEmpty) {
                displayedVehicles = allVehicles.where((vehicle) {
                  return vehicle.licensePlate.toLowerCase().contains(_searchQuery.toLowerCase().trim());
                }).toList();
              }

              if (displayedVehicles.isNotEmpty) {
                return ListView.builder(
                  itemCount: displayedVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = displayedVehicles[index];
                    return VehicleListItem(
                      vehicle: vehicle,
                      pricePerMinute: pricePerMinute,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManagerVehicleDetailScreen(
                              vehicleId: vehicle.id,
                              managerId: widget.managerId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              } else {
                if (_searchQuery.isNotEmpty) {
                  return const Center(child: Text('Машины с таким номером не найдены.'));
                } else {
                  return const Center(child: Text('Нет активных машин'));
                }
              }
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
