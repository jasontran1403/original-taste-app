// controller/seller/ingredient_create_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/services/seller_services.dart';

class IngredientCreateController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final unitController = TextEditingController();
  final stockQuantityController = TextEditingController();

  DateTime? importDate;
  DateTime? expiryDate;

  bool isSaving = false;

  @override
  void onClose() {
    nameController.dispose();
    unitController.dispose();
    stockQuantityController.dispose();
    super.onClose();
  }

  void setImportDate(DateTime? date) {
    importDate = date;
    update();
  }

  void setExpiryDate(DateTime? date) {
    expiryDate = date;
    update();
  }

  Future<bool> save() async {
    if (!formKey.currentState!.validate()) return false;

    isSaving = true;
    update();

    final name = nameController.text.trim();

    final result = await SellerService.createIngredient(
      name: name,
      unit: unitController.text.trim(),
      stockQuantity: double.tryParse(stockQuantityController.text) ?? 0,
      importDate: importDate?.millisecondsSinceEpoch,
      expiryDate: expiryDate?.millisecondsSinceEpoch,
    );

    isSaving = false;
    update();

    if (result.isSuccess) {
      // Clear form ngay khi thành công
      nameController.clear();
      unitController.clear();
      stockQuantityController.clear();
      importDate = null;
      expiryDate = null;
      update();

      // Toast thành công
      Get.snackbar(
        'Thành công',
        'Đã tạo nguyên liệu "$name"',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeIn,
      );
      return true;
    } else {
      // Toast thất bại
      Get.snackbar(
        'Lỗi',
        result.message ?? 'Không thể tạo nguyên liệu',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeIn,
      );
      return false;
    }
  }
}