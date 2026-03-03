import 'package:get/get.dart';
import '../../data/repositories/driver_repository_impl.dart';
import '../controllers/driver_contacts_controller.dart';
import '../controllers/driver_helpline_controller.dart';
import '../controllers/driver_profile_controller.dart';
import '../controllers/daily_entry_controller.dart';
import '../controllers/driver_weekly_summary_controller.dart';

/// Paste in: lib/presentation/bindings/driver_binding.dart
class DriverBinding extends Bindings {
  @override
  void dependencies() {
    final repo = DriverRepositoryImpl();
    Get.lazyPut<DriverProfileController>(() => DriverProfileController(repo));
    Get.lazyPut<DriverContactsController>(() => DriverContactsController(repo));
    Get.lazyPut<DriverHelplineController>(() => DriverHelplineController(repo));
    Get.lazyPut<DailyEntryController>(() => DailyEntryController(repo));
    Get.lazyPut<DriverWeeklySummaryController>(() => DriverWeeklySummaryController(repo));
  }
}
