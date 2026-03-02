/// App-wide constants.
/// Paste in: lib/core/constants/app_constants.dart
class AppConstants {
  AppConstants._();

  static const String appName = 'DMS';
  static const String logoAsset = 'assets/images/adil_travels_logo.png';

  // Collections
  static const String usersCollection = 'users';
  static const String driversCollection = 'drivers';
  static const String vehiclesCollection = 'vehicles';
  static const String dailyEntriesCollection = 'daily_entries';
  static const String weeklyStatusCollection = 'weekly_status';
  static const String notificationsCollection = 'notifications';

  // User roles
  static const String roleAdmin = 'admin';
  static const String roleDriver = 'driver';

  // Fuel paid by
  static const String fuelPaidDriver = 'driver';
  static const String fuelPaidOwner = 'owner';
  static const String fuelPaidBoth = 'driver & owner';

  // Services used
  static const String serviceUber = 'uber';
  static const String servicePrivateTrip = 'private trip';
  static const String serviceBoth = 'both';
  static const String serviceLeave = 'leave on today';

  // Commission percentage
  static const double commissionPercent = 0.40; // 40%

  // Notification check times (hour of day, 24h)
  static const int morningCheckHour = 9;
  static const int eveningCheckHour = 18;
}
