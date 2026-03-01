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

  String get userId => Get.find<AuthController>().currentUser.value!.uid;

  Future<void> loadSummary({DateTime? start, DateTime? end}) async {
    isLoading.value = true;
    filterStart = start;
    filterEnd = end;
    try {
      list.value = await _repo.getWeeklyStatusesByDriver(userId, start: start, end: end);
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load summary');
    } finally {
      isLoading.value = false;
    }
  }
}
