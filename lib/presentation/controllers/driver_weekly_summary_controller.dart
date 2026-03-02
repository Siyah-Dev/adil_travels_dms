import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/weekly_status_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import 'auth_controller.dart';

/// Paste in: lib/presentation/controllers/driver_weekly_summary_controller.dart
class DriverWeeklySummaryController extends GetxController {
  DriverWeeklySummaryController(this._repo);

  final DriverRepository _repo;

  final RxList<WeeklyStatusEntity> list = <WeeklyStatusEntity>[].obs;
  final RxBool isLoading = false.obs;
  DateTime? filterStart;
  DateTime? filterEnd;
  DateTime? filterDay;

  String get userId => Get.find<AuthController>().currentUser.value!.uid;

  Future<void> loadSummary({DateTime? start, DateTime? end}) async {
    isLoading.value = true;
    filterStart = start;
    filterEnd = end;
    filterDay = null;
    try {
      list.value = await _repo.getWeeklyStatusesByDriver(userId, start: start, end: end);
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load summary');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSummaryByDay(DateTime day) async {
    isLoading.value = true;
    final normalizedDay = DateTime(day.year, day.month, day.day);
    filterDay = normalizedDay;
    filterStart = null;
    filterEnd = null;
    try {
      final all = await _repo.getWeeklyStatusesByDriver(userId);
      list.value = all.where((item) {
        final start = DateTime(
          item.weekStartDate.year,
          item.weekStartDate.month,
          item.weekStartDate.day,
        );
        final end = DateTime(
          item.weekEndDate.year,
          item.weekEndDate.month,
          item.weekEndDate.day,
        );
        return !normalizedDay.isBefore(start) && !normalizedDay.isAfter(end);
      }).toList();
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load summary');
    } finally {
      isLoading.value = false;
    }
  }
}
