import 'package:flutter/material.dart';
import 'package:pos_app/models/vehicle.dart';
import 'package:pos_app/widgets/timer_widget.dart'; // We will create this widget next

class VehicleListItem extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const VehicleListItem({
    Key? key,
    required this.vehicle,
    required this.onTap,
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
            ? TimerWidget(entryTime: vehicle.entryTime) // Use the TimerWidget for active vehicles
            : Text('${(vehicle.totalTime / 60).floor()}h ${vehicle.totalTime % 60}m'), // Display total time for completed vehicles
        onTap: onTap,
      ),
    );
  }
}
