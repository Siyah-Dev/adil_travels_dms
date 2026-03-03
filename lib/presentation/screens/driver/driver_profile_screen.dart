import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/supabase_storage_service.dart';
import '../../controllers/driver_profile_controller.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_card.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

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

  void _fillFromProfile(DriverProfileController controller) {
    final profile = controller.profile.value;
    if (profile == null) return;
    _name.text = profile.name;
    _age.text = profile.age?.toString() ?? '';
    _address.text = profile.address ?? '';
    _place.text = profile.place ?? '';
    _pincode.text = profile.pincode ?? '';
    _mobile.text = profile.mobileNumber ?? '';
    _aadhar.text = profile.aadharNumber ?? '';
    _licence.text = profile.drivingLicenceNumber ?? '';
  }

  Future<void> _pickAndUpload({
    required DriverProfileController ctrl,
    required String type,
  }) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;

      final length = await picked.length();
      if (length > 2 * 1024 * 1024) {
        Get.snackbar('Invalid file', 'File size must be 2 MB or less.');
        return;
      }

      if (!SupabaseStorageService.isAllowedImageExtension(picked.name)) {
        Get.snackbar('Invalid file', 'Only JPG/PNG files are allowed.');
        return;
      }

      final bytes = await picked.readAsBytes();
      await ctrl.uploadDocument(
        type: type,
        fileName: picked.name,
        bytes: bytes,
      );
    } on PlatformException {
      Get.snackbar(
        'Image Picker Error',
        'Please restart the app and try again.',
      );
    } catch (_) {
      Get.snackbar('Upload Error', 'Could not pick image. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: GetX<DriverProfileController>(
        builder: (ctrl) {
          if (ctrl.profile.value != null && _name.text.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _fillFromProfile(ctrl),
            );
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
                        _DocumentUploadTile(
                          title: 'Profile Picture',
                          pathProvider: () =>
                              ctrl.profile.value?.profileImagePath,
                          onUpload: ctrl.isUploading.value
                              ? null
                              : () =>
                                    _pickAndUpload(ctrl: ctrl, type: 'profile'),
                          signedUrlLoader: ctrl.getSignedUrl,
                          circularPreview: true,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _name,
                          label: 'Name *',
                          hint: 'Full name',
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _mobile,
                          label: 'Mobile Number *',
                          hint: 'Mobile number',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
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
                        AppTextField(
                          controller: _place,
                          label: 'Place',
                          hint: 'Place',
                        ),
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
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
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
                        _DocumentUploadTile(
                          title: 'Aadhar Picture',
                          pathProvider: () =>
                              ctrl.profile.value?.aadharImagePath,
                          onUpload: ctrl.isUploading.value
                              ? null
                              : () =>
                                    _pickAndUpload(ctrl: ctrl, type: 'aadhar'),
                          signedUrlLoader: ctrl.getSignedUrl,
                        ),
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _licence,
                          label: 'Driving Licence Number *',
                          hint: 'Licence number',
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        _DocumentUploadTile(
                          title: 'Driving Licence Picture',
                          pathProvider: () =>
                              ctrl.profile.value?.drivingLicenceImagePath,
                          onUpload: ctrl.isUploading.value
                              ? null
                              : () =>
                                    _pickAndUpload(ctrl: ctrl, type: 'licence'),
                          signedUrlLoader: ctrl.getSignedUrl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ctrl.isLoading.value
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                ctrl.saveProfile(
                                  name: _name.text,
                                  age: int.tryParse(_age.text),
                                  address: _address.text.isEmpty
                                      ? null
                                      : _address.text,
                                  place: _place.text.isEmpty
                                      ? null
                                      : _place.text,
                                  pincode: _pincode.text.isEmpty
                                      ? null
                                      : _pincode.text,
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
            ),
          );
        },
      ),
    );
  }
}

class _DocumentUploadTile extends StatelessWidget {
  const _DocumentUploadTile({
    required this.title,
    required this.pathProvider,
    required this.onUpload,
    required this.signedUrlLoader,
    this.circularPreview = false,
  });

  final String title;
  final String? Function() pathProvider;
  final VoidCallback? onUpload;
  final Future<String?> Function(String?) signedUrlLoader;
  final bool circularPreview;

  @override
  Widget build(BuildContext context) {
    final path = pathProvider();
    final preview = Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        borderRadius: circularPreview
            ? BorderRadius.circular(41)
            : BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: path == null || path.isEmpty
          ? const Icon(Icons.image_outlined)
          : FutureBuilder<String?>(
              future: signedUrlLoader(path),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Icon(Icons.broken_image_outlined);
                }
                return ClipRRect(
                  borderRadius: circularPreview
                      ? BorderRadius.circular(41)
                      : BorderRadius.circular(8),
                  child: Image.network(snapshot.data!, fit: BoxFit.cover),
                );
              },
            ),
    );

    if (circularPreview) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: preview),
          const SizedBox(height: 8),
          Center(
            child: OutlinedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file),
              label: Text(path == null || path.isEmpty ? 'Upload' : 'Replace'),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        preview,
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  path == null || path.isEmpty ? 'Upload' : 'Replace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
