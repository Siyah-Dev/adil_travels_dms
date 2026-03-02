import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Reusable text field.
/// Paste in: lib/presentation/widgets/app_text_field.dart
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.enableObscureToggle = false,
    this.readOnly = false,
    this.onTap,
    this.maxLength,
    this.inputFormatters,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final bool enableObscureToggle;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowToggle = widget.obscureText && widget.enableObscureToggle;
    final suffix = shouldShowToggle
        ? IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            ),
            onPressed: () => setState(() => _isObscured = !_isObscured),
          )
        : widget.suffixIcon;

    return TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: suffix,
      ),
      keyboardType: widget.keyboardType,
      obscureText: _isObscured,
      validator: widget.validator,
      onChanged: widget.onChanged,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
    );
  }
}
