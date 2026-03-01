import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reusable dialogs for confirmation and simple text input prompts.
class AppDialogs {
  AppDialogs._();

  static Future<void> alert({
    required String title,
    required String message,
    String buttonText = 'OK',
    bool barrierDismissible = false,
  }) async {
    await Get.dialog<void>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(buttonText),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static Future<bool> confirm({
    required String title,
    required String message,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    bool barrierDismissible = true,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(confirmText),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
    return result ?? false;
  }

  static Future<String?> promptText({
    required String title,
    required String label,
    String? hint,
    String confirmText = 'Submit',
    String cancelText = 'Cancel',
    TextInputType keyboardType = TextInputType.text,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);

    final value = await Get.dialog<String>(
      AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(labelText: label, hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    controller.dispose();
    return value;
  }
}
