import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettings {
  final double pricePerMinute;

  AppSettings({required this.pricePerMinute});

  factory AppSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppSettings(
      pricePerMinute: (data['pricePerMinute'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pricePerMinute': pricePerMinute,
    };
  }
}
