import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:original_taste/models/import_warehouse_model.dart';

class ImportWarehouseController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  bool isLoading = false;
  bool isFiltering = false;
  bool isScanning = false;
  bool showProductInfo = false;
  String? scanErrorMessage;
  bool shouldResetScanLine = false;

  // Debounce: tránh scan trùng trong 1.2s
  bool _isProcessingScan = false;

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
    isLoading = false;
  }

  // ── QR Scanner ────────────────────────────────────────────────────

  void openQRScanner() {
    if (_isProcessingScan) return;
    isScanning = true;
    showProductInfo = false;
    scanErrorMessage = null;
    scannedProduct = null;
    quantityController.clear();
    shouldResetScanLine = true;
    update();
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

  /// Gọi khi camera detect được QR. Parse data thực tế + delay 1.2s debounce.
  /// Format QR:
  /// Sản phẩm: Hải sản tươi sống
  /// NSX: 10/12/2025
  /// HSD: 10/12/2026
  /// KL Gói: 400gr
  /// KL Mẻ: 10kg
  Future<void> onQRDetected(String rawValue) async {
    // Debounce: bỏ qua nếu đang xử lý
    if (_isProcessingScan) return;
    _isProcessingScan = true;

    // Delay 1.2s để tránh scan trùng khi camera chưa lia
    await Future.delayed(const Duration(milliseconds: 1200));

    final parsed = _parseQRData(rawValue);

    if (parsed == null) {
      scanErrorMessage = 'Định dạng QR không hợp lệ.\nVui lòng kiểm tra lại mã QR.';
      showProductInfo = false;
      scannedProduct = null;
    } else {
      scanErrorMessage = null;
      scannedProduct = parsed;
      quantityController.text = '1';
      showProductInfo = true;
    }

    update();

    // Reset debounce sau 1s thêm
    await Future.delayed(const Duration(seconds: 1));
    _isProcessingScan = false;
  }

  /// Parse QR string thành ImportProductItem
  ImportProductItem? _parseQRData(String raw) {
    try {
      final lines = raw.trim().split('\n');
      final Map<String, String> data = {};

      for (final line in lines) {
        final idx = line.indexOf(':');
        if (idx == -1) continue;
        final key = line.substring(0, idx).trim().toLowerCase()
            .replaceAll('à', 'a').replaceAll('ẩ', 'a').replaceAll('ả', 'a')
            .replaceAll('ã', 'a').replaceAll('ạ', 'a').replaceAll('ă', 'a')
            .replaceAll('ắ', 'a').replaceAll('ặ', 'a').replaceAll('ẻ', 'e')
            .replaceAll('ẽ', 'e').replaceAll('ẹ', 'e').replaceAll('ề', 'e')
            .replaceAll('ộ', 'o').replaceAll('ổ', 'o').replaceAll('ỗ', 'o')
            .replaceAll(' ', '_');
        final value = line.substring(idx + 1).trim();
        data[key] = value;
      }

      // Tìm key flexible (hỗ trợ cả có dấu lẫn không dấu)
      String? find(List<String> keys) {
        for (final k in keys) {
          final normalized = k.toLowerCase().replaceAll(' ', '_');
          if (data.containsKey(normalized)) return data[normalized];
        }
        return null;
      }

      final productName = find(['san_pham', 'sản_phẩm', 'ten', 'tên']);
      final nsxRaw = find(['nsx', 'ngay_sx', 'manufacturing_date']);
      final hsdRaw = find(['hsd', 'han_dung', 'expiry_date']);
      final packageWeight = find(['kl_goi', 'kl_gói', 'package_weight']) ?? '--';
      final batchWeight = find(['kl_me', 'kl_mẻ', 'batch_weight']) ?? '--';

      if (productName == null || nsxRaw == null || hsdRaw == null) return null;

      DateTime parseDate(String s) {
        // Hỗ trợ dd/MM/yyyy và yyyy-MM-dd
        if (s.contains('/')) {
          final parts = s.split('/');
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          return DateTime.parse(s);
        }
      }

      return ImportProductItem(
        productName: productName,
        manufacturingDate: parseDate(nsxRaw),
        expiryDate: parseDate(hsdRaw),
        packageWeight: packageWeight,
        batchWeight: batchWeight,
        quantity: 1,
      );
    } catch (e) {
      print('❌ QR parse error: $e');
      return null;
    }
  }

  void scanAgain() {
    scanErrorMessage = null;
    showProductInfo = false;
    scannedProduct = null;
    quantityController.clear();
    shouldResetScanLine = true;
    _isProcessingScan = false; // cho phép scan lại
    update();
  }

  // ── Import logic ──────────────────────────────────────────────────

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
        p.expiryDate.isAtSameMomentAs(product.expiryDate)) ?? false;

    if (isDuplicate) {
      Get.snackbar('Trùng sản phẩm', 'Sản phẩm này đã có trong phiếu nhập!',
          backgroundColor: Colors.orange[800], colorText: Colors.white);
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

    Get.snackbar('Thành công', 'Đã lưu phiếu nhập kho',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
  }

  // ── Search / Filter (giữ lại nếu dùng ở ImportWarehouseScreen) ───

  void searchByName(String query) async {
    isFiltering = true;
    update();
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty && selectedDate == null) {
      filteredList = importList.take(itemsPerPage).toList();
      currentPage = 1;
      hasMore = importList.length > itemsPerPage;
    } else {
      filteredList = importList.where((item) {
        bool matchName = query.isEmpty ||
            item.importerName.toLowerCase().contains(query.toLowerCase());
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