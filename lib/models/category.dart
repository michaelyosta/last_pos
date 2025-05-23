import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String displayName;
  final String description;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final String createdBy;

  Category({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  // Factory constructor to create a Category from a Firestore DocumentSnapshot
  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      displayName: data['displayName'] ?? '',
      description: data['description'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  // Method to convert a Category object to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'displayName': displayName,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
    };
  }
}
