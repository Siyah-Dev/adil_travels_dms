import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/daily_entry_entity.dart';
import '../../domain/repositories/driver_repository.dart';

/// Paste in: lib/presentation/controllers/admin_daily_entries_controller.dart
class AdminDailyEntriesController extends GetxController {
  AdminDailyEntriesController(this._repo);

  final DriverRepository _repo;

  final RxList<DailyEntryEntity> entries = <DailyEntryEntity>[].obs;
  final RxBool isLoading = false.obs;
  DateTime selectedDate = DateTime.now();

  Future<void> loadEntriesForDate(DateTime date) async {
    selectedDate = date;
    isLoading.value = true;
    try {
      entries.value = await _repo.getDailyEntriesByDate(date);
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load entries');
    } finally {
      isLoading.value = false;
    }
  }
}
