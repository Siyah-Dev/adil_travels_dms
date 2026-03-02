import 'package:get/get.dart';
import 'dart:typed_data';
import '../../core/utils/error_handler.dart';
import '../../core/services/supabase_storage_service.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/driver_repository.dart';
import 'auth_controller.dart';

/// Paste in: lib/presentation/controllers/driver_profile_controller.dart
class DriverProfileController extends GetxController {
  DriverProfileController(this._repo);

  final DriverRepository _repo;

  final Rx<DriverProfileEntity?> profile = Rx<DriverProfileEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;

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
        profileImagePath: existing?.profileImagePath,
        aadharImagePath: existing?.aadharImagePath,
        drivingLicenceImagePath: existing?.drivingLicenceImagePath,
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

  Future<void> uploadDocument({
    required String type,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      isUploading.value = true;
      final existing = profile.value;
      final uploadedPath = await SupabaseStorageService.uploadDriverDocument(
        driverId: userId,
        type: type,
        fileName: fileName,
        bytes: bytes,
      );

      final base = existing ??
          DriverProfileEntity(
            id: userId,
            userId: userId,
            name: authController.currentUser.value?.displayName?.trim().isNotEmpty == true
                ? authController.currentUser.value!.displayName!.trim()
                : authController.currentUser.value?.email.split('@').first ?? 'Driver',
          );

      final updated = DriverProfileEntity(
        id: base.id,
        userId: base.userId,
        name: base.name,
        age: base.age,
        address: base.address,
        place: base.place,
        pincode: base.pincode,
        mobileNumber: base.mobileNumber,
        aadharNumber: base.aadharNumber,
        drivingLicenceNumber: base.drivingLicenceNumber,
        profileImagePath: type == 'profile' ? uploadedPath : base.profileImagePath,
        aadharImagePath: type == 'aadhar' ? uploadedPath : base.aadharImagePath,
        drivingLicenceImagePath:
            type == 'licence' ? uploadedPath : base.drivingLicenceImagePath,
        updatedAt: DateTime.now(),
      );

      await _repo.saveDriverProfile(updated);
      profile.value = updated;
      ErrorHandler.showSuccess('Document uploaded');
    } catch (e) {
      ErrorHandler.showError(e, title: 'Upload failed');
    } finally {
      isUploading.value = false;
    }
  }

  Future<String?> getSignedUrl(String? path) async {
    if (path == null || path.trim().isEmpty) return null;
    try {
      return await SupabaseStorageService.createSignedUrl(path);
    } catch (_) {
      return null;
    }
  }
}
