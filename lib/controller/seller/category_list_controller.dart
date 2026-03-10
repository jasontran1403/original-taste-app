import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

import '../../../../controller/ui/general/category/category_list_controller.dart';
import '../../../../helper/services/seller_services.dart';
import '../../views/ui/general/category/category_create_screen.dart';
import '../../views/ui/general/category/category_edit_screen.dart';

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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GetBuilder(
      init: controller,
      tag: 'category_list_controller',
      builder: (controller) {
        return Layout(
          screenName: "QUẢN LÝ DANH MỤC",
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: MySpacing.all(20),
                  child: _buildCategoryTable(isMobile),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Card wrapper ───────────────────────────────────────────────────

  Widget _buildCategoryTable(bool isMobile) {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTableHeader(),
          const Divider(height: 0),
          Expanded(child: _buildBody(isMobile)),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          Tooltip(
            message: 'Thêm danh mục',
            child: MyContainer(
              onTap: _goToCreate,
              color: contentTheme.primary,
              paddingAll: 9,
              borderRadiusAll: 10,
              child: Icon(Icons.add, color: contentTheme.onPrimary, size: 18),
            ),
          ),
          MySpacing.width(6),
          Tooltip(
            message: 'Làm mới',
            child: MyContainer(
              onTap: controller.fetchCategories,
              color: contentTheme.secondary.withValues(alpha: 0.1),
              paddingAll: 9,
              borderRadiusAll: 10,
              child: Icon(Icons.refresh, color: contentTheme.secondary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body states ────────────────────────────────────────────────────

  Widget _buildBody(bool isMobile) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
      );
    }
    if (controller.categoryList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_outlined,
                size: 64, color: contentTheme.secondary.withValues(alpha: 0.3)),
            MySpacing.height(16),
            MyText.bodyLarge('Chưa có danh mục nào', muted: true),
            MySpacing.height(12),
            MyContainer(
              onTap: _goToCreate,
              color: contentTheme.primary,
              padding: MySpacing.xy(20, 10),
              borderRadiusAll: 8,
              child: MyText.bodyMedium('Thêm danh mục đầu tiên',
                  color: contentTheme.onPrimary),
            ),
          ],
        ),
      );
    }
    return _buildScrollableTable(isMobile);
  }

  // ── Scrollable table ───────────────────────────────────────────────

  Widget _buildScrollableTable(bool isMobile) {
    return Column(
      children: [
        // Sticky column header
        Container(
          decoration: BoxDecoration(
            color: contentTheme.secondary.withAlpha(12),
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: Row(
            children: [
              _headerCell('Tên danh mục', flex: 5, align: TextAlign.left),
              if (!isMobile) ...[
                _headerCell('Ngày tạo', flex: 2, align: TextAlign.center),
                _headerCell('Trạng thái', flex: 2, align: TextAlign.center),
              ],
              _headerCell('Thao tác', flex: 2, align: TextAlign.right),
            ],
          ),
        ),

        // Scrollable rows
        Expanded(
          child: ListView.builder(
            itemCount: controller.categoryList.length,
            itemBuilder: (context, index) {
              final cat = controller.categoryList[index];
              return _buildRow(cat, index % 2 == 0, isMobile);
            },
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String text,
      {required int flex, required TextAlign align}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: contentTheme.secondary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ── Data row ───────────────────────────────────────────────────────

  Widget _buildRow(CategoryModel cat, bool isEven, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: isEven
            ? Colors.transparent
            : contentTheme.secondary.withAlpha(4),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Tên danh mục ──────────────────────────────────────
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _buildCategoryImage(cat),
                  MySpacing.width(12),
                  Expanded(
                    child: Text(
                      cat.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: contentTheme.onBackground,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Ngày tạo (desktop only) ────────────────────────────
          if (!isMobile)
            Expanded(
              flex: 2,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  cat.createdAt != null ? _formatDate(cat.createdAt!) : '--',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: contentTheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // ── Trạng thái (desktop only) ──────────────────────────
          if (!isMobile)
            Expanded(
              flex: 2,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (cat.isActive ? Colors.green : Colors.red)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat.isActive ? 'Hoạt động' : 'Ẩn',
                      style: TextStyle(
                        color: cat.isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Thao tác ──────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () => _goToEdit(cat),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          size: 16, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────

  Widget _buildCategoryImage(CategoryModel cat) {
    final url = cat.imageUrl != null
        ? SellerService.buildImageUrl(cat.imageUrl!)
        : null;
    return MyContainer(
      height: 44,
      width: 44,
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
    child: Icon(Icons.category_outlined,
        size: 22,
        color: contentTheme.secondary.withValues(alpha: 0.5)),
  );

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _goToCreate() async {
    await Get.to(() => const CategoryCreateScreen())
        ?.then((_) async => await controller.fetchCategories());
  }

  Future<void> _goToEdit(CategoryModel cat) async {
    await Get.to(() => const CategoryEditScreen(), arguments: cat)
        ?.then((_) async => await controller.fetchCategories());
  }
}