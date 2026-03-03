import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/services/seller_services.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:original_taste/views/ui/general/orders/price_picker_modal.dart';

import '../../../../controller/seller/order_cart_controller.dart';
import 'custom_picker_modal.dart';

class OrderCartScreen extends StatefulWidget {
  const OrderCartScreen({super.key});

  @override
  State<OrderCartScreen> createState() => _OrderCartScreenState();
}

class _OrderCartScreenState extends State<OrderCartScreen> with UIMixin {
  late OrderCartController controller;
  final searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      OrderCartController(),
      tag: 'order_cart_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    // Giảm cart xuống 32%, tăng không gian product
    final cartH = screenH * 0.32;

    return GetBuilder<OrderCartController>(
      init: controller,
      builder: (ctrl) {
        return Layout(
          screenName: 'TẠO ĐƠN HÀNG',
          child: Column(
            children: [
              // ── CART (32% height) ──────────────────────────────
              SizedBox(
                height: cartH,
                child: MyCard(
                  shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
                  borderRadiusAll: 12,
                  paddingAll: 0,
                  child: Column(
                    children: [
                      _buildCartHeader(ctrl),
                      const Divider(height: 0),
                      Expanded(child: _buildCartBody(ctrl)),
                      const Divider(height: 0),
                      _buildCartSummary(ctrl),   // 2×2 grid
                      const Divider(height: 0),
                      _buildCartActions(ctrl),   // equal buttons
                    ],
                  ),
                ),
              ),

              MySpacing.height(10),

              // ── PRODUCTS (68% remaining) ───────────────────────
              Expanded(
                child: MyCard(
                  shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
                  borderRadiusAll: 12,
                  paddingAll: 0,
                  child: Column(
                    children: [
                      _buildProductHeader(ctrl),
                      _buildFilterBar(ctrl),
                      const Divider(height: 0),
                      Expanded(child: _buildProductGrid(ctrl)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════
  // CART
  // ══════════════════════════════════════════════════════

  Widget _buildCartHeader(OrderCartController ctrl) {
    return Padding(
      padding: MySpacing.xy(16, 9),
      child: Row(children: [
        Icon(Icons.shopping_cart_outlined, size: 17, color: contentTheme.primary),
        MySpacing.width(7),
        Expanded(
          child: MyText.titleSmall(
            'Giỏ hàng (${ctrl.cartItems.length} món)',
            style: TextStyle(
              fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (ctrl.cartItems.isNotEmpty)
          GestureDetector(
            onTap: () => _confirmClearCart(ctrl),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.delete_outline, size: 15, color: contentTheme.danger),
              MySpacing.width(3),
              MyText.labelSmall('Xóa tất cả', color: contentTheme.danger),
            ]),
          ),
      ]),
    );
  }

  Widget _buildCartBody(OrderCartController ctrl) {
    if (ctrl.cartItems.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.shopping_cart_outlined,
              size: 32, color: contentTheme.secondary.withValues(alpha: 0.2)),
          MySpacing.height(4),
          MyText.bodySmall('Giỏ hàng trống', muted: true),
          MyText.labelSmall('Chọn sản phẩm bên dưới để thêm vào', muted: true),
        ]),
      );
    }

    return ListView.separated(
      padding: MySpacing.xy(0, 2),
      itemCount: ctrl.cartItems.length,
      separatorBuilder: (_, __) =>
          Divider(height: 0, color: contentTheme.secondary.withValues(alpha: 0.1)),
      itemBuilder: (_, i) => _buildCartRow(ctrl, i),
    );
  }

  Widget _buildCartRow(OrderCartController ctrl, int index) {
    final item = ctrl.cartItems[index];
    return Padding(
      padding: MySpacing.xy(12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: item.product.imageUrl != null
                ? Image.network(
              SellerService.buildImageUrl(item.product.imageUrl!),
              width: 34, height: 34, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _cartThumb(),
            )
                : _cartThumb(),
          ),
          MySpacing.width(8),
          // Name + price label
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                MyText.bodySmall(item.product.name,
                    fontWeight: 600, maxLines: 1, overflow: TextOverflow.ellipsis),
                MyText.labelSmall(
                  '${item.price.priceName} · ${ctrl.formatCurrency(item.price.price)}',
                  muted: true,
                ),
              ],
            ),
          ),
          // Qty
          _buildQtyControl(ctrl, item),
          MySpacing.width(6),
          // Subtotal
          SizedBox(
            width: 66,
            child: MyText.bodySmall(
              ctrl.formatCurrency(item.subtotal),
              fontWeight: 700,
              color: contentTheme.primary,
              textAlign: TextAlign.right,
            ),
          ),
          MySpacing.width(4),
          GestureDetector(
            onTap: () => ctrl.removeFromCart(index),
            child: Icon(Icons.close, size: 15, color: contentTheme.danger),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyControl(OrderCartController ctrl, CartItem item) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      _qtyBtn(icon: Icons.remove, onTap: () => ctrl.decrementQty(item), color: contentTheme.secondary),
      SizedBox(
        width: 46,
        child: TextFormField(
          controller: item.qtyController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [OrderCartController.qtyFormatter],
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: contentTheme.primary, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.3)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            isDense: true,
            isCollapsed: true,
          ),
          onTap: () => ctrl.onQtyTap(item),
          onChanged: (v) => ctrl.onQtyChanged(item, v),
          onFieldSubmitted: (_) => ctrl.onQtySubmitted(item),
          onEditingComplete: () => ctrl.onQtySubmitted(item),
        ),
      ),
      _qtyBtn(icon: Icons.add, onTap: () => ctrl.incrementQty(item), color: contentTheme.primary),
    ]);
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap, required Color color}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(icon, size: 13, color: color),
        ),
      );

  Widget _cartThumb() => Container(
    width: 34, height: 34,
    decoration: BoxDecoration(
      color: contentTheme.secondary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Icon(Icons.fastfood_outlined, size: 16, color: contentTheme.secondary.withValues(alpha: 0.4)),
  );

  // ── Summary 2×2 grid ─────────────────────────────────────────────
  Widget _buildCartSummary(OrderCartController ctrl) {
    final discountRate = ctrl.selectedCustomer?.discountRate ?? 0;
    final vatLabel = switch (ctrl.vatRate) {
      'FIVE'  => 'VAT 5%',
      'EIGHT' => 'VAT 8%',
      'TEN'   => 'VAT 10%',
      _       => 'VAT 0%',
    };

    return Padding(
      padding: MySpacing.xy(14, 8),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Cột trái: Tạm tính + Chiết khấu ─────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _summaryRow(
                    label: 'Tạm tính',
                    value: ctrl.formatCurrency(ctrl.subtotal),
                  ),
                  MySpacing.height(5),
                  _summaryRow(
                    label: 'Chiết khấu${discountRate > 0 ? ' ($discountRate%)' : ''}',
                    value: discountRate > 0
                        ? '- ${ctrl.formatCurrency(ctrl.discountAmount)}'
                        : '--',
                    valueColor: discountRate > 0 ? contentTheme.danger : null,
                  ),
                ],
              ),
            ),

            // divider dọc
            Container(
              width: 1,
              margin: MySpacing.xy(12, 2),
              color: contentTheme.secondary.withValues(alpha: 0.15),
            ),

            // ── Cột phải: VAT + Tổng cộng ────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _summaryRow(
                    label: vatLabel,
                    value: ctrl.vatRate != 'ZERO'
                        ? '+ ${ctrl.formatCurrency(ctrl.vatAmount)}'
                        : '--',
                    valueColor: ctrl.vatRate != 'ZERO' ? contentTheme.warning : null,
                  ),
                  MySpacing.height(5),
                  _summaryRow(
                    label: 'Tổng cộng',
                    value: ctrl.formatCurrency(ctrl.grandTotal),
                    valueColor: contentTheme.primary,
                    bold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow({
    required String label,
    required String value,
    Color? valueColor,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: MyText.labelSmall(label,
              muted: !bold && valueColor == null,
              fontWeight: bold ? 700 : 500),
        ),
        MySpacing.width(4),
        MyText.labelSmall(
          value,
          color: valueColor,
          fontWeight: bold ? 700 : 600,
        ),
      ],
    );
  }

  // ── Action buttons — EQUAL width (flex 1 each) ───────────────────
  Widget _buildCartActions(OrderCartController ctrl) {
    return Padding(
      padding: MySpacing.xy(12, 8),
      child: Row(
        children: [
          // Nút Khách hàng — flex 1
          Expanded(
            child: GestureDetector(
              onTap: () => CustomerPickerModal.show(context, ctrl),
              child: Container(
                padding: MySpacing.xy(8, 10),
                decoration: BoxDecoration(
                  color: ctrl.selectedCustomer != null
                      ? contentTheme.success.withValues(alpha: 0.08)
                      : contentTheme.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ctrl.selectedCustomer != null
                        ? contentTheme.success.withValues(alpha: 0.5)
                        : contentTheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      ctrl.selectedCustomer != null
                          ? Icons.person_outline
                          : Icons.person_add_outlined,
                      size: 16,
                      color: ctrl.selectedCustomer != null
                          ? contentTheme.success
                          : contentTheme.secondary,
                    ),
                    MySpacing.width(5),
                    Flexible(
                      child: MyText.bodySmall(
                        ctrl.selectedCustomer != null
                            ? ctrl.selectedCustomer!.name
                            : 'Khách hàng',
                        color: ctrl.selectedCustomer != null
                            ? contentTheme.success
                            : contentTheme.secondary,
                        fontWeight: 600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          MySpacing.width(10),

          // Nút Tạo đơn — flex 1 (EQUAL)
          Expanded(
            child: GestureDetector(
              onTap: ctrl.canCreateOrder ? ctrl.submitOrder : null,
              child: Container(
                padding: MySpacing.xy(8, 10),
                decoration: BoxDecoration(
                  color: ctrl.canCreateOrder
                      ? contentTheme.primary
                      : contentTheme.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (ctrl.isSubmitting)
                      SizedBox(
                        height: 15, width: 15,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: contentTheme.onPrimary),
                      )
                    else
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: ctrl.canCreateOrder
                            ? contentTheme.onPrimary
                            : contentTheme.secondary,
                      ),
                    MySpacing.width(5),
                    MyText.bodySmall(
                      ctrl.isSubmitting ? 'Đang tạo...' : 'Tạo đơn hàng',
                      fontWeight: 700,
                      color: ctrl.canCreateOrder
                          ? contentTheme.onPrimary
                          : contentTheme.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // PRODUCTS
  // ══════════════════════════════════════════════════════

  Widget _buildProductHeader(OrderCartController ctrl) {
    return Padding(
      padding: MySpacing.xy(16, 12),
      child: Row(children: [
        Icon(Icons.grid_view_outlined, size: 17, color: contentTheme.primary),
        MySpacing.width(7),
        Expanded(
          child: MyText.titleSmall(
            'Sản phẩm (${ctrl.filteredProducts.length})',
            style: TextStyle(
              fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GestureDetector(
          onTap: ctrl.refreshProducts,
          child: Icon(Icons.refresh, size: 17, color: contentTheme.secondary),
        ),
      ]),
    );
  }

  Widget _buildFilterBar(OrderCartController ctrl) {
    return Padding(
      padding: MySpacing.xy(12, 0).copyWith(bottom: 10),
      child: Column(children: [
        // Search
        TextField(
          controller: searchCtrl,
          onChanged: ctrl.onSearch,
          style: MyTextStyle.bodySmall(),
          decoration: InputDecoration(
            hintText: 'Tìm tên sản phẩm...',
            hintStyle: MyTextStyle.bodySmall(muted: true),
            prefixIcon: Icon(Icons.search, size: 17, color: contentTheme.secondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: contentTheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            isDense: true,
            isCollapsed: true,
          ),
        ),
        MySpacing.height(8),
        // Chips row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _filterChip('Tất cả', ctrl.selectedCategory == null, () => ctrl.onSelectCategory(null)),
            ...ctrl.categories.map((c) => _filterChip(
                c.name, ctrl.selectedCategory?.id == c.id, () => ctrl.onSelectCategory(c))),
            const SizedBox(width: 10),
            Container(width: 1, height: 18, color: contentTheme.secondary.withValues(alpha: 0.25)),
            const SizedBox(width: 10),
            _sortChip(ctrl, 'name_asc',   Icons.sort_by_alpha,   'A→Z'),
            _sortChip(ctrl, 'name_desc',  Icons.sort_by_alpha,   'Z→A'),
            _sortChip(ctrl, 'price_asc',  Icons.arrow_upward,    'Giá thấp'),
            _sortChip(ctrl, 'price_desc', Icons.arrow_downward,  'Giá cao'),
          ]),
        ),
      ]),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? contentTheme.primary : contentTheme.secondary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? contentTheme.primary : contentTheme.secondary.withValues(alpha: 0.22),
          ),
        ),
        child: MyText.labelSmall(label,
            color: selected ? contentTheme.onPrimary : null,
            fontWeight: selected ? 700 : 500),
      ),
    );
  }

  Widget _sortChip(OrderCartController ctrl, String mode, IconData icon, String label) {
    final sel = ctrl.sortMode == mode;
    return GestureDetector(
      onTap: () => ctrl.onSortMode(mode),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: sel ? contentTheme.info.withValues(alpha: 0.10) : contentTheme.secondary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? contentTheme.info.withValues(alpha: 0.45) : contentTheme.secondary.withValues(alpha: 0.18),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: sel ? contentTheme.info : contentTheme.secondary),
          const SizedBox(width: 3),
          MyText.labelSmall(label, color: sel ? contentTheme.info : null, fontWeight: sel ? 700 : 500),
        ]),
      ),
    );
  }

  Widget _buildProductGrid(OrderCartController ctrl) {
    if (ctrl.isLoadingProducts) return const Center(child: CircularProgressIndicator());
    if (ctrl.filteredProducts.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search_off, size: 40, color: contentTheme.secondary.withValues(alpha: 0.3)),
        MySpacing.height(8),
        MyText.bodyMedium('Không tìm thấy sản phẩm', muted: true),
      ]));
    }

    final w = MediaQuery.of(context).size.width;
    final cols = w < 600 ? 2 : w < 900 ? 3 : 4;

    return GridView.builder(
      padding: MySpacing.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.70,   // card cao hơn cho phần product
      ),
      itemCount: ctrl.filteredProducts.length,
      itemBuilder: (_, i) => _buildProductCard(ctrl, ctrl.filteredProducts[i]),
    );
  }

  Widget _buildProductCard(OrderCartController ctrl, ProductModel product) {
    final inCart = ctrl.cartItems
        .where((c) => c.product.id == product.id)
        .fold<double>(0, (s, c) => s + c.quantity);

    return GestureDetector(
      onTap: () async {
        final price = await PricePickerDialog.show(context, product);
        if (price != null) ctrl.addToCart(product, price);
      },
      child: Container(
        decoration: BoxDecoration(
          color: inCart > 0
              ? contentTheme.primary.withValues(alpha: 0.04)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: inCart > 0
                ? contentTheme.primary.withValues(alpha: 0.4)
                : contentTheme.secondary.withValues(alpha: 0.15),
            width: inCart > 0 ? 1.5 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image — flex 6 (tall)
            Expanded(
              flex: 6,
              child: Stack(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  child: product.imageUrl != null
                      ? Image.network(
                    SellerService.buildImageUrl(product.imageUrl!),
                    width: double.infinity, height: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _prodImgPlaceholder(),
                  )
                      : _prodImgPlaceholder(),
                ),
                if (inCart > 0)
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(color: contentTheme.primary, borderRadius: BorderRadius.circular(10)),
                      child: MyText.labelSmall(
                        '×${inCart % 1 == 0 ? inCart.toStringAsFixed(0) : inCart.toStringAsFixed(2)}',
                        color: contentTheme.onPrimary, fontWeight: 700,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 6, right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: contentTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: contentTheme.primary.withValues(alpha: 0.3), blurRadius: 6)],
                    ),
                    child: Icon(Icons.add, size: 15, color: contentTheme.onPrimary),
                  ),
                ),
              ]),
            ),
            // Info — flex 3
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.bodySmall(product.name,
                        fontWeight: 600, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    if (product.defaultPrice != null)
                      MyText.labelMedium(
                        ctrl.formatCurrency(product.defaultPrice!),
                        color: contentTheme.primary, fontWeight: 700,
                      )
                    else
                      MyText.labelSmall('Chọn giá', muted: true),
                    if (product.categoryName != null)
                      MyText.labelSmall(product.categoryName!,
                          muted: true, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prodImgPlaceholder() => Container(
    color: contentTheme.secondary.withValues(alpha: 0.08),
    child: Center(child: Icon(Icons.fastfood_outlined,
        size: 32, color: contentTheme.secondary.withValues(alpha: 0.3))),
  );

  Future<void> _confirmClearCart(OrderCartController ctrl) async {
    final ok = await Get.dialog<bool>(AlertDialog(
      title: const Text('Xóa giỏ hàng'),
      content: const Text('Xóa tất cả sản phẩm trong giỏ?'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Hủy')),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: Text('Xóa', style: TextStyle(color: contentTheme.danger)),
        ),
      ],
    ));
    if (ok == true) ctrl.clearCart();
  }
}