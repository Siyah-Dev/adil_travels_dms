import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/admin_helpline_controller.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_card.dart';

class HelplineNumbersScreen extends StatefulWidget {
  const HelplineNumbersScreen({super.key});

  @override
  State<HelplineNumbersScreen> createState() => _HelplineNumbersScreenState();
}

class _HelplineNumbersScreenState extends State<HelplineNumbersScreen> {
  final _office = TextEditingController();
  final _name1 = TextEditingController();
  final _number1 = TextEditingController();
  final _name2 = TextEditingController();
  final _number2 = TextEditingController();
  final _name3 = TextEditingController();
  final _number3 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _filled = false;

  @override
  void dispose() {
    _office.dispose();
    _name1.dispose();
    _number1.dispose();
    _name2.dispose();
    _number2.dispose();
    _name3.dispose();
    _number3.dispose();
    super.dispose();
  }

  void _fillFromServer(AdminHelplineController ctrl) {
    final data = ctrl.helpline.value;
    if (_filled || data == null) return;
    _filled = true;

    _office.text = data.officeNumber;
    if (data.contacts.isNotEmpty) {
      _name1.text = data.contacts[0].name;
      _number1.text = data.contacts[0].number;
    }
    if (data.contacts.length > 1) {
      _name2.text = data.contacts[1].name;
      _number2.text = data.contacts[1].number;
    }
    if (data.contacts.length > 2) {
      _name3.text = data.contacts[2].name;
      _number3.text = data.contacts[2].number;
    }
  }

  @override
  Widget build(BuildContext context) {
    String? phoneValidator(String? v) {
      final value = v?.trim() ?? '';
      if (value.isEmpty) return null;
      if (!RegExp(r'^\d{10}$').hasMatch(value)) {
        return 'Must be exactly 10 digits';
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Helpline Numbers')),
      body: GetX<AdminHelplineController>(
        initState: (_) =>
            Get.find<AdminHelplineController>().loadHelplineNumbers(),
        builder: (ctrl) {
          _fillFromServer(ctrl);

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (ctrl.isLoading.value) const LinearProgressIndicator(),
                  SectionCard(
                    title: 'Office Number',
                    child: AppTextField(
                      controller: _office,
                      label: 'Office Number',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 10,
                      validator: phoneValidator,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    title: 'Personal Number 1',
                    child: Column(
                      children: [
                        AppTextField(controller: _name1, label: 'Name'),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _number1,
                          label: 'Number',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 10,
                          validator: phoneValidator,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    title: 'Personal Number 2',
                    child: Column(
                      children: [
                        AppTextField(controller: _name2, label: 'Name'),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _number2,
                          label: 'Number',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 10,
                          validator: phoneValidator,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionCard(
                    title: 'Personal Number 3',
                    child: Column(
                      children: [
                        AppTextField(controller: _name3, label: 'Name'),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _number3,
                          label: 'Number',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 10,
                          validator: phoneValidator,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ctrl.isSaving.value
                          ? null
                          : () {
                              if (!(_formKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }
                              ctrl.saveHelplineNumbers(
                                officeNumber: _office.text,
                                contact1Name: _name1.text,
                                contact1Number: _number1.text,
                                contact2Name: _name2.text,
                                contact2Number: _number2.text,
                                contact3Name: _name3.text,
                                contact3Number: _number3.text,
                              );
                            },
                      child: ctrl.isSaving.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Helpline Numbers'),
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
