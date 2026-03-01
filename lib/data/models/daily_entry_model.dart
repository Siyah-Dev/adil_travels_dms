import '../../domain/entities/daily_entry_entity.dart';
import '../../core/constants/firebase_constants.dart';

/// Daily entry model.
/// Paste in: lib/data/models/daily_entry_model.dart
class DailyEntryModel extends DailyEntryEntity {
  const DailyEntryModel({
    required super.id,
    required super.driverId,
    required super.driverName,
    required super.date,
    super.startKm,
    super.startTime,
    super.endKm,
    super.endTime,
    super.fuelAmount,
    super.fuelPaidBy,
    super.vehicleNumber,
    super.totalEarning,
    super.cashCollected,
    super.servicesUsed,
    super.privateTripCash,
    super.tollPaidByCustomer,
    super.createdAt,
    super.updatedAt,
  });

  factory DailyEntryModel.fromEntity(DailyEntryEntity e) => DailyEntryModel(
        id: e.id,
        driverId: e.driverId,
        driverName: e.driverName,
        date: e.date,
        startKm: e.startKm,
        startTime: e.startTime,
        endKm: e.endKm,
        endTime: e.endTime,
        fuelAmount: e.fuelAmount,
        fuelPaidBy: e.fuelPaidBy,
        vehicleNumber: e.vehicleNumber,
        totalEarning: e.totalEarning,
        cashCollected: e.cashCollected,
        servicesUsed: e.servicesUsed,
        privateTripCash: e.privateTripCash,
        tollPaidByCustomer: e.tollPaidByCustomer,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  factory DailyEntryModel.fromFirestore(Map<String, dynamic> map, String id) {
    final date = map[FirebaseConstants.date];
    return DailyEntryModel(
      id: id,
      driverId: map[FirebaseConstants.driverId] as String? ?? '',
      driverName: map[FirebaseConstants.driverName] as String? ?? '',
      date: date is DateTime ? date : (date as dynamic)?.toDate() ?? DateTime.now(),
      startKm: (map[FirebaseConstants.startKm] as num?)?.toDouble(),
      startTime: map[FirebaseConstants.startTime] as String?,
      endKm: (map[FirebaseConstants.endKm] as num?)?.toDouble(),
      endTime: map[FirebaseConstants.endTime] as String?,
      fuelAmount: (map[FirebaseConstants.fuelAmount] as num?)?.toDouble(),
      fuelPaidBy: map[FirebaseConstants.fuelPaidBy] as String?,
      vehicleNumber: map[FirebaseConstants.vehicleNumber] as String?,
      totalEarning: (map[FirebaseConstants.totalEarning] as num?)?.toDouble(),
      cashCollected: (map[FirebaseConstants.cashCollected] as num?)?.toDouble(),
      servicesUsed: map[FirebaseConstants.servicesUsed] as String?,
      privateTripCash: (map[FirebaseConstants.privateTripCash] as num?)?.toDouble(),
      tollPaidByCustomer: (map[FirebaseConstants.tollPaidByCustomer] as num?)?.toDouble(),
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
      updatedAt: (map['updatedAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.driverId: driverId,
      FirebaseConstants.driverName: driverName,
      FirebaseConstants.date: date,
      if (startKm != null) FirebaseConstants.startKm: startKm,
      if (startTime != null) FirebaseConstants.startTime: startTime,
      if (endKm != null) FirebaseConstants.endKm: endKm,
      if (endTime != null) FirebaseConstants.endTime: endTime,
      if (fuelAmount != null) FirebaseConstants.fuelAmount: fuelAmount,
      if (fuelPaidBy != null) FirebaseConstants.fuelPaidBy: fuelPaidBy,
      if (vehicleNumber != null) FirebaseConstants.vehicleNumber: vehicleNumber,
      if (totalEarning != null) FirebaseConstants.totalEarning: totalEarning,
      if (cashCollected != null) FirebaseConstants.cashCollected: cashCollected,
      if (servicesUsed != null) FirebaseConstants.servicesUsed: servicesUsed,
      if (privateTripCash != null) FirebaseConstants.privateTripCash: privateTripCash,
      if (tollPaidByCustomer != null) FirebaseConstants.tollPaidByCustomer: tollPaidByCustomer,
      'updatedAt': DateTime.now(),
    };
  }
}
