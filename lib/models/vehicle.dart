import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String licensePlate;
  final String photoUrl;
  final String licensePlatePhotoUrl;
  final String status; // "active" | "completed" | "pending"
  final Timestamp entryTime;
  final Timestamp? exitTime;
  final int totalTime; // in minutes
  final String managerId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final double? timeBasedCost; // New field for time-based cost
  final String? paymentMethod; // "cash" | "qr"
  final String paymentStatus; // "pending" | "approved" | "rejected" | "completed"
  final String? adminComment;
  final String? adminId;

  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.photoUrl,
    required this.licensePlatePhotoUrl,
    required this.status,
    required this.entryTime,
    this.exitTime,
    required this.totalTime,
    required this.managerId,
    required this.items,
    required this.totalAmount,
    this.timeBasedCost, // Initialize new field
    this.paymentMethod,
    required this.paymentStatus,
    this.adminComment,
    this.adminId,
  });

  // Factory constructor to create a Vehicle from a Firestore DocumentSnapshot
  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Vehicle(
      id: doc.id,
      licensePlate: data['licensePlate'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      licensePlatePhotoUrl: data['licensePlatePhotoUrl'] ?? '',
      status: data['status'] ?? 'active',
      entryTime: data['entryTime'] ?? Timestamp.now(),
      exitTime: data['exitTime'],
      totalTime: data['totalTime'] ?? 0,
      managerId: data['managerId'] ?? '',
      items: (data['items'] as List? ?? []).map((item) {
        return {
          'id': item['id'],
          'name': item['name'],
          'category': item['category'],
          'price': (item['price'] as num).toDouble(), // Ensure price is double
          'quantity': item['quantity'],
        };
      }).toList(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      timeBasedCost: (data['timeBasedCost'] as num?)?.toDouble(), // Parse new field
      paymentMethod: data['paymentMethod'],
      paymentStatus: data['paymentStatus'] ?? 'pending',
      adminComment: data['adminComment'],
      adminId: data['adminId'],
    );
  }

  // Method to convert a Vehicle object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'licensePlate': licensePlate,
      'photoUrl': photoUrl,
      'licensePlatePhotoUrl': licensePlatePhotoUrl,
      'status': status,
      'entryTime': entryTime,
      'exitTime': exitTime,
      'totalTime': totalTime,
      'managerId': managerId,
      'items': items,
      'totalAmount': totalAmount,
      'timeBasedCost': timeBasedCost, // Include new field in toMap
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'adminComment': adminComment,
      'adminId': adminId,
    };
  }
}
