import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/services/seller_services.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import '../../../../controller/ui/general/orders/order_detail_controller.dart';
import '../../../../helper/services/api_helper.dart';

// Khai báo contentTheme trực tiếp (đã fix)
final contentTheme = AdminTheme.theme.contentTheme;

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> with UIMixin {
  late OrderDetailController controller;

  @override
  void initState() {
    super.initState();
    // Lấy order từ arguments
    final OrderModel? passedOrder = Get.arguments as OrderModel?;

    controller = Get.put(
      OrderDetailController(order: passedOrder),
      tag: 'order_detail_${DateTime.now().millisecondsSinceEpoch}',
    );

    // Nếu không có order → báo lỗi và back
    if (passedOrder == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Lỗi', 'Không tìm thấy thông tin đơn hàng', backgroundColor: Colors.red, colorText: Colors.white);
        Get.back();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderDetailController>(
      init: controller,
      builder: (ctrl) {
        if (ctrl.isLoading) {
          return Layout(
            screenName: 'CHI TIẾT ĐƠN HÀNG',
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (ctrl.errorMessage != null) {
          return Layout(
            screenName: 'CHI TIẾT ĐƠN HÀNG',
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.error_outline, size: 52, color: Colors.red.shade300),
                MySpacing.height(12),
                MyText.bodyMedium(ctrl.errorMessage!, color: Colors.red),
              ]),
            ),
          );
        }

        if (ctrl.order == null) {
          return Layout(
            screenName: 'CHI TIẾT ĐƠN HÀNG',
            child: Center(
              child: MyText.bodyMedium('Không tìm thấy đơn hàng', color: Colors.red),
            ),
          );
        }

        final o = ctrl.order!;
        return Layout(
          screenName: 'CHI TIẾT ĐƠN HÀNG',
          child: MyFlex(
            children: [
              MyFlexItem(
                sizes: 'lg-9',
                child: Column(children: [
                  _buildHeader(ctrl, o),
                  MySpacing.height(12),
                  _buildItemsTable(ctrl, o),
                ]),
              ),
              MyFlexItem(
                sizes: 'lg-3',
                child: Column(children: [
                  _buildOrderSummary(ctrl, o),
                  MySpacing.height(12),
                  _buildPaymentInfo(ctrl, o),
                  MySpacing.height(12),
                  _buildCustomerDetails(o),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HEADER CARD
  // ══════════════════════════════════════════════════════════════

  Widget _buildHeader(OrderDetailController ctrl, OrderModel o) {
    return MyCard(
      paddingAll: 20,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Mã đơn + badges + nút ───────────────────────────
          MyFlex(
            wrapAlignment: WrapAlignment.spaceBetween,
            wrapCrossAlignment: WrapCrossAlignment.center,
            children: [
              MyFlexItem(
                sizes: 'lg-6',
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
                    MyText.bodyMedium(
                      o.orderCode,
                      style: TextStyle(
                        fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // Payment badge
                    _Chip(
                      label: ctrl.paymentStatusLabel,
                      color: ctrl.paymentStatusColor,
                      filled: true,
                    ),
                    // Order status badge
                    _Chip(
                      label: ctrl.statusLabel,
                      color: ctrl.statusColor,
                      filled: false,
                    ),
                  ]),
                  MySpacing.height(8),
                  MyText.bodySmall(ctrl.formatTimestamp(o.createdAt), muted: true),
                ]),
              ),
              MyFlexItem(
                sizes: 'lg-6',
                child: Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.end,
                  children: [
                    // Nút xuất invoice
                    MyContainer(
                      onTap: ctrl.isDownloading ? null : () => ctrl.downloadInvoice(o),
                      color: ctrl.isDownloading
                          ? contentTheme.primary.withOpacity(0.4)
                          : contentTheme.primary,
                      padding: MySpacing.xy(16, 10),
                      borderRadiusAll: 10,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        ctrl.isDownloading
                            ? SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: contentTheme.onPrimary,
                          ),
                        )
                            : Icon(Icons.picture_as_pdf_outlined, size: 15, color: contentTheme.onPrimary),
                        MySpacing.width(6),
                        MyText.bodyMedium(
                          ctrl.isDownloading ? 'Đang tải...' : 'Xuất Invoice',
                          color: contentTheme.onPrimary,
                          fontWeight: 600,
                        ),
                      ]),
                    ),
                    // Nút quay lại
                    MyContainer.bordered(
                      onTap: () => Get.back(),
                      borderColor: contentTheme.secondary,
                      padding: MySpacing.xy(16, 10),
                      borderRadiusAll: 10,
                      child: MyText.bodyMedium('Quay lại'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          MySpacing.height(20),

          // ── Progress ─────────────────────────────────────────
          MyText.bodyMedium(
            'Tiến độ',
            style: TextStyle(
                fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
          MySpacing.height(14),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: ctrl.steps.map((step) => _buildProgressItem(step)).toList(),
          ),

          // ── Phương thức thanh toán ────────────────────────────
          if (o.paymentMethod != null) ...[
            MySpacing.height(16),
            Container(
              padding: MySpacing.xy(12, 8),
              decoration: BoxDecoration(
                color: contentTheme.secondary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: contentTheme.secondary.withValues(alpha: 0.15)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  o.paymentMethod == 'CASH'
                      ? Icons.money_outlined
                      : Icons.account_balance_outlined,
                  size: 15,
                  color: contentTheme.secondary,
                ),
                MySpacing.width(6),
                MyText.bodySmall('Thanh toán: ', muted: true),
                MyText.bodySmall(ctrl.paymentMethodLabel, fontWeight: 600),
              ]),
            ),
          ],

          // ── Ghi chú ──────────────────────────────────────────
          if (o.notes != null && o.notes!.isNotEmpty) ...[
            MySpacing.height(12),
            Container(
              padding: MySpacing.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.notes_outlined, size: 14, color: Colors.amber.shade700),
                MySpacing.width(6),
                Expanded(
                  child: MyText.bodySmall('Ghi chú: ${o.notes}',
                      color: Colors.amber.shade800),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressItem(ProgressStep step) {
    return SizedBox(
      width: 148,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: step.progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(step.color),
            minHeight: 8,
          ),
        ),
        MySpacing.height(8),
        step.loading
            ? Row(children: [
          MyText.bodySmall(step.label, fontWeight: 600),
          MySpacing.width(8),
          SizedBox(
            width: 12, height: 12,
            child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(step.color)),
          ),
        ])
            : MyText.bodySmall(step.label, fontWeight: 600),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // ITEMS TABLE
  // ══════════════════════════════════════════════════════════════

  Widget _buildItemsTable(OrderDetailController ctrl, OrderModel o) {
    return MyCard(
      paddingAll: 0,
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              'Sản phẩm (${o.items.length})',
              style: TextStyle(
                  fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: MySpacing.all(16),
            child: DataTable(
              headingRowColor: WidgetStateColor.resolveWith(
                      (s) => contentTheme.secondary.withValues(alpha: 0.08)),
              headingRowHeight: 40,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 80,
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('Sản phẩm')),
                DataColumn(label: Text('Loại / Giá')),
                DataColumn(label: Text('SL')),
                DataColumn(label: Text('Đơn giá')),
                DataColumn(label: Text('Thành tiền')),
              ],
              rows: o.items.map((item) => _buildItemRow(ctrl, item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildItemRow(OrderDetailController ctrl, OrderItemModel item) {
    return DataRow(cells: [
      // Tên sản phẩm + ảnh
      DataCell(
        SizedBox(
          width: 200,
          child: Row(children: [
            // Ảnh
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: item.productImageUrl != null
                  ? Image.network(
                SellerService.buildImageUrl(item.productImageUrl),
                width: 40, height: 40, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imagePlaceholder(),
              )
                  : _imagePlaceholder(),
            ),
            MySpacing.width(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.productName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (item.unit != null)
                    Text('ĐVT: ${item.unit}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ]),
        ),
      ),
      // Variant + price name
      DataCell(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.variantName != null)
              Container(
                padding: MySpacing.xy(6, 2),
                decoration: BoxDecoration(
                  color: contentTheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(item.variantName!,
                    style: TextStyle(
                        fontSize: 11,
                        color: contentTheme.secondary,
                        fontWeight: FontWeight.w600)),
              ),
            if (item.variantName != null) const SizedBox(height: 3),
            Text(item.priceName,
                style: TextStyle(
                    fontSize: 11,
                    color: contentTheme.primary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      // Số lượng
      DataCell(Text(
        item.quantity % 1 == 0
            ? item.quantity.toInt().toString()
            : item.quantity.toString(),
        style: const TextStyle(fontWeight: FontWeight.w600),
      )),
      // Đơn giá
      DataCell(Text(
        ctrl.formatCurrency(item.unitPrice),
        style: const TextStyle(fontSize: 13),
      )),
      // Thành tiền
      DataCell(Text(
        ctrl.formatCurrency(item.subtotal),
        style: TextStyle(
            fontWeight: FontWeight.w700,
            color: contentTheme.primary,
            fontSize: 13),
      )),
    ]);
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: contentTheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(Icons.fastfood_outlined, size: 18, color: contentTheme.secondary),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // RIGHT COLUMN
  // ══════════════════════════════════════════════════════════════

  Widget _buildOrderSummary(OrderDetailController ctrl, OrderModel o) {
    return MyCard(
      paddingAll: 0,
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Tổng kết đơn hàng'),
          const Divider(height: 0),
          MySpacing.height(12),
          _summaryRow('Tạm tính', ctrl.formatCurrency(o.totalAmount)),
          const Divider(height: 8),
          _summaryRow(
            'Chiết khấu',
            o.discountAmount > 0 ? '-${ctrl.formatCurrency(o.discountAmount)}' : '0đ',
            valueColor: o.discountAmount > 0 ? Colors.green : null,
          ),
          const Divider(height: 8),
          Padding(
            padding: MySpacing.fromLTRB(16, 8, 16, 16),
            child: Row(children: [
              MyText.bodyMedium('THÀNH TIỀN', fontWeight: 700),
              const Spacer(),
              MyText.bodyMedium(
                ctrl.formatCurrency(o.finalAmount),
                style: TextStyle(
                  fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: contentTheme.primary,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(OrderDetailController ctrl, OrderModel o) {
    return MyCard(
      paddingAll: 0,
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Thanh toán'),
          const Divider(height: 0),
          Padding(
            padding: MySpacing.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment method icon + name
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: contentTheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      o.paymentMethod == 'CASH'
                          ? Icons.money_outlined
                          : Icons.account_balance_outlined,
                      size: 22,
                      color: contentTheme.secondary,
                    ),
                  ),
                  MySpacing.width(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyMedium(ctrl.paymentMethodLabel, fontWeight: 700),
                        MySpacing.height(2),
                        MyText.bodySmall('Phương thức thanh toán', muted: true),
                      ],
                    ),
                  ),
                  // Payment status icon
                  Icon(
                    o.paymentStatus == 'PAID'
                        ? Icons.check_circle
                        : Icons.pending_outlined,
                    size: 20,
                    color: ctrl.paymentStatusColor,
                  ),
                ]),
                MySpacing.height(12),
                Row(children: [
                  MyText.bodySmall('Trạng thái: ', muted: true),
                  Container(
                    padding: MySpacing.xy(7, 3),
                    decoration: BoxDecoration(
                      color: ctrl.paymentStatusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: MyText.bodySmall(
                      ctrl.paymentStatusLabel,
                      color: ctrl.paymentStatusColor,
                      fontWeight: 600,
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails(OrderModel o) {
    return MyCard(
      paddingAll: 0,
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader('Thông tin khách hàng'),
          const Divider(height: 0),
          Padding(
            padding: MySpacing.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + tên
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: contentTheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      (o.customerName?.isNotEmpty == true)
                          ? o.customerName![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: contentTheme.primary),
                    ),
                  ),
                  MySpacing.width(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyMedium(
                          o.customerName?.isNotEmpty == true
                              ? o.customerName!
                              : 'Khách lẻ',
                          fontWeight: 700,
                        ),
                        if (o.customerPhone != null)
                          MyText.bodySmall(o.customerPhone!, muted: true),
                      ],
                    ),
                  ),
                ]),

                if (o.shippingAddress != null && o.shippingAddress!.isNotEmpty) ...[
                  MySpacing.height(14),
                  _infoRow(Icons.location_on_outlined, 'Địa chỉ', o.shippingAddress!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════

  Widget _cardHeader(String title) {
    return Padding(
      padding: MySpacing.all(16),
      child: MyText.bodyMedium(
        title,
        style: TextStyle(
          fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: MySpacing.fromLTRB(16, 4, 16, 4),
      child: Row(children: [
        MyText.bodySmall(label, muted: true),
        const Spacer(),
        MyText.bodySmall(value,
            fontWeight: 600, color: valueColor),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 14, color: contentTheme.secondary.withValues(alpha: 0.6)),
      MySpacing.width(6),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          MyText.bodySmall(label, muted: true),
          MySpacing.height(2),
          MyText.bodySmall(value, fontWeight: 600),
        ]),
      ),
    ]);
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// CHIP WIDGET
// ══════════════════════════════════════════════════════════════════

class _Chip extends StatelessWidget with UIMixin {
  final String label;
  final Color color;
  final bool filled;

  const _Chip({required this.label, required this.color, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: MySpacing.xy(10, 5),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: filled ? null : Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}