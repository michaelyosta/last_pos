// lib/utils/time_cost_calculator.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TimeCostCalculator {
  /// Calculates the duration between an entry time and a current time.
  ///
  /// Takes [entryTime] as the Firestore Timestamp of entry and [currentTime] as the current DateTime.
  /// Returns the calculated [Duration]. If [currentTime] is before [entryTime],
  /// it returns `Duration.zero`.
  static Duration calculateDuration(Timestamp entryTime, DateTime currentTime) {
    if (currentTime.isBefore(entryTime.toDate())) {
      return Duration.zero; // Avoid negative durations
    }
    return currentTime.difference(entryTime.toDate());
  }

  /// Calculates the cost based on a given duration and price per minute.
  ///
  /// Takes [duration] representing the period of service and [pricePerMinute] as the cost for each minute.
  /// Returns a [double] representing the total calculated cost. If the [duration] is negative,
  /// it returns `0.0`.
  static double calculateTimeBasedCost(Duration duration, double pricePerMinute) {
    if (duration.isNegative) return 0.0;
    int totalMinutes = duration.inMinutes;
    return totalMinutes * pricePerMinute;
  }

  /// Formats a [Duration] into a string with HH:MM:SS format.
  ///
  /// Takes [duration] as the duration to be formatted.
  /// If the duration is negative, it's treated as `Duration.zero`.
  /// Returns a [String] representation of the duration, e.g., "02:30:15".
  static String formatDurationHHMMSS(Duration duration) {
    if (duration.isNegative) duration = Duration.zero;
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    int seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Formats a [Duration] into a string with Xh Ym format (e.g., "2h 30m" or "15m").
  ///
  /// Takes [duration] as the duration to be formatted.
  /// If the duration is negative, it's treated as `Duration.zero`.
  /// Returns a [String] representation. If hours are zero, only minutes are shown (e.g., "15m").
  /// Otherwise, shows hours and minutes (e.g., "2h 30m").
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
