import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_pages.dart';
import '../../controllers/auth_controller.dart';

/// Paste in: lib/presentation/screens/admin/admin_home_screen.dart
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final auth = Get.find<AuthController>();
    if (auth.isSigningOut.value) return;

    final shouldLogout = await showDialog<bool>(
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
        title: const Text('${AppConstants.appName} - Admin'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Tile(
            icon: Icons.people,
            title: 'Manage Drivers',
            subtitle: 'View, search, delete, suspend drivers',
            onTap: () => Get.toNamed(AppRoutes.adminDriverList),
          ),
          _Tile(
            icon: Icons.calendar_today,
            title: 'Daily Entries',
            subtitle: 'View drivers\' daily entries by date',
            onTap: () => Get.toNamed(AppRoutes.adminDailyEntries),
          ),
          _Tile(
            icon: Icons.date_range,
            title: 'Weekly Status',
            subtitle: 'Add and manage weekly status per driver',
            onTap: () => Get.toNamed(AppRoutes.adminWeeklyStatus),
          ),
          _Tile(
            icon: Icons.summarize,
            title: 'View Summary Report',
            subtitle: 'Filter by date range and download PDF',
            onTap: () => Get.toNamed(AppRoutes.adminWeeklySummaryReport),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
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
      margin: const EdgeInsets.only(bottom: 12),
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
