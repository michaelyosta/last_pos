import 'package:flutter/material.dart';
import 'package:pos_app/models/vehicle.dart';
import 'package:pos_app/widgets/timer_widget.dart'; // We will create this widget next

import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final double pricePerMinute;

  const VehicleListItem({
    Key? key,
    required this.vehicle,
    required this.onTap,
    required this.pricePerMinute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: CircleAvatar(
          // Display vehicle photo, or a placeholder if not available
          backgroundImage: vehicle.photoUrl.isNotEmpty
              ? NetworkImage(vehicle.photoUrl)
              : null,
          child: vehicle.photoUrl.isEmpty
              ? const Icon(Icons.directions_car)
              : null,
        ),
        title: Text(vehicle.licensePlate),
        trailing: vehicle.status == 'active'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TimerWidget(entryTime: vehicle.entryTime),
                  const SizedBox(width: 8.0),
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
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    },
                  ),
                ],
              )
            : Text('${(vehicle.totalTime / 60).floor()}h ${vehicle.totalTime % 60}m'), // Display total time for completed vehicles
        onTap: onTap,
      ),
    );
  }
}
