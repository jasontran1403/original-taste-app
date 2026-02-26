import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'import_warehouse_controller.dart'; // import controller nếu cần

class QRScannerWidget extends StatefulWidget {
  final ImportWarehouseController controller;

  const QRScannerWidget({
    super.key,
    required this.controller,
  });

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;

    return Container(
      color: Colors.black.withOpacity(0.95),
      child: SafeArea(
        child: Stack(
          children: [
            // Nút đóng
            Positioned(
              top: 20,
              left: 20,
              child: InkWell(
                onTap: () {
                  ctrl.closeQRScanner();
                  Get.back(); // đóng dialog
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Boxicons.bx_x,
                    size: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Khung quét
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đặt mã QR vào khung để quét',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        ...[
                          Alignment.topLeft,
                          Alignment.topRight,
                          Alignment.bottomLeft,
                          Alignment.bottomRight,
                        ].map((alignment) => _buildCorner(alignment)),
                        if (!ctrl.showProductInfo)
                          AnimatedBuilder(
                            animation: _scanLineController,
                            builder: (context, child) {
                              return Positioned(
                                top: _scanLineController.value * 280 + 10,
                                left: 10,
                                right: 10,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9C27B0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9C27B0)
                                            .withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Modal thông tin sản phẩm
            if (ctrl.showProductInfo && ctrl.scannedProduct != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildProductInfoModal(ctrl),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    final isTop =
        alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft =
        alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;

    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Color(0xFF9C27B0), width: 4)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Color(0xFF9C27B0), width: 4)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Color(0xFF9C27B0), width: 4)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Color(0xFF9C27B0), width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfoModal(ImportWarehouseController ctrl) {
    // Copy nguyên phần modal từ code cũ của bạn
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (giữ nguyên toàn bộ nội dung modal của bạn)
          // Row header, Divider, _buildInfoRow, TextField, Row buttons...
          // (dán nguyên code cũ vào đây)
        ],
      ),
    );
  }

// Nếu cần _buildInfoRow thì copy vào đây hoặc import từ file chung
}