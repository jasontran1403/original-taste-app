import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/helper/services/seller_services.dart';

// ── Model cho mỗi dòng tier form ──────────────────────────────────
class TierFormItem {
  final TextEditingController nameController;
  final TextEditingController minQtyController;
  final TextEditingController maxQtyController;
  final TextEditingController priceController;
  int sortOrder;

  TierFormItem({
    String name = '',
    String minQty = '0',
    String maxQty = '',
    String price = '',
    this.sortOrder = 0,
  })  : nameController = TextEditingController(text: name),
        minQtyController = TextEditingController(text: minQty),
        maxQtyController = TextEditingController(text: maxQty),
        priceController = TextEditingController(text: price);

  bool get isValid =>
      nameController.text.isNotEmpty &&
          priceController.text.isNotEmpty &&
          double.tryParse(priceController.text) != null;

  void dispose() {
    nameController.dispose();
    minQtyController.dispose();
    maxQtyController.dispose();
    priceController.dispose();
  }

  Map<String, dynamic> toJson(int idx) => {
    'tierName': nameController.text.trim(),
    'minQuantity': double.tryParse(minQtyController.text.trim()) ?? 0.0,
    'maxQuantity': maxQtyController.text.trim().isEmpty
        ? null
        : double.tryParse(maxQtyController.text.trim()),
    'price': double.tryParse(priceController.text.trim()) ?? 0.0,
    'sortOrder': idx,
  };
}

class ProductEditController extends GetxController {
  final formKey = GlobalKey<FormState>();

  late ProductModel product;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final basePriceController = TextEditingController();

  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;

  List<PlatformFile> files = [];
  String? uploadedImageUrl;
  String? existingImageUrl;
  bool isUploading = false;

  List<IngredientModel> ingredientOptions = [];
  IngredientModel? selectedIngredient;

  // Thay prices -> tiers
  List<TierFormItem> tiers = [];

  // VAT: 0, 5, 8, 10
  int selectedVatRate = 0;
  final List<int> vatRateOptions = [0, 5, 8, 10];

  bool isSaving = false;
  bool isLoadingData = false;

  String? get activeImageUrl => uploadedImageUrl ?? existingImageUrl;

  @override
  void onInit() {
    super.onInit();
    product = Get.arguments as ProductModel;
    _populateFields();
    _loadInitialData();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    basePriceController.dispose();
    for (final t in tiers) t.dispose();
    super.onClose();
  }

  void _populateFields() {
    nameController.text = product.name;
    descriptionController.text = product.description ?? '';
    existingImageUrl = product.imageUrl;
    basePriceController.text =
    product.basePrice > 0 ? product.basePrice.toStringAsFixed(0) : '';
    selectedVatRate = product.vatRate;

    if (product.priceTiers.isNotEmpty) {
      for (final t in product.priceTiers) {
        tiers.add(TierFormItem(
          name: t.tierName,
          minQty: _fmtQ(t.minQuantity),
          maxQty: t.maxQuantity == null ? '' : _fmtQ(t.maxQuantity!),
          price: t.price.toStringAsFixed(0),
          sortOrder: t.sortOrder,
        ));
      }
    }
  }

  String _fmtQ(double q) =>
      q == q.truncateToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);

  Future<void> _loadInitialData() async {
    isLoadingData = true;
    update();

    final catResult = await SellerService.getCategories();
    if (catResult.isSuccess && catResult.data != null) {
      categories = catResult.data!;
      if (product.categoryId != null) {
        selectedCategory =
            categories.where((c) => c.id == product.categoryId).firstOrNull;
      }
    }

    final ingResult = await SellerService.getIngredients();
    if (ingResult.isSuccess && ingResult.data != null) {
      ingredientOptions = ingResult.data!;
      if (product.variants.isNotEmpty &&
          product.variants.first.ingredients.isNotEmpty) {
        final ingId = product.variants.first.ingredients.first.ingredientId;
        selectedIngredient =
            ingredientOptions.where((i) => i.id == ingId).firstOrNull;
      }
    }

    isLoadingData = false;
    update();
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
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
      Get.snackbar('Lỗi upload', result.message ?? 'Không thể upload',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    isUploading = false;
    update();
  }

  void clearUploadedImage() {
    uploadedImageUrl = null;
    files = [];
    update();
  }

  // ── Tier ops ─────────────────────────────────────────────────────
  void addTier() {
    // Auto-fill minQty = maxQty của khung trước
    String autoMin = '0';
    if (tiers.isNotEmpty) {
      final prevMax = tiers.last.maxQtyController.text.trim();
      autoMin = prevMax.isNotEmpty ? prevMax : '';
    }
    tiers.add(TierFormItem(
      name: 'Khung ${tiers.length + 1}',
      minQty: autoMin,
      sortOrder: tiers.length,
    ));
    update();
  }

  void removeTier(int index) {
    tiers[index].dispose();
    tiers.removeAt(index);
    for (int i = 0; i < tiers.length; i++) tiers[i].sortOrder = i;
    update();
  }

  void setVatRate(int rate) {
    selectedVatRate = rate;
    update();
  }

  // ── Validation ────────────────────────────────────────────────────
  String? _validate() {
    if (nameController.text.trim().isEmpty) return 'Vui lòng nhập tên sản phẩm';
    if (selectedIngredient == null) return 'Vui lòng chọn nguyên liệu';
    final bp = double.tryParse(basePriceController.text.trim());
    if (bp == null || bp < 0) return 'Giá gốc không hợp lệ';
    for (int i = 0; i < tiers.length; i++) {
      if (!tiers[i].isValid)
        return 'Khung ${i + 1}: vui lòng nhập đầy đủ tên và giá';
    }
    return null;
  }

  // ── Save ──────────────────────────────────────────────────────────
  Future<void> save() async {
    final err = _validate();
    if (err != null) {
      Get.snackbar('Thiếu thông tin', err,
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (isUploading) {
      Get.snackbar('Chờ', 'Đang upload ảnh...',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isSaving = true;
    update();

    final result = await SellerService.updateProduct(
      id:           product.id,
      name:         nameController.text.trim(),
      description:  descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      unit:         'kg',
      imageUrl:     activeImageUrl,
      categoryId:   selectedCategory?.id,
      categoryName: selectedCategory?.name,   // ← gửi tên để backend dùng
      basePrice:    double.parse(basePriceController.text.trim()),
      vatRate:      selectedVatRate,
      tiers:        tiers.asMap().entries.map((e) => e.value.toJson(e.key)).toList(),
      ingredients:  [
        {'ingredientId': selectedIngredient!.id, 'quantity': 1.0}
      ],
    );

    isSaving = false;
    update();

    if (result.isSuccess) {
      Get.snackbar(
          'Thành công', 'Đã cập nhật sản phẩm "${nameController.text}"',
          backgroundColor: Colors.green, colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.back(result: true);
    } else {
      Get.snackbar('Lỗi', result.message ?? 'Không thể cập nhật',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  IconData getFileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) return Icons.image;
    return Icons.insert_drive_file;
  }
}