import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/seller/order_cart_controller.dart';
import 'package:original_taste/helper/services/seller_services.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:original_taste/views/seller/order_history_screen.dart';
import 'package:original_taste/views/ui/general/orders/custom_picker_modal.dart';

final _ct = AdminTheme.theme.contentTheme;

class OrderCartScreen extends StatefulWidget {
  const OrderCartScreen({super.key});

  @override
  State<OrderCartScreen> createState() => _OrderCartScreenState();
}

class _OrderCartScreenState extends State<OrderCartScreen> with UIMixin {
  late OrderCartController ctrl;
  final _searchCtrl = TextEditingController();
  bool _isProductsExpanded = true;
  Timer? _debounceTimer;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(OrderCartController(), permanent: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    return GetBuilder<OrderCartController>(
      init: ctrl,
      builder: (c) => Layout(
        screenName: 'TẠO ĐƠN HÀNG',
        child: Padding(
          padding: MySpacing.all(12),
          child: isWide
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LEFT - Cart (khoảng 48-50%)
              Expanded(
                flex: 5,
                child: MyCard(
                  shadow: MyShadow(elevation: 0.4, position: MyShadowPosition.bottom),
                  borderRadiusAll: 12,
                  paddingAll: 0,
                  margin: const EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      _buildCartHeader(c),
                      const Divider(height: 0),
                      Expanded(child: _buildCartBody(c)),
                      const Divider(height: 0),
                      GetBuilder<OrderCartController>(
                        id: 'summary',
                        builder: (_) => _buildCartSummary(c),
                      ),
                      const Divider(height: 0),
                      _buildCartActions(c),
                    ],
                  ),
                ),
              ),

              // RIGHT - Products (khoảng 50-52%)
              Expanded(
                flex: 5,
                child: MyCard(
                  shadow: MyShadow(elevation: 0.4, position: MyShadowPosition.bottom),
                  borderRadiusAll: 10,
                  paddingAll: 0,
                  margin: const EdgeInsets.only(left: 4),
                  child: Column(
                    children: [
                      _buildProductHeader(c),
                      _buildFilterBar(c),
                      const Divider(height: 0),
                      Expanded(child: _buildProductGrid(c)),
                    ],
                  ),
                ),
              ),
            ],
          ) : SingleChildScrollView(
            child: Column(
              children: [
                // Cart section (trên mobile)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.55,
                  child: MyCard(
                    shadow: MyShadow(elevation: 0.4, position: MyShadowPosition.bottom),
                    borderRadiusAll: 12,
                    paddingAll: 0,
                    child: Column(
                      children: [
                        _buildCartHeader(c),
                        const Divider(height: 0),
                        Expanded(child: _buildCartBody(c)),
                        const Divider(height: 0),
                        GetBuilder<OrderCartController>(
                          id: 'summary',
                          builder: (_) => _buildCartSummary(c),
                        ),
                        const Divider(height: 0),
                        _buildCartActions(c),
                      ],
                    ),
                  ),
                ),
                MySpacing.height(16),

                // Products section (dưới mobile) - THÊM padding bottom + giảm height nhẹ
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0), // khoảng cách bottom an toàn
                  child: MyCard(
                    shadow: MyShadow(elevation: 0.4, position: MyShadowPosition.bottom),
                    borderRadiusAll: 12,
                    paddingAll: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildProductHeader(c),
                        if (_isProductsExpanded) ...[
                          _buildFilterBar(c),
                          const Divider(height: 0),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.48,  // giảm từ 0.50 → 0.48
                            child: _buildProductGrid(c),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Các phần còn lại giữ nguyên như code cũ của bạn
  // ─────────────────────────────────────────────────────────────

  Widget _buildCartHeader(OrderCartController c) {
    return Padding(
      padding: MySpacing.xy(16, 9),
      child: Row(children: [
        Icon(Icons.shopping_cart_outlined, size: 17, color: _ct.primary),
        MySpacing.width(6),
        MyText.titleSmall(
          'Giỏ hàng (${c.cartItems.length})',
          style: TextStyle(
              fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
              fontWeight: FontWeight.w700),
        ),
        MySpacing.width(12),
        _ModeToggle(ctrl: c),
        const Spacer(),
        GestureDetector(
          onTap: () => Get.to(() => const OrderHistoryScreen()),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _ct.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _ct.primary.withOpacity(0.25)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.history_rounded, size: 15, color: _ct.primary),
              MySpacing.width(4),
              MyText.labelMedium('Lịch sử', color: _ct.primary),
            ]),
          ),
        ),
        if (c.cartItems.isNotEmpty) ...[
          MySpacing.width(10),
          GestureDetector(
            onTap: () => _confirmClear(c),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.delete_outline, size: 14, color: _ct.danger),
              MySpacing.width(3),
              MyText.labelSmall('Xóa tất cả', color: _ct.danger),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildCartBody(OrderCartController c) {
    if (c.cartItems.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.shopping_cart_outlined,
              size: 32, color: _ct.secondary.withOpacity(0.2)),
          MySpacing.height(4),
          MyText.bodySmall('Giỏ hàng trống', muted: true),
          MyText.labelSmall('Chọn sản phẩm bên dưới để thêm vào', muted: true),
        ]),
      );
    }
    return ListView.separated(
      padding: MySpacing.xy(0, 2),
      itemCount: c.cartItems.length,
      separatorBuilder: (_, __) =>
          Divider(height: 0, color: _ct.secondary.withOpacity(0.1)),
      itemBuilder: (_, i) => _buildCartRow(c, i),
    );
  }

  Widget _buildCartRow(OrderCartController c, int index) {
    final item = c.cartItems[index];
    return Padding(
      padding: MySpacing.xy(12, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: item.product.imageUrl != null
                ? Image.network(
              SellerService.buildImageUrl(item.product.imageUrl!),
              width: 34,
              height: 34,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _thumb(),
            )
                : _thumb(),
          ),
          MySpacing.width(8),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible( // ← Fix tên sản phẩm dài gây tràn ngang
                  child: MyText.bodySmall(
                    item.product.name,
                    fontWeight: 600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPricePicker(c, item),
                  child: _PriceBadge(item: item, orderMode: c.orderMode),
                ),
              ],
            ),
          ),
          _buildQtyControl(c, item),
          MySpacing.width(6),
          GestureDetector(
            onTap: () => _showPricePicker(c, item),
            child: SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyText.bodySmall(
                    c.formatCurrency(item.subtotal),
                    fontWeight: 700,
                    color: _ct.primary,
                    textAlign: TextAlign.right,
                  ),
                  if (item.product.vatRate > 0) ...[
                    const SizedBox(height: 1),
                    Text(
                      'VAT ${item.product.vatRate}%',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 9,
                        color: _ct.warning.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          MySpacing.width(4),
          GestureDetector(
            onTap: () => c.removeFromCart(index),
            child: Icon(Icons.close, size: 15, color: _ct.danger),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyControl(OrderCartController c, CartItem item) {
    return IntrinsicHeight(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _qtyBtn(
            icon: Icons.remove,
            color: _ct.secondary,
            onTap: () => c.decrementQty(item)),
        const SizedBox(width: 5),
        SizedBox(
          width: 56,
          child: TextFormField(
            controller: item.qtyController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [OrderCartController.qtyFormatter],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: _ct.secondary.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: _ct.primary, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: _ct.secondary.withOpacity(0.3)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              isDense: true,
            ),
            onTap: () => c.onQtyTap(item),
            onChanged: (v) => c.onQtyChanged(item, v),
            onFieldSubmitted: (_) => c.onQtySubmitted(item),
            onEditingComplete: () => c.onQtySubmitted(item),
          ),
        ),
        const SizedBox(width: 5),
        _qtyBtn(
            icon: Icons.add,
            color: _ct.primary,
            onTap: () => c.incrementQty(item)),
      ]),
    );
  }

  Widget _qtyBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(child: Icon(icon, size: 14, color: color)),
        ),
      );

  Widget _buildCartSummary(OrderCartController c) {
    final discountRate = c.selectedCustomer?.discountRate ?? 0;
    final vatBreakdown = c.vatBreakdown;
    final hasVat = c.vatAmount > 0;

    return Padding(
      padding: MySpacing.xy(14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _summaryRow('Tạm tính', c.animSubtotal, c),
          const SizedBox(height: 6),
          _summaryRow(
            'Chiết khấu${discountRate > 0 ? ' ($discountRate%)' : ''}',
            c.animDiscount,
            c,
            prefix: discountRate > 0 ? '- ' : null,
            color: discountRate > 0 ? _ct.danger : null,
            dash: discountRate == 0,
          ),
          const SizedBox(height: 6),
          _summaryRow(
            'VAT',
            c.animVat,
            c,
            prefix: hasVat ? '+ ' : null,
            color: hasVat ? _ct.warning : null,
            dash: !hasVat,
          ),
          if (hasVat && vatBreakdown.length > 1)
            ...vatBreakdown.entries.toList()
                .map((e) => Padding(
              padding: const EdgeInsets.only(left: 10, top: 3),
              child: _summaryRow(
                'VAT ${e.key}%',
                e.value,
                c,
                prefix: '+ ',
                color: _ct.warning.withOpacity(0.7),
                small: true,
              ),
            )),
          const SizedBox(height: 8),
          Divider(height: 1, color: _ct.secondary.withOpacity(0.15)),
          const SizedBox(height: 8),
          _summaryRow('Tổng cộng', c.animGrand, c,
              bold: true, color: _ct.primary),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label,
      double value,
      OrderCartController c, {
        String? prefix,
        Color? color,
        bool bold = false,
        bool dash = false,
        bool small = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: MyText.labelSmall(
            label,
            muted: !bold && color == null,
            fontWeight: bold ? 700 : 500,
            fontSize: small ? 10 : null,
          ),
        ),
        MySpacing.width(4),
        dash
            ? MyText.labelSmall('--', muted: true)
            : MyText.labelSmall(
          '${prefix ?? ''}${c.formatCurrency(value)}đ',
          color: color,
          fontWeight: bold ? 700 : 600,
          fontSize: small ? 10 : null,
        ),
      ],
    );
  }

  Widget _buildCartActions(OrderCartController c) {
    return Padding(
      padding: MySpacing.xy(12, 8),
      child: Row(children: [
        // ── Nút chọn khách hàng (giữ nguyên UI cũ) ──────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => CustomerPickerModal.show(context, c),
            child: Container(
              padding: MySpacing.xy(8, 10),
              decoration: BoxDecoration(
                color: c.selectedCustomer != null
                    ? _ct.success.withOpacity(0.08)
                    : _ct.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: c.selectedCustomer != null
                      ? _ct.success.withOpacity(0.5)
                      : _ct.secondary.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    c.selectedCustomer != null
                        ? Icons.person_outline
                        : Icons.person_add_outlined,
                    size: 16,
                    color: c.selectedCustomer != null
                        ? _ct.success
                        : _ct.secondary,
                  ),
                  MySpacing.width(5),
                  Flexible(
                    child: MyText.bodySmall(
                      c.selectedCustomer?.name ?? 'Khách hàng',
                      color: c.selectedCustomer != null
                          ? _ct.success
                          : _ct.secondary,
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

        // ── Nút tạo đơn hàng ─────────────────────────────────────────
        Expanded(
          child: GestureDetector(
            onTap: c.canCreateOrder
                ? c.submitOrder
                : () {
              // Giỏ trống → không làm gì
              if (c.cartItems.isEmpty) return;
              // Chưa có KH → mở modal với dialog thông báo
              if (c.selectedCustomer == null) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    title: Row(children: [
                      Icon(Icons.person_search_outlined,
                          color: _ct.warning, size: 22),
                      MySpacing.width(8),
                      Text(
                        c.orderMode == OrderMode.wholesale
                            ? 'Cần thông tin khách sỉ'
                            : 'Cần thông tin khách lẻ',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ]),
                    content: Text(
                      c.orderMode == OrderMode.wholesale
                          ? 'Đơn hàng sỉ bắt buộc phải có thông tin khách hàng (tìm qua SĐT hoặc tạo mới).'
                          : 'Đơn hàng lẻ bắt buộc phải điền SĐT, email và địa chỉ trước khi tạo đơn.',
                      style: const TextStyle(fontSize: 14),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Để sau',
                            style:
                            TextStyle(color: _ct.secondary)),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          CustomerPickerModal.show(context, c);
                        },
                        icon: const Icon(Icons.person_add_outlined,
                            size: 16),
                        label: Text(
                          c.orderMode == OrderMode.wholesale
                              ? 'Nhập KH sỉ'
                              : 'Nhập thông tin',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _ct.primary,
                          foregroundColor: _ct.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            child: Container(
              padding: MySpacing.xy(8, 10),
              decoration: BoxDecoration(
                color: c.canCreateOrder
                    ? _ct.primary
                    : _ct.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (c.isSubmitting)
                    SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _ct.onPrimary),
                    )
                  else
                    Icon(Icons.check_circle_outline,
                        size: 16,
                        color: c.canCreateOrder
                            ? _ct.onPrimary
                            : _ct.secondary),
                  MySpacing.width(5),
                  MyText.bodySmall(
                    c.isSubmitting ? 'Đang tạo...' : 'Tạo đơn hàng',
                    fontWeight: 700,
                    color: c.canCreateOrder ? _ct.onPrimary : _ct.secondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildProductHeader(OrderCartController c) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: MySpacing.xy(16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.grid_view_outlined, size: 17, color: _ct.primary),
                MySpacing.width(8),
                Flexible(
                  child: MyText.titleSmall(
                    'Sản phẩm (${c.filteredProducts.length})',
                    style: TextStyle(
                      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isMobile)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    _isProductsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20, // giảm size icon để tránh tràn
                    color: _ct.primary,
                  ),
                  onPressed: () => setState(() => _isProductsExpanded = !_isProductsExpanded),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 4.0), // giảm padding left xuống 4
                child: GestureDetector(
                  onTap: c.refreshProducts,
                  child: Icon(Icons.refresh, size: 18, color: _ct.secondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(OrderCartController c) {
    return Padding(
      padding: MySpacing.xy(12, 0).copyWith(bottom: 12),
      child: Column(
        children: [
          // Search box
          TextField(
            controller: _searchCtrl,
            onChanged: (value) {
              // Hủy timer cũ nếu có
              _debounceTimer?.cancel();

              // Bắt đầu loading
              setState(() => _isSearching = true);

              // Debounce 900ms
              _debounceTimer = Timer(const Duration(milliseconds: 900), () {
                c.onSearch(value);
                setState(() => _isSearching = false);
              });
            },
            style: MyTextStyle.bodySmall(),
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'Tìm tên sản phẩm...',
              hintStyle: MyTextStyle.bodySmall(muted: true),
              prefixIcon: Icon(Icons.search, size: 17, color: _ct.secondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _ct.secondary.withOpacity(0.4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _ct.secondary.withOpacity(0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: _ct.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              isDense: true,
              isCollapsed: true,
            ),
          ),

          MySpacing.height(12),

          // Row chứa Category dropdown + 2 nút toggle filter
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Đảm bảo căn giữa theo chiều dọc
            children: [
              // Dropdown Category
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 44, // ← Height cố định
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: _ct.primary.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: c.selectedCategory?.name,
                        isExpanded: true,
                        alignment: Alignment.centerLeft, // Căn giữa nội dung
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(Icons.arrow_drop_down, color: _ct.primary, size: 20),
                        ),
                        elevation: 4,
                        menuMaxHeight: 240,
                        borderRadius: BorderRadius.circular(8),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        dropdownColor: Colors.white,
                        style: TextStyle(color: _ct.primary, fontSize: 13),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Tất cả', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          ...c.categories.map((cat) => DropdownMenuItem<String?>(
                            value: cat.name,
                            child: Text(
                              cat.name ?? 'Unknown',
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            c.onSelectCategory(null);
                          } else {
                            final selected = c.categories.firstWhere((cat) => cat.name == value);
                            c.onSelectCategory(selected);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              MySpacing.width(12),

              // Nút toggle tên A-Z ↔ Z-A
              SizedBox(
                height: 44, // ← Height cố định bằng dropdown
                child: GestureDetector(
                  onTap: () {
                    if (c.sortMode == 'name_asc') {
                      c.onSortMode('name_desc');
                    } else {
                      c.onSortMode('name_asc');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    decoration: BoxDecoration(
                      color: c.sortMode.contains('name') ? _ct.info.withOpacity(0.15) : _ct.secondary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: c.sortMode.contains('name') ? _ct.info : _ct.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Center( // ← Căn giữa nội dung theo chiều dọc
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            c.sortMode == 'name_asc' ? Icons.arrow_downward : Icons.arrow_upward,
                            size: 14,
                            color: c.sortMode.contains('name') ? _ct.info : _ct.secondary,
                          ),
                          MySpacing.width(6),
                          MyText.labelMedium(
                            c.sortMode == 'name_asc' ? 'A → Z' : 'Z → A',
                            color: c.sortMode.contains('name') ? _ct.info : _ct.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              MySpacing.width(8),

              // Nút toggle giá Cao → Thấp ↔ Thấp → Cao
              SizedBox(
                height: 44, // ← Height cố định bằng dropdown
                child: GestureDetector(
                  onTap: () {
                    if (c.sortMode == 'price_desc') {
                      c.onSortMode('price_asc');
                    } else {
                      c.onSortMode('price_desc');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    decoration: BoxDecoration(
                      color: c.sortMode.contains('price') ? _ct.info.withOpacity(0.15) : _ct.secondary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: c.sortMode.contains('price') ? _ct.info : _ct.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Center( // ← Căn giữa nội dung theo chiều dọc
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            c.sortMode == 'price_desc' ? Icons.arrow_downward : Icons.arrow_upward,
                            size: 14,
                            color: c.sortMode.contains('price') ? _ct.info : _ct.secondary,
                          ),
                          MySpacing.width(6),
                          MyText.labelMedium(
                            c.sortMode == 'price_desc' ? 'Giá cao → thấp' : 'Giá thấp → cao',
                            color: c.sortMode.contains('price') ? _ct.info : _ct.secondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sortChip(OrderCartController c, String mode, IconData icon, String label) {
    final sel = c.sortMode == mode;
    return GestureDetector(
      onTap: () => c.onSortMode(mode),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: sel ? _ct.info.withOpacity(0.10) : _ct.secondary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sel ? _ct.info.withOpacity(0.45) : _ct.secondary.withOpacity(0.18),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 11, color: sel ? _ct.info : _ct.secondary),
          const SizedBox(width: 3),
          MyText.labelSmall(label,
              color: sel ? _ct.info : null, fontWeight: sel ? 700 : 500),
        ]),
      ),
    );
  }

  Widget _buildProductGrid(OrderCartController c) {
    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(_ct.primary),
        ),
      );
    }

    if (c.isLoadingProducts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 40, color: _ct.secondary.withOpacity(0.3)),
            MySpacing.height(8),
            MyText.bodyMedium('Không tìm thấy sản phẩm', muted: true),
          ],
        ),
      );
    }

    final w = MediaQuery.of(context).size.width;
    final cols = w < 600 ? 1 : w < 900 ? 3 : w < 1200 ? 3 : 4;

    return GridView.builder(
      padding: MySpacing.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.68,
      ),
      itemCount: c.filteredProducts.length,
      itemBuilder: (_, i) => _buildProductCard(c, c.filteredProducts[i]),
    );
  }

  Widget _buildProductCard(OrderCartController c, ProductModel product) {
    final inCart = c.cartItems
        .where((ci) => ci.product.id == product.id)
        .fold<double>(0, (s, ci) => s + ci.quantity);

    final displayPrice = c.orderMode == OrderMode.wholesale
        ? (product.firstTier?.price ?? product.basePrice)
        : product.basePrice;

    return GestureDetector(
      onTap: () => c.addToCart(product),
      child: Container(
        decoration: BoxDecoration(
          color: inCart > 0 ? _ct.primary.withOpacity(0.04) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: inCart > 0 ? _ct.primary.withOpacity(0.4) : _ct.secondary.withOpacity(0.15),
            width: inCart > 0 ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                    child: product.imageUrl != null
                        ? Image.network(
                      SellerService.buildImageUrl(product.imageUrl!),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgPlaceholder(),
                    )
                        : _imgPlaceholder(),
                  ),
                  if (inCart > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _ct.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: MyText.labelSmall(
                          '×${inCart % 1 == 0 ? inCart.toStringAsFixed(0) : inCart.toStringAsFixed(2)}',
                          color: _ct.onPrimary,
                          fontWeight: 700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: ClipRect(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: FittedBox( // ← Scale text nếu quá dài
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: MyText.bodySmall(
                            product.name,
                            fontWeight: 600,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          MyText.labelMedium(
                            c.formatCurrency(displayPrice),
                            color: _ct.primary,
                            fontWeight: 700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
    color: _ct.secondary.withOpacity(0.08),
    child: Center(
        child: Icon(Icons.fastfood_outlined,
            size: 32, color: _ct.secondary.withOpacity(0.3))),
  );

  Widget _thumb() => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: _ct.secondary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Icon(Icons.fastfood_outlined,
        size: 16, color: _ct.secondary.withOpacity(0.4)),
  );

  void _showPricePicker(OrderCartController c, CartItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PricePickerSheet(ctrl: c, item: item),
    );
  }

  Future<void> _confirmClear(OrderCartController c) async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xóa giỏ hàng'),
        content: const Text('Xóa tất cả sản phẩm trong giỏ?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Xóa', style: TextStyle(color: _ct.danger)),
          ),
        ],
      ),
    );
    if (ok == true) c.clearCart();
  }
}

// ─────────────────────────────────────────────────────────────
//  Các class phụ trợ (giữ nguyên)
// ─────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final OrderCartController ctrl;
  const _ModeToggle({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: _ct.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _ct.secondary.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _tab(OrderMode.retail, ctrl),
        _tab(OrderMode.wholesale, ctrl),
      ]),
    );
  }

  Widget _tab(OrderMode mode, OrderCartController c) {
    final sel = c.orderMode == mode;
    return GestureDetector(
      onTap: () => _confirmToggleMode(mode, c),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: sel ? _ct.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          mode == OrderMode.retail ? 'Lẻ' : 'Sỉ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: sel ? _ct.onPrimary : _ct.secondary,
          ),
        ),
      ),
    );
  }

  // Dialog xác nhận — chỉ hiện khi giỏ hàng có món
  void _confirmToggleMode(OrderMode mode, OrderCartController c) {
    if (c.orderMode == mode) return;

    final modeName = mode == OrderMode.retail ? 'Lẻ' : 'Sỉ';

    // Giỏ trống → chuyển luôn, không cần hỏi
    if (c.cartItems.isEmpty) {
      c.setOrderModeConfirmed(mode);
      return;
    }

    Get.dialog<bool>(
      AlertDialog(
        title: Text('Chuyển sang chế độ $modeName?'),
        content: const Text(
          'Giỏ hàng hiện tại sẽ bị xóa vì giá Sỉ và Lẻ khác nhau.\n'
              'Bạn có muốn tiếp tục không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Chuyển & Xóa giỏ',
              style: TextStyle(
                  color: _ct.danger, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true) c.setOrderModeConfirmed(mode);
    });
  }
}

class _PriceBadge extends StatelessWidget {
  final CartItem item;
  final OrderMode orderMode;

  const _PriceBadge({required this.item, required this.orderMode});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (item.priceMode) {
      case ItemPriceMode.discountPercent:
        color = Colors.green;
        label = '-${item.discountPercent ?? 0}%';
        icon = Icons.percent;
        break;
      case ItemPriceMode.base:
        color = _ct.secondary;
        label = 'Giá gốc';
        icon = Icons.sell_outlined;
        break;
      case ItemPriceMode.tier:
        final tier = item.activeTier;
        if (tier != null) {
          color = _ct.primary;
          label = tier.tierName;
          icon = Icons.layers_outlined;
        } else {
          color = _ct.secondary;
          label = 'Giá gốc';
          icon = Icons.sell_outlined;
        }
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        const SizedBox(width: 3),
        Icon(Icons.arrow_drop_down, size: 12, color: color),
      ]),
    );
  }
}

class _PricePickerSheet extends StatefulWidget {
  final OrderCartController ctrl;
  final CartItem item;

  const _PricePickerSheet({required this.ctrl, required this.item});

  @override
  State<_PricePickerSheet> createState() => _PricePickerSheetState();
}

class _PricePickerSheetState extends State<_PricePickerSheet> {
  late ItemPriceMode _mode;
  ProductPriceTierModel? _selectedTier;
  final _pctCtrl = TextEditingController();
  bool _showPctInput = false;

  OrderCartController get c => widget.ctrl;
  CartItem get item => widget.item;
  ProductModel get product => item.product;

  bool get _isRetail => c.orderMode == OrderMode.retail;
  bool get _isWholesale => c.orderMode == OrderMode.wholesale;

  @override
  void initState() {
    super.initState();
    // Chế độ Lẻ: luôn khởi tạo bằng base (bỏ qua priceMode của item)
    _mode = _isRetail ? ItemPriceMode.base : item.priceMode;
    _selectedTier = item.selectedTier ?? item.activeTier;
    if (item.discountPercent != null) {
      _pctCtrl.text = item.discountPercent!.toString();
    }
    _showPctInput = _mode == ItemPriceMode.discountPercent;
  }

  @override
  void dispose() {
    _pctCtrl.dispose();
    super.dispose();
  }

  void _apply() {
    switch (_mode) {
      case ItemPriceMode.base:
        c.selectBasePriceForItem(item);
        break;
      case ItemPriceMode.tier:
        if (_selectedTier != null) {
          c.selectTierForItem(item, _selectedTier!);
        } else {
          c.resetToAutoTier(item);
        }
        break;
      case ItemPriceMode.discountPercent:
        final pct = int.tryParse(_pctCtrl.text);
        if (pct != null && pct >= 1 && pct <= 100) {
          c.setDiscountPercentForItem(item, pct);
        }
        break;
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    // baseForPct:
    //   Lẻ  → basePrice
    //   Sỉ  → firstTier.price hoặc basePrice nếu không có tier
    final baseForPct = _isRetail
        ? product.basePrice
        : (product.firstTier?.price ?? product.basePrice);

    // Preview đơn giá
    double previewUnit = switch (_mode) {
      ItemPriceMode.base => product.basePrice,
      ItemPriceMode.tier =>
      _selectedTier?.price ?? item.activeTier?.price ?? product.basePrice,
      ItemPriceMode.discountPercent => () {
        final pct = int.tryParse(_pctCtrl.text) ?? 0;
        return baseForPct * (100 - pct) / 100;
      }(),
    };

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // ── Handle bar ───────────────────────────────────────
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: _ct.secondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // ── Header: tên sản phẩm + preview giá ──────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: TextStyle(
                        fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: _ct.primary,
                      )),
                  Text(
                    'SL: ${item.quantity} • Giá gốc: ${c.formatCurrency(product.basePrice)}đ',
                    style: TextStyle(
                        fontSize: 12, color: _ct.secondary.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(
                '${c.formatCurrency(previewUnit)}đ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _ct.primary,
                ),
              ),
              Text('đơn giá',
                  style: TextStyle(
                      fontSize: 11, color: _ct.secondary.withOpacity(0.5))),
            ]),
          ]),
        ),

        // ── Mode badge ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (_isWholesale ? _ct.primary : Colors.orange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: (_isWholesale ? _ct.primary : Colors.orange).withOpacity(0.4),
                ),
              ),
              child: Text(
                _isWholesale ? 'Chế độ: Sỉ' : 'Chế độ: Lẻ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _isWholesale ? _ct.primary : Colors.orange,
                ),
              ),
            ),
          ]),
        ),

        const Divider(height: 20),

        // ════════════════════════════════════════════════════
        // CHẾ ĐỘ LẺ: Chỉ hiện Giảm %, giá gốc hiển thị dạng thông tin tĩnh
        // ════════════════════════════════════════════════════
        if (_isRetail) ...[
          // Thông tin giá gốc — dạng tĩnh, không phải lựa chọn
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _ct.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _ct.primary.withOpacity(0.15)),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _ct.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(Icons.sell_outlined, size: 16, color: _ct.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Giá bán lẻ',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _ct.primary)),
                    Text(
                      '${c.formatCurrency(product.basePrice)}đ • Giá cố định',
                      style: TextStyle(fontSize: 11, color: _ct.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.check_circle, size: 18, color: _mode == ItemPriceMode.base ? _ct.primary : Colors.transparent),
            ]),
          ),

          // Giảm %
          _optionTile(
            selected: _mode == ItemPriceMode.discountPercent,
            icon: Icons.percent,
            title: 'Giảm theo %',
            subtitle: 'Tính trên ${c.formatCurrency(baseForPct)}đ (giá lẻ)',
            color: Colors.green,
            onTap: () => setState(() {
              _mode = ItemPriceMode.discountPercent;
              _showPctInput = true;
            }),
          ),
        ],

        // ════════════════════════════════════════════════════
        // CHẾ ĐỘ SỈ: Tier tự động + chọn tay + Giảm %
        // ════════════════════════════════════════════════════
        if (_isWholesale) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Row(children: [
              Icon(Icons.layers_outlined,
                  size: 13, color: _ct.secondary.withOpacity(0.6)),
              const SizedBox(width: 6),
              Text(
                'Khung giá theo số lượng (tự động)',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _ct.secondary.withOpacity(0.7)),
              ),
            ]),
          ),

          if (product.priceTiers.isEmpty)
            _optionTile(
              selected: _mode == ItemPriceMode.tier,
              icon: Icons.label_outline,
              title: 'Giá sỉ',
              subtitle: '${c.formatCurrency(product.basePrice)}đ',
              color: _ct.primary,
              onTap: () => setState(() {
                _mode = ItemPriceMode.tier;
                _selectedTier = null;
                _showPctInput = false;
              }),
            )
          else
            ...product.priceTiers.map((tier) {
              final isCurrentAuto = item.activeTier?.id == tier.id &&
                  item.priceMode == ItemPriceMode.tier &&
                  item.selectedTier == null;
              final isSelected = _mode == ItemPriceMode.tier &&
                  (_selectedTier?.id == tier.id ||
                      (_selectedTier == null && isCurrentAuto));

              return _optionTile(
                selected: isSelected,
                icon: Icons.label_outline,
                title: tier.tierName,
                subtitle: '${c.formatCurrency(tier.price)}đ • ${tier.rangeLabel}',
                color: _ct.primary,
                badge: isCurrentAuto ? 'auto' : null,
                onTap: () => setState(() {
                  _mode = ItemPriceMode.tier;
                  _selectedTier = tier;
                  _showPctInput = false;
                }),
              );
            }),

          _optionTile(
            selected: _mode == ItemPriceMode.discountPercent,
            icon: Icons.percent,
            title: 'Giảm theo %',
            subtitle: 'Tính trên ${c.formatCurrency(baseForPct)}đ (khung đầu tiên)',
            color: Colors.green,
            onTap: () => setState(() {
              _mode = ItemPriceMode.discountPercent;
              _showPctInput = true;
            }),
          ),
        ],

        // ── Input % ─────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: _showPctInput
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _pctCtrl,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _MaxValueFormatter(100),
                  ],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: '1 – 100',
                    suffixText: '%',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                      BorderSide(color: Colors.green, width: 1.5),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                    () {
                  final pct = int.tryParse(_pctCtrl.text) ?? 0;
                  final result = baseForPct * (100 - pct) / 100;
                  return '→ ${c.formatCurrency(result)}đ';
                }(),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.green),
              ),
            ]),
          )
              : const SizedBox.shrink(),
        ),

        const SizedBox(height: 8),

        // ── Nút Áp dụng ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canApply() ? _apply : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _ct.primary,
                foregroundColor: _ct.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Áp dụng',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
    );
  }

  bool _canApply() {
    if (_mode == ItemPriceMode.discountPercent) {
      final pct = int.tryParse(_pctCtrl.text);
      return pct != null && pct >= 1 && pct <= 100;
    }
    return true;
  }

  Widget _optionTile({
    required bool selected,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? color.withOpacity(0.5)
                : _ct.secondary.withOpacity(0.15),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? color : null)),
                  if (badge != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: _ct.info.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(badge,
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _ct.info)),
                    ),
                  ],
                ]),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 11,
                        color: _ct.secondary.withOpacity(0.7))),
              ],
            ),
          ),
          if (selected) Icon(Icons.check_circle, size: 18, color: color),
        ]),
      ),
    );
  }
}

class _MaxValueFormatter extends TextInputFormatter {
  final int max;
  const _MaxValueFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final val = int.tryParse(newValue.text);
    if (val == null || val > max) return oldValue;
    return newValue;
  }
}