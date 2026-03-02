import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../controllers/admin_vehicle_controller.dart';

class VehicleManagementScreen extends StatelessWidget {
  const VehicleManagementScreen({super.key});

  Future<void> _showAddVehicleDialog(AdminVehicleController ctrl) async {
    final nameController = TextEditingController();
    final numberController = TextEditingController();

    await Get.dialog<void>(
      AlertDialog(
        title: const Text('Add Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Vehicle Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'Vehicle Number'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(
            () => TextButton(
              onPressed: ctrl.isSaving.value
                  ? null
                  : () async {
                      final ok = await ctrl.addVehicle(
                        nameController.text,
                        numberController.text,
                      );
                      if (ok) {
                        Get.back();
                      }
                    },
              child: ctrl.isSaving.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add'),
            ),
          ),
        ],
      ),
    );

    nameController.dispose();
    numberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminVehicleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Vehicles'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVehicleDialog(ctrl),
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
      body: GetX<AdminVehicleController>(
        initState: (_) => ctrl.loadVehicles(),
        builder: (c) {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.vehicles.isEmpty) {
            return const Center(child: Text('No vehicles added yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: c.vehicles.length,
            separatorBuilder: (_, index) =>
                SizedBox(key: ValueKey('vehicle-sep-$index'), height: 10),
            itemBuilder: (_, i) {
              final v = c.vehicles[i];
              return Card(
                child: ListTile(
                  title: Text(
                    v.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(v.number),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await AppDialogs.confirm(
                        title: 'Delete Vehicle?',
                        message: 'Remove ${v.name} (${v.number})?',
                        confirmText: 'Delete',
                      );
                      if (ok) {
                        await c.deleteVehicle(v.number);
                      }
                    },
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
