// views/ui/general/ingredient/ingredient_create_screen.dart
import 'package:flutter/material.dart';
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

import '../../../../controller/seller/ingredient_create_controller.dart';

// Danh sách đơn vị dùng chung cho Create & Edit
const kIngredientUnits = [
  'Kg', 'g', 'lít', 'ml', 'cái', 'hộp', 'túi', 'gói', 'chai', 'lon', 'thùng', 'bó',
];

class IngredientCreateScreen extends StatefulWidget {
  const IngredientCreateScreen({super.key});

  @override
  State<IngredientCreateScreen> createState() => _IngredientCreateScreenState();
}

class _IngredientCreateScreenState extends State<IngredientCreateScreen>
    with UIMixin, WidgetsBindingObserver {
  late IngredientCreateController controller;
  late OutlineInputBorder _outlineInputBorder;

  // Đơn vị được chọn — mặc định kg
  String _selectedUnit = 'Kg';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(
      IngredientCreateController(),
      tag: 'ingredient_create_${DateTime.now().millisecondsSinceEpoch}',
    );
    // Đồng bộ controller ban đầu
    controller.unitController.text = _selectedUnit;

    _outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.4)),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IngredientCreateController>(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "THÊM NGUYÊN LIỆU",
          child: Form(
            key: controller.formKey,
            child: MyFlex(
              children: [
                MyFlexItem(
                  sizes: 'lg-12',
                  child: Column(
                    children: [
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

  Widget _buildGeneralInfo() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────
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
                  'Thông tin nguyên liệu',
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

          // ── Fields ──────────────────────────────────────────
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              children: [
                // Tên nguyên liệu
                _buildTextField(
                  controller: controller.nameController,
                  label: 'Tên nguyên liệu *',
                  hint: 'Nhập tên nguyên liệu',
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập tên nguyên liệu'
                      : null,
                ),
                MySpacing.height(16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Đơn vị — Dropdown
                    Expanded(
                      child: _buildUnitDropdown(),
                    ),
                    MySpacing.width(16),
                    // Tồn kho
                    Expanded(
                      child: _buildTextField(
                        controller: controller.stockQuantityController,
                        label: 'Tồn kho *',
                        hint: '0',
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Vui lòng nhập số lượng';
                          if (double.tryParse(v) == null)
                            return 'Số lượng không hợp lệ';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium('Đơn vị *'),
        MySpacing.height(8),
        InputDecorator(
          decoration: InputDecoration(
            border: _outlineInputBorder,
            focusedBorder: _outlineInputBorder,
            enabledBorder: _outlineInputBorder,
            contentPadding: MySpacing.all(14),
            isDense: true,
            isCollapsed: true,
            filled: true,
            fillColor: Colors.grey.shade100, // nền xám nhạt để trông "disabled"
          ),
          child: Text(
            'kg',  // Cố định đơn vị là kg
            style: MyTextStyle.bodyMedium(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(label),
        MySpacing.height(8),
        TextFormField(
          controller: controller,
          style: MyTextStyle.bodyMedium(),
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            border: _outlineInputBorder,
            focusedBorder: _outlineInputBorder,
            enabledBorder: _outlineInputBorder,
            errorBorder: _outlineInputBorder,
            focusedErrorBorder: _outlineInputBorder,
            contentPadding: MySpacing.all(16),
            isDense: true,
            isCollapsed: true,
            hintText: hint,
            hintStyle: MyTextStyle.bodyMedium(muted: true),
          ),
        ),
      ],
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
                  strokeWidth: 2, color: contentTheme.onPrimary),
            )
                : MyText.bodyMedium('Lưu nguyên liệu',
                fontWeight: 600, color: contentTheme.onPrimary),
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