import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:original_taste/helper/services/seller_services.dart';

class InventoryHistoryController extends GetxController {
  var logs = <InventoryLogModel>[].obs;
  var isLoading = false.obs;
  var hasMore = true.obs;
  var currentPage = 0.obs;
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchLogs(); // load lần đầu
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Debounce: chỉ load khi gần cuối và không đang loading
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 300 &&
        !isLoading.value &&
        hasMore.value) {
      fetchLogs(loadMore: true);
    }
  }

  Future<void> fetchLogs({bool loadMore = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    update(); // rebuild UI để hiện loading

    if (!loadMore) {
      currentPage.value = 0;
      logs.clear();
    }

    print("Fetching page: ${currentPage.value}"); // debug

    final result = await SellerService.getInventoryLogs(
      page: currentPage.value,
      size: 20,
    );

    if (result.isSuccess && result.data != null) {
      final paginated = result.data!;
      logs.addAll(paginated.content);
      currentPage.value++;
      hasMore.value = paginated.hasMore;

      print("Loaded ${paginated.content.length} items, hasMore: ${hasMore.value}");
    } else {
      Get.snackbar(
        'Lỗi',
        result.message ?? 'Không tải được lịch sử kho',
        snackPosition: SnackPosition.BOTTOM,
      );
      print("API error: ${result.message}");
    }

    isLoading.value = false;
    update(); // rebuild UI sau khi load xong
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }
}