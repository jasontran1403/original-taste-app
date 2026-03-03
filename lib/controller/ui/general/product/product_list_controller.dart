import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/helper/services/seller_services.dart';

class ProductListController extends GetxController {
  // ── Pagination ────────────────────────────────────────────────────
  final List<ProductModel> products = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? errorMessage;

  int _currentPage = 0;
  static const int _pageSize = 10;

  // ── Scroll ────────────────────────────────────────────────────────
  final ScrollController scrollController = ScrollController();

  String selectedOption = 'Action';

  @override
  void onInit() {
    super.onInit();
    fetchProducts(refresh: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMore) {
        fetchProducts();
      }
    }
  }

  Future<void> fetchProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      hasMore = true;
      products.clear();
      isLoading = true;
      errorMessage = null;
      update();
    } else {
      if (isLoadingMore || !hasMore) return;
      isLoadingMore = true;
      update();
    }

    final result = await SellerService.getProducts(
      page: _currentPage,
      size: _pageSize,
    );

    if (result.isSuccess && result.data != null) {
      final newItems = result.data!;
      products.addAll(newItems);
      if (newItems.length < _pageSize) {
        hasMore = false;
      } else {
        _currentPage++;
      }
    } else {
      if (refresh) errorMessage = result.message;
    }

    isLoading = false;
    isLoadingMore = false;
    update();
  }

  Future<void> deleteProduct(int id, String name) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc muốn xóa sản phẩm "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child:
            const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await SellerService.deleteProduct(id);
    if (result.isSuccess) {
      Get.snackbar('Thành công', 'Đã xóa sản phẩm "$name"',
          backgroundColor: Colors.green, colorText: Colors.white);
      fetchProducts(refresh: true);
    } else {
      Get.snackbar('Lỗi', result.message ?? 'Không thể xóa',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void onSelectedOption(String value) {
    selectedOption = value;
    update();
  }
}