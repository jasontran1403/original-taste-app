import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/services/seller_services.dart';
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

import '../../../../controller/ui/general/product/product_edit_controller.dart';

class ProductEditScreen extends StatefulWidget {
  const ProductEditScreen({super.key});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> with UIMixin {
  late ProductEditController controller;

  @override
  late OutlineInputBorder outlineInputBorder;

  Future<void> _handleSave() async {
    final success = await controller.save();
    if (success) {
      Get.back(result: true);
    }
  }

  @override
  void initState() {
    outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide:
      BorderSide(color: contentTheme.secondary.withValues(alpha: 0.4)),
    );
    controller = Get.put(
      ProductEditController(),
      tag: 'product_edit_${DateTime.now().millisecondsSinceEpoch}',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductEditController>(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: 'CHỈNH SỬA SẢN PHẨM',
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildImageSection(),
                  MySpacing.height(20),
                  _buildBasicInfo(),
                  MySpacing.height(20),
                  _buildIngredientSection(),
                  MySpacing.height(20),
                  _buildPricesSection(),
                  MySpacing.height(20),
                  _buildActionBar(),
                  MySpacing.height(32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── 1. Ảnh ────────────────────────────────────────────────────────
  Widget _buildImageSection() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Row(children: [
              MyText.titleMedium('Ảnh sản phẩm',
                  style: TextStyle(
                      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                      fontWeight: FontWeight.w600)),
              if (controller.isUploading) ...[
                MySpacing.width(12),
                SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: contentTheme.primary)),
                MySpacing.width(6),
                MyText.bodySmall('Đang upload...', color: contentTheme.primary),
              ],
            ]),
          ),
          const Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: GestureDetector(
              onTap: controller.isUploading ? null : controller.pickFiles,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: contentTheme.secondary.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _buildImageContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (controller.isUploading) {
      return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()));
    }
    final imageUrl = controller.activeImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            SellerService.buildImageUrl(imageUrl),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
          ),
        ),
        Positioned(
          top: 8, right: 8,
          child: GestureDetector(
            onTap: controller.clearUploadedImage,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
        if (controller.uploadedImageUrl != null)
          Positioned(
            bottom: 8, left: 8,
            child: Container(
              padding: MySpacing.xy(8, 4),
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6)),
              child: MyText.bodySmall('Ảnh mới',
                  color: Colors.white, fontWeight: 600),
            ),
          ),
      ]);
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() => Padding(
    padding: MySpacing.xy(0, 28),
    child: Column(children: [
      Icon(Icons.add_photo_alternate_outlined,
          size: 48, color: contentTheme.primary.withValues(alpha: 0.6)),
      MySpacing.height(10),
      MyText.bodyMedium('Nhấn vào đây để thay ảnh',
          color: contentTheme.primary),
      MySpacing.height(4),
      MyText.bodySmall('PNG, JPG, WEBP — khuyến nghị 200×200', muted: true),
    ]),
  );

  // ── 2. Thông tin cơ bản ───────────────────────────────────────────
  Widget _buildBasicInfo() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Thông tin sản phẩm'),
          const Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: MyFlex(
              contentPadding: false,
              children: [
                MyFlexItem(
                  child: _field('Tên sản phẩm *',
                    TextFormField(
                      controller: controller.nameController,
                      style: MyTextStyle.bodyMedium(),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Vui lòng nhập tên'
                          : null,
                      decoration: _inputDeco('Nhập tên sản phẩm...'),
                    ),
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4',
                  child: _field('Danh mục',
                    controller.isLoadingData
                        ? const LinearProgressIndicator()
                        : DropdownButtonFormField<CategoryModel>(
                      dropdownColor: contentTheme.light,
                      decoration: _inputDeco('Chọn danh mục'),
                      value: controller.selectedCategory,
                      onChanged: (v) {
                        controller.selectedCategory = v;
                        controller.update();
                      },
                      items: controller.categories
                          .map((c) => DropdownMenuItem(
                        value: c,
                        child: MyText.bodyMedium(c.name),
                      ))
                          .toList(),
                    ),
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4',
                  child: _field('Đơn vị',
                    Container(
                      padding: MySpacing.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: contentTheme.secondary
                                .withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(children: [
                        Icon(Icons.scale_outlined,
                            size: 18, color: contentTheme.secondary),
                        MySpacing.width(8),
                        MyText.bodyMedium('kg', fontWeight: 600),
                        MySpacing.width(6),
                        MyText.bodySmall('(cố định)', muted: true),
                      ]),
                    ),
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4',
                  child: _field('Thuế VAT (%)',
                    Theme(
                      data: Theme.of(context).copyWith(
                        // Tùy chỉnh dropdown menu (modal mở)
                        canvasColor: contentTheme.light, // Nền modal trắng nhẹ
                        shadowColor: contentTheme.primary.withOpacity(0.2),
                        splashColor: contentTheme.primary.withOpacity(0.1),
                        highlightColor: contentTheme.primary.withOpacity(0.05),
                      ),
                      child: DropdownButtonFormField<int>(
                        value: controller.selectedVatRate,
                        isExpanded: true,
                        decoration: _inputDeco('Chọn mức thuế VAT').copyWith(
                          // Tùy chỉnh input field
                          filled: true,
                          fillColor: contentTheme.light,
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: contentTheme.secondary.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: contentTheme.secondary.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: contentTheme.primary, width: 1.5),
                          ),
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: contentTheme.primary,
                          size: 28,
                        ),
                        dropdownColor: contentTheme.light, // Nền dropdown
                        borderRadius: BorderRadius.circular(12),
                        elevation: 4,
                        items: [0, 5, 8, 10].map((rate) {
                          final isSelected = rate == controller.selectedVatRate;
                          return DropdownMenuItem<int>(
                            value: rate,
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? contentTheme.primary.withOpacity(0.1) : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: MyText.bodyMedium(
                                '$rate%',
                                color: isSelected ? contentTheme.primary : contentTheme.dark,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedVatRate = value;
                            controller.update();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                MyFlexItem(
                  child: _field('Mô tả (tuỳ chọn)',
                    TextFormField(
                      controller: controller.descriptionController,
                      maxLines: 3,
                      style: MyTextStyle.bodyMedium(),
                      decoration: _inputDeco('Mô tả ngắn về sản phẩm...'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Nguyên liệu ────────────────────────────────────────────────
  Widget _buildIngredientSection() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Row(children: [
              MyText.titleMedium('Nguyên liệu *',
                  style: TextStyle(
                      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                      fontWeight: FontWeight.w600)),
              MySpacing.width(8),
              Container(
                padding: MySpacing.xy(8, 4),
                decoration: BoxDecoration(
                  color: contentTheme.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: MyText.bodySmall('Bắt buộc chọn 1',
                    color: contentTheme.warning, fontWeight: 600),
              ),
            ]),
          ),
          const Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium('Chọn nguyên liệu *'),
                MySpacing.height(8),
                controller.isLoadingData
                    ? const LinearProgressIndicator()
                    : DropdownButtonFormField<IngredientModel>(
                  dropdownColor: contentTheme.light,
                  decoration: _inputDeco('Chọn nguyên liệu...'),
                  value: controller.selectedIngredient,
                  isExpanded: true,
                  onChanged: (v) {
                    controller.selectedIngredient = v;
                    controller.update();
                  },
                  items: controller.ingredientOptions
                      .map((ing) => DropdownMenuItem(
                    value: ing,
                    child: Row(children: [
                      Flexible(
                          child: MyText.bodyMedium(ing.name,
                              overflow: TextOverflow.ellipsis)),
                      MySpacing.width(8),
                      MyText.bodySmall(
                          '(Kho: ${ing.stockQuantity.toStringAsFixed(2)} ${ing.unit})',
                          muted: true),
                    ]),
                  ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Mức giá ────────────────────────────────────────────────────
  Widget _buildPricesSection() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Row(children: [
              Expanded(
                child: MyText.titleMedium('Mức giá *',
                    style: TextStyle(
                        fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                        fontWeight: FontWeight.w600)),
              ),
              GestureDetector(
                onTap: controller.addPrice,
                child: Container(
                  padding: MySpacing.xy(12, 8),
                  decoration: BoxDecoration(
                    color: contentTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.add, size: 16, color: contentTheme.primary),
                    MySpacing.width(4),
                    MyText.bodySmall('Thêm giá',
                        color: contentTheme.primary, fontWeight: 600),
                  ]),
                ),
              ),
            ]),
          ),
          const Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              children: [
                ...List.generate(
                    controller.prices.length, (i) => _buildPriceRow(i)),
                MySpacing.height(6),
                MyText.bodySmall('* Chọn radio để đặt làm giá mặc định',
                    muted: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(int index) {
    final item = controller.prices[index];

    return Padding(
      padding: MySpacing.bottom(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Radio để set default
          GestureDetector(
            onTap: item.isDefault ? null : () => _handleSetDefault(index),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isDefault
                    ? contentTheme.primary.withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Icon(
                item.isDefault
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: item.isDefault ? contentTheme.primary : contentTheme.secondary,
                size: 20,
              ),
            ),
          ),
          MySpacing.width(4),

          // Tên giá
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: item.nameController,
              style: MyTextStyle.bodyMedium(),
              decoration: _inputDeco('Tên giá (vd: Mặc định, Sale...)'),
            ),
          ),
          MySpacing.width(10),

          // Giá
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: item.priceController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: MyTextStyle.bodyMedium(),
              decoration: _inputDeco('Giá (đ)').copyWith(
                prefixIcon: Icon(Icons.attach_money,
                    size: 18, color: contentTheme.secondary),
                prefixIconConstraints:
                const BoxConstraints(minWidth: 38, maxWidth: 38),
              ),
            ),
          ),
          MySpacing.width(8),

          // Nút xóa
          GestureDetector(
            onTap: () => _handleRemovePrice(index),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: contentTheme.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.close, size: 16, color: contentTheme.danger),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSetDefault(int index) async {
    final success = await controller.setDefaultPrice(index);
    if (success) {
      // Cập nhật UI
      setState(() {});
    }
  }

// Xử lý remove price
  Future<void> _handleRemovePrice(int index) async {
    final success = await controller.removePrice(index);
    if (success) {
      // Cập nhật UI
      setState(() {});
    }
  }

  // ── 5. Action bar ─────────────────────────────────────────────────
  Widget _buildActionBar() {
    return Container(
      padding: MySpacing.all(20),
      decoration: BoxDecoration(
        color: contentTheme.light,
        borderRadius: BorderRadius.circular(12),
      ),
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
            onTap: controller.isSaving ? null : _handleSave,
            color: contentTheme.primary,
            borderRadiusAll: 12,
            padding: MySpacing.xy(24, 12),
            child: controller.isSaving
                ? SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: contentTheme.onPrimary))
                : MyText.bodyMedium('Lưu thay đổi',
                fontWeight: 600, color: contentTheme.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [MyText.bodyMedium(label), MySpacing.height(8), child],
  );

  Widget _sectionHeader(String title) => Padding(
    padding: MySpacing.all(20),
    child: MyText.titleMedium(title,
        style: TextStyle(
            fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
            fontWeight: FontWeight.w600)),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    border: outlineInputBorder,
    focusedBorder: outlineInputBorder,
    enabledBorder: outlineInputBorder,
    errorBorder: outlineInputBorder,
    focusedErrorBorder: outlineInputBorder,
    disabledBorder: outlineInputBorder,
    contentPadding: MySpacing.all(14),
    isDense: true,
    isCollapsed: true,
    hintText: hint,
    hintStyle: MyTextStyle.bodyMedium(muted: true),
  );
}