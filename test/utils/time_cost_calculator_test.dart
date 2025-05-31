import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_app/utils/time_cost_calculator.dart';

void main() {
  group('TimeCostCalculator', () {
    group('calculateDuration', () {
      test('should return Duration.zero if currentTime is before entryTime', () {
        final entryTime = Timestamp.fromDate(DateTime(2023, 1, 1, 10, 0, 0));
        final currentTime = DateTime(2023, 1, 1, 9, 59, 59);
        final duration = TimeCostCalculator.calculateDuration(entryTime, currentTime);
        expect(duration, Duration.zero);
      });

      test('should calculate correct duration for valid inputs', () {
        final entryTime = Timestamp.fromDate(DateTime(2023, 1, 1, 10, 0, 0));
        final currentTime = DateTime(2023, 1, 1, 10, 5, 30); // 5 minutes 30 seconds later
        final duration = TimeCostCalculator.calculateDuration(entryTime, currentTime);
        expect(duration, const Duration(minutes: 5, seconds: 30));
      });

      test('should return Duration.zero if entryTime and currentTime are the same', () {
        final entryTime = Timestamp.fromDate(DateTime(2023, 1, 1, 10, 0, 0));
        final currentTime = DateTime(2023, 1, 1, 10, 0, 0);
        final duration = TimeCostCalculator.calculateDuration(entryTime, currentTime);
        expect(duration, Duration.zero);
      });
    });

    group('calculateTimeBasedCost', () {
      test('should return 0.0 if duration is negative', () {
        final cost = TimeCostCalculator.calculateTimeBasedCost(const Duration(seconds: -10), 10.0);
        expect(cost, 0.0);
      });

      test('should return 0.0 if duration is zero', () {
        final cost = TimeCostCalculator.calculateTimeBasedCost(Duration.zero, 10.0);
        expect(cost, 0.0);
      });

      test('should calculate correct cost for valid duration and pricePerMinute', () {
        final cost = TimeCostCalculator.calculateTimeBasedCost(const Duration(minutes: 30), 10.0); // 30 minutes, 10 per minute
        expect(cost, 300.0);
      });

      test('should calculate correct cost for duration less than a minute (truncates to 0 minutes)', () {
        final cost = TimeCostCalculator.calculateTimeBasedCost(const Duration(seconds: 59), 10.0);
        expect(cost, 0.0); // 0 minutes * 10.0
      });

      test('should calculate correct cost for duration just over a minute', () {
        final cost = TimeCostCalculator.calculateTimeBasedCost(const Duration(minutes: 1, seconds: 15), 10.0);
        expect(cost, 10.0); // 1 minute * 10.0
      });

      test('should return 0.0 if pricePerMinute is zero', () {
        final cost = TimeCostCalculator.calculateTimeBasedCost(const Duration(minutes: 30), 0.0);
        expect(cost, 0.0);
      });
    });

    group('formatDurationHHMMSS', () {
      test('should format zero duration correctly', () {
        expect(TimeCostCalculator.formatDurationHHMMSS(Duration.zero), "00:00:00");
      });

      test('should format negative duration as zero', () {
        expect(TimeCostCalculator.formatDurationHHMMSS(const Duration(seconds: -10)), "00:00:00");
      });

      test('should format seconds only correctly', () {
        expect(TimeCostCalculator.formatDurationHHMMSS(const Duration(seconds: 5)), "00:00:05");
      });

      test('should format minutes and seconds correctly', () {
        expect(TimeCostCalculator.formatDurationHHMMSS(const Duration(minutes: 12, seconds: 30)), "00:12:30");
      });

      test('should format hours, minutes, and seconds correctly', () {
        expect(TimeCostCalculator.formatDurationHHMMSS(const Duration(hours: 2, minutes: 25, seconds: 15)), "02:25:15");
      });

      test('should format large hours correctly', () {
        expect(TimeCostCalculator.formatDurationHHMMSS(const Duration(hours: 26, minutes: 5, seconds: 1)), "26:05:01");
      });
    });

    group('formatDurationHoursMinutes', () {
      test('should format zero duration correctly', () {
        expect(TimeCostCalculator.formatDurationHoursMinutes(Duration.zero), "0m");
      });

      test('should format negative duration as zero', () {
        expect(TimeCostCalculator.formatDurationHoursMinutes(const Duration(minutes: -10)), "0m");
      });

      test('should format minutes only (less than an hour) correctly', () {
        expect(TimeCostCalculator.formatDurationHoursMinutes(const Duration(minutes: 45)), "45m");
      });

      test('should format exactly one hour correctly', () {
        expect(TimeCostCalculator.formatDurationHoursMinutes(const Duration(hours: 1)), "1h 0m");
      });

      test('should format hours and minutes correctly', () {
        expect(TimeCostCalculator.formatDurationHoursMinutes(const Duration(hours: 3, minutes: 20)), "3h 20m");
      });

      test('should format duration with only hours correctly', () {
        expect(TimeCostCalculator.formatDurationHoursMinutes(const Duration(hours: 5, minutes: 0)), "5h 0m");
      });
    });
  });
}
