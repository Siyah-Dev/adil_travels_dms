import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/supabase_storage_service.dart';
import '../../../core/routes/app_pages.dart';
import '../../../domain/entities/daily_entry_entity.dart';
import '../../controllers/admin_driver_detail_controller.dart';
import '../../widgets/section_card.dart';

/// Paste in: lib/presentation/screens/admin/driver_detail_screen.dart
class DriverDetailScreen extends StatelessWidget {
  const DriverDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final driverId = Get.arguments as String;
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Detail')),
      body: GetX<AdminDriverDetailController>(
        initState: (_) {
          Get.find<AdminDriverDetailController>().loadDriver(driverId);
          Get.find<AdminDriverDetailController>().loadDailyEntries(driverId);
        },
        builder: (ctrl) {
          if (ctrl.loadingProfile.value && ctrl.driver.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = ctrl.driver.value;
          if (d == null) {
            return const Center(child: Text('Driver not found'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionCard(
                  title: 'Profile',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: _DriverProfileAvatar(path: d.profileImagePath),
                      ),
                      const SizedBox(height: 16),
                      _ProfileRow('Name', d.name),
                      _ProfileRow('Mobile Number', _displayValue(d.mobileNumber)),
                      _ProfileRow('Address', _displayValue(d.address)),
                      _ProfileRow('Pincode', _displayValue(d.pincode)),
                      _ProfileRow('Aadhar Number', _displayValue(d.aadharNumber)),
                      _ProfileRow('Licence Number', _displayValue(d.drivingLicenceNumber)),
                      if (d.age != null) _ProfileRow('Age', d.age.toString()),
                      if ((d.place ?? '').trim().isNotEmpty) _ProfileRow('Place', d.place!.trim()),
                      const SizedBox(height: 12),
                      _DriverDocImage(
                        title: 'Aadhar Image',
                        path: d.aadharImagePath,
                      ),
                      const SizedBox(height: 10),
                      _DriverDocImage(
                        title: 'Licence Image',
                        path: d.drivingLicenceImagePath,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Daily entries (date wise)',
                  child: ctrl.loadingEntries.value
                      ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                      : ctrl.dailyEntries.isEmpty
                          ? const Text('No entries')
                          : Column(
                              children: ctrl.dailyEntries.map((e) => _EntryTile(entry: e)).toList(),
                            ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Get.toNamed(
                    AppRoutes.adminWeeklyStatus,
                    arguments: {'driverId': d.userId},
                  ),
                  icon: const Icon(Icons.date_range),
                  label: const Text('Weekly Status'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _displayValue(String? value) {
  final v = value?.trim() ?? '';
  return v.isEmpty ? '-' : v;
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final DailyEntryEntity entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(DateFormat.yMMMd().format(entry.date)),
      subtitle: Text(
        'Start ${entry.startKm ?? '-'} km → End ${entry.endKm ?? '-'} km | ₹${entry.totalEarning ?? 0}',
      ),
      dense: true,
    );
  }
}

class _DriverProfileAvatar extends StatelessWidget {
  const _DriverProfileAvatar({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final p = path?.trim() ?? '';
    if (p.isEmpty) {
      return const CircleAvatar(
        radius: 46,
        child: Icon(Icons.person, size: 36),
      );
    }

    return FutureBuilder<String>(
      future: SupabaseStorageService.createSignedUrl(p),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircleAvatar(
            radius: 46,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final url = snapshot.data ?? '';
        if (url.isEmpty) {
          return const CircleAvatar(
            radius: 46,
            child: Icon(Icons.person, size: 36),
          );
        }

        return CircleAvatar(
          radius: 46,
          backgroundImage: NetworkImage(url),
        );
      },
    );
  }
}

class _DriverDocImage extends StatelessWidget {
  const _DriverDocImage({
    required this.title,
    required this.path,
  });

  final String title;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        if (path == null || path!.trim().isEmpty)
          const Text('-')
        else
          FutureBuilder<String>(
            future: SupabaseStorageService.createSignedUrl(path!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('Could not load image');
              }
              final imageUrl = snapshot.data!;
              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => Dialog(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () => Get.back<void>(),
                              icon: const Icon(Icons.close),
                            ),
                          ),
                          Flexible(
                            child: InteractiveViewer(
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    height: 84,
                    width: 84,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
