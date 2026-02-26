import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../models/import_warehouse_model.dart';
import 'import_warehouse_controller.dart';

class ImportWarehouseScreen extends StatefulWidget {
  const ImportWarehouseScreen({super.key});

  @override
  State<ImportWarehouseScreen> createState() => _ImportWarehouseScreenState();
}

class _ImportWarehouseScreenState extends State<ImportWarehouseScreen>
    with UIMixin, SingleTickerProviderStateMixin {
  late ImportWarehouseController controller;
  late AnimationController _scanLineController;
  final ScrollController _scrollController = ScrollController();

  // Map lưu controller cho từng ô SL (theo index) để giữ giá trị khi rebuild
  final Map<int, TextEditingController> _quantityControllers = {};

  // Timer cho debounce tìm kiếm theo tên
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    final tag = 'import_wh_${DateTime.now().millisecondsSinceEpoch}';
    controller = Get.put(ImportWarehouseController(), tag: tag);

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _scrollController.dispose();
    _quantityControllers.values.forEach((c) => c.dispose());
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: false,
      body: SafeArea(
        top: true,
        bottom: true,
        child: GetBuilder<ImportWarehouseController>(
          init: controller,
          builder: (ctrl) {
            if (ctrl.isLoading || ctrl.isFiltering) {
              return _buildSkeleton();
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: [
                    _buildSearchSection(ctrl),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: (ctrl.currentImport != null ? 1 : 0) +
                            ctrl.filteredList.length,
                        itemBuilder: (context, index) {
                          if (ctrl.currentImport != null && index == 0) {
                            return _buildImportCard(ctrl.currentImport!, true);
                          }
                          final actualIndex = ctrl.currentImport != null
                              ? index - 1
                              : index;
                          return _buildImportCard(ctrl.filteredList[actualIndex], false);
                        },
                      ),
                    ),
                  ],
                ),
                if (ctrl.isScanning) _buildQRScanner(ctrl),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              6,
                  (index) => Container(
                height: 150,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(ImportWarehouseController ctrl) {
    final hasFilter = ctrl.searchController.text.isNotEmpty || ctrl.selectedDate != null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
            onPressed: () async {
              Get.closeCurrentSnackbar();
              await Future.delayed(const Duration(milliseconds: 100));
              Get.back();
            },
            tooltip: 'Quay lại',
          ),
          const SizedBox(width: 8),

          Expanded(
            flex: 3,
            child: TextField(
              controller: ctrl.searchController,
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 900), () {
                  ctrl.searchByName(value);
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm theo tên người nhập...',
                prefixIcon: const Icon(Boxicons.bx_search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: ctrl.selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  ctrl.searchByDate(date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Boxicons.bx_calendar, size: 20, color: contentTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ctrl.selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(ctrl.selectedDate!)
                            : 'Chọn ngày',
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          InkWell(
            onTap: ctrl.openQRScanner,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: contentTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Boxicons.bx_qr_scan, color: Colors.white),
            ),
          ),

          if (hasFilter) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.clear_rounded, color: Colors.redAccent),
              onPressed: () {
                ctrl.searchController.clear();
                ctrl.selectedDate = null;
                ctrl.searchByName('');
              },
              tooltip: 'Xóa bộ lọc',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImportCard(ImportWarehouseModel import, bool isEditing) {
    return Container(
      key: ValueKey(import.id),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEditing)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: contentTheme.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Boxicons.bx_edit, color: contentTheme.warning, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Phiếu nhập đang soạn',
                    style: GoogleFonts.hankenGrotesk(
                      fontWeight: FontWeight.w700,
                      color: contentTheme.warning,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        import.importerName,
                        style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy - HH:mm').format(import.importTime),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: contentTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Đã lưu',
                    style: TextStyle(color: contentTheme.success, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...List.generate(
            import.products.length,
                (index) => _buildProductRow(import.products[index], index, isEditing),
          ),
          if (isEditing) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.saveCurrentImport,
                icon: const Icon(Boxicons.bx_save, size: 20),
                label: const Text('Lưu phiếu nhập'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: contentTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductRow(ImportProductItem product, int index, bool isEditing) {
    final qtyController = _quantityControllers.putIfAbsent(
      index,
          () => TextEditingController(text: product.quantity.toString()),
    );

    ImportProductItem getLatestProduct() {
      if (controller.currentImport == null || controller.currentImport!.products.length <= index) {
        return product;
      }
      return controller.currentImport!.products[index];
    }

    void syncTextField() {
      final latest = getLatestProduct();
      final latestText = latest.quantity.toString();
      if (qtyController.text != latestText) {
        qtyController.text = latestText;
        qtyController.selection = TextSelection.fromPosition(TextPosition(offset: latestText.length));
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => syncTextField());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: contentTheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: contentTheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(product.productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text('NSX: ${DateFormat('dd/MM/yyyy').format(product.manufacturingDate)}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                Text('HSD: ${DateFormat('dd/MM/yyyy').format(product.expiryDate)}', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('KL gói: ${product.packageWeight}', style: const TextStyle(fontSize: 11)),
                Text('KL mẻ: ${product.batchWeight}', style: const TextStyle(fontSize: 11)),
                if (isEditing)
                  SizedBox(
                    width: 90,
                    child: TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        FilteringTextInputFormatter.deny(RegExp(r'^0+(?=.)')),
                      ],
                      onChanged: (value) {
                        if (value.isEmpty) {
                          syncTextField();
                          return;
                        }

                        final newQty = int.tryParse(value);
                        if (newQty != null && newQty >= 0) {
                          if (controller.currentImport != null && controller.currentImport!.products.length > index) {
                            final latestProduct = getLatestProduct();
                            final updatedProduct = latestProduct.copyWith(quantity: newQty.toDouble());
                            final updatedProducts = List<ImportProductItem>.from(controller.currentImport!.products);
                            updatedProducts[index] = updatedProduct;
                            controller.currentImport = controller.currentImport!.copyWith(products: updatedProducts);
                            qtyController.text = newQty.toString(); // Đồng bộ text ngay
                            controller.update(); // Refresh UI ngay lập tức
                          }
                        } else {
                          syncTextField();
                        }
                      },
                      onSubmitted: (value) {
                        // Cập nhật lại một lần nữa để chắc chắn (Enter hoặc Done)
                        if (value.isEmpty) {
                          syncTextField();
                          return;
                        }
                        final newQty = int.tryParse(value);
                        if (newQty != null && newQty >= 0) {
                          if (controller.currentImport != null && controller.currentImport!.products.length > index) {
                            final latestProduct = getLatestProduct();
                            final updatedProduct = latestProduct.copyWith(quantity: newQty.toDouble());
                            final updatedProducts = List<ImportProductItem>.from(controller.currentImport!.products);
                            updatedProducts[index] = updatedProduct;
                            controller.currentImport = controller.currentImport!.copyWith(products: updatedProducts);
                            qtyController.text = newQty.toString();
                            controller.update();
                          }
                        } else {
                          syncTextField();
                        }
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  )
                else
                  Text(
                    'SL: ${getLatestProduct().quantity.toInt()}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
              ],
            ),
          ),
          if (isEditing) ...[
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionButton(Boxicons.bx_plus, contentTheme.success, () {
                  if (controller.currentImport != null && controller.currentImport!.products.length > index) {
                    final latestProduct = getLatestProduct();
                    final newQty = latestProduct.quantity.toInt() + 1;
                    final updatedProduct = latestProduct.copyWith(quantity: newQty.toDouble());
                    final updatedProducts = List<ImportProductItem>.from(controller.currentImport!.products);
                    updatedProducts[index] = updatedProduct;
                    controller.currentImport = controller.currentImport!.copyWith(products: updatedProducts);
                    qtyController.text = newQty.toString();
                    controller.update();
                  }
                }),
                const SizedBox(height: 4),
                _buildActionButton(Boxicons.bx_minus, contentTheme.warning, () {
                  if (controller.currentImport != null && controller.currentImport!.products.length > index) {
                    final latestProduct = getLatestProduct();
                    if (latestProduct.quantity.toInt() > 1) {
                      final newQty = latestProduct.quantity.toInt() - 1;
                      final updatedProduct = latestProduct.copyWith(quantity: newQty.toDouble());
                      final updatedProducts = List<ImportProductItem>.from(controller.currentImport!.products);
                      updatedProducts[index] = updatedProduct;
                      controller.currentImport = controller.currentImport!.copyWith(products: updatedProducts);
                      qtyController.text = newQty.toString();
                      controller.update();
                    }
                  }
                }),
                const SizedBox(height: 4),
                _buildActionButton(Boxicons.bx_trash, contentTheme.danger, () => controller.removeProductFromCurrent(index)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

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
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
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
                  style: GoogleFonts.hankenGrotesk(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
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
                      ...[Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight]
                          .map((align) => _buildCorner(align)),
                      if (!ctrl.showProductInfo && ctrl.scanErrorMessage == null)
                        AnimatedBuilder(
                          animation: _scanLineController,
                          builder: (context, _) {
                            double topPos = 10;
                            if (ctrl.shouldResetScanLine) {
                              _scanLineController.value = 0.0;
                              ctrl.shouldResetScanLine = false;
                              _scanLineController.forward(from: 0.0);
                            }
                            topPos = _scanLineController.value * 260 + 10;
                            return Positioned(
                              top: topPos,
                              left: 12,
                              right: 12,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0x00FF4081), Color(0xFFFF4081), Color(0x00FF4081)],
                                    stops: [0.0, 0.5, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(color: const Color(0xFFFF4081).withOpacity(0.7), blurRadius: 12, spreadRadius: 2),
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
          if (ctrl.showProductInfo && ctrl.scannedProduct != null)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildProductInfoModal(ctrl)),
          if (ctrl.scanErrorMessage != null)
            Positioned(
              bottom: 80,
              left: 24,
              right: 24,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.white, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Lỗi quét QR',
                        style: GoogleFonts.hankenGrotesk(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ctrl.scanErrorMessage!,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
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
        width: 30,
        height: 30,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Color(0xFFFF4081), width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Color(0xFFFF4081), width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Color(0xFFFF4081), width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Color(0xFFFF4081), width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfoModal(ImportWarehouseController ctrl) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 25, spreadRadius: 5, offset: const Offset(0, 10)),
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
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Quét QR thành công!',
                  style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.green.shade800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 16),
          _buildInfoRow('Sản phẩm:', ctrl.scannedProduct!.productName),
          _buildInfoRow('NSX:', DateFormat('dd/MM/yyyy').format(ctrl.scannedProduct!.manufacturingDate)),
          _buildInfoRow('HSD:', DateFormat('dd/MM/yyyy').format(ctrl.scannedProduct!.expiryDate)),
          _buildInfoRow('KL gói:', ctrl.scannedProduct!.packageWeight),
          _buildInfoRow('KL mẻ:', ctrl.scannedProduct!.batchWeight),
          const SizedBox(height: 24),
          const Text('Nhập số lượng:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl.quantityController,
            keyboardType: TextInputType.number,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép số nguyên
            ],
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Quét tiếp', style: TextStyle(color: contentTheme.secondary, fontWeight: FontWeight.w600)),
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
                    backgroundColor: contentTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Thêm & Đóng', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value, style: TextStyle(color: contentTheme.primary))),
        ],
      ),
    );
  }
}