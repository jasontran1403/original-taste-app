// views/ui/general/inventory/manual_import_screen.dart  v4
// Fix: toast dùng overlayContext (không bị huỷ khi pop), delay trước Get.back
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/helper/services/seller_services.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';

import '../../../../helper/widgets/my_container.dart';
import '../../../../helper/widgets/my_text.dart';
import '../../../seller/order_history_screen.dart';

final _ct = AdminTheme.theme.contentTheme;

class _BatchRow {
  final IngredientModel ingredient;
  double quantity;
  DateTime? expiryDate;
  _BatchRow({required this.ingredient, required this.quantity, this.expiryDate});
}

class ManualImportScreen extends StatefulWidget {
  const ManualImportScreen({super.key});
  @override
  State<ManualImportScreen> createState() => _ManualImportScreenState();
}

class _ManualImportScreenState extends State<ManualImportScreen> {
  List<IngredientModel> _allIngredients = [];
  List<IngredientModel> _filtered = [];
  final List<_BatchRow> _batch = [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  IngredientModel? _selected;
  final _qtyCtrl = TextEditingController();
  final _qtyFocus = FocusNode();
  DateTime? _popupExpiry;
  String? _popupError;

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _qtyCtrl.dispose();
    _qtyFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchIngredients() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await SellerService.getIngredients(page: 0, size: 200);
      if (result.isSuccess && result.data != null) {
        setState(() { _allIngredients = result.data!; _filtered = List.from(_allIngredients); _loading = false; });
      } else {
        setState(() { _error = result.message ?? 'Lỗi tải nguyên liệu'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _onSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      final q = _searchCtrl.text.toLowerCase().trim();
      setState(() {
        _filtered = q.isEmpty ? List.from(_allIngredients)
            : _allIngredients.where((i) => i.name.toLowerCase().contains(q)).toList();
      });
    });
  }

  void _openPopup(IngredientModel ing) {
    setState(() { _selected = ing; _qtyCtrl.text = ''; _popupExpiry = null; _popupError = null; });
    WidgetsBinding.instance.addPostFrameCallback((_) => _qtyFocus.requestFocus());
  }

  void _closePopup() => setState(() {
    _selected = null; _qtyCtrl.text = ''; _popupExpiry = null; _popupError = null;
  });

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _popupExpiry ?? now.add(const Duration(days: 30)),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 10),
      helpText: 'Chọn hạn dùng',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.light(primary: _ct.primary)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _popupExpiry = picked);
  }

  void _confirmAdd() {
    final qty = double.tryParse(_qtyCtrl.text.trim().replaceAll(',', '.'));
    if (qty == null || qty <= 0) { setState(() => _popupError = 'Số lượng phải lớn hơn 0'); return; }

    final ing = _selected!;
    final existIdx = _batch.indexWhere((r) => r.ingredient.id == ing.id);

    if (existIdx >= 0) {
      final existing = _batch[existIdx];
      final sameDate = (_popupExpiry == null && existing.expiryDate == null) ||
          (_popupExpiry != null && existing.expiryDate != null &&
              _popupExpiry!.year == existing.expiryDate!.year &&
              _popupExpiry!.month == existing.expiryDate!.month &&
              _popupExpiry!.day == existing.expiryDate!.day);
      if (sameDate) {
        setState(() => _batch[existIdx].quantity += qty);
        _closePopup();
      } else {
        _showDateConflictDialog(existIdx, qty, _popupExpiry);
      }
    } else {
      setState(() => _batch.add(_BatchRow(ingredient: ing, quantity: qty, expiryDate: _popupExpiry)));
      _closePopup();
    }
  }

  void _showDateConflictDialog(int idx, double addQty, DateTime? newExpiry) {
    final ing = _batch[idx].ingredient;
    final oldDate = _batch[idx].expiryDate;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
          SizedBox(width: 8),
          Text('Hạn dùng khác nhau'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Nguyên liệu "${ing.name}" đã có trong phiếu.'),
          const SizedBox(height: 4),
          const Text('Số lượng sẽ được cộng dồn.',
              style: TextStyle(color: Color(0xFF009688), fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _dateRow('Hạn hiện tại:', oldDate),
          _dateRow('Hạn mới nhập:', newExpiry),
          const SizedBox(height: 12),
          const Text('Ghi đè hạn dùng?'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Chỉnh sửa lại')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _ct.primary),
            onPressed: () {
              setState(() { _batch[idx].quantity += addQty; _batch[idx].expiryDate = newExpiry; });
              Navigator.pop(ctx);
              _closePopup();
            },
            child: const Text('Ghi đè & cộng dồn', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dateRow(String label, DateTime? date) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(children: [
      SizedBox(width: 130, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
      Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : '-- Không có --',
          style: TextStyle(color: date == null ? Colors.grey : _ct.primary)),
    ]),
  );

  String _displayExpiry(_BatchRow row) {
    final newExpiry = row.expiryDate;
    final oldExpiry = row.ingredient.expiryDate != null
        ? DateTime.fromMillisecondsSinceEpoch(row.ingredient.expiryDate!) : null;
    if (newExpiry == null && oldExpiry == null) return '--';
    final now = DateTime.now();
    if (newExpiry != null && newExpiry.isAfter(now)) {
      if (oldExpiry == null || newExpiry.isBefore(oldExpiry)) return DateFormat('dd/MM/yyyy').format(newExpiry);
      return DateFormat('dd/MM/yyyy').format(oldExpiry);
    }
    if (oldExpiry != null && oldExpiry.isAfter(now)) return DateFormat('dd/MM/yyyy').format(oldExpiry);
    final fallback = newExpiry ?? oldExpiry;
    return fallback != null ? DateFormat('dd/MM/yyyy').format(fallback) : '--';
  }

  // ── Submit ────────────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (_batch.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận nhập kho'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nhập ${_batch.length} nguyên liệu vào kho?'),
            const SizedBox(height: 8),
            ..._batch.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                const Icon(Icons.fiber_manual_record, size: 6, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(
                    '${r.ingredient.name}: +${_fmtQty(r.quantity)} ${r.ingredient.unit}',
                    style: const TextStyle(fontSize: 13))),
              ]),
            )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF009688)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Nhập kho', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _submitting = true);

    try {
      final result = await SellerService.manualImportIngredients(
        _batch.map((r) => ManualImportItem(
          ingredientId: r.ingredient.id,
          quantity: r.quantity,
          expiryDate: r.expiryDate?.millisecondsSinceEpoch,
        )).toList(),
      );

      if (result.isSuccess) {
        final batchCode = result.data?.batchCode ?? '';
        final count = _batch.length;

        Get.back(result: true);

        // Snackbar SAU khi pop, dùng Get.context (overlay toàn app, không bị huỷ theo screen)
        // Delay 1 frame để route animation bắt đầu trước
        await Future.delayed(const Duration(milliseconds: 100));
        Get.showSnackbar(GetSnackBar(
          title: 'Nhập kho thành công',
          message: 'Batch $batchCode — $count nguyên liệu',
          backgroundColor: const Color(0xFF009688),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 28),
          isDismissible: true,
          forwardAnimationCurve: Curves.easeOutBack,
        ));
      } else {
        // Thất bại: toast tại chỗ, không pop
        Get.showSnackbar(GetSnackBar(
          title: 'Nhập kho thất bại',
          message: result.message ?? 'Đã xảy ra lỗi',
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 28),
          isDismissible: true,
        ));
      }
    } catch (e) {
      Get.showSnackbar(GetSnackBar(
        title: 'Lỗi kết nối',
        message: e.toString(),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 28),
        isDismissible: true,
      ));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(children: [
          MyContainer.bordered(
            onTap: () => Get.back(),
            color: Colors.transparent,
            borderRadiusAll: 10,
            padding: MySpacing.xy(12, 8),
            borderColor: contentTheme.secondary.withOpacity(0.4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_rounded, size: 16, color: contentTheme.secondary),
                MySpacing.width(6),
                MyText.bodyMedium('Quay lại', color: contentTheme.secondary, fontWeight: 600),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('Nhập kho thủ công',
              style: GoogleFonts.hankenGrotesk(
                  fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black87)),
        ]),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ),
      ),
      body: Stack(children: [
        _buildBody(),
        if (_selected != null) _buildPopupOverlay(),
        if (_submitting)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
          ),
      ]),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.error_outline, size: 48, color: _ct.danger),
      const SizedBox(height: 12),
      Text(_error!, style: TextStyle(color: _ct.danger)),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: _fetchIngredients, child: const Text('Thử lại')),
    ]));
    return LayoutBuilder(builder: (ctx, constraints) =>
    constraints.maxWidth > 700 ? _buildWideLayout() : _buildNarrowLayout());
  }

  Widget _buildWideLayout() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(width: 420, child: _buildBatchPanel()),
    Container(width: 1, color: Colors.grey.shade200),
    Expanded(child: _buildIngredientPanel()),
  ]);

  Widget _buildNarrowLayout() => Column(children: [
    if (_batch.isNotEmpty) ...[_buildBatchPanel(), Container(height: 1, color: Colors.grey.shade200)],
    Expanded(child: _buildIngredientPanel()),
  ]);

  Widget _buildBatchPanel() => Container(
    color: Colors.white,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFF009688).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text('${_batch.length} mục',
                style: const TextStyle(color: Color(0xFF009688), fontWeight: FontWeight.w700, fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Text('Phiếu nhập', style: GoogleFonts.hankenGrotesk(fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
      ),
      if (_batch.isNotEmpty) ...[
        Container(
          color: const Color(0xFFF8F9FA),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(children: [
            Expanded(flex: 3, child: _thCell('Nguyên liệu')),
            Expanded(flex: 2, child: _thCell('Số lượng', center: true)),
            Expanded(flex: 2, child: _thCell('Hạn dùng', center: true)),
            const SizedBox(width: 32),
          ]),
        ),
        const Divider(height: 0),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _batch.length,
            separatorBuilder: (_, __) => Divider(height: 0, color: Colors.grey.shade100),
            itemBuilder: (_, i) => _buildBatchRow(i),
          ),
        ),
      ] else
        Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text('Chưa có nguyên liệu nào', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
          const SizedBox(height: 4),
          Text('Chọn từ danh sách bên phải', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
        ]))),
      Container(
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _batch.isEmpty ? null : () => setState(() => _batch.clear()),
              icon: const Icon(Icons.delete_sweep_outlined, size: 16),
              label: const Text('Xóa tất cả'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: (_batch.isEmpty || _submitting) ? null : _submit,
              icon: _submitting
                  ? const SizedBox(width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline, size: 16),
              label: Text(_submitting ? 'Đang nhập...' : 'Nhập kho'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009688), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ),
        ]),
      ),
    ]),
  );

  Widget _thCell(String text, {bool center = false}) => Text(text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF6B7280)),
      textAlign: center ? TextAlign.center : TextAlign.left);

  Widget _buildBatchRow(int i) {
    final row = _batch[i];
    final expiryStr = _displayExpiry(row);
    final isNear = row.expiryDate != null &&
        row.expiryDate!.isBefore(DateTime.now().add(const Duration(days: 30)));
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(row.ingredient.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis),
          Text(row.ingredient.unit, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ])),
        Expanded(flex: 2, child: Text(
            '${_fmtQty(row.quantity)} ${row.ingredient.unit}',
            style: TextStyle(fontWeight: FontWeight.w600, color: _ct.primary, fontSize: 13),
            textAlign: TextAlign.center)),
        Expanded(flex: 2, child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: isNear ? Colors.orange.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(expiryStr,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                  color: isNear ? Colors.orange.shade700 : Colors.grey.shade700),
              textAlign: TextAlign.center),
        )),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => setState(() => _batch.removeAt(i)),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
            child: const Icon(Icons.remove_circle_outline, size: 16, color: Colors.red),
          ),
        ),
      ]),
    );
  }

  Widget _buildIngredientPanel() => Column(children: [
    Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Tìm nguyên liệu...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(icon: Icon(Icons.clear, size: 16, color: Colors.grey.shade400), onPressed: _searchCtrl.clear)
              : null,
          filled: true, fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: _ct.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    ),
    Divider(height: 0, color: Colors.grey.shade200),
    Expanded(
      child: _filtered.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade300),
        const SizedBox(height: 8),
        Text('Không tìm thấy', style: TextStyle(color: Colors.grey.shade400)),
      ]))
          : ListView.builder(itemCount: _filtered.length, itemBuilder: (_, i) => _buildIngredientTile(_filtered[i])),
    ),
  ]);

  Widget _buildIngredientTile(IngredientModel ing) {
    final row = _batch.where((r) => r.ingredient.id == ing.id).firstOrNull;
    final inBatch = row != null;
    return InkWell(
      onTap: () => _openPopup(ing),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: inBatch ? const Color(0xFF009688).withOpacity(0.04) : Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(children: [
          Container(width: 38, height: 38,
              decoration: BoxDecoration(
                color: inBatch ? const Color(0xFF009688).withOpacity(0.12) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(inBatch ? Icons.check_circle_rounded : Icons.inventory_2_outlined,
                  color: inBatch ? const Color(0xFF009688) : Colors.grey.shade400, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ing.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
                color: inBatch ? const Color(0xFF009688) : Colors.black87)),
            Row(children: [
              Text('Tồn: ${_fmtQty(ing.stockQuantity)} ${ing.unit}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              if (inBatch) ...[
                const Text(' · ', style: TextStyle(color: Colors.grey)),
                Text('Nhập: +${_fmtQty(row.quantity)} ${ing.unit}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF009688), fontWeight: FontWeight.w600)),
              ],
            ]),
          ])),
          Icon(Icons.add_circle_outline_rounded,
              color: inBatch ? const Color(0xFF009688) : Colors.grey.shade400, size: 20),
        ]),
      ),
    );
  }

  Widget _buildPopupOverlay() => GestureDetector(
    onTap: _closePopup,
    child: Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(child: GestureDetector(onTap: () {}, child: _buildPopupCard())),
    ),
  );

  Widget _buildPopupCard() {
    final ing = _selected!;
    final existRow = _batch.where((r) => r.ingredient.id == ing.id).firstOrNull;
    final hasExisting = existRow != null;
    return Container(
      width: 380,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 30, offset: const Offset(0, 8))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF009688).withOpacity(0.06),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF009688).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF009688), size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ing.name, style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700, fontSize: 16)),
              Row(children: [
                Text('Tồn: ${_fmtQty(ing.stockQuantity)} ${ing.unit}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                if (hasExisting) ...[
                  const Text(' · ', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  Text('Đang nhập: ${_fmtQty(existRow.quantity)} ${ing.unit}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF009688), fontWeight: FontWeight.w600)),
                ],
              ]),
            ])),
            IconButton(onPressed: _closePopup, icon: const Icon(Icons.close_rounded, size: 20),
                style: IconButton.styleFrom(foregroundColor: Colors.grey.shade600, padding: EdgeInsets.zero)),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (hasExisting)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF009688).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF009688).withOpacity(0.2)),
                ),
                child: Row(children: [
                  const Icon(Icons.add_circle_outline, size: 14, color: Color(0xFF009688)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(
                      'Số lượng sẽ cộng thêm vào ${_fmtQty(existRow.quantity)} ${ing.unit} hiện có',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF009688)))),
                ]),
              ),
            const Text('Số lượng thêm *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _qtyCtrl, focusNode: _qtyFocus,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,2}'))],
              onChanged: (_) => setState(() => _popupError = null),
              decoration: InputDecoration(
                hintText: '0.00', hintStyle: TextStyle(color: Colors.grey.shade400),
                suffixText: ing.unit,
                suffixStyle: TextStyle(color: _ct.primary, fontWeight: FontWeight.w700, fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _ct.primary, width: 1.5)),
                errorText: _popupError,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Text('Hạn dùng', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickExpiryDate,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: _popupExpiry != null ? _ct.primary : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                  color: _popupExpiry != null ? _ct.primary.withOpacity(0.04) : Colors.transparent,
                ),
                child: Row(children: [
                  Icon(Icons.calendar_month_outlined, size: 18,
                      color: _popupExpiry != null ? _ct.primary : Colors.grey.shade400),
                  const SizedBox(width: 10),
                  Text(
                      _popupExpiry != null ? DateFormat('dd/MM/yyyy').format(_popupExpiry!) : 'Chọn ngày hết hạn',
                      style: TextStyle(fontSize: 14,
                          color: _popupExpiry != null ? Colors.black87 : Colors.grey.shade400,
                          fontWeight: _popupExpiry != null ? FontWeight.w600 : FontWeight.normal)),
                  const Spacer(),
                  if (_popupExpiry != null)
                    GestureDetector(onTap: () => setState(() => _popupExpiry = null),
                        child: Icon(Icons.clear, size: 16, color: Colors.grey.shade400))
                  else
                    Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade400),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: _closePopup,
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text('Hủy', style: TextStyle(color: Colors.grey.shade700)),
              )),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: ElevatedButton.icon(
                onPressed: _confirmAdd,
                icon: Icon(hasExisting ? Icons.add : Icons.add_circle_outline, size: 16),
                label: Text(hasExisting ? 'Cộng thêm' : 'Thêm vào phiếu'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF009688), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0),
              )),
            ]),
          ]),
        ),
      ]),
    );
  }

  String _fmtQty(double q) =>
      q == q.truncateToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);
}