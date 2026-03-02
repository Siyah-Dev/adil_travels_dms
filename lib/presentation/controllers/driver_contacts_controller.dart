import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import 'auth_controller.dart';

class DriverContactsController extends GetxController {
  DriverContactsController(this._repo);

  final DriverRepository _repo;

  final RxList<DriverProfileEntity> drivers = <DriverProfileEntity>[].obs;
  final RxBool isLoading = false.obs;

  String get currentUserId => Get.find<AuthController>().currentUser.value?.uid ?? '';

  Future<void> loadDrivers() async {
    isLoading.value = true;
    try {
      final all = await _repo.getAllDrivers();
      drivers.value = all.where((d) => d.userId != currentUserId).toList();
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load drivers');
    } finally {
      isLoading.value = false;
    }
  }
}
