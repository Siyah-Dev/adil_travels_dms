import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/driver_repository.dart';

/// Paste in: lib/presentation/controllers/admin_driver_list_controller.dart
class AdminDriverListController extends GetxController {
  AdminDriverListController(this._repo);

  final DriverRepository _repo;

  final RxList<DriverProfileEntity> drivers = <DriverProfileEntity>[].obs;
  final RxList<DriverProfileEntity> filteredDrivers = <DriverProfileEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  Future<void> loadDrivers() async {
    isLoading.value = true;
    try {
      if (searchQuery.value.trim().isEmpty) {
        drivers.value = await _repo.getAllDrivers();
      } else {
        drivers.value = await _repo.searchDrivers(searchQuery.value);
      }
      filteredDrivers.value = List.from(drivers);
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load drivers');
    } finally {
      isLoading.value = false;
    }
  }

  void search(String query) {
    searchQuery.value = query;
    if (query.trim().isEmpty) {
      filteredDrivers.value = List.from(drivers);
    } else {
      filteredDrivers.value = drivers.where((d) => d.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
  }

  Future<void> deleteDriver(String driverId) async {
    try {
      await _repo.deleteDriver(driverId);
      drivers.removeWhere((d) => d.userId == driverId);
      filteredDrivers.value = List.from(drivers);
      ErrorHandler.showSuccess('Driver removed');
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not remove driver');
    }
  }

  Future<void> setSuspended(String driverId, bool suspended) async {
    try {
      await _repo.setDriverSuspended(driverId, suspended);
      ErrorHandler.showSuccess(suspended ? 'Driver suspended' : 'Driver activated');
    } catch (e) {
      ErrorHandler.showError(e, title: suspended ? 'Could not suspend driver' : 'Could not activate driver');
    }
  }
}
