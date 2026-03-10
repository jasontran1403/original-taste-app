// views/ui/general/category/category_create_screen.dart
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

import '../../../../controller/seller/category_create_controller.dart';

class CategoryCreateScreen extends StatefulWidget {
  const CategoryCreateScreen({super.key});

  @override
  State<CategoryCreateScreen> createState() => _CategoryCreateScreenState();
}

class _CategoryCreateScreenState extends State<CategoryCreateScreen>
    with UIMixin, WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late CategoryCreateController controller;
  late OutlineInputBorder _outlineInputBorder;

  // Badge fade-out animation
  late AnimationController _badgeAnim;
  late Animation<double> _badgeOpacity;
  bool _showBadge = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(
      CategoryCreateController(),
      tag: 'category_create_${DateTime.now().millisecondsSinceEpoch}',
    );
    _outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide:
      BorderSide(color: contentTheme.secondary.withValues(alpha: 0.4)),
    );

    // Fade-out trong 600ms
    _badgeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _badgeOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _badgeAnim, curve: Curves.easeOut),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) setState(() => _showBadge = false);
        _badgeAnim.reset();
      }
    });

    // Khi upload xong → hiện badge 2s rồi fadeout
    ever(controller.uploadDone, (_) => _triggerBadge());
  }

  void _triggerBadge() {
    if (!mounted) return;
    _badgeAnim.reset();
    setState(() => _showBadge = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _badgeAnim.forward();
    });
  }

  @override
  void dispose() {
    _badgeAnim.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() => setState(() {});

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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
        mainAxisSize: MainAxisSize.min,
        children: [
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
              ],
            ),
          ),
          const Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                controller.previewBytes != null
                    ? _buildPreview()
                    : _buildDropZoneEmpty(),
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
                                onTap: controller.clearImage,
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

  Widget _buildPreview() {
    return GestureDetector(
      onTap: controller.isUploading ? null : controller.pickFiles,
      child: Stack(
        children: [
          // ── Ảnh ──────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              controller.previewBytes!,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),

          // ── Overlay spinner khi đang upload ──────────────────
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

          // ── Hint "nhấn để đổi ảnh" góc dưới phải ────────────
          if (!controller.isUploading)
            Positioned(
              bottom: 10,
              right: 10,
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

          // ── Badge "✓ Đã upload thành công" — hiện 2s rồi fadeout
          if (_showBadge)
            Positioned(
              top: 10,
              left: 10,
              child: FadeTransition(
                opacity: _badgeOpacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Đã upload thành công',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneralInfo() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  'Thông tin danh mục',
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
                    border: _outlineInputBorder,
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
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: contentTheme.onPrimary),
                  )
                      : MyText.bodyMedium('Lưu danh mục',
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