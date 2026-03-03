// controller/seller/ingredient_edit_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/services/seller_services.dart';

class IngredientEditController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final unitController = TextEditingController();
  final stockQuantityController = TextEditingController();

  late int ingredientId;
  IngredientModel? ingredient;

  DateTime? importDate;
  DateTime? expiryDate;

  bool isSaving = false;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is IngredientModel) {
      ingredient = args;
      ingredientId = args.id;
      _populateData();
    } else if (args is int) {
      ingredientId = args;
      _fetchIngredient();
    }
  }

  void _populateData() {
    if (ingredient != null) {
      nameController.text = ingredient!.name;
      unitController.text = ingredient!.unit;
      stockQuantityController.text = ingredient!.stockQuantity.toString();

      if (ingredient!.importDate != null) {
        importDate = DateTime.fromMillisecondsSinceEpoch(ingredient!.importDate!);
      }
      if (ingredient!.expiryDate != null) {
        expiryDate = DateTime.fromMillisecondsSinceEpoch(ingredient!.expiryDate!);
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    unitController.dispose();
    stockQuantityController.dispose();
    super.onClose();
  }

  Future<void> _fetchIngredient() async {
    isLoading = true;
    update();

    final result = await SellerService.getIngredientById(ingredientId);
    if (result.isSuccess && result.data != null) {
      ingredient = result.data;
      _populateData();
    }

    isLoading = false;
    update();
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

    final result = await SellerService.updateIngredient(
      id: ingredientId,
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
        'Đã cập nhật nguyên liệu',
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