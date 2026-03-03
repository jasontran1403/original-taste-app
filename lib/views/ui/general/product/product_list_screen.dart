import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/services/seller_services.dart';
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
          child: Padding(
            padding: MySpacing.all(20),
            child: MyCard(
              shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
              borderRadiusAll: 12,
              paddingAll: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const Divider(height: 0),
                  Expanded(
                    child: _buildBody(),
                  ),
                ],
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chỉ scroll dọc, bỏ scroll ngang
        Expanded(
          child: SingleChildScrollView(
            controller: controller.scrollController,
            scrollDirection: Axis.vertical,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 1200, // Tăng maxWidth lên
                  minWidth: MediaQuery.of(context).size.width - 80,
                ),
                child: DataTable(
                  headingRowColor: WidgetStatePropertyAll(
                      contentTheme.secondary.withAlpha(5)),
                  dataRowMaxHeight: 80,
                  columnSpacing: 24,
                  showBottomBorder: true,
                  columns: [
                    DataColumn(
                        label: MyText.labelLarge('Sản phẩm', fontWeight: 700)),
                    DataColumn(
                        label: MyText.labelLarge('Giá', fontWeight: 700)),
                    DataColumn(
                        label: MyText.labelLarge('Thao tác', fontWeight: 700)),
                  ],
                  rows: List.generate(controller.products.length, (index) {
                    final p = controller.products[index];
                    return DataRow(cells: [
                      // Cột 1: Tên + ảnh
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildProductImage(p),
                            MySpacing.width(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Cột 2: Giá (đã giảm width)
                      DataCell(
                        p.defaultPrice != null
                            ? SizedBox(
                          width: 100, // Giảm width cột giá
                          child: Text(
                            _formatCurrency(p.defaultPrice!),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: contentTheme.primary,
                              fontSize: 14,
                            ),
                          ),
                        )
                            : const Text('--'),
                      ),
                      // Cột 3: Thao tác
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MyContainer(
                              onTap: () => _goToEdit(p),
                              color: contentTheme.primary.withValues(alpha: 0.1),
                              padding: MySpacing.xy(8, 6),
                              borderRadiusAll: 6,
                              child: SvgPicture.asset(
                                'assets/svg/pen_2.svg',
                                height: 14,
                                width: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }),
                ),
              ),
            ),
          ),
        ),
        // Load more / end indicator
        if (controller.isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (!controller.hasMore && controller.products.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: MyText.bodySmall(
                'Đã hiển thị tất cả ${controller.products.length} sản phẩm',
                muted: true,
              ),
            ),
          ),
      ],
    );
  }

  // ── Image cell ────────────────────────────────────────────────────
  Widget _buildProductImage(ProductModel p) {
    final url = p.imageUrl != null
        ? SellerService.buildImageUrl(p.imageUrl!)
        : null;
    return MyContainer(
      height: 48,
      width: 48,
      paddingAll: 0,
      borderRadiusAll: 8,
      color: contentTheme.light,
      child: url != null && url.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
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
    child: Icon(
      Icons.fastfood_outlined,
      size: 20,
      color: contentTheme.secondary.withValues(alpha: 0.4),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────
  String _formatCurrency(double value) {
    return '${value.toStringAsFixed(0)} đ';
  }

  Future<void> _goToCreate() async {
    final result = await Get.to(() => const ProductCreateScreen());
    if (result == true) controller.fetchProducts(refresh: true);
  }

  Future<void> _goToEdit(ProductModel p) async {
    final result = await Get.to(() => const ProductEditScreen(), arguments: p);
    if (result == true) controller.fetchProducts(refresh: true);
  }
}