import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import 'auth_controller.dart';

/// Paste in: lib/presentation/controllers/driver_profile_controller.dart
class DriverProfileController extends GetxController {
  DriverProfileController(this._repo);

  final DriverRepository _repo;

  final Rx<DriverProfileEntity?> profile = Rx<DriverProfileEntity?>(null);
  final RxBool isLoading = false.obs;

  String get userId => Get.find<AuthController>().currentUser.value!.uid;

  AuthController get authController => Get.find<AuthController>();

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      profile.value = await _repo.getDriverProfile(userId);
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile({
    required String name,
    int? age,
    String? address,
    String? place,
    String? pincode,
    required String mobileNumber,
    required String aadharNumber,
    required String drivingLicenceNumber,
  }) async {
    isLoading.value = true;
    try {
      final existing = profile.value;
      final entity = DriverProfileEntity(
        id: existing?.id ?? userId,
        userId: userId,
        name: name.trim(),
        age: age,
        address: address?.trim(),
        place: place?.trim(),
        pincode: pincode?.trim(),
        mobileNumber: mobileNumber.trim(),
        aadharNumber: aadharNumber.trim(),
        drivingLicenceNumber: drivingLicenceNumber.trim(),
        updatedAt: DateTime.now(),
      );
      await _repo.saveDriverProfile(entity);
      profile.value = entity;
      ErrorHandler.showSuccess('Profile updated successfully');
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not save profile');
    } finally {
      isLoading.value = false;
    }
  }
}
