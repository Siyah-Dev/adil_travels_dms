import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_dialogs.dart';
import '../../controllers/admin_vehicle_controller.dart';

class VehicleManagementScreen extends StatelessWidget {
  const VehicleManagementScreen({super.key});

  Future<void> _showAddVehicleDialog(AdminVehicleController ctrl) async {
    await Get.dialog<bool>(_AddVehicleDialog(controller: ctrl));
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

class _AddVehicleDialog extends StatefulWidget {
  const _AddVehicleDialog({required this.controller});

  final AdminVehicleController controller;

  @override
  State<_AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<_AddVehicleDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AlertDialog(
        title: const Text('Add Vehicle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Vehicle Name'),
              enabled: !widget.controller.isSaving.value,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(labelText: 'Vehicle Number'),
              enabled: !widget.controller.isSaving.value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: widget.controller.isSaving.value ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: widget.controller.isSaving.value
                ? null
                : () async {
                    final nav = Navigator.of(context, rootNavigator: true);
                    final ok = await widget.controller.addVehicle(
                      _nameController.text,
                      _numberController.text,
                    );
                    if (ok) {
                      nav.pop(true);
                    }
                  },
            child: widget.controller.isSaving.value
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add'),
          ),
        ],
      ),
    );
  }
}
