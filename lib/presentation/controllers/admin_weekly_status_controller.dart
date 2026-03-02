import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/weekly_status_entity.dart';
import '../../domain/repositories/driver_repository.dart';

/// Paste in: lib/presentation/controllers/admin_weekly_status_controller.dart
class AdminWeeklyStatusController extends GetxController {
  AdminWeeklyStatusController(this._repo);

  final DriverRepository _repo;

  final RxList<DriverProfileEntity> drivers = <DriverProfileEntity>[].obs;
  final Rx<DriverProfileEntity?> selectedDriver = Rx<DriverProfileEntity?>(null);
  final Rx<WeeklyStatusEntity?> currentStatus = Rx<WeeklyStatusEntity?>(null);
  final RxBool isLoading = false.obs;
  DateTime weekStart = DateTime.now();
  DateTime weekEnd = DateTime.now();

  Future<void> loadDrivers({String? preferredDriverId}) async {
    isLoading.value = true;
    try {
      drivers.value = await _repo.getAllDrivers();
      if (preferredDriverId != null && preferredDriverId.isNotEmpty) {
        DriverProfileEntity? matched;
        for (final d in drivers) {
          if (d.userId == preferredDriverId) {
            matched = d;
            break;
          }
        }
        if (matched != null) {
          await selectDriver(matched);
        }
      }
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load drivers');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectDriver(DriverProfileEntity? driver) async {
    selectedDriver.value = driver;
    if (driver == null) {
      currentStatus.value = null;
      return;
    }
    await loadWeeklyStatus(driver.userId, weekStart);
  }

  Future<void> loadWeeklyStatus(String driverId, DateTime start) async {
    weekStart = start;
    weekEnd = start.add(const Duration(days: 6));
    currentStatus.value = await _repo.getWeeklyStatus(driverId, start);
  }

  Future<void> saveWeeklyStatus({
    required String driverId,
    required String driverName,
    required DateTime weekStartDate,
    required DateTime weekEndDate,
    required double totalEarnings,
    required double totalCashCollected,
    required double phonePayReceived,
    required double roomRent,
    required double petrolExpense,
    required double pendingBalance,
  }) async {
    try {
      final cashAgainst = totalEarnings - totalCashCollected;
      final entity = WeeklyStatusEntity(
        id: currentStatus.value?.id ?? '',
        driverId: driverId,
        driverName: driverName,
        weekStartDate: weekStartDate,
        weekEndDate: weekEndDate,
        totalEarnings: totalEarnings,
        totalCashCollected: totalCashCollected,
        cashAgainstEarnings: cashAgainst,
        commissionFleet: 0,
        phonePayReceived: phonePayReceived,
        roomRent: roomRent,
        petrolExpense: petrolExpense,
        pendingBalance: pendingBalance,
        finalBalance: 0,
      );
      await _repo.saveWeeklyStatus(entity);
      currentStatus.value = await _repo.getWeeklyStatus(driverId, weekStartDate);
      ErrorHandler.showSuccess('Weekly status saved');
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not save weekly status');
    }
  }
}
