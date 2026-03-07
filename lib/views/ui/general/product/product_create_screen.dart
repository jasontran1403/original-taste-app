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

import '../../../../controller/ui/general/product/product_create_controller.dart';

class ProductCreateScreen extends StatefulWidget {
  const ProductCreateScreen({super.key});
  @override
  State<ProductCreateScreen> createState() => _ProductCreateScreenState();
}

class _ProductCreateScreenState extends State<ProductCreateScreen> with UIMixin {
  late ProductCreateController controller;

  @override
  late OutlineInputBorder outlineInputBorder;

  @override
  void initState() {
    outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.4)),
    );
    controller = Get.put(
      ProductCreateController(),
      tag: 'product_create_${DateTime.now().millisecondsSinceEpoch}',
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductCreateController>(
      init: controller,
      builder: (c) => Layout(
        screenName: 'TẠO SẢN PHẨM',
        child: Form(
          key: c.formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              _buildImageSection(c),
              MySpacing.height(20),
              _buildBasicInfo(c),
              MySpacing.height(20),
              _buildIngredientSection(c),
              MySpacing.height(20),
              _buildPriceSection(c),
              MySpacing.height(20),
              _buildActionBar(c),
              MySpacing.height(32),
            ]),
          ),
        ),
      ),
    );
  }

  // ── 1. Ảnh ────────────────────────────────────────────────────────
  Widget _buildImageSection(ProductCreateController c) {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: MySpacing.all(20),
          child: Row(children: [
            MyContainer.bordered(
              onTap: () => Get.back(),
              color: Colors.white.withOpacity(0.9), // trắng đục
              borderRadiusAll: 12, // bo tròn
              padding: MySpacing.xy(16, 10),
              borderColor: Colors.grey.shade300, // border xám nhẹ
              child: MyText.bodyMedium(
                'Quay lại',
                color: Colors.black87,
                // Không fontWeight → text normal
              ),
            ),
            MySpacing.width(16), // khoảng cách giữa nút và tiêu đề
            MyText.titleMedium('Ảnh sản phẩm',
                style: TextStyle(
                    fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                    fontWeight: FontWeight.w600)),
            if (c.isUploading) ...[
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
            onTap: c.isUploading ? null : c.pickFiles,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                    color: contentTheme.secondary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildImageContent(c),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildImageContent(ProductCreateController c) {
    if (c.isUploading) {
      return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()));
    }
    if (c.uploadedImageUrl != null) {
      return Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            SellerService.buildImageUrl(c.uploadedImageUrl!),
            height: 200, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
          ),
        ),
        Positioned(
          top: 8, right: 8,
          child: GestureDetector(
            onTap: c.clearImage,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
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
      MyText.bodyMedium('Nhấn vào đây để chọn ảnh',
          color: contentTheme.primary),
      MySpacing.height(4),
      MyText.bodySmall('PNG, JPG, WEBP — khuyến nghị 200×200', muted: true),
    ]),
  );

  // ── 2. Thông tin cơ bản ───────────────────────────────────────────
  Widget _buildBasicInfo(ProductCreateController c) {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                    controller: c.nameController,
                    style: MyTextStyle.bodyMedium(),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Vui lòng nhập tên' : null,
                    decoration: _inputDeco('Nhập tên sản phẩm...'),
                  ),
                ),
              ),
              MyFlexItem(
                sizes: 'lg-4',
                child: _field('Danh mục',
                  c.isLoadingData
                      ? const LinearProgressIndicator()
                      : DropdownButtonFormField<CategoryModel>(
                    dropdownColor: contentTheme.light,
                    decoration: _inputDeco('Chọn danh mục'),
                    value: c.selectedCategory,
                    onChanged: (v) {
                      c.selectedCategory = v;
                      c.update();
                    },
                    items: c.categories
                        .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: MyText.bodyMedium(cat.name),
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
                          color: contentTheme.secondary.withValues(alpha: 0.4)),
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
                child: _field('Thuế VAT',
                  DropdownButtonFormField<int>(
                    dropdownColor: contentTheme.light,
                    decoration: _inputDeco('Chọn VAT'),
                    value: c.selectedVatRate,
                    onChanged: (v) {
                      c.selectedVatRate = v ?? 0;
                      c.update();
                    },
                    items: c.vatRateOptions
                        .map((r) => DropdownMenuItem(
                      value: r,
                      child: MyText.bodyMedium('$r%'),
                    ))
                        .toList(),
                  ),
                ),
              ),
              MyFlexItem(
                child: _field('Mô tả (tuỳ chọn)',
                  TextFormField(
                    controller: c.descriptionController,
                    maxLines: 3,
                    style: MyTextStyle.bodyMedium(),
                    decoration: _inputDeco('Mô tả ngắn về sản phẩm...'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ── 3. Nguyên liệu ────────────────────────────────────────────────
  Widget _buildIngredientSection(ProductCreateController c) {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MyText.bodyMedium('Chọn nguyên liệu *'),
            MySpacing.height(8),
            c.isLoadingData
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<IngredientModel>(
              dropdownColor: contentTheme.light,
              decoration: _inputDeco('Chọn nguyên liệu...'),
              value: c.selectedIngredient,
              isExpanded: true,
              onChanged: (v) {
                c.selectedIngredient = v;
                c.update();
              },
              items: c.ingredientOptions
                  .map((ing) => DropdownMenuItem(
                value: ing,
                child: Row(children: [
                  Flexible(
                      child: MyText.bodyMedium(ing.name,
                          overflow: TextOverflow.ellipsis)),
                  MySpacing.width(8),
                  MyText.bodySmall(
                      '(tồn: ${ing.stockQuantity.toStringAsFixed(2)} ${ing.unit})',
                      muted: true),
                ]),
              ))
                  .toList(),
            ),
            if (c.selectedIngredient != null) ...[
              MySpacing.height(12),
              Container(
                padding: MySpacing.all(12),
                decoration: BoxDecoration(
                  color: contentTheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline, size: 16, color: contentTheme.primary),
                  MySpacing.width(8),
                  Expanded(
                    child: MyText.bodySmall(
                      '${c.selectedIngredient!.name} '
                          '— Tồn kho: ${c.selectedIngredient!.stockQuantity.toStringAsFixed(2)} ${c.selectedIngredient!.unit}. '
                          'Mỗi đơn vị sản phẩm bán ra sẽ trừ 1 ${c.selectedIngredient!.unit} nguyên liệu.',
                      color: contentTheme.primary,
                    ),
                  ),
                ]),
              ),
            ],
          ]),
        ),
      ]),
    );
  }

  // ── 4. Giá ────────────────────────────────────────────────────────
  Widget _buildPriceSection(ProductCreateController c) {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('Giá sản phẩm'),
        const Divider(height: 0),
        Padding(
          padding: MySpacing.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Giá gốc ──────────────────────────────────────────
              _field('Giá gốc (lẻ) *',
                TextFormField(
                  controller: c.basePriceController,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: MyTextStyle.bodyMedium(),
                  decoration: _inputDeco('Giá gốc (đ)').copyWith(
                    prefixIcon: Icon(Icons.attach_money,
                        size: 18, color: contentTheme.secondary),
                    prefixIconConstraints:
                    const BoxConstraints(minWidth: 38, maxWidth: 38),
                    helperText: 'Áp dụng khi không có khung giá phù hợp',
                    helperStyle: MyTextStyle.bodySmall(
                        xMuted: true),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                    if (double.tryParse(v.trim()) == null) return 'Số không hợp lệ';
                    return null;
                  },
                ),
              ),

              MySpacing.height(24),

              // ── Khung giá sỉ ─────────────────────────────────────
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.titleSmall('Khung giá sỉ',
                          style: TextStyle(
                              fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                              fontWeight: FontWeight.w600)),
                      MyText.bodySmall(
                          'Giá tự động áp dụng theo số lượng đặt',
                          muted: true),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: c.addTier,
                  child: Container(
                    padding: MySpacing.xy(12, 8),
                    decoration: BoxDecoration(
                      color: contentTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.add, size: 16, color: contentTheme.primary),
                      MySpacing.width(4),
                      MyText.bodySmall('Thêm khung',
                          color: contentTheme.primary, fontWeight: 600),
                    ]),
                  ),
                ),
              ]),

              if (c.tiers.isEmpty) ...[
                MySpacing.height(12),
                Container(
                  width: double.infinity,
                  padding: MySpacing.xy(16, 14),
                  decoration: BoxDecoration(
                    color: contentTheme.secondary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: contentTheme.secondary.withValues(alpha: 0.15),
                        style: BorderStyle.solid),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline,
                        size: 16,
                        color: contentTheme.secondary.withValues(alpha: 0.5)),
                    MySpacing.width(8),
                    MyText.bodySmall(
                        'Không có khung giá — dùng giá gốc cho tất cả đơn',
                        muted: true),
                  ]),
                ),
              ] else ...[
                MySpacing.height(12),
                // Header labels
                Padding(
                  padding: MySpacing.bottom(6),
                  child: Row(children: [
                    const SizedBox(width: 32),
                    Expanded(flex: 3, child: MyText.bodySmall('Tên khung', muted: true)),
                    MySpacing.width(8),
                    Expanded(flex: 2, child: MyText.bodySmall('Từ (SL)', muted: true)),
                    MySpacing.width(8),
                    Expanded(flex: 2, child: MyText.bodySmall('Đến (SL)', muted: true)),
                    MySpacing.width(8),
                    Expanded(flex: 2, child: MyText.bodySmall('Giá (đ)', muted: true)),
                    const SizedBox(width: 36),
                  ]),
                ),
                ...List.generate(c.tiers.length, (i) => _buildTierRow(c, i)),
                MySpacing.height(6),
                MyText.bodySmall(
                    '* "Đến" để trống = không giới hạn trên',
                    muted: true),
              ],
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildTierRow(ProductCreateController c, int index) {
    final tier = c.tiers[index];
    return Padding(
      padding: MySpacing.bottom(10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // Index badge
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: contentTheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: MyText.bodySmall('${index + 1}',
                color: contentTheme.primary, fontWeight: 700),
          ),
        ),
        MySpacing.width(8),
        // Tên khung
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: tier.nameController,
            style: MyTextStyle.bodyMedium(),
            decoration: _inputDeco('Tên khung'),
          ),
        ),
        MySpacing.width(8),
        // Từ
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: tier.minQtyController,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: MyTextStyle.bodyMedium(),
            decoration: _inputDeco('0'),
          ),
        ),
        MySpacing.width(8),
        // Đến
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: tier.maxQtyController,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: MyTextStyle.bodyMedium(),
            decoration: _inputDeco('∞'),
          ),
        ),
        MySpacing.width(8),
        // Giá
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: tier.priceController,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,0}')),
            ],
            style: MyTextStyle.bodyMedium(),
            decoration: _inputDeco('Giá'),
          ),
        ),
        MySpacing.width(8),
        // Xóa
        GestureDetector(
          onTap: () => c.removeTier(index),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: contentTheme.danger.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.close, size: 16, color: contentTheme.danger),
          ),
        ),
      ]),
    );
  }

  // ── 5. Action bar ─────────────────────────────────────────────────
  Widget _buildActionBar(ProductCreateController c) {
    return Container(
      padding: MySpacing.all(20),
      decoration: BoxDecoration(
        color: contentTheme.light,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
          onTap: c.isSaving ? null : c.save,
          color: contentTheme.primary,
          borderRadiusAll: 12,
          padding: MySpacing.xy(24, 12),
          child: c.isSaving
              ? SizedBox(
              height: 18, width: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: contentTheme.onPrimary))
              : MyText.bodyMedium('Lưu sản phẩm',
              fontWeight: 600, color: contentTheme.onPrimary),
        ),
      ]),
    );
  }

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      MyText.bodyMedium(label),
      MySpacing.height(8),
      child,
    ],
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