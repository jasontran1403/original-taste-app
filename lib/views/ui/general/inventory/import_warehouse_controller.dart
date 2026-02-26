import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:original_taste/models/import_warehouse_model.dart';

class ImportWarehouseController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  bool isLoading = true;
  bool isFiltering = false; // Thêm biến này để hiển thị skeleton khi filter
  bool isScanning = false;
  bool showProductInfo = false;
  String? scanErrorMessage;
  bool shouldResetScanLine = false;

  List<ImportWarehouseModel> importList = [];
  List<ImportWarehouseModel> filteredList = [];
  ImportWarehouseModel? currentImport;
  ImportProductItem? scannedProduct;

  int currentPage = 0;
  int itemsPerPage = 10;
  bool hasMore = true;

  DateTime? selectedDate;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await Future.delayed(const Duration(seconds: 1));
    importList = _generateFakeData();
    filteredList = importList.take(itemsPerPage).toList();
    currentPage = 1;
    hasMore = importList.length > itemsPerPage;
    isLoading = false;
    update();
  }

  List<ImportWarehouseModel> _generateFakeData() {
    final List<ImportWarehouseModel> data = [];
    final names = ['Nguyễn Văn A', 'Trần Thị B', 'Lê Văn C', 'Phạm Thị D', 'Hoàng Văn E'];
    final products = [
      'Hải sản tươi sống',
      'Thịt bò Úc',
      'Rau củ hữu cơ',
      'Trái cây nhập khẩu',
      'Sữa tươi Vinamilk',
      'Gạo ST25',
      'Cá hồi Na Uy',
      'Tôm sú',
      'Thịt heo sạch',
      'Rau xà lách',
    ];

    for (int i = 0; i < 15; i++) {
      final itemCount = (i % 3) + 1;
      final List<ImportProductItem> productItems = [];

      for (int j = 0; j < itemCount; j++) {
        productItems.add(ImportProductItem(
          productName: products[(i * itemCount + j) % products.length],
          manufacturingDate: DateTime.now().subtract(Duration(days: (i * 5) + j)),
          expiryDate: DateTime.now().add(Duration(days: 365 - (i * 10) - j)),
          packageWeight: '${(j + 1) * 500}gr',
          batchWeight: '${(j + 1) * 30}kg',
          quantity: (j + 1) * 10,
        ));
      }

      data.add(ImportWarehouseModel(
        id: 'IMP${(i + 1).toString().padLeft(4, '0')}',
        importerName: names[i % names.length],
        importTime: DateTime.now().subtract(Duration(hours: i * 6)),
        products: productItems,
        isSaved: true,
      ));
    }
    return data;
  }

  void searchByName(String query) async {
    isFiltering = true;
    update();

    await Future.delayed(const Duration(milliseconds: 300)); // Giả lập delay tìm kiếm

    if (query.isEmpty && selectedDate == null) {
      filteredList = importList.take(itemsPerPage).toList();
      currentPage = 1;
      hasMore = importList.length > itemsPerPage;
    } else {
      filteredList = importList.where((item) {
        bool matchName = query.isEmpty || item.importerName.toLowerCase().contains(query.toLowerCase());
        bool matchDate = selectedDate == null ||
            (item.importTime.year == selectedDate!.year &&
                item.importTime.month == selectedDate!.month &&
                item.importTime.day == selectedDate!.day);
        return matchName && matchDate;
      }).toList();
    }

    isFiltering = false;
    update();
  }

  void searchByDate(DateTime? date) {
    selectedDate = date;
    searchByName(searchController.text);
  }

  void openQRScanner() {
    isScanning = true;
    showProductInfo = false;
    scanErrorMessage = null;
    scannedProduct = null;
    quantityController.clear();
    shouldResetScanLine = false;
    update();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (isScanning) simulateQRScan();
    });
  }

  void closeQRScanner() {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isScanning = false;
      showProductInfo = false;
      scanErrorMessage = null;
      scannedProduct = null;
      quantityController.clear();
      shouldResetScanLine = false;
      update();
    });
  }

  Future<void> simulateQRScan() async {
    scanErrorMessage = null;
    shouldResetScanLine = true;
    update();

    await Future.delayed(const Duration(milliseconds: 2200));

    final isValid = DateTime.now().millisecond % 5 != 0;

    if (!isValid) {
      scanErrorMessage = "Định dạng QR không hợp lệ hoặc không đọc được dữ liệu.";
      update();
      return;
    }

    scannedProduct = ImportProductItem(
      productName: 'Cá hồi Na Uy fillet',
      manufacturingDate: DateTime(2025, 12, 10),
      expiryDate: DateTime(2026, 6, 15),
      packageWeight: '400gr',
      batchWeight: '10kg',
      quantity: 1,
    );

    quantityController.text = '1';
    showProductInfo = true;
    update();
  }

  void scanAgain() {
    scanErrorMessage = null;
    showProductInfo = false;
    scannedProduct = null;
    quantityController.clear();
    shouldResetScanLine = true;
    update();

    Future.delayed(const Duration(milliseconds: 400), simulateQRScan);
  }

  void updateProductQuantity(int productIndex, double change) {
    if (currentImport == null) return;
    final product = currentImport!.products[productIndex];
    final newQty = product.quantity + change;
    if (newQty > 0) {
      currentImport!.products[productIndex] = product.copyWith(quantity: newQty);
      update();
    }
  }

  void addProductToCurrentImport() {
    if (scannedProduct == null) return;

    final qtyText = quantityController.text.trim();
    final qty = double.tryParse(qtyText) ?? 1.0;
    if (qty <= 0) {
      Get.snackbar('Lỗi', 'Số lượng phải lớn hơn 0',
          backgroundColor: Colors.red[700], colorText: Colors.white);
      return;
    }

    final product = scannedProduct!;
    final isDuplicate = currentImport?.products.any((p) =>
    p.productName == product.productName &&
        p.manufacturingDate.isAtSameMomentAs(product.manufacturingDate) &&
        p.expiryDate.isAtSameMomentAs(product.expiryDate)) ??
        false;

    if (isDuplicate) {
      Get.snackbar(
        'Trùng sản phẩm',
        'Sản phẩm này đã có trong phiếu nhập hiện tại!',
        backgroundColor: Colors.orange[800],
        colorText: Colors.white,
      );
      scanAgain();
      return;
    }

    final newItem = ImportProductItem(
      productName: product.productName,
      manufacturingDate: product.manufacturingDate,
      expiryDate: product.expiryDate,
      packageWeight: product.packageWeight,
      batchWeight: product.batchWeight,
      quantity: qty,
    );

    currentImport ??= ImportWarehouseModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      importerName: 'Đang soạn',
      importTime: DateTime.now(),
      products: [],
      isSaved: false,
    );

    currentImport!.products.add(newItem);
    update();

    scannedProduct = null;
    showProductInfo = false;
    quantityController.clear();
  }

  void removeProductFromCurrent(int index) {
    if (currentImport == null) return;
    currentImport!.products.removeAt(index);
    if (currentImport!.products.isEmpty) currentImport = null;
    update();
  }

  void saveCurrentImport() {
    if (currentImport == null || currentImport!.products.isEmpty) return;

    // Clone list để đảm bảo lấy dữ liệu mới nhất
    final savedProducts = currentImport!.products.map((p) => p.copyWith()).toList();

    final saved = ImportWarehouseModel(
      id: currentImport!.id.replaceAll('temp_', 'IMP'),
      importerName: currentImport!.importerName,
      importTime: currentImport!.importTime,
      products: savedProducts,
      isSaved: true,
    );

    importList.insert(0, saved);
    filteredList.insert(0, saved);
    currentImport = null;
    update();

    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: const Text('Đã lưu phiếu nhập kho thành công'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void loadMore() {
    if (!hasMore) return;
    final start = currentPage * itemsPerPage;
    final end = (start + itemsPerPage).clamp(0, importList.length);
    if (start < importList.length) {
      filteredList.addAll(importList.sublist(start, end));
      currentPage++;
      hasMore = end < importList.length;
      update();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    quantityController.dispose();
    super.onClose();
  }
}