import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/driver_profile_controller.dart';
import '../../widgets/logout_action_button.dart';
import '../../widgets/navigation_menu_tile.dart';

/// Paste in: lib/presentation/screens/driver/driver_home_screen.dart
class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final auth = Get.find<AuthController>();
    if (auth.isSigningOut.value) return;

    final shouldLogout = await AppDialogs.confirm(
      title: 'Confirm Logout',
      message: 'Are you sure you want to log out?',
    );

    if (shouldLogout) {
      await auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          Obx(
            () => LogoutActionButton(
              isLoading: auth.isSigningOut.value,
              onPressed: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
      body: GetX<DriverProfileController>(
        init: Get.find<DriverProfileController>(),
        initState: (_) => Get.find<DriverProfileController>().loadProfile(),
        builder: (profileCtrl) {
          if (profileCtrl.isLoading.value &&
              profileCtrl.profile.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final name = profileCtrl.profile.value?.name ?? 'Driver';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(name),
                    subtitle: const Text('Tap to edit profile'),
                    onTap: () => Get.toNamed(AppRoutes.driverProfile),
                  ),
                ),
                const SizedBox(height: 24),
                NavigationMenuTile(
                  icon: Icons.edit_note,
                  title: 'Daily Entry',
                  subtitle: 'Fill today\'s trip details',
                  margin: EdgeInsets.zero,
                  onTap: () => Get.toNamed(AppRoutes.dailyEntry),
                ),
                NavigationMenuTile(
                  icon: Icons.summarize,
                  title: 'Weekly Summary',
                  subtitle: 'View and download weekly report',
                  margin: const EdgeInsets.only(top: 12),
                  onTap: () => Get.toNamed(AppRoutes.driverWeeklySummary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
