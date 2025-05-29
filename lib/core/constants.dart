// lib/core/constants.dart

// User Roles
class UserRoles {
  static const String admin = 'admin';
  static const String manager = 'manager';
}

// Vehicle Statuses
class VehicleStatuses {
  static const String active = 'active';
  static const String completed = 'completed';
  // Add any other statuses like 'pending_admin_review', 'pending' if used.
  // From Vehicle.dart: "active" | "completed" | "pending" - so 'pending' is used.
  // From ManagerOrderConfirmationScreen: 'pending_admin_review' is used for paymentStatus, not vehicle status.
  // Let's stick to what's in Vehicle model for vehicle status.
  static const String pending = 'pending'; // As per Vehicle.dart comment.
                                          // ManagerOrderConfirmationScreen uses 'active' when cancelling.
}

// Payment Statuses
class PaymentStatuses {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String rejected = 'rejected';
  static const String completed = 'completed';
  static const String pendingAdminReview = 'pending_admin_review'; // Used in ManagerOrderConfirmationScreen
}

// Payment Methods
class PaymentMethods {
  static const String cash = 'cash';
  static const String qr = 'qr';
}

// Firestore Collection Names
class FirestoreCollections {
  static const String users = 'users';
  static const String vehicles = 'vehicles';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String settings = 'settings';
  static const String serverTime = 'serverTime'; // Used in PaymentQrScreen (though usage pattern was changed)
}

// Firestore Document IDs
class FirestoreDocuments {
  static const String globalSettings = 'global_settings';
  // static const String serverTimeCurrent = 'current'; // For serverTime doc, if that pattern was kept.
}
