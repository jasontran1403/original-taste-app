import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'import_warehouse_controller.dart';

class QRImportScreen extends StatefulWidget {
  const QRImportScreen({super.key});

  @override
  State<QRImportScreen> createState() => _QRImportScreenState();
}

class _QRImportScreenState extends State<QRImportScreen>
    with UIMixin, SingleTickerProviderStateMixin {
  late ImportWarehouseController controller;
  late MobileScannerController _cameraController;
  late AnimationController _scanLineController;

  final Map<int, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();

    final tag = 'qr_import_${DateTime.now().millisecondsSinceEpoch}';
    controller = Get.put(ImportWarehouseController(), tag: tag);

    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _scanLineController.dispose();
    for (var c in _quantityControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GetBuilder<ImportWarehouseController>(
        init: controller,
        builder: (ctrl) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Camera full screen ──
              MobileScanner(
                controller: _cameraController,
                onDetect: (capture) {
                  final raw = capture.barcodes.firstOrNull?.rawValue;
                  if (raw != null) {
                    _cameraController.stop();
                    ctrl.onQRDetected(raw);
                  }
                },
              ),

              // ── Dark overlay với lỗ trong suốt ──
              _buildOverlay(),

              // ── Header ──
              _buildHeader(ctrl),

              // ── Khung scan + scan line ──
              _buildScanFrame(ctrl),

              // ── Hint text ──
              if (!ctrl.showProductInfo && ctrl.scanErrorMessage == null)
                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Hướng camera vào mã QR trên bao bì',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

              // ── Modal kết quả thành công ──
              if (ctrl.showProductInfo && ctrl.scannedProduct != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildProductInfoModal(ctrl),
                ),

              // ── Modal lỗi ──
              if (ctrl.scanErrorMessage != null)
                Positioned(
                  bottom: 80,
                  left: 24,
                  right: 24,
                  child: _buildErrorModal(ctrl),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────

  Widget _buildHeader(ImportWarehouseController ctrl) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Nút back
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nhập kho',
                  style: GoogleFonts.hankenGrotesk(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Nút đèn flash
              GestureDetector(
                onTap: () => _cameraController.toggleTorch(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flashlight_on_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Overlay ───────────────────────────────────────────────────────

  Widget _buildOverlay() {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }

  // ── Scan frame + animation ────────────────────────────────────────

  Widget _buildScanFrame(ImportWarehouseController ctrl) {
    return Center(
      child: SizedBox(
        width: 260,
        height: 260,
        child: Stack(
          children: [
            // 4 góc teal
            ...[
              Alignment.topLeft,
              Alignment.topRight,
              Alignment.bottomLeft,
              Alignment.bottomRight,
            ].map((align) => _buildCorner(align)),

            // Scan line (chỉ khi chưa có kết quả)
            if (!ctrl.showProductInfo && ctrl.scanErrorMessage == null)
              AnimatedBuilder(
                animation: _scanLineController,
                builder: (context, _) {
                  if (ctrl.shouldResetScanLine) {
                    _scanLineController.value = 0.0;
                    ctrl.shouldResetScanLine = false;
                    _scanLineController.forward(from: 0.0);
                  }
                  final topPos = _scanLineController.value * 240 + 10;
                  return Positioned(
                    top: topPos,
                    left: 8,
                    right: 8,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0x00009688),
                            Color(0xFF009688),
                            Color(0x00009688),
                          ],
                          stops: [0.0, 0.5, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF009688).withOpacity(0.8),
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
        width: 28,
        height: 28,
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(color: Color(0xFF009688), width: 4)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Color(0xFF009688), width: 4)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Color(0xFF009688), width: 4)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Color(0xFF009688), width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── Product info modal ────────────────────────────────────────────

  Widget _buildProductInfoModal(ImportWarehouseController ctrl) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.green, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quét QR thành công!',
                  style: GoogleFonts.hankenGrotesk(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Info rows
          _buildInfoRow('Sản phẩm:', ctrl.scannedProduct!.productName),
          _buildInfoRow('NSX:',
              DateFormat('dd/MM/yyyy').format(ctrl.scannedProduct!.manufacturingDate)),
          _buildInfoRow('HSD:',
              DateFormat('dd/MM/yyyy').format(ctrl.scannedProduct!.expiryDate)),
          _buildInfoRow('KL gói:', ctrl.scannedProduct!.packageWeight),
          _buildInfoRow('KL mẻ:', ctrl.scannedProduct!.batchWeight),

          const SizedBox(height: 16),
          const Text('Nhập số lượng:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),

          // Quantity input
          TextField(
            controller: ctrl.quantityController,
            keyboardType: TextInputType.number,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Nhập số lượng',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                const BorderSide(color: Color(0xFF009688), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),

          const SizedBox(height: 20),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  focusNode: FocusNode(canRequestFocus: false),
                  onPressed: () {
                    ctrl.scanAgain();
                    _cameraController.start();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.grey, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Quét tiếp',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  focusNode: FocusNode(canRequestFocus: false),
                  onPressed: () {
                    ctrl.addProductToCurrentImport();
                    // Restart camera để quét tiếp
                    _cameraController.start();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF009688),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Xác nhận',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Error modal ───────────────────────────────────────────────────

  Widget _buildErrorModal(ImportWarehouseController ctrl) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3), blurRadius: 20)
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.white, size: 44),
            const SizedBox(height: 10),
            Text('Lỗi quét QR',
                style: GoogleFonts.hankenGrotesk(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(ctrl.scanErrorMessage!,
                style:
                const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  focusNode: FocusNode(canRequestFocus: false),
                  onPressed: () {
                    ctrl.scanAgain();
                    _cameraController.start();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Quét lại'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  focusNode: FocusNode(canRequestFocus: false),
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Đóng'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 85,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: Color(0xFF009688), fontSize: 13))),
        ],
      ),
    );
  }
}

// ── Custom painter cho overlay với lỗ trong suốt ──────────────────

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const frameSize = 260.0;
    final frameLeft = (size.width - frameSize) / 2;
    final frameTop = (size.height - frameSize) / 2;
    final frameRect = Rect.fromLTWH(frameLeft, frameTop, frameSize, frameSize);

    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    // Vẽ 4 vùng tối xung quanh khung
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, frameTop), paint); // top
    canvas.drawRect(
        Rect.fromLTWH(0, frameTop + frameSize, size.width,
            size.height - frameTop - frameSize),
        paint); // bottom
    canvas.drawRect(
        Rect.fromLTWH(0, frameTop, frameLeft, frameSize), paint); // left
    canvas.drawRect(
        Rect.fromLTWH(frameLeft + frameSize, frameTop,
            size.width - frameLeft - frameSize, frameSize),
        paint); // right
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}