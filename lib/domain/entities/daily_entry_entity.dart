/// Daily entry entity filled by driver each day.
/// Paste in: lib/domain/entities/daily_entry_entity.dart
class DailyEntryEntity {
  final String id;
  final String driverId;
  final String driverName;
  final DateTime date;
  final double? startKm;
  final String? startTime;
  final double? endKm;
  final String? endTime;
  final double? fuelAmount;
  final String? fuelPaidBy;
  final String? vehicleNumber;
  final double? totalEarning;
  final double? cashCollected;
  final String? servicesUsed;
  final double? privateTripCash;
  final double? tollPaidByCustomer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DailyEntryEntity({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.date,
    this.startKm,
    this.startTime,
    this.endKm,
    this.endTime,
    this.fuelAmount,
    this.fuelPaidBy,
    this.vehicleNumber,
    this.totalEarning,
    this.cashCollected,
    this.servicesUsed,
    this.privateTripCash,
    this.tollPaidByCustomer,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasMandatoryFields =>
      driverName.isNotEmpty &&
      vehicleNumber != null &&
      vehicleNumber!.isNotEmpty &&
      startKm != null &&
      endKm != null;
}
