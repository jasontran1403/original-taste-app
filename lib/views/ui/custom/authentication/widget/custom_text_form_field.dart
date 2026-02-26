import 'package:flutter/material.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';

class CustomTextFormField extends StatefulWidget {
  final String? labelText;
  final TextEditingController? controller;
  final String? hintText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final int? maxLines;
  final bool obscureText;
  final TextInputType? keyboardType;

  const CustomTextFormField({
    super.key,
    this.labelText,
    this.controller,
    this.hintText,
    this.validator,
    this.prefixIcon,
    this.maxLines,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isObscured = true;

  ContentTheme get tTheme => AdminTheme.theme.contentTheme;

  OutlineInputBorder get _border => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: tTheme.secondary, width: 0.5),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText?.isNotEmpty ?? false) ...[
          MyText.bodyMedium(widget.labelText!),
          MySpacing.height(8),
        ],
        TextFormField(
          controller: widget.controller,
          // obscureText chỉ active khi field là password và chưa toggle hiện
          obscureText: widget.obscureText && _isObscured,
          keyboardType: widget.obscureText ? TextInputType.visiblePassword : widget.keyboardType,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          style: MyTextStyle.bodyMedium(),
          validator: widget.validator,
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon,
            hintText: widget.hintText,
            contentPadding: MySpacing.all(16),
            filled: true,
            fillColor: tTheme.background,
            isDense: true,
            isCollapsed: true,
            border: _border,
            enabledBorder: _border,
            focusedBorder: _border,
            disabledBorder: _border,
            focusedErrorBorder: _border,
            // Hiện icon toggle ẩn/hiện mật khẩu khi là password field
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 18,
                color: tTheme.secondary,
              ),
              onPressed: () => setState(() => _isObscured = !_isObscured),
            )
                : null,
          ),
        ),
      ],
    );
  }
}