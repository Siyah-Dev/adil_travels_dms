import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../domain/entities/driver_profile_entity.dart';
import '../../controllers/admin_driver_list_controller.dart';

/// Paste in: lib/presentation/screens/admin/driver_list_screen.dart
class DriverListScreen extends StatelessWidget {
  const DriverListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drivers')),
      body: GetX<AdminDriverListController>(
        initState: (_) => Get.find<AdminDriverListController>().loadDrivers(),
        builder: (ctrl) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search drivers',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: ctrl.search,
                ),
              ),
              Expanded(
                child: ctrl.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: ctrl.filteredDrivers.length,
                        itemBuilder: (_, i) {
                          final d = ctrl.filteredDrivers[i];
                          return _DriverTile(
                            driver: d,
                            onTap: () => Get.toNamed(
                              AppRoutes.adminDriverDetail,
                              arguments: d.userId,
                            ),
                            onDelete: () async {
                              final ok = await AppDialogs.confirm(
                                title: 'Delete driver?',
                                message: 'Remove ${d.name}? This will delete their profile.',
                                confirmText: 'Delete',
                              );
                              if (ok == true) ctrl.deleteDriver(d.userId);
                            },
                            onSuspend: () => ctrl.setSuspended(d.userId, true),
                            onActivate: () => ctrl.setSuspended(d.userId, false),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DriverTile extends StatelessWidget {
  const _DriverTile({
    required this.driver,
    required this.onTap,
    required this.onDelete,
    required this.onSuspend,
    required this.onActivate,
  });

  final DriverProfileEntity driver;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(driver.name),
      subtitle: Text(driver.place ?? driver.address ?? ''),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'detail') {
            onTap();
          } else if (v == 'delete') {
            onDelete();
          } else if (v == 'suspend') {
            onSuspend();
          } else if (v == 'activate') {
            onActivate();
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'detail', child: Text('View profile')),
          const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
          const PopupMenuItem(value: 'activate', child: Text('Activate')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: onTap,
    );
  }
}
