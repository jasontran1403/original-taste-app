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
    return GetBuilder(
      init: controller,
      tag: 'category_list_controller',
      builder: (controller) {
        return Layout(
          screenName: "QUẢN LÝ DANH MỤC",
          child: Padding(
            padding: MySpacing.all(20),
            child: _buildCategoryTable(),
          ),
        );
      },
    );
  }

  Widget _buildCategoryTable() {
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
              ),
            )
          else if (controller.categoryList.isEmpty)
              Padding(
                padding: MySpacing.all(48),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category_outlined, size: 64,
                          color: contentTheme.secondary.withValues(alpha: 0.3)),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              sortAscending: true,
              headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(4)),
              dataRowMaxHeight: 80,
              columnSpacing: 80,
              showBottomBorder: true,
              columns: const [
                DataColumn(label: Text('Tên danh mục')),
                DataColumn(label: Text('Ngày tạo')),
                DataColumn(label: Text('Trạng thái')),
                DataColumn(
                  label: Text('Thao tác'),
                  headingRowAlignment: MainAxisAlignment.end,
                ),
              ],
              rows: List.generate(controller.categoryList.length, (index) {
                final cat = controller.categoryList[index];
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          _buildCategoryImage(cat),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(Text(
                      cat.createdAt != null ? _formatDate(cat.createdAt!) : '--',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    )),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: (cat.isActive ? Colors.green : Colors.red).withOpacity(0.1),
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
                    DataCell(
                      Container(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () => _goToEdit(cat),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // InkWell(
                            //   onTap: () => print("Placeholder image"),
                            //   child: Container(
                            //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            //     decoration: BoxDecoration(
                            //       color: Colors.red.withOpacity(0.1),
                            //       borderRadius: BorderRadius.circular(8),
                            //     ),
                            //     child: const Icon(Icons.delete, size: 16, color: Colors.red),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryImage(CategoryModel cat) {
    final url =
    cat.imageUrl != null ? SellerService.buildImageUrl(cat.imageUrl!) : null;
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
    child: Icon(Icons.category_outlined,
        size: 24, color: contentTheme.secondary.withValues(alpha: 0.5)),
  );

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _goToCreate() async {
    await Get.to(
          () => const CategoryCreateScreen()
    )?.then((result) async {
      await controller.fetchCategories();
    });
  }

  Future<void> _goToEdit(CategoryModel cat) async {
    await Get.to(
          () => const CategoryEditScreen(),
      arguments: cat,
    )?.then((result) async {
      await controller.fetchCategories();
    });
  }
}