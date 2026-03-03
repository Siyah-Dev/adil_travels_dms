import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/helpline_numbers_entity.dart';
import '../../domain/repositories/driver_repository.dart';

class AdminHelplineController extends GetxController {
  AdminHelplineController(this._repo);

  final DriverRepository _repo;

  final Rx<HelplineNumbersEntity?> helpline = Rx<HelplineNumbersEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  Future<void> loadHelplineNumbers() async {
    isLoading.value = true;
    try {
      helpline.value = await _repo.getHelplineNumbers();
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load helpline numbers');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveHelplineNumbers({
    required String officeNumber,
    required String contact1Name,
    required String contact1Number,
    required String contact2Name,
    required String contact2Number,
    required String contact3Name,
    required String contact3Number,
  }) async {
    if (isSaving.value) return;

    final office = officeNumber.trim();
    final n1 = contact1Name.trim();
    final p1 = contact1Number.trim();
    final n2 = contact2Name.trim();
    final p2 = contact2Number.trim();
    final n3 = contact3Name.trim();
    final p3 = contact3Number.trim();
    final isPhone = RegExp(r'^\d{10}$');

    bool isValidOptionalPhone(String value) =>
        value.isEmpty || isPhone.hasMatch(value);

    if (!isValidOptionalPhone(office) ||
        !isValidOptionalPhone(p1) ||
        !isValidOptionalPhone(p2) ||
        !isValidOptionalPhone(p3)) {
      ErrorHandler.showInfo(
        'If entered, all number fields must be exactly 10 digits.',
      );
      return;
    }

    isSaving.value = true;
    try {
      final payload = HelplineNumbersEntity(
        officeNumber: office,
        contacts: [
          HelplineContactEntity(name: n1, number: p1),
          HelplineContactEntity(name: n2, number: p2),
          HelplineContactEntity(name: n3, number: p3),
        ],
      );
      await _repo.saveHelplineNumbers(payload);
      helpline.value = payload;
      ErrorHandler.showSuccess('Helpline numbers saved');
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not save helpline numbers');
    } finally {
      isSaving.value = false;
    }
  }
}
