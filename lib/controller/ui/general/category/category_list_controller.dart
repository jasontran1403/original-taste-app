import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../helper/services/seller_services.dart';

class CategoryListController extends GetxController {
  // ── State ────────────────────────────────────────────────────────
  bool isLoading = false;
  String? errorMessage;
  List<CategoryModel> categoryList = [];
  List<bool> selectedCheckboxes = [];
  bool isAllSelected = false;
  String selectedOption = 'Action';

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // ── Load data ────────────────────────────────────────────────────
  Future<void> fetchCategories() async {
    print("Loaded");
    isLoading = true;
    errorMessage = null;
    update();

    final result = await SellerService.getCategories();

    if (result.isSuccess && result.data != null) {
      categoryList = result.data!;
      selectedCheckboxes = List.filled(categoryList.length, false);
      isAllSelected = false;
    } else {
      errorMessage = result.message;
    }
    isLoading = false;
    update();
  }

  // ── Delete ───────────────────────────────────────────────────────
  Future<void> deleteCategory(int id, String name) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xóa danh mục'),
        content: Text('Bạn có chắc muốn xóa danh mục "$name"?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isLoading = true;
    update();

    final result = await SellerService.deleteCategory(id);
    if (result.isSuccess) {
      Get.snackbar('Thành công', 'Đã xóa danh mục "$name"',
          backgroundColor: Colors.green, colorText: Colors.white);
      await fetchCategories();
    } else {
      Get.snackbar('Lỗi', result.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    isLoading = false;
    update();
  }

  // ── Checkbox ─────────────────────────────────────────────────────
  void toggleSelectAll(bool? value) {
    isAllSelected = value ?? false;
    selectedCheckboxes = List.filled(categoryList.length, isAllSelected);
    update();
  }

  void toggleCheckbox(int index, bool? value) {
    selectedCheckboxes[index] = value ?? false;
    isAllSelected = selectedCheckboxes.every((v) => v);
    update();
  }

  void onSelectedOption(String value) {
    selectedOption = value;
    update();
  }
}