import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/services/seller_services.dart';

class OrderDetailController extends MyController {
  OrderModel? order;
  bool isLoading = false;
  String? errorMessage;
  bool isDownloading = false; // ← Thêm biến này

  OrderDetailController({this.order});

  @override
  void onInit() {
    super.onInit();
    if (order == null) {
      errorMessage = 'Không tìm thấy thông tin đơn hàng';
      update();
    } else {
      isLoading = false;
      update();
    }
  }

  Future<void> downloadInvoice(OrderModel o) async {

  }


  // ── Progress steps dựa trên status thực ────────────────────────
  List<ProgressStep> get steps {
    final s = order?.status ?? '';
    final p = order?.paymentStatus ?? '';

    final payDone    = p == 'PAID';
    final processD   = s == 'PROCESSING' || s == 'COMPLETED' || s == 'CONFIRMED';
    final completedD = s == 'COMPLETED';
    final cancelled  = s == 'CANCELLED';

    return [
      ProgressStep('Tạo đơn',    1.0,  Colors.green,  false),
      ProgressStep('Thanh toán', payDone ? 1.0 : 0.4,
          payDone ? Colors.green : Colors.orange, p == 'UNPAID'),
      ProgressStep('Xử lý',     processD ? 1.0 : 0.0,
          cancelled ? Colors.red : (processD ? Colors.green : Colors.blue),
          s == 'PROCESSING'),
      ProgressStep('Hoàn thành', completedD ? 1.0 : 0.0,
          cancelled ? Colors.red : Colors.green, false),
    ];
  }

  String get statusLabel {
    switch (order?.status) {
      case 'PENDING':    return 'Chờ xử lý';
      case 'CONFIRMED':  return 'Đã xác nhận';
      case 'PROCESSING': return 'Đang xử lý';
      case 'COMPLETED':  return 'Hoàn thành';
      case 'CANCELLED':  return 'Đã hủy';
      default:           return order?.status ?? '';
    }
  }

  Color get statusColor {
    switch (order?.status) {
      case 'PENDING':    return Colors.orange;
      case 'CONFIRMED':  return Colors.blue;
      case 'PROCESSING': return Colors.blue;
      case 'COMPLETED':  return Colors.green;
      case 'CANCELLED':  return Colors.red;
      default:           return Colors.grey;
    }
  }

  String get paymentStatusLabel {
    switch (order?.paymentStatus) {
      case 'PAID':     return 'Đã thanh toán';
      case 'UNPAID':   return 'Chưa thanh toán';
      case 'REFUNDED': return 'Đã hoàn tiền';
      default:         return order?.paymentStatus ?? '';
    }
  }

  Color get paymentStatusColor {
    switch (order?.paymentStatus) {
      case 'PAID':     return Colors.green;
      case 'UNPAID':   return Colors.orange;
      case 'REFUNDED': return Colors.blue;
      default:         return Colors.grey;
    }
  }

  String get paymentMethodLabel {
    switch (order?.paymentMethod) {
      case 'CASH':          return 'Tiền mặt';
      case 'BANK_TRANSFER': return 'Chuyển khoản';
      default:              return order?.paymentMethod ?? 'Tiền mặt';
    }
  }

  String formatCurrency(double amount) {
    final s = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '${s}đ';
  }

  String formatTimestamp(int? ts) {
    if (ts == null) return '—';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

class ProgressStep {
  final String label;
  final double progress;
  final Color color;
  final bool loading;

  const ProgressStep(this.label, this.progress, this.color, this.loading);
}