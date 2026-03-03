import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/error_handler.dart';
import '../../controllers/driver_helpline_controller.dart';

class DriverHelplineScreen extends StatelessWidget {
  const DriverHelplineScreen({super.key});

  Future<void> _call(String number) async {
    final value = number.trim();
    if (value.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    ErrorHandler.showInfo('Could not open dialer.', title: 'Call failed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Helpline Numbers')),
      body: GetX<DriverHelplineController>(
        initState: (_) => Get.find<DriverHelplineController>().loadHelplines(),
        builder: (ctrl) {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.contacts.isEmpty) {
            return const Center(child: Text('No helpline numbers available.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.contacts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = ctrl.contacts[i];
              return Card(
                child: ListTile(
                  title: Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    c.number,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    onPressed: () => _call(c.number),
                    tooltip: 'Call',
                    icon: Icon(
                      Icons.call,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
