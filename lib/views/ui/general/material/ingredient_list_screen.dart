// views/ui/general/ingredient/ingredient_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

// SỬA: import đúng đường dẫn controller (UI/GENERAL)
import '../../../../controller/seller/ingredient_list_controller.dart';
import '../../../../helper/services/seller_services.dart';
import 'ingredient_create_screen.dart';
import 'ingredient_edit_screen.dart';

class IngredientListScreen extends StatefulWidget {
  const IngredientListScreen({super.key});

  @override
  State<IngredientListScreen> createState() => _IngredientListScreenState();
}

class _IngredientListScreenState extends State<IngredientListScreen> with UIMixin {
  late IngredientListController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(IngredientListController());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IngredientListController>(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "QUẢN LÝ NGUYÊN LIỆU",
          child: Padding(
            padding: MySpacing.all(20),
            child: _buildIngredientTable(),
          ),
        );
      },
    );
  }

  // THÊM method _buildTableHeader
  Widget _buildTableHeader() {
    return Padding(
      padding: MySpacing.all(20),
      child: Row(
        children: [
          Expanded(
            child: MyText.titleMedium(
              'Tất cả nguyên liệu',
              style: TextStyle(
                fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          MyContainer(
            onTap: _goToCreate,
            color: contentTheme.primary,
            paddingAll: 8,
            borderRadiusAll: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: contentTheme.onPrimary, size: 16),
                MySpacing.width(4),
                MyText.bodyMedium('Thêm nguyên liệu', color: contentTheme.onPrimary),
              ],
            ),
          ),
          MySpacing.width(12),
          MyContainer(
            onTap: () => controller.fetchIngredients(refresh: true),
            color: contentTheme.secondary.withValues(alpha: 0.1),
            paddingAll: 8,
            borderRadiusAll: 12,
            child: Icon(Icons.refresh, color: contentTheme.secondary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientTable() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTableHeader(),
          const Divider(height: 0),
          if (controller.isLoading.value && controller.ingredientList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.errorMessage.value != null)
            Padding(
              padding: MySpacing.all(32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: contentTheme.danger),
                    MySpacing.height(12),
                    MyText.bodyMedium(controller.errorMessage.value!, color: contentTheme.danger),
                    MySpacing.height(12),
                    MyContainer(
                      onTap: () => controller.fetchIngredients(refresh: true),
                      color: contentTheme.primary,
                      paddingAll: 10,
                      borderRadiusAll: 8,
                      child: MyText.bodyMedium('Thử lại', color: contentTheme.onPrimary),
                    ),
                  ],
                ),
              ),
            )
          else if (controller.ingredientList.isEmpty)
              Padding(
                padding: MySpacing.all(48),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64,
                          color: contentTheme.secondary.withValues(alpha: 0.3)),
                      MySpacing.height(16),
                      MyText.bodyLarge('Chưa có nguyên liệu nào', muted: true),
                      MySpacing.height(12),
                      MyContainer(
                        onTap: _goToCreate,
                        color: contentTheme.primary,
                        padding: MySpacing.xy(20, 10),
                        borderRadiusAll: 8,
                        child: MyText.bodyMedium('Thêm nguyên liệu đầu tiên',
                            color: contentTheme.onPrimary),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildDataTableWithPagination(),
        ],
      ),
    );
  }

  Widget _buildDataTableWithPagination() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: 500,
          ),
          child: _buildDataTable(),
        ),
        if (controller.isLoading.value && controller.ingredientList.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (!controller.hasMoreData.value)
          Padding(
            padding: const EdgeInsets.all(16),
            child: MyText.bodySmall('Đã hiển thị tất cả nguyên liệu', muted: true),
          ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Container(
      width: double.infinity, // Chiếm full width
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade200, width: 1),
          verticalInside: BorderSide(color: Colors.grey.shade200, width: 1),
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        columnWidths: {
          0: const FlexColumnWidth(2), // Tên nguyên liệu rộng nhất
          1: const FlexColumnWidth(1),    // Đơn vị - Tồn kho
          2: const FlexColumnWidth(1),    // Hạn dùng
          3: const FlexColumnWidth(1),    // Thao tác
        },
        children: [
          // Header Row
          TableRow(
            decoration: BoxDecoration(
              color: contentTheme.secondary.withAlpha(4),
            ),
            children: [
              _buildHeaderCell('Tên nguyên liệu', alignment: Alignment.centerLeft),
              _buildHeaderCell('Đơn vị - Tồn kho', alignment: Alignment.center),
              _buildHeaderCell('Hạn dùng', alignment: Alignment.center),
              _buildHeaderCell('Thao tác', alignment: Alignment.centerRight),
            ],
          ),
          // Data Rows
          ...List.generate(controller.ingredientList.length, (index) {
            final ing = controller.ingredientList[index];
            return TableRow(
              children: [
                _buildNameCell(ing),
                _buildUnitStockCell(ing),
                _buildExpiryCell(ing),
                _buildActionCell(ing),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required Alignment alignment}) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildNameCell(IngredientModel ing) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              ing.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitStockCell(IngredientModel ing) {
    return Container(
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Text(
        '${ing.stockQuantity} ${ing.unit}',
        style: const TextStyle(fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildExpiryCell(IngredientModel ing) {
    return Container(
      padding: const EdgeInsets.all(12),
      alignment: Alignment.center,
      child: Text(
        ing.expiryDate != null ? _formatDate(ing.expiryDate!) : '--',
        style: const TextStyle(fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionCell(IngredientModel ing) {
    return Container(
      padding: const EdgeInsets.all(8),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
            onTap: () => _goToEdit(ing),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.edit, size: 14, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => _confirmDelete(ing),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.delete, size: 14, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientIcon(IngredientModel ing) {
    return MyContainer(
      height: 48,
      width: 48,
      borderRadiusAll: 8,
      color: contentTheme.primary.withOpacity(0.1),
      child: const Icon(Icons.inventory_2_outlined, size: 24),
    );
  }

  Future<void> _confirmDelete(IngredientModel ing) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa nguyên liệu "${ing.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await controller.deleteIngredient(ing.id, ing.name);
      if (success) {
        Get.snackbar(
          'Thành công',
          'Đã xóa nguyên liệu "${ing.name}"',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      }
    }
  }

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _goToCreate() async {
    final result = await Get.to(() => const IngredientCreateScreen());
    if (result == true) {
      await controller.fetchIngredients(refresh: true);
      Get.snackbar(
        'Thành công',
        'Đã thêm nguyên liệu mới',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }

  Future<void> _goToEdit(IngredientModel ing) async {
    final result = await Get.to(
          () => const IngredientEditScreen(),
      arguments: ing,
    );
    if (result == true) {
      await controller.fetchIngredients(refresh: true);
      Get.snackbar(
        'Thành công',
        'Đã cập nhật nguyên liệu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    }
  }
}