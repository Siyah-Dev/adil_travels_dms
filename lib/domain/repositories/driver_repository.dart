import '../entities/driver_profile_entity.dart';
import '../entities/daily_entry_entity.dart';
import '../entities/weekly_status_entity.dart';

/// Driver repository contract.
/// Paste in: lib/domain/repositories/driver_repository.dart
abstract class DriverRepository {
  // Profile
  Future<DriverProfileEntity?> getDriverProfile(String userId);
  Future<void> saveDriverProfile(DriverProfileEntity profile);
  Future<List<DriverProfileEntity>> getAllDrivers();
  Future<List<DriverProfileEntity>> searchDrivers(String query);
  Future<void> deleteDriver(String driverId);
  Future<void> setDriverSuspended(String driverId, bool suspended);

  // Daily entries
  Future<void> saveDailyEntry(DailyEntryEntity entry);
  Future<DailyEntryEntity?> getDailyEntry(String driverId, DateTime date);
  Future<List<DailyEntryEntity>> getDailyEntriesByDriver(String driverId, {DateTime? start, DateTime? end});
  Future<List<DailyEntryEntity>> getDailyEntriesByDate(DateTime date);
  Future<List<DailyEntryEntity>> getEntriesWithMissingMandatoryFields(DateTime date);

  // Weekly status
  Future<void> saveWeeklyStatus(WeeklyStatusEntity status);
  Future<WeeklyStatusEntity?> getWeeklyStatus(String driverId, DateTime weekStart);
  Future<List<WeeklyStatusEntity>> getWeeklyStatusesByDriver(String driverId, {DateTime? start, DateTime? end});
  Future<List<WeeklyStatusEntity>> getWeeklyStatusesInRange(DateTime start, DateTime end);
}
