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
      _servicesUsed = e.servicesUsed;
      _date = e.date;
    });
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
          Get.find<DailyEntryController>().loadTodayEntry();
          final name = Get.find<DriverProfileController>().profile.value?.name;
          if (name != null && name.isNotEmpty) _driverName.text = name;
        },
        builder: (entryCtrl) {
          if (entryCtrl.todayEntry.value != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _fillFromEntry(entryCtrl));
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
                          trailing: TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now().add(const Duration(days: 1)),
                              );
                              if (picked != null) setState(() => _date = picked);
                            },
                            child: const Text('Change'),
                          ),
                        ),
                        AppTextField(
                          controller: _driverName,
                          label: 'Driver Name',
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
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
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _startTime,
                          label: 'Starting Time',
                          hint: 'e.g. 09:00',
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _endKm,
                          label: 'Ending Kilometer',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _endTime,
                          label: 'Ending Time',
                          hint: 'e.g. 18:00',
                        ),
                        const SizedBox(height: 12),
                        AppRadioGroup<String>(
                          title: 'Vehicle Number',
                          options: AppConstants.vehicleNumbers,
                          value: _vehicleNumber,
                          onChanged: (v) => setState(() => _vehicleNumber = v),
                        ),
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: _fuelAmount,
                          label: 'Fuel Amount',
                          hint: '0',
                          keyboardType: TextInputType.number,
                        ),
                        AppRadioGroup<String>(
                          title: 'Fuel Paid By',
                          options: const [
                            AppConstants.fuelPaidDriver,
                            AppConstants.fuelPaidOwner,
                            AppConstants.fuelPaidBoth,
                          ],
                          value: _fuelPaidBy,
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
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _cashCollected,
                          label: 'Cash Collected (₹)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppRadioGroup<String>(
                          title: 'Services Used',
                          options: const [
                            AppConstants.serviceUber,
                            AppConstants.servicePrivateTrip,
                            AppConstants.serviceBoth,
                            AppConstants.serviceLeave,
                          ],
                          value: _servicesUsed,
                          onChanged: (v) => setState(() => _servicesUsed = v),
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _privateTripCash,
                          label: 'Private Trip Cash Collected (₹)',
                          hint: '0',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _tollPaid,
                          label: 'Toll Paid by Customer (₹)',
                          hint: '0',
                          keyboardType: TextInputType.number,
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
                              if (_formKey.currentState?.validate() ?? false) {
                                if (_vehicleNumber == null || _vehicleNumber!.isEmpty) {
                                  ErrorHandler.showInfo('Please select a vehicle number.', title: 'Required');
                                  return;
                                }
                                entryCtrl.saveEntry(
                                  date: _date,
                                  driverName: _driverName.text.trim(),
                                  startKm: double.tryParse(_startKm.text),
                                  startTime: _startTime.text.isEmpty ? null : _startTime.text,
                                  endKm: double.tryParse(_endKm.text),
                                  endTime: _endTime.text.isEmpty ? null : _endTime.text,
                                  fuelAmount: double.tryParse(_fuelAmount.text),
                                  fuelPaidBy: _fuelPaidBy,
                                  vehicleNumber: _vehicleNumber,
                                  totalEarning: double.tryParse(_totalEarning.text),
                                  cashCollected: double.tryParse(_cashCollected.text),
                                  servicesUsed: _servicesUsed,
                                  privateTripCash: double.tryParse(_privateTripCash.text),
                                  tollPaidByCustomer: double.tryParse(_tollPaid.text),
                                );
                              }
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
