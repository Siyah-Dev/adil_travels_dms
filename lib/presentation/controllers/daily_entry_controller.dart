import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/daily_entry_entity.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import 'auth_controller.dart';
import 'driver_profile_controller.dart';

/// Paste in: lib/presentation/controllers/daily_entry_controller.dart
class DailyEntryController extends GetxController {
  DailyEntryController(this._repo);

  final DriverRepository _repo;

  final Rx<DailyEntryEntity?> todayEntry = Rx<DailyEntryEntity?>(null);
  final RxList<VehicleEntity> vehicles = <VehicleEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingVehicles = false.obs;
  final RxBool saving = false.obs;
  final RxString loadError = ''.obs;
  final RxString vehiclesError = ''.obs;

  String get userId => Get.find<AuthController>().currentUser.value!.uid;
  String get driverName => Get.find<DriverProfileController>().profile.value?.name ?? '';

  Future<void> loadVehicles() async {
    isLoadingVehicles.value = true;
    vehiclesError.value = '';
    try {
      final fetched = await _repo.getVehicles();
      vehicles.value = fetched;
    } catch (e) {
      vehicles.clear();
      vehiclesError.value = ErrorHandler.message(e);
    } finally {
      isLoadingVehicles.value = false;
    }
  }

  Future<void> loadTodayEntry() async {
    await loadEntryForDate(DateTime.now());
  }

  Future<void> loadEntryForDate(DateTime date) async {
    isLoading.value = true;
    loadError.value = '';
    // Clear stale entry immediately so UI doesn't render previous date values while loading.
    todayEntry.value = null;
    try {
      final day = DateTime(date.year, date.month, date.day);
      final loaded = await _repo.getDailyEntry(userId, day);
      if (loaded != null &&
          loaded.leaveOnToday &&
          loaded.leaveEnabledAt != null &&
          DateTime.now().difference(loaded.leaveEnabledAt!).inHours >= 14) {
        final autoOff = DailyEntryEntity(
          id: loaded.id,
          driverId: loaded.driverId,
          driverName: loaded.driverName,
          date: loaded.date,
          startKm: loaded.startKm,
          startTime: loaded.startTime,
          endKm: loaded.endKm,
          endTime: loaded.endTime,
          fuelAmount: loaded.fuelAmount,
          fuelPaidBy: loaded.fuelPaidBy,
          vehicleNumber: loaded.vehicleNumber,
          totalEarning: loaded.totalEarning,
          cashCollected: loaded.cashCollected,
          servicesUsed: loaded.servicesUsed == AppConstants.serviceLeave ? null : loaded.servicesUsed,
          leaveOnToday: false,
          leaveEnabledAt: null,
          privateTripCash: loaded.privateTripCash,
          tollPaidByCustomer: loaded.tollPaidByCustomer,
          createdAt: loaded.createdAt,
          updatedAt: DateTime.now(),
        );
        await _repo.saveDailyEntry(autoOff);
        todayEntry.value = autoOff;
      } else {
        todayEntry.value = loaded;
      }
    } catch (e) {
      todayEntry.value = null;
      final msg = ErrorHandler.message(e);
      if (msg.toLowerCase().contains('permission')) {
        loadError.value =
            'Unable to load existing entry due to access permission. You can still fill the form and try saving.';
      } else {
        loadError.value = 'Could not load entry: $msg';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveEntry({
    required DateTime date,
    required String driverName,
    double? startKm,
    String? startTime,
    double? endKm,
    String? endTime,
    double? fuelAmount,
    String? fuelPaidBy,
    String? vehicleNumber,
    double? totalEarning,
    double? cashCollected,
    String? servicesUsed,
    bool leaveOnToday = false,
    DateTime? leaveEnabledAt,
    double? privateTripCash,
    double? tollPaidByCustomer,
  }) async {
    saving.value = true;
    try {
      final existing = todayEntry.value;
      final entity = DailyEntryEntity(
        id: existing?.id ?? '',
        driverId: userId,
        driverName: driverName.trim(),
        date: date,
        startKm: startKm,
        startTime: startTime?.trim(),
        endKm: endKm,
        endTime: endTime?.trim(),
        fuelAmount: fuelAmount,
        fuelPaidBy: fuelPaidBy,
        vehicleNumber: vehicleNumber,
        totalEarning: totalEarning,
        cashCollected: cashCollected,
        servicesUsed: leaveOnToday ? AppConstants.serviceLeave : servicesUsed,
        leaveOnToday: leaveOnToday,
        leaveEnabledAt: leaveOnToday ? (leaveEnabledAt ?? DateTime.now()) : null,
        privateTripCash: privateTripCash,
        tollPaidByCustomer: tollPaidByCustomer,
        createdAt: existing?.createdAt,
        updatedAt: DateTime.now(),
      );
      await _repo.saveDailyEntry(entity);
      todayEntry.value = entity;
      ErrorHandler.showSuccess('Daily entry saved');
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not save daily entry');
    } finally {
      saving.value = false;
    }
  }
}
