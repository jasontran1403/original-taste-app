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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GetBuilder<ProductListController>(
      tag: 'product_list_controller',
      builder: (controller) {
        return Layout(
          screenName: 'QUẢN LÝ SẢN PHẨM',
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: MySpacing.all(16),
                  child: MyCard(
                    shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
                    borderRadiusAll: 12,
                    paddingAll: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(isMobile),
                        const Divider(height: 0),
                        Expanded(child: _buildBody(isMobile)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────
  Widget _buildHeader(bool isMobile) {
    return Padding(
      padding: MySpacing.all(16),
      child: Row(
        children: [
          Expanded(
            child: MyText.titleMedium(
              'Tất cả sản phẩm',
              style: TextStyle(
                fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Tooltip(
            message: 'Thêm sản phẩm',
            child: MyContainer(
              onTap: _goToCreate,
              color: contentTheme.primary,
              borderRadiusAll: 8,
              paddingAll: 9,
              child: Icon(Icons.add, color: contentTheme.onPrimary, size: 18),
            ),
          ),
          MySpacing.width(6),
          Tooltip(
            message: 'Làm mới',
            child: MyContainer(
              onTap: () => controller.fetchProducts(refresh: true),
              color: contentTheme.secondary.withValues(alpha: 0.1),
              paddingAll: 9,
              borderRadiusAll: 8,
              child: Icon(Icons.refresh, color: contentTheme.secondary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Body states ───────────────────────────────────────────────────
  Widget _buildBody(bool isMobile) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null && controller.products.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 48, color: contentTheme.danger),
          MySpacing.height(12),
          MyText.bodyMedium(controller.errorMessage!, color: contentTheme.danger),
          MySpacing.height(12),
          MyContainer(
            onTap: () => controller.fetchProducts(refresh: true),
            color: contentTheme.primary,
            paddingAll: 10,
            borderRadiusAll: 8,
            child: MyText.bodyMedium('Thử lại', color: contentTheme.onPrimary),
          ),
        ]),
      );
    }

    if (controller.products.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
        ]),
      );
    }

    return _buildScrollableTable(isMobile);
  }

  // ── Scrollable table ──────────────────────────────────────────────
  Widget _buildScrollableTable(bool isMobile) {
    return Column(
      children: [
        // Sticky column header
        Container(
          color: contentTheme.secondary.withAlpha(12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(children: [
            Expanded(
              flex: 5,
              child: MyText.labelLarge('Sản phẩm', fontWeight: 700),
            ),
            if (!isMobile) ...[
              SizedBox(
                width: 90,
                child: MyText.labelLarge('Giá gốc', fontWeight: 700),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: MyText.labelLarge('Danh mục', fontWeight: 700),
                ),
              ),
            ],
            const SizedBox(width: 48),
          ]),
        ),
        const Divider(height: 0),

        // Scrollable rows via ListView
        Expanded(
          child: ListView.builder(
            controller: controller.scrollController,
            itemCount: controller.products.length +
                (controller.isLoadingMore ? 1 : 0) +
                (!controller.hasMore && controller.products.isNotEmpty ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < controller.products.length) {
                return Column(children: [
                  _buildRow(controller.products[index], isMobile),
                  Divider(
                      height: 0,
                      color: contentTheme.secondary.withAlpha(20)),
                ]);
              }
              if (controller.isLoadingMore) {
                return Padding(
                  padding: MySpacing.xy(0, 16),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              return Padding(
                padding: MySpacing.xy(0, 16),
                child: Center(
                  child: MyText.bodySmall(
                    'Đã hiển thị tất cả ${controller.products.length} sản phẩm',
                    muted: true,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Data row ──────────────────────────────────────────────────────
  Widget _buildRow(ProductModel p, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        // ── Ảnh + tên ─────────────────────────────────────────
        Expanded(
          flex: 5,
          child: Row(children: [
            _buildProductImage(p),
            MySpacing.width(10),
            Expanded(
              child: MyText.bodyMedium(p.name,
                  fontWeight: 600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        ),

        // ── Giá gốc (desktop only) ─────────────────────────────
        if (!isMobile)
          SizedBox(
            width: 90,
            child: MyText.bodyMedium(
              _formatCurrency(p.basePrice),
              fontWeight: 700,
              color: contentTheme.primary,
            ),
          ),

        // ── Danh mục (desktop only) ────────────────────────────
        if (!isMobile)
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: MyText.bodyMedium(
                p.categoryName ?? '--',
                fontWeight: 500,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

        // ── Thao tác ──────────────────────────────────────────
        SizedBox(
          width: 48,
          child: MyContainer(
            onTap: () => _goToEdit(p),
            color: contentTheme.primary.withValues(alpha: 0.1),
            padding: MySpacing.xy(10, 8),
            borderRadiusAll: 8,
            child: SvgPicture.asset('assets/svg/pen_2.svg',
                height: 16, width: 16),
          ),
        ),
      ]),
    );
  }

  // ── Image cell ────────────────────────────────────────────────────
  Widget _buildProductImage(ProductModel p) {
    final url =
    p.imageUrl != null ? SellerService.buildImageUrl(p.imageUrl!) : null;
    return MyContainer(
      height: 52,
      width: 52,
      paddingAll: 0,
      borderRadiusAll: 10,
      color: contentTheme.light,
      child: url != null && url.isNotEmpty
          ? ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(url,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imgPlaceholder()),
      )
          : _imgPlaceholder(),
    );
  }

  Widget _imgPlaceholder() => Center(
    child: Icon(Icons.fastfood_outlined,
        size: 24, color: contentTheme.secondary.withValues(alpha: 0.4)),
  );

  // ── Helpers ───────────────────────────────────────────────────────
  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(0).split('');
    final buffer = StringBuffer();
    final len = parts.length;
    for (int i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buffer.write('.');
      buffer.write(parts[i]);
    }
    return buffer.toString();
  }

  Future<void> _goToCreate() async {
    await Get.to(() => const ProductCreateScreen());
    controller.fetchProducts(refresh: true);
  }

  Future<void> _goToEdit(ProductModel p) async {
    await Get.to(() => const ProductEditScreen(), arguments: p);
    controller.fetchProducts(refresh: true);
  }
}