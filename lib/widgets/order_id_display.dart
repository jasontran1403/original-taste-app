// lib/widgets/order_id_display.dart
//
// Widget hiển thị Order ID theo dạng nhiều dòng:
//
// POS-20260308-0009        → dòng 1: 20260308  dòng 2: 0009
// POS-SN-20260308-0009     → dòng 1: SN        dòng 2: 20260308   dòng 3: 0009
// ORD-20260129-0000000001  → dòng 1: 20260129  dòng 2: 0000000001
//
// Quy tắc chung:
//   - Bỏ prefix đầu tiên (bất kỳ chuỗi IN HOA + dấu -)
//   - Các phần còn lại tách bằng '-', mỗi phần 1 dòng

import 'package:flutter/material.dart';

/// Parse raw order code thành danh sách dòng hiển thị.
List<String> parseOrderIdLines(String raw) {
  // Bỏ prefix đầu tiên dạng "XXX-" (1-4 ký tự in hoa/số + dấu -)
  final stripped = raw.replaceFirst(RegExp(r'^[A-Z0-9]+-'), '');
  return stripped.split('-').where((p) => p.isNotEmpty).toList();
}

/// Widget hiển thị order ID dạng nhiều dòng.
///
/// [color]      — màu chính của text
/// [fontSize]   — font size dòng đầu
/// [subSize]    — font size các dòng sau (nhỏ hơn một chút)
/// [fontWeight] — weight dòng đầu
class OrderIdDisplay extends StatelessWidget {
  final String orderCode;
  final Color color;
  final double fontSize;
  final double subSize;
  final FontWeight fontWeight;

  const OrderIdDisplay({
    super.key,
    required this.orderCode,
    required this.color,
    this.fontSize = 12,
    this.subSize = 10,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    final lines = parseOrderIdLines(orderCode);

    if (lines.isEmpty) {
      return Text(orderCode,
          style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dòng đầu: ngày hoặc store name
        Text(
          lines[0],
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        // Các dòng tiếp theo: nhỏ hơn, muted hơn
        for (int i = 1; i < lines.length; i++)
          Text(
            lines[i],
            style: TextStyle(
              fontSize: subSize,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.70),
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}