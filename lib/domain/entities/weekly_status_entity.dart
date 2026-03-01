/// Weekly status entity (admin-filled for each driver).
/// Paste in: lib/domain/entities/weekly_status_entity.dart
class WeeklyStatusEntity {
  final String id;
  final String driverId;
  final String driverName;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final double totalEarnings;
  final double totalCashCollected;
  final double cashAgainstEarnings; // computed
  final double commissionFleet; // 40% of totalEarnings
  final double phonePayReceived;
  final double roomRent;
  final double petrolExpense;
  final double pendingBalance; // can be -/+
  final double finalBalance; // computed
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WeeklyStatusEntity({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.totalEarnings,
    required this.totalCashCollected,
    required this.cashAgainstEarnings,
    required this.commissionFleet,
    required this.phonePayReceived,
    required this.roomRent,
    required this.petrolExpense,
    required this.pendingBalance,
    required this.finalBalance,
    this.createdAt,
    this.updatedAt,
  });
}
