import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:original_taste/helper/services/seller_services.dart';

class InventoryHistoryController extends GetxController {
  var logs = <InventoryLogModel>[].obs;
  var isLoading = false.obs;
  var hasMore = true.obs;
  var currentPage = 0.obs;
  final scrollController = ScrollController();

  int? ingredientId;
  String ingredientName = '';

  @override
  void onInit() {
    super.onInit();
    // Nhận argument từ IngredientListScreen
    final args = Get.arguments;
    if (args is IngredientModel) {
      ingredientId = args.id;
      ingredientName = args.name;
    }
    fetchLogs();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300 &&
        !isLoading.value &&
        hasMore.value) {
      fetchLogs(loadMore: true);
    }
  }

  Future<void> fetchLogs({bool loadMore = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    update();

    if (!loadMore) {
      currentPage.value = 0;
      logs.clear();
    }

    final result = await SellerService.getInventoryLogs(
      page: currentPage.value,
      size: 20,
      ingredientId: ingredientId, // ← filter theo ingredient
    );

    if (result.isSuccess && result.data != null) {
      final paginated = result.data!;
      logs.addAll(paginated.content);
      currentPage.value++;
      hasMore.value = paginated.hasMore;
    } else {
      Get.snackbar('Lỗi', result.message ?? 'Không tải được lịch sử kho',
          snackPosition: SnackPosition.BOTTOM);
    }

    isLoading.value = false;
    update();
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}