import 'package:get/get.dart';
import '../../data/repositories/driver_repository_impl.dart';
import '../controllers/admin_driver_list_controller.dart';
import '../controllers/admin_driver_detail_controller.dart';
import '../controllers/admin_daily_entries_controller.dart';
import '../controllers/admin_weekly_status_controller.dart';
import '../controllers/admin_weekly_summary_controller.dart';

/// Paste in: lib/presentation/bindings/admin_binding.dart
class AdminBinding extends Bindings {
  @override
  void dependencies() {
    final repo = DriverRepositoryImpl();
    Get.lazyPut<AdminDriverListController>(() => AdminDriverListController(repo));
    Get.lazyPut<AdminDriverDetailController>(() => AdminDriverDetailController(repo));
    Get.lazyPut<AdminDailyEntriesController>(() => AdminDailyEntriesController(repo));
    Get.lazyPut<AdminWeeklyStatusController>(() => AdminWeeklyStatusController(repo));
    Get.lazyPut<AdminWeeklySummaryController>(() => AdminWeeklySummaryController(repo));
  }
}
