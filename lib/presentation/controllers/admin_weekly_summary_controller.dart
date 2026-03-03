import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/weekly_status_entity.dart';
import '../../domain/repositories/driver_repository.dart';

/// Paste in: lib/presentation/controllers/admin_weekly_summary_controller.dart
class AdminWeeklySummaryController extends GetxController {
  AdminWeeklySummaryController(this._repo);

  final DriverRepository _repo;

  final RxList<DriverProfileEntity> drivers = <DriverProfileEntity>[].obs;
  final RxString selectedDriverId = ''.obs;
  final RxList<WeeklyStatusEntity> list = <WeeklyStatusEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  DateTime? filterStart;
  DateTime? filterEnd;
  DateTime? filterDate;

  List<WeeklyStatusEntity> get filteredWeeklyList {
    final id = selectedDriverId.value.trim();
    if (id.isEmpty) return list;
    return list.where((e) => e.driverId == id).toList();
  }

  Future<void> loadDrivers() async {
    try {
      drivers.value = await _repo.getAllDrivers();
    } catch (_) {}
  }

  void setDriverFilter(String? driverId) {
    selectedDriverId.value = driverId?.trim() ?? '';
  }

  DriverProfileEntity? get selectedDriver {
    final id = selectedDriverId.value.trim();
    if (id.isEmpty) return null;
    for (final driver in drivers) {
      if (driver.userId == id) return driver;
    }
    return null;
  }

  Future<void> loadSummary({required DateTime start, required DateTime end}) async {
    isLoading.value = true;
    errorMessage.value = '';
    filterStart = start;
    filterEnd = end;
    try {
      list.value = await _repo.getWeeklyStatusesInRange(start, end);
    } catch (e) {
      errorMessage.value = ErrorHandler.message(e);
      ErrorHandler.showError(e, title: 'Could not load summary');
    } finally {
      isLoading.value = false;
    }
  }
}
