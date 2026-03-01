import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/daily_entry_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import 'auth_controller.dart';
import 'driver_profile_controller.dart';

/// Paste in: lib/presentation/controllers/daily_entry_controller.dart
class DailyEntryController extends GetxController {
  DailyEntryController(this._repo);

  final DriverRepository _repo;

  final Rx<DailyEntryEntity?> todayEntry = Rx<DailyEntryEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool saving = false.obs;
  final RxString loadError = ''.obs;

  String get userId => Get.find<AuthController>().currentUser.value!.uid;
  String get driverName => Get.find<DriverProfileController>().profile.value?.name ?? '';

  Future<void> loadTodayEntry() async {
    isLoading.value = true;
    loadError.value = '';
    try {
      final date = DateTime.now();
      todayEntry.value = await _repo.getDailyEntry(userId, date);
    } catch (e) {
      todayEntry.value = null;
      final msg = ErrorHandler.message(e);
      if (msg.toLowerCase().contains('permission')) {
        loadError.value =
            'Unable to load existing entry due to access permission. You can still fill the form and try saving.';
      } else {
        loadError.value = 'Could not load today\'s entry: $msg';
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
        servicesUsed: servicesUsed,
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
