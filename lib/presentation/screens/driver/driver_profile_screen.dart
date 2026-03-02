import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_pages.dart';
import '../../controllers/driver_profile_controller.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_card.dart';

/// Paste in: lib/presentation/screens/driver/driver_profile_screen.dart
class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _address = TextEditingController();
  final _place = TextEditingController();
  final _pincode = TextEditingController();
  final _mobile = TextEditingController();
  final _aadhar = TextEditingController();
  final _licence = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _address.dispose();
    _place.dispose();
    _pincode.dispose();
    _mobile.dispose();
    _aadhar.dispose();
    _licence.dispose();
    super.dispose();
  }

  void _fillFromProfile(DriverProfileController ctrl) {
    final p = ctrl.profile.value;
    if (p == null) return;
    _name.text = p.name;
    _age.text = p.age?.toString() ?? '';
    _address.text = p.address ?? '';
    _place.text = p.place ?? '';
    _pincode.text = p.pincode ?? '';
    _mobile.text = p.mobileNumber ?? '';
    _aadhar.text = p.aadharNumber ?? '';
    _licence.text = p.drivingLicenceNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: GetX<DriverProfileController>(
        builder: (ctrl) {
          if (ctrl.profile.value != null && _name.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _fillFromProfile(ctrl));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SectionCard(
                    title: 'Personal Details',
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _name,
                          label: 'Name *',
                          hint: 'Full name',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _mobile,
                          label: 'Mobile Number *',
                          hint: 'Mobile number',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 10,
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Required';
                            if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                              return 'Mobile number must be exactly 10 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _age,
                          label: 'Age',
                          hint: 'Age',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _address,
                          label: 'Address',
                          hint: 'Address',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(controller: _place, label: 'Place', hint: 'Place'),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _pincode,
                          label: 'Pincode',
                          hint: 'Pincode',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _aadhar,
                          label: 'Aadhar Number *',
                          hint: 'Aadhar number',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 16,
                          validator: (v) {
                            final value = v?.trim() ?? '';
                            if (value.isEmpty) return 'Required';
                            if (!RegExp(r'^\d{16}$').hasMatch(value)) {
                              return 'Aadhar number must be exactly 16 digits';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _licence,
                          label: 'Driving Licence Number *',
                          hint: 'Licence number',
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.toNamed(AppRoutes.driverWeeklySummary),
                          child: const Text('View Summary'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: ctrl.isLoading.value
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    ctrl.saveProfile(
                                      name: _name.text,
                                      age: int.tryParse(_age.text),
                                      address: _address.text.isEmpty ? null : _address.text,
                                      place: _place.text.isEmpty ? null : _place.text,
                                      pincode: _pincode.text.isEmpty ? null : _pincode.text,
                                      mobileNumber: _mobile.text,
                                      aadharNumber: _aadhar.text,
                                      drivingLicenceNumber: _licence.text,
                                    );
                                  }
                                },
                          child: ctrl.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ],
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
