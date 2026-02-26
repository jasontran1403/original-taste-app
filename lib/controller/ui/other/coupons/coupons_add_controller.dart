import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/controller/my_controller.dart';

enum CouponStatus { active, inactive, futurePlan }

class CouponsAddController extends MyController {
  CouponStatus status = CouponStatus.active;
  DateTime? startDate;
  DateTime? endDate;

  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  final formKey = GlobalKey<FormState>();
  String? selectedCategory;
  String? selectedCountry;
  String? couponType = 'Free Shipping';

  final TextEditingController codeController = TextEditingController();
  final TextEditingController limitController = TextEditingController();
  final TextEditingController discountValueController = TextEditingController();

  final List<String> categories = [
    "Fashion",
    "Electronics",
    "Footwear",
    "Sportswear",
    "Watches",
    "Furniture",
    "Appliances",
    "Headphones",
    "Other Accessories",
  ];

  final List<String> countries = [
    "United Kingdom",
    "France",
    "Netherlands",
    "U.S.A",
    "Denmark",
    "Canada",
    "Australia",
    "India",
    "Germany",
    "Spain",
    "United Arab Emirates",
  ];

  Future<void> pickDate({required bool isStartDate}) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: isStartDate ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (isStartDate) {
        startDate = picked;
      } else {
        endDate = picked;
      }
      update();
    }
  }

  @override
  void dispose() {
    codeController.dispose();
    limitController.dispose();
    discountValueController.dispose();
    super.dispose();
  }

  void submitForm() {
    if (formKey.currentState!.validate()) {
      // Handle form submission logic here
      log("Coupon Code: ${codeController.text}");
      log("Category: $selectedCategory");
      log("Country: $selectedCountry");
      log("Limit: ${limitController.text}");
      log("Type: $couponType");
      log("Discount Value: ${discountValueController.text}");
      // Show success or do backend call
    }
  }
}
