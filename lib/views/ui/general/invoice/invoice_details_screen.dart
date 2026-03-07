// views/ui/general/invoice/invoice_details_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/services/seller_services.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

// ══════════════════════════════════════════════════════════════════
// CONTROLLER
// ══════════════════════════════════════════════════════════════════

class InvoiceDetailsController extends GetxController {
  OrderModel? order;
  bool isLoading = false;
  bool isExporting = false; // ← trạng thái xuất PDF
  String? errorMessage;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is int) {
      _fetchOrder(args);
    } else if (args is OrderModel) {
      order = args;
      update();
    }
  }

  Future<void> _fetchOrder(int id) async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await SellerService.getOrderById(id);

    isLoading = false;
    if (result.isSuccess && result.data != null) {
      order = result.data;
      update(['order_details']); // ép rebuild UI
    } else {
      errorMessage = result.message ?? 'Không thể tải chi tiết đơn hàng';
    }
    update();
  }

  Future<void> exportPdf() async {
    if (order == null || isExporting) return;
    isExporting = true;
    update();

    final result = await SellerService.generateAndSendInvoice(order!.id);

    isExporting = false;
    update();

    Get.snackbar(
      result.isSuccess ? 'Thành công' : 'Lỗi',
      result.isSuccess
          ? (result.message ?? 'Đã gửi hóa đơn qua Telegram')
          : (result.message ?? 'Không thể xuất PDF'),
      backgroundColor: result.isSuccess ? Colors.green : Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: result.isSuccess ? 4 : 3),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════

class InvoiceDetailsScreen extends StatefulWidget {
  const InvoiceDetailsScreen({super.key});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen>
    with UIMixin {
  late InvoiceDetailsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      InvoiceDetailsController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InvoiceDetailsController>(
      init: controller,
      builder: (ctrl) {
        return Layout(
          screenName: 'CHI TIẾT ĐƠN HÀNG',
          child: ctrl.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ctrl.errorMessage != null
              ? _buildError(ctrl)
              : ctrl.order == null
              ? const Center(
              child: Text('Không tìm thấy đơn hàng'))
              : _buildContent(ctrl.order!),
        );
      },
    );
  }

  // ── Error state ───────────────────────────────────────────────

  Widget _buildError(InvoiceDetailsController ctrl) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline,
            size: 52, color: contentTheme.danger),
        MySpacing.height(12),
        MyText.bodyMedium(ctrl.errorMessage!, color: contentTheme.danger),
        MySpacing.height(16),
        ElevatedButton.icon(
          onPressed: () {
            final args = Get.arguments;
            if (args is int) ctrl._fetchOrder(args);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại'),
        ),
      ]),
    );
  }

  // ── Main content ──────────────────────────────────────────────

  Widget _buildContent(OrderModel o) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: MyCard(
        borderRadiusAll: 12,
        shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
        paddingAll: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(o),
            MySpacing.height(24),
            const Divider(height: 1),
            MySpacing.height(20),
            _buildCustomerSection(o),
            MySpacing.height(24),
            const Divider(height: 1),
            MySpacing.height(20),
            _buildItemsTable(o),
            MySpacing.height(24),
            const Divider(height: 1),
            MySpacing.height(16),
            _buildSummary(o),
            MySpacing.height(24),
            _buildActionButtons(o),
          ],
        ),
      ),
    );
  }

  // ── Header: mã đơn + trạng thái ──────────────────────────────

  Widget _buildHeader(OrderModel o) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nút quay lại
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
              contentTheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.arrow_back_rounded,
                size: 18, color: contentTheme.secondary),
          ),
        ),
        MySpacing.width(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      o.orderCode,
                      style: TextStyle(
                        fontFamily:
                        GoogleFonts.hankenGrotesk().fontFamily,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: contentTheme.primary,
                      ),
                    ),
                  ),
                  MySpacing.width(12),
                  _StatusBadge(status: o.status),
                ],
              ),
              MySpacing.height(6),
              if (o.createdAt != null)
                MyText.bodySmall(_formatDate(o.createdAt),
                    muted: true),
            ],
          ),
        ),
      ],
    );
  }

  // ── Customer info ─────────────────────────────────────────────

  Widget _buildCustomerSection(OrderModel o) {
    final hasCustomerInfo = (o.customerName != null && o.customerName!.trim().isNotEmpty) ||
        (o.customerPhone != null && o.customerPhone!.trim().isNotEmpty) ||
        (o.shippingAddress != null && o.shippingAddress!.trim().isNotEmpty);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Thông tin khách hàng'),
              MySpacing.height(12),
              if (o.customerName != null && o.customerName!.trim().isNotEmpty)
                _infoRow(Icons.person_outline, o.customerName!.trim()),
              if (o.customerPhone != null && o.customerPhone!.trim().isNotEmpty)
                _infoRow(Icons.phone_outlined, o.customerPhone!.trim()),
              if (o.shippingAddress != null && o.shippingAddress!.trim().isNotEmpty)
                _infoRow(Icons.location_on_outlined, o.shippingAddress!.trim()),
              if (!hasCustomerInfo)
                MyText.bodyMedium('Khách vãng lai', muted: true),
            ],
          ),
        ),
        MySpacing.width(24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Thanh toán & Ghi chú'),
              MySpacing.height(12),
              _infoRow(
                o.paymentStatus == 'PAID' ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                _paymentStatusLabel(o.paymentStatus),
                color: o.paymentStatus == 'PAID' ? Colors.green : Colors.orange,
              ),
              if (o.paymentMethod != null && o.paymentMethod!.trim().isNotEmpty)
                _infoRow(Icons.payment_outlined, _paymentMethodLabel(o.paymentMethod!.trim())),
              if (o.notes != null && o.notes!.trim().isNotEmpty)
                _infoRow(Icons.notes_outlined, o.notes!.trim(), color: Colors.orange.shade700),
            ],
          ),
        ),
      ],
    );
  }

  // ── Items table ───────────────────────────────────────────────

  Widget _buildItemsTable(OrderModel o) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Sản phẩm (${o.items.length})'),
        MySpacing.height(12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Header row
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: contentTheme.secondary
                      .withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(children: [
                  Expanded(
                      flex: 4,
                      child: _tableHeader('Tên sản phẩm')),
                  Expanded(
                      flex: 1,
                      child: _tableHeader('SL',
                          center: true)),
                  Expanded(
                      flex: 2,
                      child: _tableHeader('Đơn giá',
                          center: true)),
                  Expanded(
                      flex: 2,
                      child: _tableHeader('Thành tiền',
                          right: true)),
                ]),
              ),
              // Item rows
              ...o.items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                    color: i.isEven ? Colors.transparent : contentTheme.secondary.withOpacity(0.02),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên sản phẩm
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            if (item.notes != null && item.notes!.isNotEmpty)
                              Text(
                                'Ghi chú: ${item.notes}',
                                style: TextStyle(fontSize: 11, color: Colors.orange.shade700, fontStyle: FontStyle.italic),
                              ),
                          ],
                        ),
                      ),
                      // Số lượng + unit (2 chữ số thập phân)
                      Expanded(
                        flex: 1,
                        child: Text(
                          '${item.quantity.toStringAsFixed(2)} ${item.unit ?? ''}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      // Đơn giá (nếu base != unit thì hiển thị 2 dòng)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _fmt(item.unitPrice),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: contentTheme.primary),
                            ),
                            if (item.basePrice != item.unitPrice)
                              Text(
                                _fmt(item.basePrice),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: contentTheme.secondary.withOpacity(0.7),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Thành tiền
                      Expanded(
                        flex: 2,
                        child: Text(
                          _fmt(item.subtotal),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: contentTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ── Summary ───────────────────────────────────────────────────

  Widget _buildSummary(OrderModel o) {
    // Tính VAT breakdown từ items
    final vatBreakdown = <int, double>{};
    for (var item in o.items) {
      if (item.vatRate > 0 && item.vatAmount > 0) {
        vatBreakdown.update(
          item.vatRate,
              (value) => value + item.vatAmount,
          ifAbsent: () => item.vatAmount,
        );
      }
    }

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 300, // tăng width để breakdown không bị tràn
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _summaryRow('Tạm tính', _fmt(o.totalAmount)),
            if (o.discountAmount > 0)
              _summaryRow('Chiết khấu', '-${_fmt(o.discountAmount)}', valueColor: Colors.green),
            if (o.vatAmount > 0) ...[
              _summaryRow('VAT: ', '+${_fmt(o.vatAmount)}', valueColor: Colors.orange),
              ...vatBreakdown.entries.map((e) => Padding(
                padding: const EdgeInsets.only(left: 20, top: 4),
                child: _summaryRow(
                  'o VAT ${e.key}%',
                  '+${_fmt(e.value)}',
                  fontSize: 12,
                  valueColor: Colors.orange.withOpacity(0.8),
                ),
              )),
            ],
            const Divider(height: 16),
            _summaryRow(
              'Tổng cộng',
              _fmt(o.finalAmount),
              isBold: true,
              valueColor: contentTheme.primary,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
      String label,
      String value, {
        bool isBold = false,
        Color? valueColor,
        double fontSize = 14,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText.bodyMedium(
            label,
            muted: !isBold,
            fontWeight: isBold ? 700 : null,
            fontSize: fontSize,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? contentTheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action buttons ────────────────────────────────────────────

  Widget _buildActionButtons(OrderModel o) {
    return GetBuilder<InvoiceDetailsController>(
      init: controller,
      builder: (ctrl) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ── Quay lại ──
          MyContainer.bordered(
            onTap: () => Get.back(),
            borderRadiusAll: 10,
            borderColor: contentTheme.secondary,
            padding: MySpacing.xy(20, 12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.arrow_back, size: 16, color: contentTheme.secondary),
              MySpacing.width(6),
              MyText.bodyMedium('Quay lại', color: contentTheme.secondary),
            ]),
          ),
          MySpacing.width(12),
          // ── Xuất PDF ──
          MyContainer(
            onTap: ctrl.isExporting ? null : ctrl.exportPdf,
            color: ctrl.isExporting
                ? contentTheme.primary.withValues(alpha: 0.5)
                : contentTheme.primary,
            borderRadiusAll: 10,
            padding: MySpacing.xy(20, 12),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ctrl.isExporting
                  ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: contentTheme.onPrimary,
                ),
              )
                  : Icon(Icons.picture_as_pdf_outlined,
                  size: 16, color: contentTheme.onPrimary),
              MySpacing.width(6),
              MyText.bodyMedium(
                ctrl.isExporting ? 'Đang tạo...' : 'Tạo Invoice',
                color: contentTheme.onPrimary,
                fontWeight: 600,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Small helpers ─────────────────────────────────────────────

  Widget _sectionTitle(String text) => Text(
    text,
    style: TextStyle(
      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: contentTheme.primary,
    ),
  );

  Widget _infoRow(IconData icon, String text, {Color? color}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                size: 14,
                color: color ??
                    contentTheme.secondary
                        .withValues(alpha: 0.6)),
            MySpacing.width(6),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: color != null
                        ? FontWeight.w600
                        : null),
              ),
            ),
          ],
        ),
      );

  Widget _tableHeader(String text,
      {bool center = false, bool right = false}) =>
      Text(
        text,
        textAlign: right
            ? TextAlign.right
            : center
            ? TextAlign.center
            : TextAlign.left,
        style: const TextStyle(
            fontWeight: FontWeight.w700, fontSize: 12),
      );

  String _fmt(double amount) {
    final s = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},');
    return '${s}đ';
  }

  String _fmtQty(double qty) =>
      qty == qty.truncate() ? qty.toInt().toString() : qty.toString();

  String _formatDate(int? ts) {
    if (ts == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  String _paymentStatusLabel(String s) {
    switch (s) {
      case 'PAID':
        return 'Đã thanh toán';
      case 'UNPAID':
        return 'Chưa thanh toán';
      case 'REFUNDED':
        return 'Đã hoàn tiền';
      default:
        return s;
    }
  }

  String _paymentMethodLabel(String s) {
    switch (s) {
      case 'CASH':
        return 'Tiền mặt';
      case 'BANK_TRANSFER':
        return 'Chuyển khoản';
      default:
        return s;
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// STATUS BADGE
// ══════════════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color c;
    String label;
    switch (status) {
      case 'PENDING':
        c = Colors.orange;
        label = 'Chờ xử lý';
        break;
      case 'CONFIRMED':
        c = Colors.blue;
        label = 'Xác nhận';
        break;
      case 'PROCESSING':
        c = Colors.blue;
        label = 'Đang xử lý';
        break;
      case 'COMPLETED':
        c = Colors.green;
        label = 'Hoàn thành';
        break;
      case 'CANCELLED':
        c = Colors.red;
        label = 'Đã hủy';
        break;
      default:
        c = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: c)),
    );
  }
}