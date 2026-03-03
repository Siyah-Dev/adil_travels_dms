import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/error_handler.dart';
import '../../controllers/daily_entry_controller.dart';
import '../../controllers/driver_profile_controller.dart';
import '../../widgets/app_radio_group.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_card.dart';

/// Paste in: lib/presentation/screens/driver/daily_entry_screen.dart
class DailyEntryScreen extends StatefulWidget {
  const DailyEntryScreen({super.key});

  @override
  State<DailyEntryScreen> createState() => _DailyEntryScreenState();
}

class _DailyEntryScreenState extends State<DailyEntryScreen> {
  final _driverName = TextEditingController();
  final _startKm = TextEditingController();
  final _startTime = TextEditingController();
  final _endKm = TextEditingController();
  final _endTime = TextEditingController();
  final _fuelAmount = TextEditingController();
  final _totalEarning = TextEditingController();
  final _cashCollected = TextEditingController();
  final _privateTripCash = TextEditingController();
  final _tollPaid = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _fuelPaidBy;
  String? _vehicleNumber;
  String? _servicesUsed;
  DateTime _date = DateTime.now();
  bool _filledFromEntry = false;
  bool _filledFromProfile = false;
  bool _leaveOnToday = false;
  DateTime? _leaveEnabledAt;
  bool _forceLeaveOffUntilSave = false;

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;

    final now = DateTime.now();
    final value = DateTime(
      now.year,
      now.month,
      now.day,
      picked.hour,
      picked.minute,
    );
    controller.text = DateFormat('hh:mm a').format(value);
  }

  void _clearNonEssentialFields() {
    _startKm.clear();
    _startTime.clear();
    _endKm.clear();
    _endTime.clear();
    _fuelAmount.clear();
    _totalEarning.clear();
    _cashCollected.clear();
    _privateTripCash.clear();
    _tollPaid.clear();
    _fuelPaidBy = null;
    _vehicleNumber = null;
    _servicesUsed = null;
  }

  Future<void> _toggleLeave(DailyEntryController ctrl, bool enabled) async {
    if (enabled) {
      setState(() {
        _forceLeaveOffUntilSave = false;
        _leaveOnToday = true;
        _leaveEnabledAt = DateTime.now();
        _clearNonEssentialFields();
      });
      return;
    }

    setState(() {
      _leaveOnToday = false;
      _leaveEnabledAt = null;
      _filledFromEntry = false;
      _forceLeaveOffUntilSave = true;
    });

    await ctrl.loadTodayEntry();

    if (ctrl.todayEntry.value == null) {
      setState(() {
        _clearNonEssentialFields();
      });
    }
  }

  @override
  void dispose() {
    _driverName.dispose();
    _startKm.dispose();
    _startTime.dispose();
    _endKm.dispose();
    _endTime.dispose();
    _fuelAmount.dispose();
    _totalEarning.dispose();
    _cashCollected.dispose();
    _privateTripCash.dispose();
    _tollPaid.dispose();
    super.dispose();
  }

  void _fillFromEntry(DailyEntryController ctrl) {
    if (_filledFromEntry) return;
    final e = ctrl.todayEntry.value;
    if (e == null) return;
    _filledFromEntry = true;

    _driverName.text = e.driverName;
    _startKm.text = e.startKm?.toString() ?? '';
    _startTime.text = e.startTime ?? '';
    _endKm.text = e.endKm?.toString() ?? '';
    _endTime.text = e.endTime ?? '';
    _fuelAmount.text = e.fuelAmount?.toString() ?? '';
    _totalEarning.text = e.totalEarning?.toString() ?? '';
    _cashCollected.text = e.cashCollected?.toString() ?? '';
    _privateTripCash.text = e.privateTripCash?.toString() ?? '';
    _tollPaid.text = e.tollPaidByCustomer?.toString() ?? '';

    setState(() {
      _fuelPaidBy = e.fuelPaidBy;
      _vehicleNumber = e.vehicleNumber;
      final effectiveLeave = _forceLeaveOffUntilSave ? false : e.leaveOnToday;
      _servicesUsed =
          effectiveLeave || e.servicesUsed == AppConstants.serviceLeave
          ? null
          : e.servicesUsed;
      _date = e.date;
      _leaveOnToday = effectiveLeave;
      _leaveEnabledAt = effectiveLeave ? e.leaveEnabledAt : null;
    });

    if (_leaveOnToday) {
      setState(() {
        _clearNonEssentialFields();
      });
    }
  }

  void _fillDriverNameFromProfile(DriverProfileController profileCtrl) {
    if (_filledFromProfile) return;
    final name = profileCtrl.profile.value?.name;
    if (name != null && name.isNotEmpty) {
      _filledFromProfile = true;
      _driverName.text = name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Entry')),
      body: GetX<DailyEntryController>(
        initState: (_) {
          final ctrl = Get.find<DailyEntryController>();
          ctrl.loadTodayEntry();
          ctrl.loadVehicles();
          final name = Get.find<DriverProfileController>().profile.value?.name;
          if (name != null && name.isNotEmpty) _driverName.text = name;
        },
        builder: (entryCtrl) {
          if (entryCtrl.todayEntry.value != null) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _fillFromEntry(entryCtrl),
            );
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fillDriverNameFromProfile(Get.find<DriverProfileController>());
            });
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SectionCard(
                    title: 'Date & Driver',
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Date'),
                          subtitle: Text(DateFormat.yMMMd().format(_date)),
                          trailing: IconButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 1),
                                ),
                              );
                              if (picked != null) {
                                setState(() => _date = picked);
                              }
                            },
                            tooltip: 'Pick date',
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                        AppTextField(
                          controller: _driverName,
                          label: 'Driver Name',
                          enabled: false,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Leave on Today'),
                          // subtitle: Text(
                          //   _leaveOnToday
                          //       ? 'All other fields are cleared and disabled.'
                          //       : 'Turn on if driver is on leave today.',
                          // ),
                          value: _leaveOnToday,
                          onChanged: entryCtrl.saving.value
                              ? null
                              : (v) => _toggleLeave(entryCtrl, v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    title: 'Trip (Mandatory)',
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _startKm,
                          label: 'Starting Kilometer',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          enabled: !_leaveOnToday,
                          validator: (v) {
                            if (_leaveOnToday) return null;
                            return v == null || v.isEmpty ? 'Required' : null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _startTime,
                          label: 'Starting Time',
                          hint: 'Select time',
                          enabled: !_leaveOnToday,
                          readOnly: true,
                          onTap: _leaveOnToday
                              ? null
                              : () => _pickTime(_startTime),
                          suffixIcon: const Icon(Icons.access_time),
                          validator: (v) {
                            if (_leaveOnToday) return null;
                            return v == null || v.trim().isEmpty
                                ? 'Required'
                                : null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _endKm,
                          label: 'Ending Kilometer',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          enabled: !_leaveOnToday,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _endTime,
                          label: 'Ending Time',
                          hint: 'Select time',
                          enabled: !_leaveOnToday,
                          readOnly: true,
                          onTap: _leaveOnToday
                              ? null
                              : () => _pickTime(_endTime),
                          suffixIcon: const Icon(Icons.access_time),
                        ),
                        const SizedBox(height: 12),
                        if (entryCtrl.vehicles.isEmpty)
                          InkWell(
                            onTap: _leaveOnToday
                                ? null
                                : () => ErrorHandler.showInfo(
                                    'No vehicles available. Please contact admin.',
                                    title: 'Vehicle List Empty',
                                  ),
                            child: const InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Vehicle',
                                alignLabelWithHint: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                constraints: BoxConstraints(minHeight: 72),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              child: Text('No vehicles available'),
                            ),
                          )
                        else
                          DropdownButtonFormField<String>(
                            isDense: false,
                            initialValue:
                                entryCtrl.vehicles.any(
                                  (v) => v.number == _vehicleNumber,
                                )
                                ? _vehicleNumber
                                : null,
                            hint: const Text('Choose your vehicle'),
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: const InputDecoration(
                              labelText: 'Vehicle',
                              alignLabelWithHint: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              constraints: BoxConstraints(minHeight: 96),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            isExpanded: true,
                            itemHeight: null,
                            selectedItemBuilder: (context) {
                              return entryCtrl.vehicles.map((vehicle) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      vehicle.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      vehicle.number,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                );
                              }).toList();
                            },
                            items: entryCtrl.vehicles.map((vehicle) {
                              return DropdownMenuItem<String>(
                                value: vehicle.number,
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        vehicle.name,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        vehicle.number,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: _leaveOnToday
                                ? null
                                : (v) => setState(() => _vehicleNumber = v),
                            validator: (v) {
                              if (_leaveOnToday) return null;
                              if (v == null || v.isEmpty) {
                                return 'Please choose your vehicle';
                              }
                              return null;
                            },
                          ),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: _fuelAmount,
                          label: 'Fuel Amount',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          enabled: !_leaveOnToday,
                        ),
                        const SizedBox(height: 8),
                        AppRadioGroup<String>(
                          title: 'Fuel Paid By',
                          options: const [
                            AppConstants.fuelPaidDriver,
                            AppConstants.fuelPaidOwner,
                            AppConstants.fuelPaidBoth,
                          ],
                          value: _fuelPaidBy,
                          enabled: !_leaveOnToday,
                          onChanged: (v) => setState(() => _fuelPaidBy = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    title: 'Earnings & Services',
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _totalEarning,
                          label: 'Total Earning (₹)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          enabled: !_leaveOnToday,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _cashCollected,
                          label: 'Cash Collected (₹)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          enabled: !_leaveOnToday,
                        ),
                        const SizedBox(height: 12),
                        AppRadioGroup<String>(
                          title: 'Services Used',
                          options: const [
                            AppConstants.serviceUber,
                            AppConstants.servicePrivateTrip,
                            AppConstants.serviceBoth,
                          ],
                          value: _servicesUsed,
                          enabled: !_leaveOnToday,
                          onChanged: (v) => setState(() => _servicesUsed = v),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _privateTripCash,
                          label: 'Private Trip Cash Collected (₹)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          enabled: !_leaveOnToday,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _tollPaid,
                          label: 'Toll Paid by Customer (₹)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          enabled: !_leaveOnToday,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: entryCtrl.saving.value
                          ? null
                          : () {
                              if (_driverName.text.trim().isEmpty) {
                                ErrorHandler.showInfo(
                                  'Driver name is required.',
                                  title: 'Required',
                                );
                                return;
                              }

                              if (!_leaveOnToday) {
                                _forceLeaveOffUntilSave = false;
                              }

                              if (!_leaveOnToday) {
                                if (entryCtrl.vehicles.isEmpty) {
                                  ErrorHandler.showInfo(
                                    'No vehicles available. Please contact admin.',
                                    title: 'Vehicle List Empty',
                                  );
                                  return;
                                }
                                if (!(_formKey.currentState?.validate() ??
                                    false)) {
                                  return;
                                }
                              }

                              entryCtrl.saveEntry(
                                date: _date,
                                driverName: _driverName.text.trim(),
                                startKm: _leaveOnToday
                                    ? null
                                    : double.tryParse(_startKm.text),
                                startTime:
                                    _leaveOnToday || _startTime.text.isEmpty
                                    ? null
                                    : _startTime.text,
                                endKm: _leaveOnToday
                                    ? null
                                    : double.tryParse(_endKm.text),
                                endTime: _leaveOnToday || _endTime.text.isEmpty
                                    ? null
                                    : _endTime.text,
                                fuelAmount: _leaveOnToday
                                    ? null
                                    : double.tryParse(_fuelAmount.text),
                                fuelPaidBy: _leaveOnToday ? null : _fuelPaidBy,
                                vehicleNumber: _leaveOnToday
                                    ? null
                                    : _vehicleNumber,
                                totalEarning: _leaveOnToday
                                    ? null
                                    : double.tryParse(_totalEarning.text),
                                cashCollected: _leaveOnToday
                                    ? null
                                    : double.tryParse(_cashCollected.text),
                                servicesUsed: _leaveOnToday
                                    ? null
                                    : _servicesUsed,
                                leaveOnToday: _leaveOnToday,
                                leaveEnabledAt: _leaveOnToday
                                    ? (_leaveEnabledAt ?? DateTime.now())
                                    : null,
                                privateTripCash: _leaveOnToday
                                    ? null
                                    : double.tryParse(_privateTripCash.text),
                                tollPaidByCustomer: _leaveOnToday
                                    ? null
                                    : double.tryParse(_tollPaid.text),
                              );
                            },
                      child: entryCtrl.saving.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Daily Entry'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
