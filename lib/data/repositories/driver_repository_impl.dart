import '../../core/constants/app_constants.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/daily_entry_entity.dart';
import '../../domain/entities/weekly_status_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/firebase_driver_datasource.dart';

/// Paste in: lib/data/repositories/driver_repository_impl.dart
class DriverRepositoryImpl implements DriverRepository {
  final FirebaseDriverDatasource _driverDs = FirebaseDriverDatasource();
  final FirebaseAuthDatasource _authDs = FirebaseAuthDatasource();

  @override
  Future<DriverProfileEntity?> getDriverProfile(String userId) => _driverDs.getDriverProfile(userId);

  @override
  Future<void> saveDriverProfile(DriverProfileEntity profile) => _driverDs.saveDriverProfile(profile);

  @override
  Future<List<DriverProfileEntity>> getAllDrivers() => _driverDs.getAllDrivers();

  @override
  Future<List<DriverProfileEntity>> searchDrivers(String query) => _driverDs.searchDrivers(query);

  @override
  Future<void> deleteDriver(String driverId) => _driverDs.deleteDriver(driverId);

  @override
  Future<void> setDriverSuspended(String driverId, bool suspended) =>
      _authDs.setSuspended(driverId, suspended);

  @override
  Future<void> saveDailyEntry(DailyEntryEntity entry) async {
    final id = entry.id;
    final toSave = DailyEntryEntity(
      id: id,
      driverId: entry.driverId,
      driverName: entry.driverName,
      date: entry.date,
      startKm: entry.startKm,
      startTime: entry.startTime,
      endKm: entry.endKm,
      endTime: entry.endTime,
      fuelAmount: entry.fuelAmount,
      fuelPaidBy: entry.fuelPaidBy,
      vehicleNumber: entry.vehicleNumber,
      totalEarning: entry.totalEarning,
      cashCollected: entry.cashCollected,
      servicesUsed: entry.servicesUsed,
      privateTripCash: entry.privateTripCash,
      tollPaidByCustomer: entry.tollPaidByCustomer,
      createdAt: entry.createdAt,
      updatedAt: DateTime.now(),
    );
    await _driverDs.saveDailyEntry(toSave);
  }

  @override
  Future<DailyEntryEntity?> getDailyEntry(String driverId, DateTime date) =>
      _driverDs.getDailyEntry(driverId, date);

  @override
  Future<List<DailyEntryEntity>> getDailyEntriesByDriver(String driverId, {DateTime? start, DateTime? end}) =>
      _driverDs.getDailyEntriesByDriver(driverId, start: start, end: end);

  @override
  Future<List<DailyEntryEntity>> getDailyEntriesByDate(DateTime date) =>
      _driverDs.getDailyEntriesByDate(date);

  @override
  Future<List<DailyEntryEntity>> getEntriesWithMissingMandatoryFields(DateTime date) =>
      _driverDs.getEntriesWithMissingMandatoryFields(date);

  @override
  Future<void> saveWeeklyStatus(WeeklyStatusEntity status) async {
    final cashAgainst = status.totalEarnings - status.totalCashCollected;
    final commission = status.totalEarnings * AppConstants.commissionPercent;
    final finalBal = (commission + status.roomRent + status.petrolExpense) -
        cashAgainst -
        status.phonePayReceived -
        status.pendingBalance;
    final existing = await _driverDs.getWeeklyStatus(status.driverId, status.weekStartDate);
    final id = status.id.isNotEmpty ? status.id : (existing?.id ?? '');
    final toSave = WeeklyStatusEntity(
      id: id,
      driverId: status.driverId,
      driverName: status.driverName,
      weekStartDate: status.weekStartDate,
      weekEndDate: status.weekEndDate,
      totalEarnings: status.totalEarnings,
      totalCashCollected: status.totalCashCollected,
      cashAgainstEarnings: cashAgainst,
      commissionFleet: commission,
      phonePayReceived: status.phonePayReceived,
      roomRent: status.roomRent,
      petrolExpense: status.petrolExpense,
      pendingBalance: status.pendingBalance,
      finalBalance: finalBal,
      createdAt: existing?.createdAt ?? status.createdAt,
      updatedAt: DateTime.now(),
    );
    await _driverDs.saveWeeklyStatus(toSave);
  }

  @override
  Future<WeeklyStatusEntity?> getWeeklyStatus(String driverId, DateTime weekStart) =>
      _driverDs.getWeeklyStatus(driverId, weekStart);

  @override
  Future<List<WeeklyStatusEntity>> getWeeklyStatusesByDriver(String driverId, {DateTime? start, DateTime? end}) =>
      _driverDs.getWeeklyStatusesByDriver(driverId, start: start, end: end);

  @override
  Future<List<WeeklyStatusEntity>> getWeeklyStatusesInRange(DateTime start, DateTime end) =>
      _driverDs.getWeeklyStatusesInRange(start, end);
}
