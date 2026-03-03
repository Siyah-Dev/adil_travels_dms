import 'package:get/get.dart';
import '../../core/utils/error_handler.dart';
import '../../domain/entities/helpline_numbers_entity.dart';
import '../../domain/repositories/driver_repository.dart';

class DriverHelplineController extends GetxController {
  DriverHelplineController(this._repo);

  final DriverRepository _repo;

  final RxList<HelplineContactEntity> contacts = <HelplineContactEntity>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> loadHelplines() async {
    isLoading.value = true;
    try {
      final helpline = await _repo.getHelplineNumbers();
      if (helpline == null) {
        contacts.clear();
        return;
      }

      final mapped = <HelplineContactEntity>[];
      final office = helpline.officeNumber.trim();
      if (office.isNotEmpty) {
        mapped.add(HelplineContactEntity(name: 'Office', number: office));
      }

      for (var i = 0; i < helpline.contacts.length; i++) {
        final c = helpline.contacts[i];
        final number = c.number.trim();
        if (number.isEmpty) continue;
        final name = c.name.trim().isEmpty ? 'Contact ${i + 1}' : c.name.trim();
        mapped.add(HelplineContactEntity(name: name, number: number));
      }

      contacts.value = mapped;
    } catch (e) {
      ErrorHandler.showError(e, title: 'Could not load helpline numbers');
    } finally {
      isLoading.value = false;
    }
  }
}
