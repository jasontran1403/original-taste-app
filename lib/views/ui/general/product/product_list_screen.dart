import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/services/seller_services.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';
import '../../../../controller/ui/general/product/product_list_controller.dart';
import 'product_create_screen.dart';
import 'product_edit_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> with UIMixin {
  late ProductListController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProductListController(), tag: 'product_list_controller');
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductListController>(
      tag: 'product_list_controller',
      builder: (controller) {
        return Layout(
          screenName: 'QUẢN LÝ SẢN PHẨM',
          child: MyCard(
            shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
            borderRadiusAll: 12,
            paddingAll: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableH = constraints.maxHeight.isFinite
                    ? constraints.maxHeight
                    : MediaQuery.of(context).size.height - 120;
                return SizedBox(
                  height: availableH,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const Divider(height: 0),
                      Expanded(child: _buildBody()),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: MySpacing.all(20),
      child: Row(
        children: [
          Expanded(
            child: MyText.titleMedium(
              'Tất cả sản phẩm',
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
            borderRadiusAll: 8,
            paddingAll: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: contentTheme.onPrimary, size: 16),
                MySpacing.width(4),
                MyText.labelMedium('Thêm sản phẩm',
                    fontWeight: 600, color: contentTheme.onPrimary),
              ],
            ),
          ),
          MySpacing.width(12),
          MyContainer(
            onTap: () => controller.fetchProducts(refresh: true),
            color: contentTheme.secondary.withValues(alpha: 0.1),
            paddingAll: 8,
            borderRadiusAll: 8,
            child: Icon(Icons.refresh, color: contentTheme.secondary, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────
  Widget _buildBody() {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null && controller.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: contentTheme.danger),
            MySpacing.height(12),
            MyText.bodyMedium(controller.errorMessage!,
                color: contentTheme.danger),
            MySpacing.height(12),
            MyContainer(
              onTap: () => controller.fetchProducts(refresh: true),
              color: contentTheme.primary,
              paddingAll: 10,
              borderRadiusAll: 8,
              child: MyText.bodyMedium('Thử lại',
                  color: contentTheme.onPrimary),
            ),
          ],
        ),
      );
    }

    if (controller.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64,
                color: contentTheme.secondary.withValues(alpha: 0.3)),
            MySpacing.height(16),
            MyText.bodyLarge('Chưa có sản phẩm nào', muted: true),
            MySpacing.height(12),
            MyContainer(
              onTap: _goToCreate,
              color: contentTheme.primary,
              padding: MySpacing.xy(20, 10),
              borderRadiusAll: 8,
              child: MyText.bodyMedium('Thêm sản phẩm đầu tiên',
                  color: contentTheme.onPrimary),
            ),
          ],
        ),
      );
    }

    return _buildTable();
  }

  Widget _buildTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        return SingleChildScrollView(
          controller: controller.scrollController,
          child: SizedBox(
            width: tableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: tableWidth,
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(
                        contentTheme.secondary.withAlpha(5)),
                    dataRowMaxHeight: 80,
                    columnSpacing: 24,
                    horizontalMargin: 16,
                    showBottomBorder: true,
                    columns: [
                      DataColumn(
                          label: MyText.labelLarge('Sản phẩm', fontWeight: 700)),
                      DataColumn(
                          label: MyText.labelLarge('Giá gốc',
                              fontWeight: 700)),
                      // DataColumn(
                      //     label: MyText.labelLarge('Nguyên liệu',
                      //         fontWeight: 700)),
                      DataColumn(
                          label: MyText.labelLarge('Danh mục', fontWeight: 700)),
                      DataColumn(
                          label: MyText.labelLarge('Thao tác', fontWeight: 700)),
                    ],
                    rows: List.generate(controller.products.length, (index) {
                      final p = controller.products[index];
                      return DataRow(cells: [
                        // Tên + ảnh
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildProductImage(p),
                              MySpacing.width(12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 180,
                                    child: MyText.bodyMedium(p.name,
                                        fontWeight: 600,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Giá gốc
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyText.bodyMedium(
                                _formatCurrency(p.basePrice),
                                fontWeight: 700,
                                color: contentTheme.primary,
                              ),
                            ],
                          ),
                        ),
                        // Nguyên liệu
                        // DataCell(_buildIngredientCell(p)),
                        // Danh mục — dùng categoryName (không có .category trên ProductModel)
                        DataCell(
                          MyText.bodyMedium(
                            p.categoryName ?? '--',
                            fontWeight: 500,
                          ),
                        ),
                        // Thao tác: Edit + Delete
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MyContainer(
                                onTap: () => _goToEdit(p),
                                color: contentTheme.primary
                                    .withValues(alpha: 0.1),
                                padding: MySpacing.xy(12, 8),
                                borderRadiusAll: 8,
                                child: SvgPicture.asset('assets/svg/pen_2.svg',
                                    height: 16, width: 16),
                              ),
                              MySpacing.width(8),
                              // MyContainer(
                              //   onTap: () =>
                              //       controller.deleteProduct(p.id, p.name),
                              //   color: contentTheme.danger
                              //       .withValues(alpha: 0.1),
                              //   padding: MySpacing.xy(12, 8),
                              //   borderRadiusAll: 8,
                              //   child: SvgPicture.asset(
                              //     'assets/svg/trash_bin_2.svg',
                              //     height: 16,
                              //     width: 16,
                              //     colorFilter: ColorFilter.mode(
                              //         contentTheme.danger, BlendMode.srcIn),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ]);
                    }),
                  ),
                ),
                // Load more / end indicator
                if (controller.isLoadingMore)
                  Padding(
                    padding: MySpacing.xy(0, 16),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                if (!controller.hasMore && controller.products.isNotEmpty)
                  Padding(
                    padding: MySpacing.xy(0, 16),
                    child: Center(
                      child: MyText.bodySmall(
                        'Đã hiển thị tất cả ${controller.products.length} sản phẩm',
                        muted: true,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Image cell ────────────────────────────────────────────────────
  Widget _buildProductImage(ProductModel p) {
    final url = p.imageUrl != null
        ? SellerService.buildImageUrl(p.imageUrl!)
        : null;
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
          errorBuilder: (_, __, ___) => _imgPlaceholder(),
        ),
      )
          : _imgPlaceholder(),
    );
  }

  Widget _imgPlaceholder() => Center(
    child: Icon(Icons.fastfood_outlined,
        size: 24,
        color: contentTheme.secondary.withValues(alpha: 0.4)),
  );

  // ── Ingredient cell ───────────────────────────────────────────────
  Widget _buildIngredientCell(ProductModel p) {
    if (p.variants.isNotEmpty && p.variants.first.ingredients.isNotEmpty) {
      final ing = p.variants.first.ingredients.first;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            child: MyText.bodySmall(ing.ingredientName,
                fontWeight: 600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    }
    return MyText.bodySmall('--', muted: true);
  }

  // ── Helpers ───────────────────────────────────────────────────────
  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M đ';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K đ';
    }
    return '${value.toStringAsFixed(0)} đ';
  }

  Future<void> _goToCreate() async {
    await Get.to(() => const ProductCreateScreen());
    controller.fetchProducts(refresh: true); // luôn refresh khi quay về
  }

  Future<void> _goToEdit(ProductModel p) async {
    await Get.to(() => const ProductEditScreen(), arguments: p);
    controller.fetchProducts(refresh: true); // luôn refresh khi quay về
  }
}