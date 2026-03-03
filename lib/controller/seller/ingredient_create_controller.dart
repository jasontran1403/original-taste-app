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

    final result = await SellerService.createIngredient(
      name: nameController.text.trim(),
      unit: unitController.text.trim(),
      stockQuantity: double.tryParse(stockQuantityController.text) ?? 0,
      importDate: importDate?.millisecondsSinceEpoch,
      expiryDate: expiryDate?.millisecondsSinceEpoch,
    );

    isSaving = false;
    update();

    if (result.isSuccess) {
      Get.snackbar(
        'Thành công',
        'Đã tạo nguyên liệu "${nameController.text}"',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } else {
      Get.snackbar(
        'Lỗi',
        result.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}