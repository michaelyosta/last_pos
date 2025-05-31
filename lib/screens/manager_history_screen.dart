import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:pos_app/models/vehicle.dart'; // Import Vehicle model
import 'package:pos_app/widgets/bottom_navigation_bar.dart'; // Import bottom navigation bar
import 'package:pos_app/widgets/vehicle_list_item.dart'; // Import VehicleListItem (will reuse)
import 'manager_vehicles_list_screen.dart'; // Import vehicle list screen
import 'manager_scan_vehicle_screen.dart'; // Import scan screen
import 'manager_vehicle_detail_screen.dart'; // Import detail screen
import 'package:pos_app/models/app_settings.dart'; // Import AppSettings model
import 'package:pos_app/core/constants.dart'; // Import constants

class ManagerHistoryScreen extends StatefulWidget { // Changed to StatefulWidget to use widget.managerId
  final String managerId;

  const ManagerHistoryScreen({Key? key, required this.managerId}) : super(key: key);

  @override
  _ManagerHistoryScreenState createState() => _ManagerHistoryScreenState();
}

class _ManagerHistoryScreenState extends State<ManagerHistoryScreen> {
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
      return const Text('История Обслуживания');
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
                .where('status', isEqualTo: VehicleStatuses.completed) // Use constant // Filter for completed vehicles
                .where('managerId', isEqualTo: widget.managerId) // Added this line
                .orderBy('exitTime', descending: true) // Order by exit time
                .limit(FIRESTORE_PAGE_LIMIT) // Basic pagination: Load more functionality not yet implemented.
                .snapshots()
                .map((snapshot) => snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList()),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Ошибка загрузки истории: ${snapshot.error}'));
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
                  return const Center(child: Text('История обслуживания пуста'));
                }
              }
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
