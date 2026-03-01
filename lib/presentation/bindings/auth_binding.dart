import 'package:get/get.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../controllers/auth_controller.dart';

/// Paste in: lib/presentation/bindings/auth_binding.dart
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(AuthRepositoryImpl()), permanent: true);
    }
  }
}
