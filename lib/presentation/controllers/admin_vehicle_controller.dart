import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/driver_repository.dart';

class AdminVehicleController extends GetxController {
  AdminVehicleController(this._repo);

  final DriverRepository _repo;

  final RxList<VehicleEntity> vehicles = <VehicleEntity>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  Future<void> loadVehicles() async {
    isLoading.value = true;
    try {
      vehicles.value = await _repo.getVehicles();
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load vehicles');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addVehicle(String name, String number) async {
    final trimmedName = name.trim();
    final trimmedNumber = number.trim();
    if (trimmedName.isEmpty || trimmedNumber.isEmpty) {
      ErrorHandler.showInfo('Vehicle name and number are required.');
      return false;
    }

    isSaving.value = true;
    try {
      await _repo.addVehicle(trimmedName, trimmedNumber);
      await loadVehicles();
      ErrorHandler.showSuccess('Vehicle added');
      return true;
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not add vehicle');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteVehicle(String number) async {
    try {
      await _repo.deleteVehicle(number);
      vehicles.removeWhere((v) => v.number == number);
      ErrorHandler.showSuccess('Vehicle removed');
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not remove vehicle');
    }
  }
}
