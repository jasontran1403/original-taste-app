// views/ui/general/category/category_edit_screen.dart
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
    borderSide:
    BorderSide(color: contentTheme.secondary.withValues(alpha: 0.4)),
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

  // ── Image card ────────────────────────────────────────────────────
  Widget _buildImageUpload() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: MySpacing.all(20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: MyContainer.bordered(
                    onTap: () => Get.back(),
                    color: Colors.transparent,
                    borderRadiusAll: 10,
                    padding: MySpacing.xy(12, 8),
                    borderColor: contentTheme.secondary.withOpacity(0.4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_rounded,
                            size: 16, color: contentTheme.secondary),
                        MySpacing.width(6),
                        MyText.bodyMedium('Quay lại',
                            color: contentTheme.secondary, fontWeight: 600),
                      ],
                    ),
                  ),
                ),
                MyText.titleMedium(
                  'Ảnh danh mục',
                  style: TextStyle(
                    fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Upload status — góc phải

              ],
            ),
          ),
          const Divider(height: 0),
          // Image area + error banner
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageContent(),
                // ── Error banner ──────────────────────────────────
                if (controller.uploadError != null) ...[
                  MySpacing.height(10),
                  Container(
                    width: double.infinity,
                    padding: MySpacing.all(12),
                    decoration: BoxDecoration(
                      color: contentTheme.danger.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: contentTheme.danger.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.error_outline,
                            size: 16, color: contentTheme.danger),
                        MySpacing.width(8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText.bodySmall('Upload thất bại',
                                  color: contentTheme.danger, fontWeight: 700),
                              MySpacing.height(2),
                              MyText.bodySmall(controller.uploadError!,
                                  color: contentTheme.danger),
                              MySpacing.height(6),
                              GestureDetector(
                                onTap: controller.clearNewImage,
                                child: MyText.bodySmall(
                                    'Xóa và chọn lại ảnh',
                                    color: contentTheme.primary,
                                    fontWeight: 600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Image content: 3 trạng thái ──────────────────────────────────
  //
  //  1. previewBytes != null → ảnh vừa chọn (Image.memory) — giống create
  //  2. currentImageUrl != null → ảnh hiện tại từ server (Image.network)
  //  3. empty → upload box
  //
  Widget _buildImageContent() {
    // Ảnh vừa chọn (kể cả khi đang upload hoặc lỗi)
    if (controller.previewBytes != null) {
      return _buildPreview();
    }
    // Ảnh hiện tại từ server
    if (controller.currentImageUrl != null) {
      return _buildExistingImage();
    }
    // Chưa có ảnh
    return _buildDropZoneEmpty();
  }

  // Preview ảnh mới chọn — giống CategoryCreateScreen
  Widget _buildPreview() {
    return GestureDetector(
      onTap: controller.isUploading ? null : controller.pickFiles,
      child: Stack(
        children: [
          // Ảnh
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              controller.previewBytes!,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),

          // Overlay spinner khi đang upload
          if (controller.isUploading)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 12),
                        Text('Đang upload...',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Hint "nhấn để đổi ảnh" khi không upload
          if (!controller.isUploading && controller.uploadError == null)
            Positioned(
              bottom: 10, right: 10,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text('Nhấn để đổi ảnh',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

          // Nút quay lại ảnh cũ (góc trên phải) — chỉ hiện khi có ảnh cũ và không lỗi
          if (!controller.isUploading &&
              controller.uploadError == null &&
              controller.currentImageUrl != null)
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: controller.clearNewImage,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.undo_rounded, size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text('Dùng ảnh cũ',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Ảnh hiện tại từ server — có overlay "nhấn để thay đổi"
  Widget _buildExistingImage() {
    return GestureDetector(
      onTap: controller.isUploading ? null : controller.pickFiles,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              SellerService.buildImageUrl(controller.currentImageUrl!),
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt,
                        size: 48, color: Colors.white.withOpacity(0.9)),
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
        ],
      ),
    );
  }

  Widget _buildDropZoneEmpty() {
    return GestureDetector(
      onTap: controller.pickFiles,
      child: Container(
        width: double.infinity,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: contentTheme.secondary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Boxicons.bx_cloud_upload,
                  size: 56, color: contentTheme.primary),
              MySpacing.height(16),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  MyText.bodyLarge('Kéo thả ảnh vào đây, hoặc'),
                  MyText.bodyLarge('chọn file', color: contentTheme.primary),
                ],
              ),
              MySpacing.height(8),
              MyText.bodySmall('Hỗ trợ: PNG, JPG, WEBP, GIF (200×200)',
                  muted: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() => Center(
    child: Icon(Icons.category_outlined,
        size: 48,
        color: contentTheme.secondary.withValues(alpha: 0.3)),
  );

  // ── General info ──────────────────────────────────────────────────
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
            child: MyText.titleMedium(
              'Thông tin danh mục',
              style: TextStyle(
                fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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

  // ── Action bar ────────────────────────────────────────────────────
  Widget _buildActions() {
    final isBlocked = controller.hasUploadError;

    return MyContainer(
      paddingAll: 20,
      borderRadiusAll: 12,
      color: contentTheme.light,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBlocked) ...[
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Icon(Icons.image_not_supported_outlined,
                  size: 14, color: contentTheme.danger),
              MySpacing.width(6),
              MyText.bodySmall('Ảnh upload lỗi — vui lòng xóa và chọn lại',
                  color: contentTheme.danger),
            ]),
            MySpacing.height(10),
          ],
          Row(
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
              Opacity(
                opacity: isBlocked ? 0.45 : 1.0,
                child: MyContainer(
                  onTap: (controller.isSaving || isBlocked) ? null : _handleSave,
                  color: contentTheme.primary,
                  borderRadiusAll: 12,
                  padding: MySpacing.xy(24, 12),
                  child: controller.isSaving
                      ? SizedBox(
                    height: 18, width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: contentTheme.onPrimary),
                  )
                      : MyText.bodyMedium('Lưu thay đổi',
                      fontWeight: 600, color: contentTheme.onPrimary),
                ),
              ),
            ],
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