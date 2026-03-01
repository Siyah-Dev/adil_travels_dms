/// Firebase field names and paths.
/// Paste in: lib/core/constants/firebase_constants.dart
class FirebaseConstants {
  FirebaseConstants._();

  // User
  static const String uid = 'uid';
  static const String email = 'email';
  static const String role = 'role';
  static const String displayName = 'displayName';
  static const String fcmToken = 'fcmToken';
  static const String isSuspended = 'isSuspended';
  static const String createdAt = 'createdAt';

  // Driver profile
  static const String name = 'name';
  static const String age = 'age';
  static const String address = 'address';
  static const String place = 'place';
  static const String pincode = 'pincode';
  static const String aadharNumber = 'aadharNumber';
  static const String drivingLicenceNumber = 'drivingLicenceNumber';

  // Daily entry
  static const String driverId = 'driverId';
  static const String driverName = 'driverName';
  static const String date = 'date';
  static const String startKm = 'startKm';
  static const String startTime = 'startTime';
  static const String endKm = 'endKm';
  static const String endTime = 'endTime';
  static const String fuelAmount = 'fuelAmount';
  static const String fuelPaidBy = 'fuelPaidBy';
  static const String vehicleNumber = 'vehicleNumber';
  static const String totalEarning = 'totalEarning';
  static const String cashCollected = 'cashCollected';
  static const String servicesUsed = 'servicesUsed';
  static const String privateTripCash = 'privateTripCash';
  static const String tollPaidByCustomer = 'tollPaidByCustomer';

  // Weekly status
  static const String weekStartDate = 'weekStartDate';
  static const String weekEndDate = 'weekEndDate';
  static const String totalEarnings = 'totalEarnings';
  static const String totalCashCollected = 'totalCashCollected';
  static const String cashAgainstEarnings = 'cashAgainstEarnings';
  static const String commissionFleet = 'commissionFleet';
  static const String phonePayReceived = 'phonePayReceived';
  static const String roomRent = 'roomRent';
  static const String petrolExpense = 'petrolExpense';
  static const String pendingBalance = 'pendingBalance';
  static const String finalBalance = 'finalBalance';
}
