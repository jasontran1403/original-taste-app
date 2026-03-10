// controller/seller/category_edit_controller.dart
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/services/seller_services.dart';

class CategoryEditController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  late int categoryId;
  CategoryModel? category;

  List<PlatformFile> files = [];
  Uint8List? previewBytes;       // ← preview ảnh mới chọn (như create)
  String? currentImageUrl;
  String? uploadedImageUrl;
  bool isUploading = false;
  bool isSaving = false;
  bool isLoading = false;

  // ── Upload error — block nút Lưu ────────────────────────────────
  String? uploadError;
  bool get hasUploadError => uploadError != null;

  String? get activeImageUrl => uploadedImageUrl ?? currentImageUrl;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is CategoryModel) {
      category = args;
      categoryId = args.id;
      nameController.text = args.name;
      currentImageUrl = args.imageUrl;
    } else if (args is int) {
      categoryId = args;
      _fetchCategory();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> _fetchCategory() async {
    print("Loaded category");
    isLoading = true;
    update();
    final result = await SellerService.getCategoryById(categoryId);
    if (result.isSuccess && result.data != null) {
      category = result.data;
      nameController.text = category!.name;
      currentImageUrl = category!.imageUrl;
    }
    isLoading = false;
    update();
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,           // ← cần để lấy bytes cho preview
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      files = result.files;
      previewBytes = file.bytes; // ← set preview ngay lập tức
      uploadedImageUrl = null;
      uploadError = null;
      update();
      await _uploadImage(file);
    }
  }

  Future<void> _uploadImage(PlatformFile file) async {
    if (file.path == null) return;
    isUploading = true;
    uploadError = null;
    update();

    final result = await SellerService.uploadCategoryImage(file.path!);

    isUploading = false;

    if (result.isSuccess && result.data != null) {
      uploadedImageUrl = result.data;
      uploadError = null;
    } else {
      uploadedImageUrl = null;
      uploadError = result.message?.isNotEmpty == true
          ? result.message!
          : 'Upload thất bại. Vui lòng thử lại.';
    }

    update();
  }

  // Xóa ảnh mới chọn → quay lại ảnh hiện tại
  void clearNewImage() {
    files = [];
    previewBytes = null;
    uploadedImageUrl = null;
    uploadError = null;
    update();
  }

  Future<bool> save() async {
    if (!formKey.currentState!.validate()) return false;
    if (isUploading) {
      Get.snackbar('Chờ', 'Đang upload ảnh...',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          forwardAnimationCurve: Curves.easeOutBack);
      return false;
    }

    isSaving = true;
    update();

    final result = await SellerService.updateCategory(
      id: categoryId,
      name: nameController.text.trim(),
      imageUrl: activeImageUrl,
    );

    isSaving = false;
    update();

    if (result.isSuccess) {
      Get.snackbar(
        'Thành công', 'Đã cập nhật danh mục',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeIn,
      );
      return true;
    } else {
      Get.snackbar(
        'Lỗi', result.message ?? 'Không thể cập nhật danh mục',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeIn,
      );
      return false;
    }
  }

  IconData getFileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) return Icons.image;
    return Icons.insert_drive_file;
  }
}