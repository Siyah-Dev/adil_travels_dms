import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/routes/app_pages.dart';
import '../../../core/services/supabase_storage_service.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../../core/utils/error_handler.dart';
import '../../../domain/entities/daily_entry_entity.dart';
import '../../../domain/entities/driver_profile_entity.dart';
import '../../controllers/admin_driver_list_controller.dart';

/// Paste in: lib/presentation/screens/admin/driver_list_screen.dart
class DriverListScreen extends StatelessWidget {
  const DriverListScreen({super.key});

  Future<void> _call(String? mobileNumber) async {
    final number = mobileNumber?.trim() ?? '';
    if (number.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    ErrorHandler.showInfo('Could not open dialer.', title: 'Call failed');
  }

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
                          final todayEntry = ctrl.todayEntryByDriver[d.userId];
                          return _DriverTile(
                            driver: d,
                            todayEntry: todayEntry,
                            onCall: () => _call(d.mobileNumber),
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
    required this.todayEntry,
    required this.onCall,
    required this.onTap,
    required this.onDelete,
    required this.onSuspend,
    required this.onActivate,
  });

  final DriverProfileEntity driver;
  final DailyEntryEntity? todayEntry;
  final VoidCallback onCall;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSuspend;
  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    final mobile = driver.mobileNumber?.trim() ?? '';
    final hasMobile = mobile.isNotEmpty;
    final vehicleNumber = todayEntry?.vehicleNumber?.trim() ?? '';
    final leaveToday = todayEntry?.leaveOnToday ?? false;

    final subtitle = leaveToday
        ? 'On leave today'
        : (vehicleNumber.isNotEmpty ? vehicleNumber : 'No vehicle selected');

    return ListTile(
      leading: _DriverAvatar(imagePath: driver.profileImagePath),
      title: Text(driver.name),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: hasMobile ? onCall : null,
            tooltip: hasMobile ? 'Call' : 'Mobile not available',
            icon: Icon(
              Icons.call,
              color: hasMobile ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
          ),
          PopupMenuButton<String>(
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
        ],
      ),
      onTap: onTap,
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({required this.imagePath});

  final String? imagePath;

  Future<String?> _loadImageUrl() async {
    if (imagePath == null || imagePath!.trim().isEmpty) return null;
    try {
      return await SupabaseStorageService.createSignedUrl(imagePath!);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.trim().isEmpty) {
      return const CircleAvatar(child: Icon(Icons.person));
    }

    return FutureBuilder<String?>(
      future: _loadImageUrl(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        final url = snapshot.data;
        if (url == null || url.isEmpty) {
          return const CircleAvatar(child: Icon(Icons.person));
        }
        return CircleAvatar(backgroundImage: NetworkImage(url));
      },
    );
  }
}
