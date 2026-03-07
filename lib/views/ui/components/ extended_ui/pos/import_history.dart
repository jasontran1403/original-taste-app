import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/helper/services/pos_service.dart';

// ══════════════════════════════════════════════════════════════════
// CONTROLLER
// ══════════════════════════════════════════════════════════════════

class StockImportHistoryController extends GetxController {
  final batches       = <StockImportBatch>[].obs;
  final isLoading     = true.obs;
  final errorMsg      = ''.obs;
  final selectedIndex = 0.obs;
  final isChanging    = false.obs; // loading khi đổi card

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    errorMsg.value  = '';
    try {
      final result        = await PosService.getStockImportHistory();
      batches.value       = result;
      selectedIndex.value = 0;
    } catch (e) {
      errorMsg.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectBatch(int index) async {
    if (isChanging.value || selectedIndex.value == index) return;
    isChanging.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    selectedIndex.value = index;
    isChanging.value    = false;
  }

  StockImportBatch? get selectedBatch =>
      batches.isNotEmpty ? batches[selectedIndex.value] : null;
}

// ══════════════════════════════════════════════════════════════════
// SCREEN — StatefulWidget để force-reload mỗi lần mở tab
// ══════════════════════════════════════════════════════════════════

class StockImportHistoryScreen extends StatefulWidget {
  const StockImportHistoryScreen({super.key});

  @override
  State<StockImportHistoryScreen> createState() =>
      _StockImportHistoryScreenState();
}

class _StockImportHistoryScreenState extends State<StockImportHistoryScreen> {
  late StockImportHistoryController ctrl;

  @override
  void initState() {
    super.initState();
    // Xoá controller cũ (nếu còn) để luôn tạo mới + tự load API
    if (Get.isRegistered<StockImportHistoryController>()) {
      Get.delete<StockImportHistoryController>(force: true);
    }
    ctrl = Get.put(StockImportHistoryController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Lịch sử nhập kho',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Obx(() => ctrl.isLoading.value
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
              : IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: ctrl.loadHistory,
          )),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (ctrl.errorMsg.value.isNotEmpty) {
          return _ErrorView(
            message: ctrl.errorMsg.value,
            onRetry: ctrl.loadHistory,
          );
        }
        if (ctrl.batches.isEmpty) {
          return const _EmptyView();
        }
        return _HistoryBody(ctrl: ctrl);
      }),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  final StockImportHistoryController ctrl;
  const _HistoryBody({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hàng card ngang ─────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(ctrl.batches.length, (i) {
                    return _BatchHeaderCard(
                      batch:       ctrl.batches[i],
                      isActive:    ctrl.selectedIndex.value == i,
                      isLoading:   ctrl.isChanging.value && ctrl.selectedIndex.value != i,
                      onTap:       () => ctrl.selectBatch(i),
                    );
                  }),
                ),
              )),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFEEEEEE)),

        // ── Bảng chi tiết batch đang chọn ───────────────────────
        Expanded(
          child: Obx(() {
            // Hiệu ứng loading khi đổi card
            if (ctrl.isChanging.value) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 36, height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Đang tải...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            final batch = ctrl.selectedBatch;
            if (batch == null) return const SizedBox();
            return _BatchDetailTable(batch: batch);
          }),
        ),
      ],
    );
  }
}

class _BatchHeaderCard extends StatelessWidget {
  final StockImportBatch batch;
  final bool isActive;
  final bool isLoading;
  final VoidCallback onTap;
  const _BatchHeaderCard({
    required this.batch,
    required this.isActive,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dt      = DateTime.fromMillisecondsSinceEpoch(batch.importedAt);
    final timeStr = DateFormat('HH:mm').format(dt);
    final dateStr = DateFormat('dd/MM').format(dt);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 104,
        height: 104,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.deepOrange : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? Colors.deepOrange : Colors.grey.shade200,
            width: isActive ? 0 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Colors.deepOrange.withOpacity(0.28)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isActive ? 8 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              timeStr,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 11,
                color: isActive
                    ? Colors.white.withOpacity(0.8)
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 6),
            isLoading
                ? SizedBox(
              width: 18, height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.deepOrange.withOpacity(0.5),
              ),
            )
                : Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withOpacity(0.22)
                    : Colors.deepOrange.withOpacity(0.09),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${batch.totalItems} NL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : Colors.deepOrange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchDetailTable extends StatelessWidget {
  final StockImportBatch batch;
  const _BatchDetailTable({required this.batch});

  @override
  Widget build(BuildContext context) {
    final dt     = DateTime.fromMillisecondsSinceEpoch(batch.importedAt);
    final header = DateFormat('HH:mm:ss  •  dd/MM/yyyy').format(dt);
    final items  = batch.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sub-header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            const Icon(Icons.inventory_2_rounded,
                size: 15, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Text(
              'Nhập lúc $header',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ]),
        ),

        // Table
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  // Header row (chỉ còn 2 cột: Ảnh + Tên | Số bịch)
                  Container(
                    color: Colors.grey.shade50,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(children: [
                      const SizedBox(width: 48), // ảnh
                      _thText('Tên nguyên liệu', flex: 1),
                      _thCell('Số bịch', width: 80),
                    ]),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),

                  // Data rows
                  ...items.asMap().entries.map((e) {
                    final i    = e.key;
                    final item = e.value;
                    return Column(children: [
                      _DataRow(item: item),
                      if (i < items.length - 1)
                        const Divider(
                            height: 1,
                            indent: 64,
                            endIndent: 16,
                            color: Color(0xFFF0F0F0)),
                    ]);
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _thText(String label, {required int flex}) => Expanded(
    flex: flex,
    child: Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade500,
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget _thCell(String label, {required double width}) => SizedBox(
    width: width,
    child: Center(
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.4,
        ),
      ),
    ),
  );
}

class _DataRow extends StatelessWidget {
  final StockImportItemDetail item;
  const _DataRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final isMain     = item.isMain;
    final accent = isMain ? Colors.blue : Colors.purple;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        // Ảnh
        ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: item.ingredientImageUrl != null
              ? Image.network(
            item.ingredientImageUrl!,
            width: 38, height: 38, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _placeholder(accent),
          )
              : _placeholder(accent),
        ),
        const SizedBox(width: 10),

        // Tên nguyên liệu (flex để chiếm hết không gian)
        Expanded(
          child: Text(
            item.ingredientName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),

        // Số bịch (cột cuối)
        SizedBox(
          width: 80,
          child: Center(
            child: Text(
              '${item.packQty}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _placeholder(Color color) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Icon(Icons.fastfood_rounded, size: 16, color: color),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.inventory_2_outlined, size: 72, color: Colors.grey.shade300),
      const SizedBox(height: 16),
      Text('Chưa có lần nhập kho nào',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400)),
      const SizedBox(height: 6),
      Text('Lịch sử chỉ hiển thị khi ca đang mở',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
    ]),
  );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.error_outline_rounded,
            size: 52, color: Colors.red.shade300),
        const SizedBox(height: 12),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
        ),
      ]),
    ),
  );
}