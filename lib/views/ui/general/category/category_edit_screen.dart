// views/ui/general/category/category_edit_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_list_extension.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/views/layout/layout.dart';

import '../../../../controller/seller/category_edit_controller.dart';
import '../../../../helper/services/seller_services.dart';

class CategoryEditScreen extends StatefulWidget {
  const CategoryEditScreen({super.key});

  @override
  State<CategoryEditScreen> createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen>
    with UIMixin, WidgetsBindingObserver {
  late CategoryEditController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(
      CategoryEditController(),
      tag: 'category_edit_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() => setState(() {});

  OutlineInputBorder get outlineInputBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
        color: contentTheme.secondary.withValues(alpha: 0.4)),
  );

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryEditController>(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "CHỈNH SỬA DANH MỤC",
          child: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
            key: controller.formKey,
            child: MyFlex(
              children: [
                MyFlexItem(
                  sizes: 'lg-12',
                  child: Column(
                    children: [
                      _buildImageUpload(),
                      MySpacing.height(20),
                      _buildGeneralInfo(),
                      MySpacing.height(20),
                      _buildActions(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageUpload() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(0),
            child: Row(
              children: [
                Padding(
                  padding: MySpacing.all(20),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Nút "← Quay lại" ở bên trái
                      Align(
                        alignment: Alignment.centerLeft,
                        child:
                        MyContainer.bordered(
                          onTap: () => Get.back(),
                          color: Colors.transparent,
                          borderRadiusAll: 10,
                          padding: MySpacing.xy(12, 8),
                          borderColor: contentTheme.secondary.withOpacity(0.4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back_rounded, size: 16, color: contentTheme.secondary),
                              MySpacing.width(6),
                              MyText.bodyMedium('Quay lại', color: contentTheme.secondary, fontWeight: 600),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: MyText.titleMedium(
                    'Ảnh danh mục',
                    style: TextStyle(
                      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (controller.isUploading) ...[
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: contentTheme.primary),
                  ),
                  MySpacing.width(8),
                  MyText.bodySmall('Đang upload...',
                      color: contentTheme.primary),
                ],
                if (controller.uploadedImageUrl != null &&
                    !controller.isUploading) ...[
                  MySpacing.width(12),
                  Icon(Icons.check_circle,
                      color: contentTheme.success, size: 18),
                  MySpacing.width(4),
                  MyText.bodySmall('Đã upload',
                      color: contentTheme.success),
                ],
              ],
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: _buildImageContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if ((controller.currentImageUrl != null ||
        controller.uploadedImageUrl != null) &&
        controller.files.isEmpty) {
      return _buildImagePreview();
    }
    if (controller.files.isNotEmpty) return _buildFileList();
    return _buildUploadBox();
  }

  Widget _buildImagePreview() {
    final imageUrl =
        controller.uploadedImageUrl ?? controller.currentImageUrl;
    return MyContainer(
      onTap: controller.isUploading ? null : controller.pickFiles,
      borderRadiusAll: 12,
      height: 290,
      width: double.infinity,
      color: contentTheme.light,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              SellerService.buildImageUrl(imageUrl!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap:
                controller.isUploading ? null : controller.pickFiles,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt,
                          size: 48,
                          color: Colors.white.withOpacity(0.9)),
                      MySpacing.height(8),
                      Text(
                        'Nhấn để thay đổi ảnh',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return Column(
      children: [
        MyContainer.bordered(
          onTap: controller.isUploading ? null : controller.pickFiles,
          borderRadiusAll: 12,
          width: double.infinity,
          child: Padding(
            padding: MySpacing.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.files
                  .mapIndexed(
                    (index, file) => MyContainer.bordered(
                  borderRadiusAll: 12,
                  paddingAll: 16,
                  width: 110,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyContainer(
                        height: 44,
                        width: 44,
                        borderRadiusAll: 8,
                        color: contentTheme.primary
                            .withValues(alpha: 0.1),
                        paddingAll: 0,
                        child: Icon(
                            controller.getFileIcon(file.name),
                            size: 20,
                            color: contentTheme.primary),
                      ),
                      MySpacing.height(8),
                      MyText.bodySmall(file.name,
                          fontWeight: 700,
                          muted: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),
        ),
        if (controller.currentImageUrl != null ||
            controller.uploadedImageUrl != null) ...[
          MySpacing.height(12),
          MyContainer.bordered(
            onTap: () {
              controller.files.clear();
              controller.update();
            },
            borderRadiusAll: 8,
            padding: MySpacing.xy(16, 8),
            borderColor: contentTheme.primary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back,
                    size: 16, color: contentTheme.primary),
                MySpacing.width(4),
                MyText.bodySmall('Quay lại ảnh hiện tại',
                    color: contentTheme.primary),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadBox() {
    return MyContainer.bordered(
      onTap: controller.isUploading ? null : controller.pickFiles,
      borderRadiusAll: 12,
      width: double.infinity,
      child: Padding(
        padding: MySpacing.xy(0, 32),
        child: Column(
          children: [
            Icon(Boxicons.bx_cloud_upload,
                size: 48, color: contentTheme.primary),
            MySpacing.height(16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: [
                MyText.bodyLarge('Kéo thả ảnh vào đây, hoặc'),
                MyText.bodyLarge('chọn file',
                    color: contentTheme.primary),
              ],
            ),
            MySpacing.height(8),
            MyText.bodySmall('Hỗ trợ: PNG, JPG, WEBP (200×200)',
                muted: true),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Center(
    child: Icon(Icons.category_outlined,
        size: 48,
        color: contentTheme.secondary.withValues(alpha: 0.3)),
  );

  Widget _buildGeneralInfo() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                MyText.titleMedium(
                  'Thông tin category',
                  style: TextStyle(
                    fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium('Tên danh mục *'),
                MySpacing.height(8),
                TextFormField(
                  controller: controller.nameController,
                  style: MyTextStyle.bodyMedium(),
                  onChanged: (_) => controller.update(),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập tên danh mục'
                      : null,
                  decoration: InputDecoration(
                    border: outlineInputBorder,
                    focusedBorder: outlineInputBorder,
                    enabledBorder: outlineInputBorder,
                    errorBorder: outlineInputBorder,
                    focusedErrorBorder: outlineInputBorder,
                    disabledBorder: outlineInputBorder,
                    contentPadding: MySpacing.all(16),
                    isDense: true,
                    isCollapsed: true,
                    hintText: 'Nhập tên danh mục',
                    hintStyle: MyTextStyle.bodyMedium(muted: true),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return MyContainer(
      paddingAll: 20,
      borderRadiusAll: 12,
      color: contentTheme.light,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MyContainer.bordered(
            onTap: () => Get.back(),
            color: Colors.transparent,
            borderRadiusAll: 12,
            padding: MySpacing.xy(24, 10),
            borderColor: contentTheme.dark,
            child: MyText.bodyMedium('Hủy'),
          ),
          MySpacing.width(12),
          MyContainer(
            onTap: _handleSave,
            color: contentTheme.primary,
            borderRadiusAll: 12,
            padding: MySpacing.xy(24, 12),
            child: controller.isSaving
                ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: contentTheme.onPrimary),
            )
                : MyText.bodyMedium('Lưu thay đổi',
                fontWeight: 600,
                color: contentTheme.onPrimary),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final success = await controller.save();
    if (success) {
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.back(result: true);
    }
  }
}