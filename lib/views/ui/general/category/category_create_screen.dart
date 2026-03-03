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

import '../../../../controller/seller/category_create_controller.dart';
import '../../../../helper/services/seller_services.dart';

class CategoryCreateScreen extends StatefulWidget {
  const CategoryCreateScreen({super.key});

  @override
  State<CategoryCreateScreen> createState() => _CategoryCreateScreenState();
}

class _CategoryCreateScreenState extends State<CategoryCreateScreen> with UIMixin, WidgetsBindingObserver {
  late CategoryCreateController controller;
  late OutlineInputBorder _outlineInputBorder;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(CategoryCreateController(), tag: 'category_create_${DateTime.now().millisecondsSinceEpoch}');

    // Khởi tạo border một lần duy nhất
    _outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.4)),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Không gọi controller.dispose() vì GetX tự xử lý
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryCreateController>(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "TẠO DANH MỤC",
          child: Form(
            key: controller.formKey,
            child: MyFlex(
              children: [
                MyFlexItem(
                  sizes: 'lg-12 md-12',
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

  // ── Upload image ──────────────────────────────────────────────────
  Widget _buildImageUpload() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Row(
              children: [
                MyText.titleMedium(
                  'Ảnh danh mục',
                  style: TextStyle(
                    fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (controller.isUploading) ...[
                  MySpacing.width(12),
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: contentTheme.primary),
                  ),
                  MySpacing.width(8),
                  MyText.bodySmall('Đang upload...', color: contentTheme.primary),
                ],
              ],
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: MyContainer.bordered(
              onTap: controller.isUploading ? null : controller.pickFiles,
              borderRadiusAll: 12,
              width: double.infinity,
              height: 260,
              child: controller.files.isEmpty
                  ? _buildDropZoneEmpty()
                  : _buildDropZoneWithFiles(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZoneEmpty() {
    return SizedBox(
      height: 260,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Boxicons.bx_cloud_upload,
                size: 56, color: contentTheme.primary),
            MySpacing.height(20),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: [
                MyText.bodyLarge('Kéo thả ảnh vào đây, hoặc'),
                MyText.bodyLarge('chọn file',
                    color: contentTheme.primary),
              ],
            ),
            MySpacing.height(10),
            MyText.bodySmall(
                'Hỗ trợ: PNG, JPG, WEBP, GIF (200×200)',
                muted: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZoneWithFiles() {
    return SizedBox(
      height: 260,
      child: Center(
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: controller.files.mapIndexed(
                (index, file) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(file.path!),
                width: 240,
                height: 240,
                fit: BoxFit.cover,
              ),
            ),
          ).toList(),
        ),
      ),
    );
  }

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
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên danh mục' : null,
                  decoration: InputDecoration(
                    border: _outlineInputBorder, // Sử dụng biến đã khởi tạo
                    focusedBorder: _outlineInputBorder,
                    enabledBorder: _outlineInputBorder,
                    errorBorder: _outlineInputBorder,
                    focusedErrorBorder: _outlineInputBorder,
                    contentPadding: MySpacing.all(16),
                    isDense: true,
                    isCollapsed: true,
                    hintText: 'Nhập tên danh mục (vd: Cà phê, Trà sữa...)',
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

  // ── Bottom action bar ─────────────────────────────────────────────
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
            onTap: () => _handleSave(),
            color: contentTheme.primary,
            borderRadiusAll: 12,
            padding: MySpacing.xy(24, 12),
            child: controller.isSaving
                ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: contentTheme.onPrimary),
            )
                : MyText.bodyMedium('Lưu danh mục', fontWeight: 600, color: contentTheme.onPrimary),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final success = await controller.save(); // success sẽ là bool
    if (success) {
      Get.back(result: true);
    }
  }

  OutlineInputBorder get outlineInputBorder {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.4)),
    );
  }
}