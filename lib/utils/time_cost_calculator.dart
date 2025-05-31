// lib/utils/time_cost_calculator.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TimeCostCalculator {
  /// Calculates the duration between an entry time (Timestamp) and a current time.
  static Duration calculateDuration(Timestamp entryTime, DateTime currentTime) {
    if (currentTime.isBefore(entryTime.toDate())) {
      return Duration.zero; // Avoid negative durations
    }
    return currentTime.difference(entryTime.toDate());
  }

  /// Calculates the cost based on duration and price per minute.
  static double calculateTimeBasedCost(Duration duration, double pricePerMinute) {
    if (duration.isNegative) return 0.0;
    int totalMinutes = duration.inMinutes;
    return totalMinutes * pricePerMinute;
  }

  /// Formats a duration into HH:MM:SS string.
  static String formatDurationHHMMSS(Duration duration) {
    if (duration.isNegative) duration = Duration.zero;
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats a duration into Xh Ym string (e.g., "2h 30m").
  static String formatDurationHoursMinutes(Duration duration) {
    if (duration.isNegative) duration = Duration.zero;
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
