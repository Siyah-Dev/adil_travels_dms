import 'package:flutter/material.dart';

/// Reusable radio group for string options.
/// Paste in: lib/presentation/widgets/app_radio_group.dart
class AppRadioGroup<T extends String> extends StatelessWidget {
  const AppRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.title,
    this.enabled = true,
  });

  final List<T> options;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? title;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
        ],
        ...options.map((option) => RadioListTile<T>(
              title: Text(option),
              value: option,
              groupValue: value,
              onChanged: enabled ? (v) => onChanged(v) : null,
            )),
      ],
    );
  }
}
