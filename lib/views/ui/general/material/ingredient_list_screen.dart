// views/ui/general/ingredient/ingredient_list_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

import '../../../../controller/seller/ingredient_list_controller.dart';
import '../../../../helper/services/seller_services.dart';
import '../../../../models/import_warehouse_model.dart';
import '../inventory/import_warehouse_controller.dart';
import '../inventory/inventory_history_screen.dart';
import '../inventory/qr_import_screen.dart';
import 'ingredient_create_screen.dart';
import 'ingredient_edit_screen.dart';
import 'manual_import_screen.dart';

class IngredientListScreen extends StatefulWidget {
  const IngredientListScreen({super.key});

  @override
  State<IngredientListScreen> createState() => _IngredientListScreenState();
}

class _IngredientListScreenState extends State<IngredientListScreen>
    with UIMixin, SingleTickerProviderStateMixin {
  late IngredientListController controller;
  late ImportWarehouseController _importCtrl;
  final ScrollController _scrollController = ScrollController();

  late AnimationController _scanLineController;
  final Map<int, TextEditingController> _quantityControllers = {};

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<IngredientListController>()) {
      Get.delete<IngredientListController>(force: true);
    }
    controller = Get.put(IngredientListController());
    _scrollController.addListener(_onScroll);

    final tag = 'import_wh_ingredient_${DateTime.now().millisecondsSinceEpoch}';
    _importCtrl = Get.put(ImportWarehouseController(), tag: tag);

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scanLineController.dispose();
    _quantityControllers.values.forEach((c) => c.dispose());
    Get.delete<IngredientListController>(force: true);
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<IngredientListController>(
      init: controller,
      builder: (controller) {
        return GetBuilder<ImportWarehouseController>(
          init: _importCtrl,
          builder: (importCtrl) {
            return Layout(
              screenName: "QUẢN LÝ NGUYÊN LIỆU",
              child: Stack(
                children: [
                  Padding(
                    padding: MySpacing.all(20),
                    child: _buildIngredientTable(),
                  ),
                  if (importCtrl.isScanning) _buildQRScanner(importCtrl),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────

  Widget _buildTableHeader() {
    return Padding(
      padding: MySpacing.all(20),
      child: Row(
        children: [
          Expanded(
            child: MyText.titleMedium(
              'Tất cả nguyên liệu',
              style: TextStyle(
                fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          MyContainer(
            onTap: _goToManualImport,
            color: const Color(0xFF5C6BC0),
            paddingAll: 8,
            borderRadiusAll: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit_note_rounded, color: Colors.white, size: 16),
                MySpacing.width(4),
                MyText.bodyMedium('Nhập thủ công', color: Colors.white, fontWeight: 600),
              ],
            ),
          ),
          MySpacing.width(8),
          MyContainer(
            onTap: () => Get.to(() => const QRImportScreen()),
            color: const Color(0xFF009688),
            paddingAll: 8,
            borderRadiusAll: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 16),
                MySpacing.width(4),
                MyText.bodyMedium('Nhập QR', color: Colors.white, fontWeight: 600),
              ],
            ),
          ),
          MySpacing.width(8),
          MyContainer(
            onTap: _goToCreate,
            color: contentTheme.primary,
            paddingAll: 8,
            borderRadiusAll: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add, color: contentTheme.onPrimary, size: 16),
                MySpacing.width(4),
                MyText.bodyMedium('Thêm nguyên liệu', color: contentTheme.onPrimary),
              ],
            ),
          ),
          MySpacing.width(8),
          MyContainer(
            onTap: () => controller.fetchIngredients(refresh: true),
            color: contentTheme.secondary.withValues(alpha: 0.1),
            paddingAll: 8,
            borderRadiusAll: 12,
            child: Icon(Icons.refresh, color: contentTheme.secondary, size: 18),
          ),
        ],
      ),
    );
  }

  // ── Table ─────────────────────────────────────────────────────────

  Widget _buildIngredientTable() {
    return MyCard(
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTableHeader(),
          const Divider(height: 0),
          if (controller.isLoading.value && controller.ingredientList.isEmpty)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (controller.errorMessage.value != null)
            Padding(
              padding: MySpacing.all(32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: contentTheme.danger),
                    MySpacing.height(12),
                    MyText.bodyMedium(controller.errorMessage.value!,
                        color: contentTheme.danger),
                    MySpacing.height(12),
                    MyContainer(
                      onTap: () => controller.fetchIngredients(refresh: true),
                      color: contentTheme.primary,
                      paddingAll: 10,
                      borderRadiusAll: 8,
                      child: MyText.bodyMedium('Thử lại', color: contentTheme.onPrimary),
                    ),
                  ],
                ),
              ),
            )
          else if (controller.ingredientList.isEmpty)
              Padding(
                padding: MySpacing.all(48),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 64,
                          color: contentTheme.secondary.withValues(alpha: 0.3)),
                      MySpacing.height(16),
                      MyText.bodyLarge('Chưa có nguyên liệu nào', muted: true),
                      MySpacing.height(12),
                      MyContainer(
                        onTap: _goToCreate,
                        color: contentTheme.primary,
                        padding: MySpacing.xy(20, 10),
                        borderRadiusAll: 8,
                        child: MyText.bodyMedium('Thêm nguyên liệu đầu tiên',
                            color: contentTheme.onPrimary),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(  // ← Thêm Expanded ở đây để bảng chiếm hết không gian còn lại
                child: _buildDataTableWithPagination(),
              ),
        ],
      ),
    );
  }

  Widget _buildDataTableWithPagination() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDataTable(),
        if (controller.isLoading.value && controller.ingredientList.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (!controller.hasMoreData.value)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: MyText.bodySmall(
              'Đã hiển thị tất cả ${controller.ingredientList.length} nguyên liệu',
              muted: true,
            ),
          ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Expanded(  // ← Thêm Expanded để giới hạn chiều cao
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // ── Header row ─────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: contentTheme.secondary.withAlpha(12),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  _headerCell('Tên nguyên liệu', flex: 3, align: TextAlign.left),
                  _headerCell('Tồn kho', flex: 2, align: TextAlign.center),
                  _headerCell('Hạn dùng', flex: 2, align: TextAlign.center),
                  _headerCell('Thao tác', flex: 2, align: TextAlign.right),
                ],
              ),
            ),

            // ── Data rows ──────────────────────────────────────────
            ...controller.ingredientList.asMap().entries.map((entry) {
              final index = entry.key;
              final ing = entry.value;
              final isEven = index % 2 == 0;
              return _buildRow(ing, isEven);
            }),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, {required int flex, required TextAlign align}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: contentTheme.secondary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IngredientModel ing, bool isEven) {
    return Container(
      decoration: BoxDecoration(
        color: isEven ? Colors.transparent : contentTheme.secondary.withAlpha(4),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Tên nguyên liệu ──────────────────────────────────
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () => Get.to(
                    () => const InventoryHistoryScreen(),
                arguments: ing,
              ),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    // Avatar icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: contentTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 18,
                        color: contentTheme.primary,
                      ),
                    ),
                    MySpacing.width(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ing.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: contentTheme.onBackground,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          MySpacing.height(2),
                          Text(
                            'ID: ${ing.id}',
                            style: TextStyle(
                              fontSize: 11,
                              color: contentTheme.secondary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: contentTheme.secondary.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Tồn kho ──────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _stockColor(ing.stockQuantity).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${ing.stockQuantity} ${ing.unit}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: _stockColor(ing.stockQuantity),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),

          // ── Hạn dùng ─────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Center(
                child: ing.expiryDate != null
                    ? _buildExpiryBadge(ing.expiryDate!)
                    : Text(
                  '--',
                  style: TextStyle(
                    fontSize: 13,
                    color: contentTheme.secondary.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // ── Thao tác ─────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionBtn(
                    icon: Icons.edit_outlined,
                    color: contentTheme.primary,
                    onTap: () => _goToEdit(ing),
                  ),
                  // MySpacing.width(8),
                  // _actionBtn(
                  //   icon: Icons.delete_outline_rounded,
                  //   color: contentTheme.danger,
                  //   onTap: () => _confirmDelete(ing),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Color _stockColor(double qty) {
    if (qty <= 0) return Colors.red.shade600;
    if (qty <= 5) return Colors.orange.shade600;
    return Colors.green.shade600;
  }

  Widget _buildExpiryBadge(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = dt.difference(now).inDays;

    Color color;
    if (diff < 0) {
      color = Colors.red.shade600;
    } else if (diff <= 7) {
      color = Colors.orange.shade600;
    } else {
      color = contentTheme.secondary;
    }

    return Text(
      _formatDate(timestamp),
      style: TextStyle(
        fontSize: 13,
        fontWeight: diff <= 7 ? FontWeight.w600 : FontWeight.w400,
        color: color,
      ),
      textAlign: TextAlign.center,
    );
  }

  // ── QR Scanner (giữ nguyên từ bản cũ) ────────────────────────────

  Widget _buildQRScanner(ImportWarehouseController ctrl) {
    return Container(
      color: Colors.black.withOpacity(0.92),
      child: Stack(
        children: [
          Positioned(
            top: 40,
            left: 16,
            child: InkWell(
              focusNode: FocusNode(canRequestFocus: false),
              onTap: ctrl.closeQRScanner,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.close_rounded, size: 28, color: Colors.black87),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ctrl.showProductInfo || ctrl.scanErrorMessage != null
                      ? 'Kết quả quét'
                      : 'Đặt mã QR vào khung để quét',
                  style: GoogleFonts.hankenGrotesk(
                      color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70, width: 2.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      ...[
                        Alignment.topLeft,
                        Alignment.topRight,
                        Alignment.bottomLeft,
                        Alignment.bottomRight,
                      ].map((align) => _buildCorner(align)),
                      if (!ctrl.showProductInfo && ctrl.scanErrorMessage == null)
                        AnimatedBuilder(
                          animation: _scanLineController,
                          builder: (context, _) {
                            if (ctrl.shouldResetScanLine) {
                              _scanLineController.value = 0.0;
                              ctrl.shouldResetScanLine = false;
                              _scanLineController.forward(from: 0.0);
                            }
                            final topPos = _scanLineController.value * 260 + 10;
                            return Positioned(
                              top: topPos,
                              left: 12,
                              right: 12,
                              child: Container(
                                height: 4,
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
                                        color: const Color(0xFF009688).withOpacity(0.7),
                                        blurRadius: 12,
                                        spreadRadius: 2),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!ctrl.showProductInfo && ctrl.scanErrorMessage == null)
                  Text(
                    'Hướng camera vào mã QR trên bao bì',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.6), fontSize: 13),
                  ),
              ],
            ),
          ),
          if (ctrl.showProductInfo && ctrl.scannedProduct != null)
            Positioned(
                bottom: 0, left: 0, right: 0,
                child: _buildProductInfoModal(ctrl)),
          if (ctrl.scanErrorMessage != null)
            Positioned(
              bottom: 80, left: 24, right: 24,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.white, size: 48),
                      const SizedBox(height: 12),
                      Text('Lỗi quét QR',
                          style: GoogleFonts.hankenGrotesk(
                              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(ctrl.scanErrorMessage!,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            focusNode: FocusNode(canRequestFocus: false),
                            onPressed: ctrl.scanAgain,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Quét lại'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            focusNode: FocusNode(canRequestFocus: false),
                            onPressed: ctrl.closeQRScanner,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Đóng'),
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
    );
  }

  Widget _buildCorner(Alignment alignment) {
    final isTop = alignment == Alignment.topLeft || alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft || alignment == Alignment.bottomLeft;
    return Align(
      alignment: alignment,
      child: Container(
        width: 30, height: 30,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Color(0xFF009688), width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Color(0xFF009688), width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Color(0xFF009688), width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Color(0xFF009688), width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfoModal(ImportWarehouseController ctrl) {
    final qtyCtrl = _quantityControllers.putIfAbsent(
        0, () => TextEditingController(text: '1'));
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 25,
              spreadRadius: 5,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.green, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Quét QR thành công!',
                  style: GoogleFonts.hankenGrotesk(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: Colors.green.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),
          _buildInfoRow('Sản phẩm:', ctrl.scannedProduct!.productName),
          _buildInfoRow('NSX:',
              DateFormat('dd/MM/yyyy').format(ctrl.scannedProduct!.manufacturingDate)),
          _buildInfoRow('HSD:',
              DateFormat('dd/MM/yyyy').format(ctrl.scannedProduct!.expiryDate)),
          _buildInfoRow('KL gói:', ctrl.scannedProduct!.packageWeight),
          _buildInfoRow('KL mẻ:', ctrl.scannedProduct!.batchWeight),
          const SizedBox(height: 20),
          const Text('Nhập số lượng:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl.quantityController,
            keyboardType: TextInputType.number,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Nhập số lượng',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: contentTheme.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  focusNode: FocusNode(canRequestFocus: false),
                  onPressed: ctrl.scanAgain,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: contentTheme.secondary, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Quét tiếp',
                      style: TextStyle(
                          color: contentTheme.secondary, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  focusNode: FocusNode(canRequestFocus: false),
                  onPressed: () {
                    ctrl.addProductToCurrentImport();
                    ctrl.closeQRScanner();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF009688),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Xác nhận nhập',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
              width: 90,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: TextStyle(color: contentTheme.primary))),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  String _formatDate(int timestamp) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _confirmDelete(IngredientModel ing) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa nguyên liệu "${ing.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Hủy')),
          TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa')),
        ],
      ),
    );
    if (confirm == true) {
      final success = await controller.deleteIngredient(ing.id, ing.name);
      if (success) {
        Get.snackbar('Thành công', 'Đã xóa nguyên liệu "${ing.name}"',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
            borderRadius: 8);
      }
    }
  }

  Future<void> _goToCreate() async {
    await Get.to(() => const IngredientCreateScreen());
    await controller.fetchIngredients(refresh: true);
  }

  Future<void> _goToManualImport() async {
    final result = await Get.to<bool>(() => const ManualImportScreen());
    if (result == true) await controller.fetchIngredients(refresh: true);
  }

  Future<void> _goToEdit(IngredientModel ing) async {
    await Get.to(() => const IngredientEditScreen(), arguments: ing);
    await controller.fetchIngredients(refresh: true);
  }
}