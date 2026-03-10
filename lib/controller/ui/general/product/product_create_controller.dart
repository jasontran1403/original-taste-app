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
          (double.tryParse(priceController.text) ?? -1) >= 0;

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

class ProductCreateController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final nameController        = TextEditingController();
  final descriptionController = TextEditingController();
  final basePriceController   = TextEditingController();

  List<CategoryModel>  categories         = [];
  CategoryModel?       selectedCategory;

  List<PlatformFile>   files              = [];
  String?              uploadedImageUrl;
  bool                 isUploading        = false;

  // ── Upload error — hiển thị dưới ảnh, block nút Lưu ─────────────
  String?              uploadError;

  List<IngredientModel> ingredientOptions = [];
  IngredientModel?      selectedIngredient;

  // Khung giá sỉ
  List<TierFormItem> tiers = [];

  // VAT
  int selectedVatRate = 0;
  final List<int> vatRateOptions = [0, 5, 8, 10];

  bool isSaving        = false;
  bool isLoadingData   = false;

  // Có block nút Lưu không?
  bool get hasUploadError => uploadError != null;

  @override
  void onInit() {
    super.onInit();
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

  Future<void> _loadInitialData() async {
    isLoadingData = true;
    update();
    final catResult = await SellerService.getCategories();
    if (catResult.isSuccess && catResult.data != null) {
      categories = catResult.data!;
    }
    final ingResult = await SellerService.getIngredients();
    if (ingResult.isSuccess && ingResult.data != null) {
      ingredientOptions = ingResult.data!;
    }
    isLoadingData = false;
    update();
  }

  // ── Image ────────────────────────────────────────────────────────
  Future<void> pickFiles() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
    if (result != null && result.files.isNotEmpty) {
      files = result.files;
      // Reset lỗi cũ khi user chọn file mới
      uploadError = null;
      uploadedImageUrl = null;
      update();
      await _uploadImage(result.files.first);
    }
  }

  Future<void> _uploadImage(PlatformFile file) async {
    if (file.path == null) return;
    isUploading = true;
    uploadError = null;
    update();

    final result = await SellerService.uploadProductImage(file.path!);

    isUploading = false;

    if (result.isSuccess && result.data != null) {
      uploadedImageUrl = result.data;
      uploadError = null;
    } else {
      // Lấy message lỗi từ server (vd: "Invalid image format. Allowed: [jpg, jpeg, ...]")
      uploadedImageUrl = null;
      uploadError = result.message?.isNotEmpty == true
          ? result.message!
          : 'Upload thất bại. Vui lòng thử lại.';
    }

    update();
  }

  void clearImage() {
    uploadedImageUrl = null;
    uploadError = null;
    files = [];
    update();
  }

  // ── Tiers ────────────────────────────────────────────────────────
  void addTier() {
    String autoMin = '0';
    if (tiers.isNotEmpty) {
      final prevMax = tiers.last.maxQtyController.text.trim();
      autoMin = prevMax.isNotEmpty ? prevMax : '';
    }
    tiers.add(TierFormItem(
      name: 'Khung ${tiers.length + 1}',
      minQty: autoMin,
    ));
    update();
  }

  void removeTier(int index) {
    tiers[index].dispose();
    tiers.removeAt(index);
    update();
  }

  // ── Validate & Save ──────────────────────────────────────────────
  String? _validate() {
    if (nameController.text.trim().isEmpty) return 'Vui lòng nhập tên sản phẩm';
    if (selectedIngredient == null) return 'Vui lòng chọn nguyên liệu';
    final bp = double.tryParse(basePriceController.text.trim());
    if (bp == null || bp < 0) return 'Vui lòng nhập giá gốc hợp lệ';
    for (int i = 0; i < tiers.length; i++) {
      if (!tiers[i].isValid)
        return 'Khung giá ${i + 1}: vui lòng nhập đầy đủ tên và giá';
    }
    return null;
  }

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

    final result = await SellerService.createProduct(
      name:         nameController.text.trim(),
      description:  descriptionController.text.trim().isEmpty
          ? null
          : descriptionController.text.trim(),
      unit:         'kg',
      imageUrl:     uploadedImageUrl,
      categoryId:   selectedCategory?.id,
      categoryName: selectedCategory?.name,
      basePrice:    double.parse(basePriceController.text.trim()),
      vatRate:      selectedVatRate,
      tiers:        List.generate(tiers.length, (i) => tiers[i].toJson(i)),
      ingredients:  [
        {'ingredientId': selectedIngredient!.id, 'quantity': 1.0}
      ],
    );

    isSaving = false;
    update();

    if (result.isSuccess) {
      Get.snackbar('Thành công', 'Đã tạo sản phẩm "${nameController.text}"',
          backgroundColor: Colors.green, colorText: Colors.white);
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.back(result: true);
    } else {
      Get.snackbar('Lỗi', result.message ?? 'Không thể tạo sản phẩm',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}