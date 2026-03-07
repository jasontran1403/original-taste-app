import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:original_taste/helper/widgets/my_text.dart';

class TestEmptyScreen extends StatelessWidget {
  const TestEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Layout(
      screenName: 'TEST EMPTY',
      child: Center(
        child: MyText.titleLarge(
          'Đây là màn hình test trống.\nKhông có chart, không có ListTile, không có InkWell.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}