import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_pages.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/driver_profile_controller.dart';

/// Paste in: lib/presentation/screens/driver/driver_home_screen.dart
class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final auth = Get.find<AuthController>();
    if (auth.isSigningOut.value) return;

    final shouldLogout =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        ) ??
        false;

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
            () => IconButton(
              onPressed: auth.isSigningOut.value ? null : () => _confirmLogout(context),
              icon: auth.isSigningOut.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
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
                _MenuTile(
                  icon: Icons.edit_note,
                  title: 'Daily Entry',
                  subtitle: 'Fill today\'s trip details',
                  onTap: () => Get.toNamed(AppRoutes.dailyEntry),
                ),
                _MenuTile(
                  icon: Icons.summarize,
                  title: 'Weekly Summary',
                  subtitle: 'View and download weekly report',
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

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
