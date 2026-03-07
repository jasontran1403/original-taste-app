import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/services/seller_services.dart';

class CategoryCreateController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  List<PlatformFile> files = [];
  Uint8List? previewBytes;
  String? uploadedImageUrl;
  bool isUploading = false;
  bool isSaving = false;

  // Trigger để screen lắng nghe → hiện badge rồi fadeout
  final uploadDone = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      files = result.files;
      previewBytes = file.bytes;
      uploadedImageUrl = null;
      update();
      await _uploadImage(file);
    }
  }

  Future<void> _uploadImage(PlatformFile file) async {
    if (file.path == null) return;
    isUploading = true;
    update();

    final result = await SellerService.uploadCategoryImage(file.path!);
    if (result.isSuccess && result.data != null) {
      uploadedImageUrl = result.data;
      uploadDone.toggle(); // ← trigger badge
    } else {
      Get.snackbar('Lỗi upload', result.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          forwardAnimationCurve: Curves.easeOutBack);
    }
    isUploading = false;
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

    final name = nameController.text.trim();
    final result = await SellerService.createCategory(
      name: name,
      imageUrl: uploadedImageUrl,
    );

    isSaving = false;
    update();

    if (result.isSuccess) {
      nameController.clear();
      files = [];
      previewBytes = null;
      uploadedImageUrl = null;
      update();

      Get.snackbar('Thành công', 'Đã tạo danh mục "$name"',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          forwardAnimationCurve: Curves.easeOutBack,
          reverseAnimationCurve: Curves.easeIn);
      return true;
    } else {
      Get.snackbar('Lỗi', result.message ?? 'Không thể tạo danh mục',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          forwardAnimationCurve: Curves.easeOutBack,
          reverseAnimationCurve: Curves.easeIn);
      return false;
    }
  }
}