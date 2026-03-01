import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/weekly_status_entity.dart';
import '../../domain/repositories/driver_repository.dart';

/// Paste in: lib/presentation/controllers/admin_weekly_summary_controller.dart
class AdminWeeklySummaryController extends GetxController {
  AdminWeeklySummaryController(this._repo);

  final DriverRepository _repo;

  final RxList<WeeklyStatusEntity> list = <WeeklyStatusEntity>[].obs;
  final RxBool isLoading = false.obs;
  DateTime? filterStart;
  DateTime? filterEnd;

  Future<void> loadSummary({required DateTime start, required DateTime end}) async {
    isLoading.value = true;
    filterStart = start;
    filterEnd = end;
    try {
      list.value = await _repo.getWeeklyStatusesInRange(start, end);
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load summary');
    } finally {
      isLoading.value = false;
    }
  }
}
