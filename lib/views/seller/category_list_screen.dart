import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

import '../../controller/ui/general/category/category_list_controller.dart';
import '../../helper/services/seller_services.dart';
import '../ui/general/category/category_create_screen.dart';
import '../ui/general/category/category_edit_screen.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> with UIMixin {
  late CategoryListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CategoryListController());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'category_list_controller',
      builder: (controller) {
        return Layout(
          screenName: "QUẢN LÝ DANH MỤC",
          child: MyFlex(
            children: [
              MyFlexItem(child: _buildSummaryCards()),
              MyFlexItem(child: _buildCategoryTable()),
            ],
          ),
        );
      },
    );
  }

  // ── Summary cards ─────────────────────────────────────────────────
  Widget _buildSummaryCards() {
    final total = controller.categoryList.length;
    return MyFlex(
      children: [
        MyFlexItem(sizes: 'lg-3 md-6', child: _statCard('Tổng danh mục', total.toString(), Icons.category_outlined, contentTheme.primary)),
        MyFlexItem(sizes: 'lg-3 md-6', child: _statCard('Đang hoạt động', total.toString(), Icons.check_circle_outline, contentTheme.success)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 20,
      child: Row(
        children: [
          MyContainer(
            borderRadiusAll: 10,
            color: color.withValues(alpha: 0.1),
            paddingAll: 12,
            child: Icon(icon, color: color, size: 24),
          ),
          MySpacing.width(16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.bodySmall(label, muted: true),
              MySpacing.height(4),
              MyText.titleLarge(value, fontWeight: 700),
            ],
          ),
        ],
      ),
    );
  }

  // ── Main table ────────────────────────────────────────────────────
  Widget _buildCategoryTable() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeader(),
          const Divider(height: 0),
          if (controller.isLoading)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.errorMessage != null)
            Padding(
              padding: MySpacing.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 48, color: contentTheme.danger),
                    MySpacing.height(12),
                    MyText.bodyMedium(controller.errorMessage!, color: contentTheme.danger),
                    MySpacing.height(12),
                    MyContainer(
                      onTap: controller.fetchCategories,
                      color: contentTheme.primary,
                      paddingAll: 10,
                      borderRadiusAll: 8,
                      child: MyText.bodyMedium('Thử lại', color: contentTheme.onPrimary),
                    ),
                  ],
                ),
              ),
            )
          else if (controller.categoryList.isEmpty)
              Padding(
                padding: MySpacing.all(48),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.category_outlined, size: 64, color: contentTheme.secondary.withValues(alpha: 0.3)),
                      MySpacing.height(16),
                      MyText.bodyLarge('Chưa có danh mục nào', muted: true),
                      MySpacing.height(12),
                      MyContainer(
                        onTap: _goToCreate,
                        color: contentTheme.primary,
                        padding: MySpacing.xy(20, 10),
                        borderRadiusAll: 8,
                        child: MyText.bodyMedium('Thêm danh mục đầu tiên', color: contentTheme.onPrimary),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildDataTable(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: MySpacing.all(20),
      child: Row(
        children: [
          Expanded(
            child: MyText.titleMedium(
              'Tất cả danh mục',
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
                MyText.bodyMedium('Thêm danh mục', color: contentTheme.onPrimary),
              ],
            ),
          ),
          MySpacing.width(12),
          MyContainer(
            onTap: controller.fetchCategories,
            color: contentTheme.secondary.withValues(alpha: 0.1),
            paddingAll: 8,
            borderRadiusAll: 12,
            child: Icon(Icons.refresh, color: contentTheme.secondary, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortAscending: true,
        onSelectAll: (value) => controller.toggleSelectAll(value),
        headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
        dataRowMaxHeight: 80,
        columnSpacing: 80,
        showBottomBorder: true,
        columns: [
          DataColumn(
            label: Theme(
              data: ThemeData(),
              child: Checkbox(
                value: controller.isAllSelected,
                activeColor: contentTheme.primary,
                visualDensity: VisualDensity.compact,
                onChanged: controller.toggleSelectAll,
              ),
            ),
          ),
          DataColumn(label: MyText.labelLarge('Tên danh mục', fontWeight: 700)),
          DataColumn(label: MyText.labelLarge('Ngày tạo', fontWeight: 700)),
          DataColumn(label: MyText.labelLarge('Trạng thái', fontWeight: 700)),
          DataColumn(label: MyText.labelLarge('Thao tác', fontWeight: 700)),
        ],
        rows: List.generate(controller.categoryList.length, (index) {
          final cat = controller.categoryList[index];
          return DataRow(
            cells: [
              DataCell(
                Theme(
                  data: ThemeData(),
                  child: Checkbox(
                    value: controller.selectedCheckboxes[index],
                    activeColor: contentTheme.primary,
                    visualDensity: VisualDensity.compact,
                    onChanged: (value) => controller.toggleCheckbox(index, value),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    _buildCategoryImage(cat),
                    MySpacing.width(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText.bodyMedium(cat.name, fontWeight: 600),
                        MyText.bodySmall('ID: ${cat.id}', muted: true),
                      ],
                    ),
                  ],
                ),
              ),
              DataCell(MyText.bodyMedium(
                cat.createdAt != null
                    ? _formatDate(cat.createdAt!)
                    : '--',
                fontWeight: 500,
              )),
              DataCell(
                MyContainer(
                  color: (cat.isActive ? contentTheme.success : contentTheme.danger)
                      .withValues(alpha: 0.1),
                  padding: MySpacing.xy(10, 5),
                  borderRadiusAll: 20,
                  child: MyText.bodySmall(
                    cat.isActive ? 'Hoạt động' : 'Ẩn',
                    color: cat.isActive ? contentTheme.success : contentTheme.danger,
                    fontWeight: 600,
                  ),
                ),
              ),
              DataCell(
                Row(
                  spacing: 8,
                  children: [
                    // Edit
                    MyContainer(
                      onTap: () => _goToEdit(cat),
                      color: contentTheme.primary.withValues(alpha: 0.1),
                      padding: MySpacing.xy(12, 8),
                      borderRadiusAll: 8,
                      child: SvgPicture.asset('assets/svg/pen_2.svg', height: 16, width: 16),
                    ),
                    // Delete
                    MyContainer(
                      onTap: () => controller.deleteCategory(cat.id, cat.name),
                      color: contentTheme.danger.withValues(alpha: 0.1),
                      padding: MySpacing.xy(12, 8),
                      borderRadiusAll: 8,
                      child: SvgPicture.asset(
                        'assets/svg/trash_bin_2.svg',
                        height: 16,
                        width: 16,
                        colorFilter: ColorFilter.mode(contentTheme.danger, BlendMode.srcIn),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategoryImage(CategoryModel cat) {
    final url = cat.imageUrl != null ? SellerService.buildImageUrl(cat.imageUrl!) : null;
    return MyContainer(
      height: 56,
      width: 56,
      paddingAll: 0,
      borderRadiusAll: 10,
      color: contentTheme.light,
      child: url != null && url.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderIcon(),
        ),
      )
          : _placeholderIcon(),
    );
  }

  Widget _placeholderIcon() => Center(
    child: Icon(Icons.category_outlined, size: 24, color: contentTheme.secondary.withValues(alpha: 0.5)),
  );

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  // ── Navigation ────────────────────────────────────────────────────
  Future<void> _goToCreate() async {
    final result = await Get.to(() => const CategoryCreateScreen());
    if (result == true) controller.fetchCategories();
  }

  Future<void> _goToEdit(CategoryModel cat) async {
    final result = await Get.to(() => const CategoryEditScreen(), arguments: cat);
    if (result == true) controller.fetchCategories();
  }
}