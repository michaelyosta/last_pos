import 'package:flutter/material.dart';
import 'package:pos_app/models/vehicle.dart';
import 'package:pos_app/widgets/timer_widget.dart';
import 'package:pos_app/core/constants.dart';
import 'package:pos_app/utils/time_cost_calculator.dart'; // Import TimeCostCalculator

// vehicle.entryTime.toDate() requires Timestamp from cloud_firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

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
        trailing: vehicle.status == VehicleStatuses.active // Use constant
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TimerWidget(entryTime: vehicle.entryTime),
                  const SizedBox(width: 8.0),
                  StreamBuilder<Duration>(
                    stream: Stream.periodic(const Duration(seconds: 1), (_) {
                      return DateTime.now().difference(vehicle.entryTime.toDate());
                    }),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        // Calculate initial value immediately for the first frame
                        DateTime now = DateTime.now();
                        DateTime entryDateTime = vehicle.entryTime.toDate();
                        // Duration difference = now.difference(entryDateTime); // Not needed directly
                        Duration difference = TimeCostCalculator.calculateDuration(vehicle.entryTime, now);
                        // int totalMinutes = difference.inMinutes; // Not needed directly
                        double timeBasedCost = TimeCostCalculator.calculateTimeBasedCost(difference, pricePerMinute);
                        return Text(
                          '${timeBasedCost.toStringAsFixed(2)} тнг',
                          style: Theme.of(context).textTheme.bodyMedium,
                        );
                      }
                      final Duration difference = snapshot.data!;
                      // final int totalMinutes = difference.inMinutes; // Not needed directly
                      final double timeBasedCost = TimeCostCalculator.calculateTimeBasedCost(difference, pricePerMinute);
                      return Text(
                        '${timeBasedCost.toStringAsFixed(2)} тнг',
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    },
                  ),
                ],
              )
            : Text(TimeCostCalculator.formatDurationHoursMinutes(Duration(minutes: vehicle.totalTime))), // Use formatter
        onTap: onTap,
      ),
    );
  }
}
