import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/services/seller_services.dart';
import 'package:original_taste/helper/theme/admin_theme.dart'; // ← Import file chứa AdminTheme
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:http/http.dart' as http;
import 'package:original_taste/views/ui/general/invoice/invoice_details_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

import '../../helper/services/api_helper.dart';

// Khai báo contentTheme trực tiếp từ AdminTheme (fix lỗi 1)
final contentTheme = AdminTheme.theme.contentTheme;

// ══════════════════════════════════════════════════════════════════
// CONTROLLER
// ══════════════════════════════════════════════════════════════════

class OrderHistoryController extends MyController {
  List<OrderModel> orders = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading = true;
    errorMessage = null;
    update();

    final result = await SellerService.getMyOrders();

    isLoading = false;
    if (result.isSuccess && result.data != null) {
      orders = List<OrderModel>.from(result.data!)
        ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    } else {
      errorMessage = result.message ?? 'Không thể tải danh sách đơn hàng';
    }
    update();
  }
}

// ══════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderHistoryController>(
      init: OrderHistoryController(),
      tag: 'order_history',
      builder: (ctrl) => Layout(
        screenName: 'LỊCH SỬ ĐƠN HÀNG',
        child: Column(
          children: [
            // Nút quay lại - nằm ngay dưới tiêu đề, phía trên list order
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: contentTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: contentTheme.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: contentTheme.primary,
                        ),
                        MySpacing.width(8),
                        MyText.bodyMedium(
                          'Quay lại giỏ hàng',
                          color: contentTheme.primary,
                          fontWeight: 700, // ← Sửa fontWeight thành int (fix lỗi 2)
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Nội dung list order
            Expanded(
              child: _OrderHistoryBody(ctrl: ctrl),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderHistoryBody extends StatelessWidget with UIMixin {
  final OrderHistoryController ctrl;
  const _OrderHistoryBody({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(60), child: CircularProgressIndicator()));
    }

    if (ctrl.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.error_outline, size: 52, color: Colors.red.shade300),
            MySpacing.height(12),
            MyText.bodyMedium(ctrl.errorMessage!, color: Colors.red),
            MySpacing.height(16),
            ElevatedButton.icon(
              onPressed: ctrl.loadOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ]),
        ),
      );
    }

    if (ctrl.orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.receipt_long_outlined, size: 72, color: contentTheme.secondary.withOpacity(0.2)),
            MySpacing.height(16),
            MyText.titleMedium('Chưa có đơn hàng nào', muted: true),
            MySpacing.height(6),
            MyText.bodySmall('Các đơn hàng đã tạo sẽ hiển thị ở đây', muted: true),
          ]),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: ctrl.loadOrders,
      child: ListView.separated(
        padding: MySpacing.all(16),
        itemCount: ctrl.orders.length,
        separatorBuilder: (_, __) => MySpacing.height(12),
        itemBuilder: (ctx, i) {
          final order = ctrl.orders[i];
          return GestureDetector(
            onTap: () {
              Get.toNamed('/order-detail', arguments: order); // Chuyển sang OrderDetailScreen
            },
            child: _OrderCard(order: order),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// ORDER CARD
// ══════════════════════════════════════════════════════════════════

class _OrderCard extends StatefulWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> with UIMixin {
  bool _isDownloading = false;

  OrderModel get o => widget.order;

  @override
  Widget build(BuildContext context) {
    return MyCard(
      paddingAll: 0,
      borderRadiusAll: 14,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: mã đơn + status ──────────────────────────
          Container(
            padding: MySpacing.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: contentTheme.secondary.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon đơn hàng
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: contentTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.receipt_outlined,
                      size: 18, color: contentTheme.primary),
                ),
                MySpacing.width(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium(
                        o.orderCode,
                        style: TextStyle(
                          fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      MySpacing.height(3),
                      MyText.bodySmall(_formatDate(o.createdAt), muted: true),
                    ],
                  ),
                ),
                MySpacing.width(8),
                _StatusChip(status: o.status),
              ],
            ),
          ),

          // ── Thông tin khách hàng ─────────────────────────────
          Padding(
            padding: MySpacing.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên + SĐT
                if (o.customerName != null || o.customerPhone != null)
                  Row(children: [
                    Icon(Icons.person_outline, size: 13,
                        color: contentTheme.secondary.withValues(alpha: 0.6)),
                    MySpacing.width(5),
                    Expanded(
                      child: MyText.bodySmall(
                        [o.customerName, o.customerPhone]
                            .where((e) => e != null && e.isNotEmpty)
                            .join(' · '),
                        muted: true,
                      ),
                    ),
                  ]),

                if (o.customerName != null || o.customerPhone != null)
                  MySpacing.height(5),

                // Số sản phẩm + payment status
                Row(children: [
                  Icon(Icons.shopping_basket_outlined, size: 13,
                      color: contentTheme.secondary.withValues(alpha: 0.6)),
                  MySpacing.width(5),
                  MyText.bodySmall('${o.items.length} sản phẩm', muted: true),
                  const Spacer(),
                  _PaymentChip(status: o.paymentStatus),
                ]),

                MySpacing.height(8),

                // Số tiền
                Row(children: [
                  MyText.bodySmall('Tổng: ', muted: true),
                  MyText.bodyMedium(
                    _fmt(o.finalAmount),
                    style: TextStyle(
                      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Colors.green,
                    ),
                  ),
                  if (o.discountAmount > 0) ...[
                    MySpacing.width(6),
                    Container(
                      padding: MySpacing.xy(5, 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: MyText.labelSmall(
                        '-${_fmt(o.discountAmount)}',
                        color: contentTheme.danger,
                        fontWeight: 600,
                      ),
                    ),
                  ],
                ]),
              ],
            ),
          ),

          // ── 2 nút: Chi tiết + Invoice ─────────────────────────
          Padding(
            padding: MySpacing.all(12),
            child: Row(children: [
              // ── Chi tiết ──
              Expanded(
                child: _ActionButton(
                  icon: Icons.visibility_outlined,
                  label: 'Chi tiết',
                  onTap: () => Get.to(() => const InvoiceDetailsScreen(), arguments: o.id),
                  outlined: true,
                ),
              ),
              MySpacing.width(10),
              // ── Tạo invoice ──
              Expanded(
                child: _ActionButton(
                  icon: _isDownloading
                      ? Icons.hourglass_empty_rounded
                      : Icons.picture_as_pdf_outlined,
                  label: _isDownloading ? 'Đang tải...' : 'Xuất PDF',
                  onTap: _isDownloading ? null : _downloadInvoice,
                  outlined: false,
                  loading: _isDownloading,
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // ── Download invoice PDF ─────────────────────────────────────────
  Future<void> _downloadInvoice() async {
    setState(() => _isDownloading = true);

    try {
      final result = await SellerService.generateAndSendInvoice(o.id);

      if (result.isSuccess) {
        _showSuccess(result.message ?? 'Đã tạo và gửi hóa đơn thành công qua Telegram');
      } else {
        final errMsg = getErrorMessage(result.code, result.message ?? 'Lỗi không xác định');
        _showError(errMsg);
      }
    } catch (e) {
      _showError('Lỗi kết nối hoặc xử lý: $e');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────
  String _fmt(double amount) {
    final s = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '${s}đ';
  }

  String _formatDate(int? ts) {
    if (ts == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ══════════════════════════════════════════════════════════════════
// SMALL WIDGETS
// ══════════════════════════════════════════════════════════════════

class _StatusChip extends StatelessWidget with UIMixin {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color c;
    String label;
    switch (status) {
      case 'PENDING':
        c = Colors.orange; label = 'Chờ xử lý'; break;
      case 'CONFIRMED':
        c = Colors.blue; label = 'Xác nhận'; break;
      case 'PROCESSING':
        c = Colors.blue; label = 'Xử lý'; break;
      case 'COMPLETED':
        c = Colors.green; label = 'Hoàn thành'; break;
      case 'CANCELLED':
        c = Colors.red; label = 'Đã hủy'; break;
      default:
        c = Colors.grey; label = status;
    }
    return Container(
      padding: MySpacing.xy(8, 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
    );
  }
}

class _PaymentChip extends StatelessWidget with UIMixin {
  final String status;
  const _PaymentChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color c;
    String label;
    switch (status) {
      case 'PAID':     c = Colors.green;  label = 'Đã TT'; break;
      case 'UNPAID':   c = Colors.orange; label = 'Chưa TT'; break;
      case 'REFUNDED': c = Colors.blue;   label = 'Hoàn tiền'; break;
      default:         c = Colors.grey;   label = status;
    }
    return Container(
      padding: MySpacing.xy(6, 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
    );
  }
}

class _ActionButton extends StatelessWidget with UIMixin {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final bool loading;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.outlined,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = outlined ? contentTheme.secondary : contentTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: MySpacing.xy(0, 10),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : (onTap == null ? color.withValues(alpha: 0.4) : color),
          border: outlined ? Border.all(color: color.withValues(alpha: 0.35)) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: outlined ? color : contentTheme.onPrimary),
            )
                : Icon(icon, size: 14,
                color: outlined ? color : contentTheme.onPrimary),
            MySpacing.width(5),
            Text(label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: outlined ? color : contentTheme.onPrimary,
                )),
          ],
        ),
      ),
    );
  }
}