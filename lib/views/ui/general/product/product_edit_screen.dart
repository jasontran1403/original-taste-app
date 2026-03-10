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

  /// Map<tierIndex, listener> để detach đúng khi tiers thay đổi
  final Map<int, VoidCallback> _maxListeners = {};

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
  void dispose() {
    _detachAllListeners();
    super.dispose();
  }

  // ── Sync listeners ─────────────────────────────────────────────────
  //
  //  Khi maxQtyController[i] thay đổi:
  //    → minQtyController[i+1] được cập nhật cùng giá trị (read-only sync)
  //    → controller.update() để rebuild warning banner
  //
  void _attachListeners() {
    _detachAllListeners();
    final tiers = controller.tiers;

    // Khung đầu luôn có minQty = "0"
    if (tiers.isNotEmpty) {
      tiers[0].minQtyController.text = '0';
    }

    for (int i = 0; i < tiers.length - 1; i++) {
      final cur = i;
      final next = i + 1;

      void cb() {
        final val = tiers[cur].maxQtyController.text;
        if (tiers[next].minQtyController.text != val) {
          tiers[next].minQtyController.text = val;
          tiers[next].minQtyController.selection =
              TextSelection.collapsed(offset: val.length);
        }
        controller.update();
      }

      _maxListeners[cur] = cb;
      tiers[cur].maxQtyController.addListener(cb);
    }

    // Listener trên khung cuối để cập nhật validation banner
    if (tiers.isNotEmpty) {
      final last = tiers.length - 1;
      void lastCb() => controller.update();
      _maxListeners[last] = lastCb;
      tiers[last].maxQtyController.addListener(lastCb);
    }
  }

  void _detachAllListeners() {
    final tiers = controller.tiers;
    _maxListeners.forEach((i, cb) {
      if (i < tiers.length) tiers[i].maxQtyController.removeListener(cb);
    });
    _maxListeners.clear();
  }

  // ── Tier validation ────────────────────────────────────────────────
  Map<int, String> _validateTierContinuity(List tiers) {
    if (tiers.isEmpty) return {};
    final errors = <int, String>{};

    for (int i = 0; i < tiers.length; i++) {
      final minRaw =
      (tiers[i].minQtyController as TextEditingController).text.trim();
      final maxRaw =
      (tiers[i].maxQtyController as TextEditingController).text.trim();
      final minVal = double.tryParse(minRaw);
      final maxVal = maxRaw.isEmpty ? null : double.tryParse(maxRaw);

      if (i == 0 && (minVal == null || minVal != 0)) {
        errors[i] = 'Khung 1 phải bắt đầu từ 0';
        continue;
      }
      if (minVal == null) {
        errors[i] = 'Khung ${i + 1}: giá trị "Từ" không hợp lệ';
        continue;
      }
      if (maxRaw.isNotEmpty && maxVal == null) {
        errors[i] = 'Khung ${i + 1}: giá trị "Đến" không hợp lệ';
        continue;
      }
      if (maxVal != null && maxVal <= minVal) {
        errors[i] = 'Khung ${i + 1}: "Đến" ($maxVal) phải lớn hơn "Từ" ($minVal)';
        continue;
      }
      if (i == tiers.length - 1 && maxRaw.isNotEmpty) {
        errors[i] =
        'Khung ${i + 1} là khung cuối — "Đến" phải để trống (vô cực)';
        continue;
      }
      if (i < tiers.length - 1 && maxRaw.isEmpty) {
        errors[i] =
        'Khung ${i + 1}: "Đến" không được để trống vì còn khung sau';
      }
    }
    return errors;
  }

  bool _hasTierErrors(List tiers) =>
      _validateTierContinuity(tiers).isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductEditController>(
      init: controller,
      builder: (c) {
        // Gắn lại listener sau mỗi rebuild (thêm/xóa tier)
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _attachListeners());

        return Layout(
          screenName: 'CHỈNH SỬA SẢN PHẨM',
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
        );
      },
    );
  }

  // ── 1. Ảnh ────────────────────────────────────────────────────────
  Widget _buildImageSection(ProductEditController c) {
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
              color: Colors.white.withOpacity(0.9),
              borderRadiusAll: 12,
              padding: MySpacing.xy(16, 10),
              borderColor: Colors.grey.shade300,
              child: MyText.bodyMedium('Quay lại', color: Colors.black87),
            ),
            MySpacing.width(16),
            Expanded(
              child: MyText.titleMedium('Ảnh sản phẩm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  )),
            ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: c.isUploading ? null : c.pickFiles,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: c.uploadError != null
                            ? contentTheme.danger.withValues(alpha: 0.6)
                            : contentTheme.secondary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _buildImageContent(c),
                ),
              ),
              // ── Error banner ─────────────────────────────────────
              if (c.uploadError != null) ...[
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
                            MyText.bodySmall(c.uploadError!,
                                color: contentTheme.danger),
                            MySpacing.height(6),
                            GestureDetector(
                              onTap: c.clearUploadedImage,
                              child: MyText.bodySmall('Xóa và chọn lại ảnh',
                                  color: contentTheme.primary, fontWeight: 600),
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
      ]),
    );
  }

  Widget _buildImageContent(ProductEditController c) {
    if (c.isUploading) {
      return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()));
    }
    // Lỗi upload — hiển thị icon lỗi, ẩn ảnh cũ để tránh nhầm lẫn
    if (c.uploadError != null) {
      return Padding(
        padding: MySpacing.xy(0, 28),
        child: Column(children: [
          Icon(Icons.broken_image_outlined,
              size: 48, color: contentTheme.danger.withValues(alpha: 0.6)),
          MySpacing.height(10),
          MyText.bodyMedium('Ảnh không hợp lệ — nhấn để chọn lại',
              color: contentTheme.danger),
        ]),
      );
    }
    final url = c.activeImageUrl;
    if (url != null && url.isNotEmpty) {
      return Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            SellerService.buildImageUrl(url),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imagePlaceholder(),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: c.clearUploadedImage,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
        if (c.uploadedImageUrl != null)
          Positioned(
            bottom: 8,
            left: 8,
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
  Widget _buildBasicInfo(ProductEditController c) {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('Thông tin sản phẩm'),
        const Divider(height: 0),
        Padding(
          padding: MySpacing.all(20),
          child: MyFlex(contentPadding: false, children: [
            MyFlexItem(
              child: _field('Tên sản phẩm *',
                  TextFormField(
                    controller: c.nameController,
                    style: MyTextStyle.bodyMedium(),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Vui lòng nhập tên'
                        : null,
                    decoration: _inputDeco('Nhập tên sản phẩm...'),
                  )),
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
                  )),
            ),
            MyFlexItem(
              sizes: 'lg-4',
              child: _field('Đơn vị',
                  Container(
                    padding: MySpacing.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color:
                          contentTheme.secondary.withValues(alpha: 0.4)),
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
                  )),
            ),
            MyFlexItem(
              sizes: 'lg-4',
              child: _field('Thuế VAT',
                  DropdownButtonFormField<int>(
                    dropdownColor: contentTheme.light,
                    decoration: _inputDeco('Chọn VAT'),
                    value: c.selectedVatRate,
                    onChanged: (v) => c.setVatRate(v ?? 0),
                    items: c.vatRateOptions
                        .map((r) => DropdownMenuItem(
                      value: r,
                      child: MyText.bodyMedium('$r%'),
                    ))
                        .toList(),
                  )),
            ),
            MyFlexItem(
              child: _field('Mô tả (tuỳ chọn)',
                  TextFormField(
                    controller: c.descriptionController,
                    maxLines: 3,
                    style: MyTextStyle.bodyMedium(),
                    decoration: _inputDeco('Mô tả ngắn về sản phẩm...'),
                  )),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── 3. Nguyên liệu ────────────────────────────────────────────────
  Widget _buildIngredientSection(ProductEditController c) {
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
                  Icon(Icons.info_outline,
                      size: 16, color: contentTheme.primary),
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
  Widget _buildPriceSection(ProductEditController c) {
    final tierErrors = c.tiers.isNotEmpty
        ? _validateTierContinuity(c.tiers)
        : <int, String>{};

    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader('Giá sản phẩm'),
        const Divider(height: 0),
        Padding(
          padding: MySpacing.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Giá gốc ─────────────────────────────────────────────
            _field('Giá gốc (lẻ) *',
              TextFormField(
                controller: c.basePriceController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: MyTextStyle.bodyMedium(),
                decoration: _inputDeco('Giá gốc (đ)').copyWith(
                  prefixIcon: Icon(Icons.attach_money,
                      size: 18, color: contentTheme.secondary),
                  prefixIconConstraints:
                  const BoxConstraints(minWidth: 38, maxWidth: 38),
                  helperText: 'Áp dụng khi không có khung giá phù hợp',
                  helperStyle: MyTextStyle.bodySmall(xMuted: true),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Bắt buộc';
                  if (double.tryParse(v.trim()) == null)
                    return 'Số không hợp lệ';
                  return null;
                },
              ),
            ),

            MySpacing.height(24),

            // ── Khung giá sỉ ────────────────────────────────────────
            Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.titleSmall('Khung giá sỉ',
                          style: TextStyle(
                              fontFamily:
                              GoogleFonts.hankenGrotesk().fontFamily,
                              fontWeight: FontWeight.w600)),
                      MyText.bodySmall(
                          'Giá tự động áp dụng theo số lượng đặt',
                          muted: true),
                    ]),
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
                      color:
                      contentTheme.secondary.withValues(alpha: 0.15)),
                ),
                child: Row(children: [
                  Icon(Icons.info_outline,
                      size: 16,
                      color:
                      contentTheme.secondary.withValues(alpha: 0.5)),
                  MySpacing.width(8),
                  MyText.bodySmall(
                      'Không có khung giá — dùng giá gốc cho tất cả đơn',
                      muted: true),
                ]),
              ),
            ] else ...[
              MySpacing.height(12),
              // Header
              Padding(
                padding: MySpacing.bottom(6),
                child: Row(children: [
                  const SizedBox(width: 80),
                  MySpacing.width(8),
                  Expanded(
                      flex: 2,
                      child: MyText.bodySmall('Từ (SL)', muted: true)),
                  MySpacing.width(8),
                  Expanded(
                      flex: 2,
                      child: MyText.bodySmall('Đến (SL)', muted: true)),
                  MySpacing.width(8),
                  Expanded(
                      flex: 2,
                      child: MyText.bodySmall('Giá (đ)', muted: true)),
                  const SizedBox(width: 36),
                ]),
              ),
              ...List.generate(
                  c.tiers.length,
                      (i) => _buildTierRow(c, i,
                      hasError: tierErrors.containsKey(i))),
              MySpacing.height(4),
              MyText.bodySmall(
                  '* "Đến" để trống = không giới hạn trên',
                  muted: true),
              if (tierErrors.isNotEmpty) ...[
                MySpacing.height(10),
                _buildTierErrorBanner(tierErrors),
              ],
            ],
          ]),
        ),
      ]),
    );
  }

  // ── Warning banner ─────────────────────────────────────────────────
  Widget _buildTierErrorBanner(Map<int, String> errors) {
    return Container(
      width: double.infinity,
      padding: MySpacing.all(14),
      decoration: BoxDecoration(
        color: contentTheme.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border:
        Border.all(color: contentTheme.danger.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.warning_amber_rounded,
              size: 16, color: contentTheme.danger),
          MySpacing.width(6),
          MyText.bodySmall('Các khung giá phải nối tiếp nhau',
              color: contentTheme.danger, fontWeight: 700),
        ]),
        MySpacing.height(6),
        ...errors.entries.map((e) => Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodySmall('• ', color: contentTheme.danger),
                Expanded(
                    child: MyText.bodySmall(e.value,
                        color: contentTheme.danger)),
              ]),
        )),
      ]),
    );
  }

  // ── Tier row ──────────────────────────────────────────────────────
  //
  //  Ô "Từ" luôn read-only:
  //    - Khung 1: cố định "0"
  //    - Khung 2+: bằng "Đến" của khung trước (tự động sync qua listener)
  //
  Widget _buildTierRow(
      ProductEditController c,
      int index, {
        bool hasError = false,
      }) {
    final tier = c.tiers[index];
    final tierName = 'Khung ${index + 1}';

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide:
      BorderSide(color: contentTheme.danger.withValues(alpha: 0.8)),
    );
    final lockedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
          color: contentTheme.secondary.withValues(alpha: 0.2)),
    );

    // Decoration ô "Từ" — luôn locked
    final decoMin = (hasError
        ? _inputDeco('0').copyWith(
      border: errorBorder,
      focusedBorder: errorBorder,
      enabledBorder: errorBorder,
      disabledBorder: errorBorder,
    )
        : _inputDeco('0').copyWith(
      border: lockedBorder,
      focusedBorder: lockedBorder,
      enabledBorder: lockedBorder,
      disabledBorder: lockedBorder,
      filled: true,
      fillColor:
      contentTheme.secondary.withValues(alpha: 0.06),
    ))
        .copyWith(
      suffixIcon: Icon(Icons.lock_outline,
          size: 13,
          color: contentTheme.secondary.withValues(alpha: 0.45)),
      suffixIconConstraints:
      const BoxConstraints(minWidth: 28, maxWidth: 28),
    );

    // Decoration ô "Đến"
    final decoMax = hasError
        ? _inputDeco('∞').copyWith(
      border: errorBorder,
      focusedBorder: errorBorder,
      enabledBorder: errorBorder,
    )
        : _inputDeco('∞');

    return Padding(
      padding: MySpacing.bottom(10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

        // ── Badge tên khung ────────────────────────────────────────
        Container(
          width: 80,
          padding: MySpacing.xy(10, 8),
          decoration: BoxDecoration(
            color: hasError
                ? contentTheme.danger.withValues(alpha: 0.08)
                : contentTheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: hasError
                    ? contentTheme.danger.withValues(alpha: 0.35)
                    : contentTheme.primary.withValues(alpha: 0.20)),
          ),
          child: Text(tierName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: hasError
                    ? contentTheme.danger
                    : contentTheme.primary,
              )),
        ),
        MySpacing.width(8),

        // ── Từ — read-only, sync từ Đến của khung trước ───────────
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: tier.minQtyController,
            readOnly: true,
            enableInteractiveSelection: false,
            style: MyTextStyle.bodyMedium(
                color:
                contentTheme.secondary.withValues(alpha: 0.65)),
            decoration: decoMin,
          ),
        ),
        MySpacing.width(8),

        // ── Đến — có thể nhập, tự push xuống Từ của khung sau ─────
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: tier.maxQtyController,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: MyTextStyle.bodyMedium(),
            decoration: decoMax,
          ),
        ),
        MySpacing.width(8),

        // ── Giá ────────────────────────────────────────────────────
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: tier.priceController,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d*\.?\d{0,0}')),
            ],
            style: MyTextStyle.bodyMedium(),
            decoration: _inputDeco('Giá'),
          ),
        ),
        MySpacing.width(8),

        // ── Xóa ────────────────────────────────────────────────────
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
  Widget _buildActionBar(ProductEditController c) {
    final hasTierErr = c.tiers.isNotEmpty && _hasTierErrors(c.tiers);
    final hasUploadErr = c.uploadError != null;
    final isBlocked = hasTierErr || hasUploadErr;

    return Container(
      padding: MySpacing.all(20),
      decoration: BoxDecoration(
        color: contentTheme.light,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        if (hasTierErr) ...[
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Icon(Icons.error_outline, size: 14, color: contentTheme.danger),
            MySpacing.width(6),
            MyText.bodySmall(
                'Khung giá chưa hợp lệ — vui lòng kiểm tra lại',
                color: contentTheme.danger),
          ]),
          MySpacing.height(10),
        ],
        if (hasUploadErr) ...[
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Icon(Icons.image_not_supported_outlined,
                size: 14, color: contentTheme.danger),
            MySpacing.width(6),
            MyText.bodySmall('Ảnh upload lỗi — vui lòng xóa và chọn lại',
                color: contentTheme.danger),
          ]),
          MySpacing.height(10),
        ],
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
              onTap: (c.isSaving || isBlocked) ? null : c.save,
              color: contentTheme.primary,
              borderRadiusAll: 12,
              padding: MySpacing.xy(24, 12),
              child: c.isSaving
                  ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: contentTheme.onPrimary))
                  : MyText.bodyMedium('Lưu thay đổi',
                  fontWeight: 600, color: contentTheme.onPrimary),
            ),
          ),
        ]),
      ]),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────
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