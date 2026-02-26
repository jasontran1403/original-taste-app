// lib/views/ui/components/ extended_ui/pos/history_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/helper/services/pos_service.dart';
import 'package:original_taste/views/ui/components/%20extended_ui/pos/report_export_widget.dart';

import '../pos_components.dart';

class PosHistoryScreen extends StatefulWidget {
  const PosHistoryScreen({super.key});

  @override
  State<PosHistoryScreen> createState() => _PosHistoryScreenState();
}

class _PosHistoryScreenState extends State<PosHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  List<PosShiftModel> _shifts = [];
  PosShiftModel? _selectedShift;
  List<PosOrderModel> _orders = [];
  bool _isLoadingShifts = true;
  bool _isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    setState(() {
      _isLoadingShifts = true;
      _selectedShift = null;
      _orders = [];
    });
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final shifts = await PosService.getShiftsByDate(dateStr);
      if (mounted) {
        final sorted = [...shifts]
          ..sort((a, b) => b.openTime.compareTo(a.openTime));
        setState(() => _shifts = sorted);
        if (sorted.isNotEmpty) _selectShift(sorted.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoadingShifts = false);
    }
  }

  Future<void> _selectShift(PosShiftModel shift) async {
    setState(() {
      _selectedShift = shift;
      _isLoadingOrders = true;
    });
    try {
      final orders = await PosService.getOrdersByShift(shift.id);
      if (mounted) setState(() => _orders = orders);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoadingOrders = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
            const ColorScheme.light(primary: Colors.deepOrange)),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadShifts();
    }
  }

  String _formatMoney(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _formatTime(int epoch) => DateFormat('HH:mm:ss')
      .format(DateTime.fromMillisecondsSinceEpoch(epoch));

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED': return Colors.green;
      case 'CANCELLED': return Colors.red;
      default: return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'COMPLETED': return 'Hoàn thành';
      case 'CANCELLED': return 'Đã hủy';
      default: return 'Chờ xử lý';
    }
  }

  // ── Yêu cầu 4: Badge label + màu theo source ──
  String _sourceLabel(String source) {
    switch (source) {
      case 'SHOPEE_FOOD': return 'Shopee';
      case 'GRAB_FOOD':   return 'Grab';
      default:            return 'Offline';
    }
  }

  Color _sourceColor(String source) {
    switch (source) {
      case 'SHOPEE_FOOD': return const Color(0xFFEE4D2D); // Shopee đỏ cam
      case 'GRAB_FOOD':   return const Color(0xFF00B14F); // Grab xanh lá
      default:            return Colors.lightBlue;         // Offline xanh nhạt
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Lịch sử đơn hàng',
            style: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          ExportReportButton(selectedShift: _selectedShift),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
            style: TextButton.styleFrom(foregroundColor: Colors.deepOrange),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildShiftSelector(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  Widget _buildShiftSelector() {
    if (_isLoadingShifts) {
      return const Padding(
          padding: EdgeInsets.all(12), child: LinearProgressIndicator());
    }
    if (_shifts.isEmpty) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(14),
        child: Center(
          child: Text(
            'Không có ca làm việc ngày ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _shifts.map((shift) {
                final isSelected = _selectedShift?.id == shift.id;
                return GestureDetector(
                  onTap: () => _selectShift(shift),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.green.shade50
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isSelected
                              ? Colors.green.shade400
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Icon(
                            shift.isOpen
                                ? Icons.play_circle_fill
                                : Icons.check_circle,
                            size: 14,
                            color: shift.isOpen
                                ? Colors.green.shade600
                                : Colors.red.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(shift.staffName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.green.shade800
                                      : Colors.black87)),
                        ]),
                        Row(children: [
                          Icon(Icons.login,
                              size: 16, color: Colors.lightBlue),
                          const SizedBox(width: 3),
                          Text(_formatTime(shift.openTime),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.lightBlue)),
                        ]),
                        if (!shift.isOpen && shift.closeTime != null)
                          Row(children: [
                            Icon(Icons.logout,
                                size: 16, color: Colors.red.shade300),
                            const SizedBox(width: 3),
                            Text(_formatTime(shift.closeTime!),
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red.shade300)),
                          ]),
                        Text(
                          '${shift.totalOrders} đơn · ${_formatMoney(shift.totalRevenue)}đ',
                          style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? Colors.green.shade700
                                  : Colors.deepOrange),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (_selectedShift != null)
            _buildShiftSummaryBar(_selectedShift!),
        ],
      ),
    );
  }

  Widget _buildShiftSummaryBar(PosShiftModel shift) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SummaryItem(
              label: 'Tổng đơn',
              value: '${shift.totalOrders}',
              icon: Icons.receipt_long),
          _SummaryItem(
              label: 'Doanh thu',
              value: '${_formatMoney(shift.totalRevenue)}đ',
              icon: Icons.trending_up),
          if (shift.openingCash != null)
            _SummaryItem(
                label: 'Tiền đầu ca',
                value: '${_formatMoney(shift.openingCash!)}đ',
                icon: Icons.account_balance_wallet_outlined),
          if (shift.closingCash != null)
            _SummaryItem(
                label: 'Tiền cuối ca',
                value: '${_formatMoney(shift.closingCash!)}đ',
                icon: Icons.payments_outlined),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_isLoadingOrders) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_selectedShift == null) {
      return const Center(
          child: Text('Chọn ca để xem đơn hàng',
              style: TextStyle(color: Colors.grey)));
    }
    if (_orders.isEmpty) {
      return const Center(
          child: Text('Ca này chưa có đơn hàng',
              style: TextStyle(color: Colors.grey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _OrderCard(
        order: _orders[i],
        formatMoney: _formatMoney,
        formatTime: _formatTime,
        statusColor: _statusColor,
        statusLabel: _statusLabel,
        sourceLabel: _sourceLabel,
        sourceColor: _sourceColor,
        onReloadOrders: () => _selectShift(_selectedShift!), // Reload chỉ ca hiện tại
        onOrderCancelled: (id) => setState(() {
          final idx = _orders.indexWhere((o) => o.id == id);
          if (idx != -1) {
            _orders[idx] = PosOrderModel(
              id: _orders[idx].id, orderCode: _orders[idx].orderCode,
              shiftId: _orders[idx].shiftId, staffName: _orders[idx].staffName,
              orderSource: _orders[idx].orderSource, status: 'CANCELLED',
              totalAmount: _orders[idx].totalAmount, finalAmount: _orders[idx].finalAmount,
              totalVat: _orders[idx].totalVat, note: _orders[idx].note,
              paymentMethod: _orders[idx].paymentMethod,
              createdAt: _orders[idx].createdAt, updatedAt: _orders[idx].updatedAt,
              items: _orders[idx].items,
            );
          }
        }),
      ),
    );
  }
}

// ════════════════════════════════════════
// Order Card
// ════════════════════════════════════════

class _OrderCard extends StatefulWidget {
  final PosOrderModel order;
  final String Function(double) formatMoney;
  final String Function(int) formatTime;
  final Color Function(String) statusColor;
  final String Function(String) statusLabel;
  final String Function(String) sourceLabel;
  final Color Function(String) sourceColor;
  final void Function(int orderId)? onOrderCancelled;
  final VoidCallback onReloadOrders; // Callback reload danh sách đơn của ca

  const _OrderCard({
    required this.order,
    required this.formatMoney,
    required this.formatTime,
    required this.statusColor,
    required this.statusLabel,
    required this.sourceLabel,
    required this.sourceColor,
    this.onOrderCancelled,
    required this.onReloadOrders,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  // Tính tổng VAT của order từ items
  double _calcTotalVat(List<PosOrderItemModel> items) =>
      items.fold(0.0, (s, i) => s + i.vatAmount);

  // VAT breakdown: vatPercent → tổng vatAmount
  Map<int, double> _calcVatBreakdown(List<PosOrderItemModel> items) {
    final map = <int, double>{};
    for (final item in items) {
      if (item.vatPercent > 0 && item.vatAmount > 0) {
        map[item.vatPercent] = (map[item.vatPercent] ?? 0) + item.vatAmount;
      }
    }
    return map;
  }

  Future<void> _showSwitchPaymentDialog(
      BuildContext context,
      PosOrderModel order,
      VoidCallback onSuccess,
      ) async {
    final currentMethod = order.paymentMethod;
    final newMethod = currentMethod == 'CASH' ? 'TRANSFER' : 'CASH';
    final newLabel = newMethod == 'CASH' ? 'Tiền mặt' : 'Chuyển khoản';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              currentMethod == 'CASH' ? Icons.account_balance_outlined : Icons.payments_outlined,
              color: currentMethod == 'CASH' ? Colors.blue : Colors.green,
            ),
            const SizedBox(width: 8),
            Text('Đổi phương thức thanh toán', style: TextStyle(color: Colors.deepOrange)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn: ${order.orderCode}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Hiện tại: ${currentMethod == 'CASH' ? 'Tiền mặt' : 'Chuyển khoản'}'),
            const SizedBox(height: 8),
            Text('Bạn muốn đổi sang: $newLabel?', style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent,
              foregroundColor: Colors.white,  // Màu chữ/icon mặc định khi nhấn/hover
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Xác nhận',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await PosService.updateOrderPaymentMethod(order.id, newMethod);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã đổi thành $newLabel'),
          backgroundColor: Colors.green,
        ),
      );
      onSuccess(); // Reload danh sách đơn của ca hiện tại
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final totalVat = _calcTotalVat(o.items);
    final vatBreakdown = _calcVatBreakdown(o.items);
    final hasVat = totalVat > 0;
    final grandTotal = o.finalAmount + totalVat;

    final paymentLabel = o.paymentMethod == 'CASH' ? 'Tiền mặt' : 'Chuyển khoản';
    final paymentColor = o.paymentMethod == 'CASH' ? Colors.green : Colors.blue;
    final paymentIcon = o.paymentMethod == 'CASH' ? Icons.payments_outlined : Icons.account_balance_outlined;
    final isCancelled = o.status == 'CANCELLED';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 6)],
      ),
      child: Column(
        children: [
          // ── Header (luôn hiển thị) ──
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Source badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.sourceColor(o.orderSource).withOpacity(0.13),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.sourceLabel(o.orderSource),
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.sourceColor(o.orderSource),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Payment method badge - click để đổi nếu chưa hủy
                  GestureDetector(
                    onTap: isCancelled
                        ? null
                        : () => _showSwitchPaymentDialog(
                      context,
                      o,
                      widget.onReloadOrders,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCancelled ? Colors.grey.withOpacity(0.13) : paymentColor.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            paymentIcon,
                            size: 12,
                            color: isCancelled ? Colors.grey : paymentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$paymentLabel',
                            style: TextStyle(
                              fontSize: 11,
                              color: isCancelled ? Colors.grey : paymentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.orderCode,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          widget.formatTime(o.createdAt),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Tổng tiền + VAT + Status badge
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.formatMoney(grandTotal)}đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          fontSize: 15,
                        ),
                      ),
                      if (hasVat)
                        Text(
                          'VAT +${widget.formatMoney(totalVat)}đ',
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.statusColor(o.status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.statusLabel(o.status),
                          style: TextStyle(
                            fontSize: 10,
                            color: widget.statusColor(o.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded content ──
          if (_expanded) ...[
            Divider(height: 1, color: Colors.grey[200]),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Danh sách items
                  ...o.items.map((item) => _OrderItemRow(
                    item: item,
                    formatMoney: widget.formatMoney,
                  )),

                  // Ghi chú
                  if (o.note != null && o.note!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes, size: 14, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              o.note!,
                              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Divider(height: 1, color: Colors.grey[200]),
                  const SizedBox(height: 8),

                  // Tạm tính
                  _billRow('Tạm tính', '${widget.formatMoney(o.totalAmount)}đ'),

                  // VAT breakdown
                  if (hasVat) ...[
                    const SizedBox(height: 4),
                    ...(vatBreakdown.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
                        .map((e) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _billRow(
                        'Thuế VAT ${e.key}%',
                        '+${widget.formatMoney(e.value)}đ',
                        color: Colors.grey[600],
                      ),
                    )),
                    const SizedBox(height: 6),
                    Divider(height: 1, color: Colors.grey[200]),
                  ],

                  const SizedBox(height: 8),

                  // Tổng cộng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        '${widget.formatMoney(o.finalAmount)}đ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Dòng cuối: Thanh toán (click đổi) + Hủy đơn (nếu chưa hủy) ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Thanh toán: ... (click để đổi nếu chưa hủy)
                      GestureDetector(
                        onTap: isCancelled
                            ? null
                            : () => _showSwitchPaymentDialog(
                          context,
                          o,
                          widget.onReloadOrders,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              paymentIcon,
                              size: 16,
                              color: isCancelled ? Colors.grey : paymentColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Phương thức thanh toán: $paymentLabel',
                              style: TextStyle(
                                fontSize: 14,
                                color: isCancelled ? Colors.grey : paymentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Nút hủy đơn (chỉ hiện nếu chưa hủy)
                      if (!isCancelled)
                        TextButton.icon(
                          onPressed: () => showCancelOrderDialog(
                            context,
                            o,
                            onCancelled: () {
                              widget.onReloadOrders(); // Reload sau hủy
                            },
                          ),
                          icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                          label: const Text('Hủy đơn', style: TextStyle(color: Colors.red, fontSize: 14)),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Helper bill row
Widget _billRow(String label, String value, {Color? color}) {
  final c = color ?? Colors.black87;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: c)),
        Text(value,
            style: TextStyle(
                fontSize: 12, color: c, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

// ════════════════════════════════════════
// Order Item Row
// ════════════════════════════════════════

class _OrderItemRow extends StatelessWidget {
  final PosOrderItemModel item;
  final String Function(double) formatMoney;

  const _OrderItemRow({required this.item, required this.formatMoney});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.productImageUrl != null
                ? CachedNetworkImage(
              imageUrl:
              PosService.buildImageUrl(item.productImageUrl),
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _imgFallback(),
            )
                : _imgFallback(),
          ),
          const SizedBox(width: 10),

          // Tên + NL + badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên + badge số lượng
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                        border:
                        Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text('x${item.quantity}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                    ),
                  ],
                ),

                // Discount badge
                if (item.discountPercent > 0) ...[
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: item.discountPercent == 100
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.discountPercent == 100
                          ? 'Miễn phí'
                          : 'Giảm ${item.discountPercent}%',
                      style: TextStyle(
                          fontSize: 10,
                          color: item.discountPercent == 100
                              ? Colors.red
                              : Colors.green),
                    ),
                  ),
                ],

                // Nguyên liệu — không hiện tên biến thể, chỉ hiện NL
                if (item.selectedIngredients.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...item.selectedIngredients.map((si) {
                    final totalQty = si.selectedCount * item.quantity;
                    return Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(children: [
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(right: 5, top: 1),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepOrange),
                        ),
                        Text('${si.ingredientName} x$totalQty',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ]),
                    );
                  }),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Giá
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${formatMoney(item.subtotal)}đ',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87),
              ),
              Text(
                '${formatMoney(item.finalUnitPrice)}/sp',
                style:
                const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.fastfood, color: Colors.grey, size: 22),
  );
}

// ════════════════════════════════════════
// Summary Item
// ════════════════════════════════════════

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.deepOrange),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}