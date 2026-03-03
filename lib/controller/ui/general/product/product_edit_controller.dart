// controller/ui/general/product/product_edit_controller.dart
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/helper/services/seller_services.dart';

class PriceItem {
  TextEditingController nameController;
  TextEditingController priceController;
  bool isDefault;
  int? id; // ID của price khi edit (có thể null nếu là price mới)

  PriceItem({
    required this.nameController,
    required this.priceController,
    this.isDefault = false,
    this.id,
  });

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }
}

class ProductEditController extends GetxController {
  final formKey = GlobalKey<FormState>();
  int selectedVatRate = 0;

  // Basic info
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // Product data
  late int productId;
  ProductModel? product;

  // Image
  List<PlatformFile> files = [];
  String? currentImageUrl;
  String? uploadedImageUrl;
  bool isUploading = false;

  // Categories
  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;

  // Ingredients
  List<IngredientModel> ingredientOptions = [];
  IngredientModel? selectedIngredient;

  // Prices
  List<PriceItem> prices = [];

  // UI States
  bool isLoading = false;
  bool isLoadingData = false;
  bool isSaving = false;

  String? get activeImageUrl => uploadedImageUrl ?? currentImageUrl;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ProductModel) {
      product = args;
      productId = args.id;
    } else if (args is int) {
      productId = args;
      _fetchProduct();
    }
    _loadInitialData(); // Load data trước
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    for (var price in prices) {
      price.dispose();
    }
    super.onClose();
  }

  // ── Load dữ liệu ban đầu ─────────────────────────────────────────
  Future<void> _loadInitialData() async {
    isLoadingData = true;
    update();

    try {
      // Load categories
      final catResult = await SellerService.getCategories();
      if (catResult.isSuccess) {
        categories = catResult.data ?? [];
        print('📋 Loaded ${categories.length} categories');
      }

      // Load ingredients
      final ingResult = await SellerService.getIngredients(page: 0, size: 100);
      if (ingResult.isSuccess) {
        ingredientOptions = ingResult.data ?? [];
        print('📋 Loaded ${ingredientOptions.length} ingredients');
        print('📋 Ingredient IDs: ${ingredientOptions.map((i) => '${i.id}:${i.name}').join(', ')}');
      }

      // SAU KHI LOAD XONG, mới populate data
      if (product != null) {
        _populateData();
      }
    } catch (e) {
      print('💥 Error loading data: $e');
    } finally {
      isLoadingData = false;
      update();
    }
  }

// Sửa _fetchProduct để populate sau khi load xong
  Future<void> _fetchProduct() async {
    isLoading = true;
    update();

    final result = await SellerService.getProductById(productId);
    if (result.isSuccess && result.data != null) {
      product = result.data;
      // Không gọi _populateData() ngay, đợi _loadInitialData xong
    } else {
      Get.snackbar(
        'Lỗi',
        result.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    isLoading = false;
    update();
  }


  // ── Populate data từ product hiện tại ────────────────────────────
  void _populateData() {
    if (product == null) return;

    nameController.text = product!.name;
    descriptionController.text = product!.description ?? '';
    currentImageUrl = product!.imageUrl;

    // Populate category (giữ nguyên logic cũ của bạn)
    selectedCategory = null;
    if (product!.categoryId != null) {
      selectedCategory = categories.firstWhereOrNull(
            (c) => c.id == product!.categoryId,
      );
    }
    if (selectedCategory == null && product!.categoryName != null) {
      selectedCategory = categories.firstWhereOrNull(
            (c) => c.name.trim().toLowerCase() == product!.categoryName!.trim().toLowerCase(),
      );
    }

    // Populate prices (giữ nguyên)
    if (product!.prices.isNotEmpty) {
      for (var price in product!.prices) {
        prices.add(PriceItem(
          id: price.id,
          nameController: TextEditingController(text: price.priceName),
          priceController: TextEditingController(
            text: price.price % 1 == 0 ? price.price.toStringAsFixed(0) : price.price.toString(),
          ),
          isDefault: price.isDefault,
        ));
      }
    } else {
      _addDefaultPrice();
    }

    // Populate ingredient (giữ nguyên)
    if (product!.variants.isNotEmpty) {
      final firstVariant = product!.variants.first;
      if (firstVariant.ingredients.isNotEmpty) {
        final ing = firstVariant.ingredients.first;
        selectedIngredient = ingredientOptions.firstWhereOrNull(
              (i) => i.id == ing.ingredientId,
        );
      }
    }

    // Populate VAT rate hiện tại
    selectedVatRate = product!.vatRate;  // ← THÊM DÒNG NÀY

    update();
  }

  void _addDefaultPrice() {
    if (prices.isEmpty) {
      prices.add(PriceItem(
        nameController: TextEditingController(text: 'Mặc định'),
        priceController: TextEditingController(),
        isDefault: true,
      ));
    }
  }

  // ── Image handling ───────────────────────────────────────────────
  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      files = result.files;
      update();
      await _uploadImage(result.files.first);
    }
  }

  Future<void> _uploadImage(PlatformFile file) async {
    if (file.path == null) return;
    isUploading = true;
    update();

    final result = await SellerService.uploadProductImage(file.path!);
    if (result.isSuccess && result.data != null) {
      uploadedImageUrl = result.data;
    } else {
      Get.snackbar(
        'Lỗi upload',
        result.message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    isUploading = false;
    update();
  }

  void clearUploadedImage() {
    uploadedImageUrl = null;
    files.clear();
    update();
  }

  // ── Price handling ───────────────────────────────────────────────
  void addPrice() {
    // Check if there's already a default price
    final hasDefault = prices.any((p) => p.isDefault);

    prices.add(PriceItem(
      nameController: TextEditingController(),
      priceController: TextEditingController(),
      isDefault: !hasDefault && prices.isEmpty,
    ));
    update();
  }

  // ── Validation ───────────────────────────────────────────────────
  bool _validatePrices() {
    for (int i = 0; i < prices.length; i++) {
      final price = prices[i];

      if (price.nameController.text.trim().isEmpty) {
        Get.snackbar(
          'Lỗi',
          'Vui lòng nhập tên cho giá thứ ${i + 1}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final priceValue = double.tryParse(price.priceController.text);
      if (priceValue == null || priceValue <= 0) {
        Get.snackbar(
          'Lỗi',
          'Giá thứ ${i + 1} không hợp lệ',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    }
    return true;
  }

  Future<bool> setDefaultPrice(int index) async {
    final price = prices[index];

    if (price.id == null) {
      Get.snackbar(
        'Lỗi',
        'Không thể set default cho giá chưa được lưu',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    try {
      isSaving = true;
      update();

      final result = await SellerService.setDefaultPrice(
        productId: productId,
        priceId: price.id!,    );

      if (result.isSuccess && result.data != null) {
        // Cập nhật lại product với dữ liệu mới
        product = result.data;

        // Cập nhật lại danh sách prices trong controller
        _updatePricesFromProduct();

        Get.snackbar(
          'Thành công',
          'Đã set giá mặc định',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Lỗi',
          result.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể set giá mặc định: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

  Future<bool> removePrice(int index) async {
    final price = prices[index];

    // Kiểm tra nếu là price default
    if (price.isDefault) {
      Get.snackbar(
        'Không thể xóa',
        'Vui lòng chọn giá mặc định khác trước khi xóa giá này',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Kiểm tra nếu chỉ còn 1 price
    if (prices.length <= 1) {
      Get.snackbar(
        'Không thể xóa',
        'Sản phẩm phải có ít nhất một mức giá',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    // Nếu là price mới (chưa có ID), chỉ cần xóa khỏi local list
    if (price.id == null) {
      prices.removeAt(index);
      update();
      Get.snackbar(
        'Thành công',
        'Đã xóa giá tạm thời',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    }

    // Xác nhận trước khi xóa
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa giá "${price.nameController.text}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    try {
      isSaving = true;
      update();

      final result = await SellerService.removePrice(
        productId: productId,
        priceId: price.id!,
      );

      if (result.isSuccess && result.data != null) {
        // Cập nhật lại product với dữ liệu mới
        product = result.data;

        // Cập nhật lại danh sách prices trong controller
        _updatePricesFromProduct();

        Get.snackbar(
          'Thành công',
          'Đã xóa giá',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Lỗi',
          result.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể xóa giá: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }

// Helper method để cập nhật prices từ product mới
  void _updatePricesFromProduct() {
    if (product == null) return;

    // Clear controllers cũ
    for (var price in prices) {
      price.dispose();
    }
    prices.clear();

    // Tạo mới từ product
    for (var price in product!.prices) {
      prices.add(PriceItem(
        id: price.id,
        nameController: TextEditingController(text: price.priceName),
        priceController: TextEditingController(text: price.price.toString()),
        isDefault: price.isDefault,
      ));
    }

    update();
  }


  // ── Save product ─────────────────────────────────────────────────
  Future<bool> save() async {
    if (!formKey.currentState!.validate()) return false;
    if (selectedIngredient == null) {
      Get.snackbar('Lỗi', 'Vui lòng chọn nguyên liệu cho sản phẩm', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    if (!_validatePrices()) return false;

    isSaving = true;
    update();

    try {
      // Prepare prices data
      final pricesData = prices.map((p) {
        return {
          'priceName': p.nameController.text.trim(),
          'price': double.parse(p.priceController.text),
          'isDefault': p.isDefault,
          if (p.id != null) 'id': p.id,
        };
      }).toList();

      // Prepare variants data
      List<Map<String, dynamic>> variantsData = [];
      if (product!.variants.isNotEmpty) {
        variantsData = product!.variants.map((v) {
          return {
            'id': v.id,
            'variantName': v.variantName,
            'isDefault': v.isDefault,
            'ingredients': [
              {'ingredientId': selectedIngredient!.id, 'quantity': 1.0}
            ],
          };
        }).toList();
      } else {
        variantsData = [
          {
            'variantName': 'Mặc định',
            'isDefault': true,
            'ingredients': [
              {'ingredientId': selectedIngredient!.id, 'quantity': 1.0}
            ],
          }
        ];
      }

      print('DEBUG: Sending update with vatRate = $selectedVatRate%');  // ← Thêm log để kiểm tra

      final result = await SellerService.updateProduct(
        id: productId,
        name: nameController.text.trim(),
        description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
        unit: 'kg',
        imageUrl: activeImageUrl,
        categoryId: selectedCategory?.id,
        categoryName: selectedCategory?.name,
        prices: pricesData,
        variants: variantsData,
        vatRate: selectedVatRate,  // ← ĐÃ CÓ, nhưng đảm bảo gửi
      );

      if (result.isSuccess) {
        Get.snackbar('Thành công', 'Đã cập nhật sản phẩm', backgroundColor: Colors.green, colorText: Colors.white);
        return true;
      } else {
        Get.snackbar('Lỗi', result.message ?? 'Không thể cập nhật', backgroundColor: Colors.red, colorText: Colors.white);
        return false;
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật sản phẩm: $e', backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    } finally {
      isSaving = false;
      update();
    }
  }
}