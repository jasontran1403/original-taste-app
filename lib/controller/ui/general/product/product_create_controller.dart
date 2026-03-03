import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/helper/services/seller_services.dart';

// ── Giá item trong form ───────────────────────────────────────────
class PriceFormItem {
  final TextEditingController nameController;
  final TextEditingController priceController;
  bool isDefault;

  PriceFormItem({
    String name = '',
    String price = '',
    this.isDefault = false,
  })  : nameController = TextEditingController(text: name),
        priceController = TextEditingController(text: price);

  void dispose() {
    nameController.dispose();
    priceController.dispose();
  }

  bool get isValid =>
      nameController.text.trim().isNotEmpty &&
          priceController.text.trim().isNotEmpty &&
          (double.tryParse(priceController.text.trim()) ?? -1) >= 0;
}

class ProductCreateController extends GetxController {
  final formKey = GlobalKey<FormState>();

  int selectedVatRate = 0;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  List<CategoryModel> categories = [];
  CategoryModel? selectedCategory;

  List<PlatformFile> files = [];
  String? uploadedImageUrl;
  bool isUploading = false;

  // Ingredient bắt buộc chọn 1.
  // quantity = 1.0 cố định: bán 1 đơn vị sản phẩm thì trừ 1 kg nguyên liệu
  List<IngredientModel> ingredientOptions = [];
  IngredientModel? selectedIngredient;

  List<PriceFormItem> prices = [];

  bool isSaving = false;
  bool isLoadingData = false;

  @override
  void onInit() {
    super.onInit();
    prices.add(PriceFormItem(name: 'Mặc định', isDefault: true));
    _loadInitialData();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    for (final p in prices) p.dispose();
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

  void clearImage() {
    uploadedImageUrl = null;
    files = [];
    update();
  }

  void addPrice() {
    prices.add(PriceFormItem());
    update();
  }

  void removePrice(int index) {
    if (prices.length <= 1) {
      Get.snackbar('Lưu ý', 'Sản phẩm phải có ít nhất 1 mức giá',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    final wasDefault = prices[index].isDefault;
    prices[index].dispose();
    prices.removeAt(index);
    if (wasDefault && prices.isNotEmpty) prices[0].isDefault = true;
    update();
  }

  void setDefaultPrice(int index) {
    for (int i = 0; i < prices.length; i++) {
      prices[i].isDefault = (i == index);
    }
    update();
  }

  String? _validate() {
    if (nameController.text.trim().isEmpty) return 'Vui lòng nhập tên sản phẩm';
    if (selectedIngredient == null) return 'Vui lòng chọn nguyên liệu';
    if (prices.isEmpty) return 'Vui lòng thêm ít nhất 1 mức giá';
    for (int i = 0; i < prices.length; i++) {
      if (!prices[i].isValid)
        return 'Mức giá ${i + 1}: vui lòng nhập đầy đủ tên và giá';
    }
    if (!prices.any((p) => p.isDefault))
      return 'Vui lòng chọn 1 mức giá mặc định';
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

    try {
      final result = await SellerService.createProduct(
        name: nameController.text.trim(),
        description: descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        unit: 'kg',
        imageUrl: uploadedImageUrl,
        categoryId: selectedCategory?.id,
        categoryName: selectedCategory?.name,
        prices: prices
            .map((p) => {
          'priceName': p.nameController.text.trim(),
          'price': double.parse(p.priceController.text.trim()),
          'isDefault': p.isDefault,
        })
            .toList(),
        ingredients: [
          {'ingredientId': selectedIngredient!.id, 'quantity': 1.0}
        ],
        vatRate: selectedVatRate,  // ← THÊM DÒNG NÀY (gửi lên backend)
      );

      isSaving = false;
      update();

      if (result.isSuccess) {
        Get.snackbar('Thành công', 'Đã tạo sản phẩm "${nameController.text}"',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.back(result: true);
      } else {
        Get.snackbar('Lỗi', result.message ?? 'Không thể tạo sản phẩm',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      isSaving = false;
      update();
      Get.snackbar('Lỗi', 'Không thể tạo sản phẩm: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  IconData getFileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) return Icons.image;
    return Icons.insert_drive_file;
  }
}