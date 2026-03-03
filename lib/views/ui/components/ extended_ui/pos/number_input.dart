// lib/views/ui/components/extended_ui/pos/number_input.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double width;
  final bool autoFormat; // true: tự động format 1,000,000 khi nhập
  final FocusNode? focusNode;

  const NumberInput({
    super.key,
    required this.controller,
    required this.label,
    this.width = 54.0,
    this.autoFormat = false, // mặc định false cho kiểm kho, true cho chuyển khoản
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        SizedBox(
          width: width,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              if (autoFormat) _ThousandsSeparatorFormatter(),
              FilteringTextInputFormatter.digitsOnly,
            ],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 11),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.deepOrange, width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
              hintText: '0',
              hintStyle: const TextStyle(color: Colors.grey),
            ),
            onTap: () {
              controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: controller.text.length,
              );
            },
          ),
        ),
      ],
    );
  }
}

// Formatter tự động thêm dấu phẩy mỗi 3 số (kiểu Việt Nam: 1,000,000)
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Loại bỏ dấu phẩy cũ để lấy số thuần
    String text = newValue.text.replaceAll(',', '');

    // Giới hạn số chữ số (ví dụ 12 chữ số ~ 999 tỷ)
    if (text.length > 12) {
      text = text.substring(0, 12);
    }

    // Format lại với dấu phẩy
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      int remaining = text.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write(',');
      }
    }

    String formatted = buffer.toString();

    // Giữ vị trí con trỏ
    int selectionIndex = newValue.selection.end;
    int oldLength = newValue.text.length;
    int newLength = formatted.length;

    // Điều chỉnh vị trí con trỏ sau khi thêm dấu phẩy
    if (selectionIndex == oldLength) {
      selectionIndex = newLength;
    } else {
      int diff = newLength - oldLength;
      selectionIndex += diff;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}