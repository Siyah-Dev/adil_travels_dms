import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/daily_entry_entity.dart';
import '../../domain/repositories/driver_repository.dart';

/// Paste in: lib/presentation/controllers/admin_driver_detail_controller.dart
class AdminDriverDetailController extends GetxController {
  AdminDriverDetailController(this._repo);

  final DriverRepository _repo;

  final Rx<DriverProfileEntity?> driver = Rx<DriverProfileEntity?>(null);
  final RxList<DailyEntryEntity> dailyEntries = <DailyEntryEntity>[].obs;
  final RxBool loadingProfile = false.obs;
  final RxBool loadingEntries = false.obs;

  Future<void> loadDriver(String driverId) async {
    loadingProfile.value = true;
    try {
      driver.value = await _repo.getDriverProfile(driverId);
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load driver');
    } finally {
      loadingProfile.value = false;
    }
  }

  Future<void> loadDailyEntries(String driverId, {DateTime? start, DateTime? end}) async {
    loadingEntries.value = true;
    try {
      dailyEntries.value = await _repo.getDailyEntriesByDriver(driverId, start: start, end: end);
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load daily entries');
    } finally {
      loadingEntries.value = false;
    }
  }
}
