import '../../domain/entities/weekly_status_entity.dart';
import '../../core/constants/firebase_constants.dart';

/// Weekly status model.
/// Paste in: lib/data/models/weekly_status_model.dart
class WeeklyStatusModel extends WeeklyStatusEntity {
  const WeeklyStatusModel({
    required super.id,
    required super.driverId,
    required super.driverName,
    required super.weekStartDate,
    required super.weekEndDate,
    required super.totalEarnings,
    required super.totalCashCollected,
    required super.cashAgainstEarnings,
    required super.commissionFleet,
    required super.phonePayReceived,
    required super.roomRent,
    required super.petrolExpense,
    required super.pendingBalance,
    required super.finalBalance,
    super.createdAt,
    super.updatedAt,
  });

  factory WeeklyStatusModel.fromEntity(WeeklyStatusEntity e) => WeeklyStatusModel(
        id: e.id,
        driverId: e.driverId,
        driverName: e.driverName,
        weekStartDate: e.weekStartDate,
        weekEndDate: e.weekEndDate,
        totalEarnings: e.totalEarnings,
        totalCashCollected: e.totalCashCollected,
        cashAgainstEarnings: e.cashAgainstEarnings,
        commissionFleet: e.commissionFleet,
        phonePayReceived: e.phonePayReceived,
        roomRent: e.roomRent,
        petrolExpense: e.petrolExpense,
        pendingBalance: e.pendingBalance,
        finalBalance: e.finalBalance,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  factory WeeklyStatusModel.fromFirestore(Map<String, dynamic> map, String id) {
    final ws = (map[FirebaseConstants.weekStartDate] as dynamic)?.toDate();
    final we = (map[FirebaseConstants.weekEndDate] as dynamic)?.toDate();
    return WeeklyStatusModel(
      id: id,
      driverId: map[FirebaseConstants.driverId] as String? ?? '',
      driverName: map[FirebaseConstants.driverName] as String? ?? '',
      weekStartDate: ws ?? DateTime.now(),
      weekEndDate: we ?? DateTime.now(),
      totalEarnings: (map[FirebaseConstants.totalEarnings] as num?)?.toDouble() ?? 0,
      totalCashCollected: (map[FirebaseConstants.totalCashCollected] as num?)?.toDouble() ?? 0,
      cashAgainstEarnings: (map[FirebaseConstants.cashAgainstEarnings] as num?)?.toDouble() ?? 0,
      commissionFleet: (map[FirebaseConstants.commissionFleet] as num?)?.toDouble() ?? 0,
      phonePayReceived: (map[FirebaseConstants.phonePayReceived] as num?)?.toDouble() ?? 0,
      roomRent: (map[FirebaseConstants.roomRent] as num?)?.toDouble() ?? 0,
      petrolExpense: (map[FirebaseConstants.petrolExpense] as num?)?.toDouble() ?? 0,
      pendingBalance: (map[FirebaseConstants.pendingBalance] as num?)?.toDouble() ?? 0,
      finalBalance: (map[FirebaseConstants.finalBalance] as num?)?.toDouble() ?? 0,
      createdAt: (map['createdAt'] as dynamic)?.toDate(),
      updatedAt: (map['updatedAt'] as dynamic)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.driverId: driverId,
      FirebaseConstants.driverName: driverName,
      FirebaseConstants.weekStartDate: weekStartDate,
      FirebaseConstants.weekEndDate: weekEndDate,
      FirebaseConstants.totalEarnings: totalEarnings,
      FirebaseConstants.totalCashCollected: totalCashCollected,
      FirebaseConstants.cashAgainstEarnings: cashAgainstEarnings,
      FirebaseConstants.commissionFleet: commissionFleet,
      FirebaseConstants.phonePayReceived: phonePayReceived,
      FirebaseConstants.roomRent: roomRent,
      FirebaseConstants.petrolExpense: petrolExpense,
      FirebaseConstants.pendingBalance: pendingBalance,
      FirebaseConstants.finalBalance: finalBalance,
      'updatedAt': DateTime.now(),
    };
  }
}
