// controller/ui/general/ingredient/ingredient_list_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/helper/services/seller_services.dart';

class IngredientListController extends GetxController {
  var ingredientList = <IngredientModel>[].obs;
  var isLoading = false.obs;
  RxnString errorMessage = RxnString();

  // Pagination
  var currentPage = 0.obs;
  var pageSize = 10.obs;
  var hasMoreData = true.obs;

  @override
  void onInit() {
    super.onInit();
    print('🟢 IngredientListController initialized');
    fetchIngredients();
  }

  @override
  void onClose() {
    print('🔴 IngredientListController closed');
    super.onClose();
  }

  Future<void> fetchIngredients({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 0;
        ingredientList.clear();
      }

      isLoading.value = true;
      errorMessage.value = null;
      update();

      final result = await SellerService.getIngredients(
        page: currentPage.value,
        size: pageSize.value,
      );

      if (result.isSuccess) {
        final newData = result.data ?? [];

        if (refresh) {
          ingredientList.value = newData;
        } else {
          ingredientList.addAll(newData);
        }

        // Kiểm tra còn dữ liệu không
        hasMoreData.value = newData.length == pageSize.value;
        print('✅ ingredientList updated with ${ingredientList.length} items');
      } else {
        errorMessage.value = result.message;
        print('❌ Error: ${result.message}');
      }
    } catch (e) {
      errorMessage.value = 'Lỗi kết nối: $e';
      print('💥 Exception: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> loadMore() async {
    if (!hasMoreData.value || isLoading.value) return;

    currentPage.value++;
    await fetchIngredients();
  }

  Future<bool> deleteIngredient(int id, String name) async {
    try {
      final result = await SellerService.deleteIngredient(id);
      if (result.isSuccess) {
        await fetchIngredients(refresh: true);
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
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa nguyên liệu: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}