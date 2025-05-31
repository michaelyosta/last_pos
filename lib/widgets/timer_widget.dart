import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:pos_app/utils/time_cost_calculator.dart'; // Import TimeCostCalculator

class TimerWidget extends StatefulWidget {
  final Timestamp entryTime;

  const TimerWidget({Key? key, required this.entryTime}) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;
  String _displayTime = "00:00:00";

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateDisplayTime();
        });
      }
    });
    _updateDisplayTime(); // Update immediately on initialization
  }

  void _updateDisplayTime() {
    DateTime now = DateTime.now();
    // DateTime entryDateTime = widget.entryTime.toDate(); // Not needed directly
    Duration difference = TimeCostCalculator.calculateDuration(widget.entryTime, now);
    _displayTime = TimeCostCalculator.formatDurationHHMMSS(difference);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayTime,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
