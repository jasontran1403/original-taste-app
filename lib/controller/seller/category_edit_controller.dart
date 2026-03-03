import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/services/seller_services.dart';

class CategoryEditController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  // Nhận từ arguments khi navigate
  late int categoryId;
  CategoryModel? category;

  List<PlatformFile> files = [];
  String? currentImageUrl;   // ảnh hiện tại (từ server)
  String? uploadedImageUrl;  // ảnh mới upload
  bool isUploading = false;
  bool isSaving = false;
  bool isLoading = false;

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

    final result = await SellerService.uploadCategoryImage(file.path!);
    if (result.isSuccess && result.data != null) {
      uploadedImageUrl = result.data;
    } else {
      Get.snackbar('Lỗi upload', result.message,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
    isUploading = false;
    update();
  }

  // Ảnh hiện dùng (mới upload ưu tiên, fallback về ảnh cũ)
  String? get activeImageUrl => uploadedImageUrl ?? currentImageUrl;

  Future<bool> save() async {
    if (!formKey.currentState!.validate()) return false;
    if (isUploading) {
      Get.snackbar('Chờ', 'Đang upload ảnh...',
          backgroundColor: Colors.orange, colorText: Colors.white);
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
      Get.snackbar('Thành công', 'Đã cập nhật danh mục',
          backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } else {
      Get.snackbar('Lỗi', result.message,
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }

  IconData getFileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext)) return Icons.image;
    return Icons.insert_drive_file;
  }
}