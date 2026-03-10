// lib/views/ui/components/extended_ui/pos/shift_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/pos_service.dart';
import 'package:intl/intl.dart';
import 'number_input.dart';

class _DenomRow extends StatefulWidget {
  final int denom;
  final TextEditingController controller;

  const _DenomRow({
    required this.denom,
    required this.controller,
  });

  @override
  State<_DenomRow> createState() => _DenomRowState();
}

class _DenomRowState extends State<_DenomRow> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = (double v) => v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: _isFocused ? Colors.blue.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isFocused ? Colors.blue.shade300 : Colors.orange.shade200,
                  width: _isFocused ? 1.5 : 1.0,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${fmt(widget.denom.toDouble())}đ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isFocused ? Colors.blue.shade800 : Colors.orange.shade700,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NumberInput(
              controller: widget.controller,
              label: '',
              width: double.infinity,
              focusNode: _focusNode,
            ),
          ),
        ],
      ),
    );
  }
}

class ShiftScreen extends StatefulWidget {
  final PosShiftModel? currentShift;
  final void Function(PosShiftModel? shift) onShiftChanged;

  const ShiftScreen({
    super.key,
    required this.currentShift,
    required this.onShiftChanged,
  });

  @override
  State<ShiftScreen> createState() => _ShiftScreenState();
}

class _ShiftScreenState extends State<ShiftScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _tabsReady = false;

  bool _isLoading = false;
  bool _isFirstShift = false;
  List<Map<String, dynamic>> _ingredients = [];

  static const List<int> kDenominations = [
    500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000
  ];

  final _staffNameCtrl = TextEditingController();
  final Map<int, TextEditingController> _openDenomCtrl = {
    for (final d in kDenominations) d: TextEditingController(text: '0')
  };
  final Map<int, TextEditingController> _openPackCtrl = {};
  final Map<int, TextEditingController> _openUnitCtrl = {};
  final Map<int, TextEditingController> _closeDenomCtrl = {
    for (final d in kDenominations) d: TextEditingController(text: '0')
  };
  final Map<int, TextEditingController> _closePackCtrl = {};
  final Map<int, TextEditingController> _closeUnitCtrl = {};
  final _noteCtrl = TextEditingController();
  final _transferCtrl = TextEditingController(text: '0');

  final _finalCashNotifier = ValueNotifier<double>(0.0);

  bool get _isClosing => widget.currentShift?.isOpen == true;
  bool get _needInventory => _isClosing || _isFirstShift;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _tabsReady = false;

    _transferCtrl.addListener(_updateFinalCash);
    for (final ctrl in _closeDenomCtrl.values) {
      ctrl.addListener(_updateFinalCash);
    }

    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _staffNameCtrl.dispose();
    _noteCtrl.dispose();
    _transferCtrl.removeListener(_updateFinalCash);
    _transferCtrl.dispose();
    for (final c in _openDenomCtrl.values) c.dispose();
    for (final c in _closeDenomCtrl.values) {
      c.removeListener(_updateFinalCash);
      c.dispose();
    }
    for (final c in _openPackCtrl.values) c.dispose();
    for (final c in _openUnitCtrl.values) c.dispose();
    for (final c in _closePackCtrl.values) c.dispose();
    for (final c in _closeUnitCtrl.values) c.dispose();
    _finalCashNotifier.dispose();
    super.dispose();
  }

  void _updateFinalCash() {
    _finalCashNotifier.value = _calcFinalCash();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        PosService.getIngredients(),
        PosService.isFirstShiftOfDay(),
      ]);
      final ingredients = results[0] as List<Map<String, dynamic>>;
      final isFirst = results[1] as bool;

      for (final ing in ingredients) {
        final id = ing['id'] as int;
        _openPackCtrl[id] = TextEditingController(text: '0');
        _openUnitCtrl[id] = TextEditingController(text: '0');
        _closePackCtrl[id] = TextEditingController(text: '0');
        _closeUnitCtrl[id] = TextEditingController(text: '0');
      }

      if (!_isClosing && widget.currentShift != null) {
        for (final inv in widget.currentShift!.openInventory) {
          _openPackCtrl[inv.ingredientId]?.text = '${inv.packQuantity}';
          _openUnitCtrl[inv.ingredientId]?.text = '${inv.unitQuantity}';
        }
      }

      final newTabCount = (_isClosing || isFirst) ? 2 : 1;

      if (mounted) {
        setState(() {
          _ingredients = ingredients;
          _isFirstShift = isFirst;
          _isLoading = false;
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_tabController.length != newTabCount) {
          final oldCtrl = _tabController;
          _tabController = TabController(length: newTabCount, vsync: this);
          oldCtrl.dispose();
        }
        setState(() => _tabsReady = true);
      });
    } catch (e) {
      if (mounted) setState(() {
        _isLoading = false;
        _tabsReady = true;
      });
    }
  }

  bool _inventoryHasAnyQty() {
    for (final ing in _ingredients) {
      final id = ing['id'] as int;
      final pack = int.tryParse(_openPackCtrl[id]?.text ?? '0') ?? 0;
      final unit = int.tryParse(_openUnitCtrl[id]?.text ?? '0') ?? 0;
      if (pack > 0 || unit > 0) return true;
    }
    return false;
  }

  double _calcCash(Map<int, TextEditingController> ctrlMap) {
    double total = 0;
    for (final entry in ctrlMap.entries) {
      total += entry.key * (int.tryParse(entry.value.text.replaceAll(',', '')) ?? 0);
    }
    return total;
  }

  double _calcFinalCash() {
    final cash = _calcCash(_closeDenomCtrl);
    final transferStr = _transferCtrl.text.replaceAll(',', '');
    final transfer = double.tryParse(transferStr) ?? 0;
    return cash + transfer;
  }

  List<Map<String, dynamic>> _buildDenomList(Map<int, TextEditingController> ctrlMap) =>
      ctrlMap.entries
          .where((e) => (int.tryParse(e.value.text.replaceAll(',', '')) ?? 0) > 0)
          .map((e) => {
        'denomination': e.key,
        'quantity': int.parse(e.value.text.replaceAll(',', ''))
      })
          .toList();

  List<Map<String, dynamic>> _buildInventoryList(
      Map<int, TextEditingController> packCtrl,
      Map<int, TextEditingController> unitCtrl,
      ) =>
      _ingredients
          .map((ing) {
        final id = ing['id'] as int;
        return {
          'ingredientId': id,
          'packQuantity': int.tryParse(packCtrl[id]?.text ?? '0') ?? 0,
          'unitQuantity': int.tryParse(unitCtrl[id]?.text ?? '0') ?? 0,
        };
      })
          .toList();

  Future<void> _openShift() async {
    if (_staffNameCtrl.text.trim().isEmpty) {
      _showSnack('Vui lòng nhập tên nhân viên', Colors.orange);
      return;
    }
    if (_isFirstShift && _ingredients.isNotEmpty && !_inventoryHasAnyQty()) {
      await _showFirstShiftWarning();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final shift = await PosService.openShift(
        staffName: _staffNameCtrl.text.trim(),
        openDenominations: _buildDenomList(_openDenomCtrl),
        openInventory: _isFirstShift ? _buildInventoryList(_openPackCtrl, _openUnitCtrl) : null,
      );
      widget.onShiftChanged(shift);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack('$e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showFirstShiftWarning() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
                  child: Icon(Icons.inventory_2_outlined, size: 36, color: Colors.orange.shade700),
                ),
                const SizedBox(height: 14),
                Text(
                  'Ca đầu ngày bắt buộc nhập kho',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.orange.shade800),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
              child: Column(children: [
                Text(
                  'Đây là ca đầu tiên trong ngày. Vui lòng nhập số lượng nguyên liệu tồn kho trước khi mở ca.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.touch_app_outlined, size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chuyển sang tab "Kiểm kho" để nhập số lượng.',
                        style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (_tabController.length >= 2) {
                        _tabController.animateTo(1);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Đã hiểu, đi nhập kho ngay',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _closeShift() async {
    setState(() => _isLoading = true);
    try {
      final transferStr = _transferCtrl.text.replaceAll(',', '');
      final transfer = double.tryParse(transferStr) ?? 0;

      final shift = await PosService.closeShift(
        closeDenominations: _buildDenomList(_closeDenomCtrl),
        closeInventory: _buildInventoryList(_closePackCtrl, _closeUnitCtrl),
        transferAmount: transfer > 0 ? transfer : null,
        note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      );

      widget.onShiftChanged(null);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đóng ca thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      String errorMsg = e.toString();

      if (errorMsg.contains('Phải nhập mệnh giá tiền cuối ca')) {
        errorMsg = 'Vui lòng nhập ít nhất một mệnh giá tiền cuối ca.';
      } else if (errorMsg.contains('Phải nhập kho cuối ca')) {
        errorMsg = 'Vui lòng nhập số lượng nguyên liệu kiểm kho cuối ca.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmCloseShift() async {
    // FIX: delay 1 frame để gesture của ElevatedButton hoàn tất trước khi
    // barrier dialog được mount. Nếu không delay, gesture event "xuyên thủng"
    // qua barrier và dismiss dialog ngay lập tức.
    // useRootNavigator: true để dialog mount lên root Navigator — tránh bị
    // Scaffold hoặc widget cha bắt gesture dismiss.
    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,   // ← mount lên root, thoát khỏi gesture scope của cha
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 26),
          SizedBox(width: 8),
          Text('Xác nhận đóng ca'),
        ]),
        content: const Text(
            'Bạn có chắc chắn muốn đóng ca không?\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogCtx, rootNavigator: true).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(dialogCtx, rootNavigator: true).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đóng ca'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) _closeShift();
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color));
  }

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isClosing ? 'Đóng ca' : 'Mở ca',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isClosing
                ? ElevatedButton.icon(
              icon: const Icon(Icons.stop_circle_outlined, size: 20),
              label: const Text('Đóng ca',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              // FIX: không gọi _confirmCloseShift trực tiếp — gesture của button
              // sẽ dismiss dialog ngay. Delay 80ms để gesture settle xong.
              onPressed: _isLoading
                  ? null
                  : () async {
                await Future.delayed(const Duration(milliseconds: 80));
                if (mounted) _confirmCloseShift();
              },
            )
                : ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, size: 20),
              label: const Text('Mở ca',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isLoading ? null : _openShift,
            ),
          ),
        ],
        bottom: _tabsReady && _needInventory
            ? TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          indicatorWeight: 2.5,
          tabs: const [
            Tab(text: 'Thông tin ca'),
            Tab(text: 'Kiểm kho'),
          ],
        )
            : null,
      ),
      body: _isLoading || !_tabsReady
          ? const Center(child: CircularProgressIndicator())
          : _needInventory
          ? TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _isClosing
                ? _buildCloseInfoTab()
                : _buildOpenInfoTab(),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _isClosing
                ? _buildCloseInventoryTab()
                : _buildOpenInventoryTab(),
          ),
        ],
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildOpenInfoTab(),
      ),
    );
  }

  Widget _buildOpenInfoTab() => Column(children: [
    _SectionCard(
      title: 'Thông tin ca',
      icon: Icons.person_outline,
      child: TextField(
        controller: _staffNameCtrl,
        decoration: InputDecoration(
          labelText: 'Tên nhân viên đứng ca *',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          prefixIcon: const Icon(Icons.badge_outlined),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
      ),
    ),
    const SizedBox(height: 8),
    _SectionCard(
      title: 'Tiền đầu ca',
      icon: Icons.payments_outlined,
      trailing: ValueListenableBuilder(
        valueListenable: _DenomNotifier(_openDenomCtrl),
        builder: (_, __, ___) => Text(
          '${_fmt(_calcCash(_openDenomCtrl))}đ',
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 16),
        ),
      ),
      child: _buildDenomGrid(_openDenomCtrl),
    ),
  ]);

  Widget _buildCloseInfoTab() => Column(children: [
    Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.deepOrange.shade400, Colors.orange.shade300]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Ca đang mở',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            Text(widget.currentShift!.staffName,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            Text(
              'Mở lúc ${DateFormat('HH:mm dd/MM').format(DateTime.fromMillisecondsSinceEpoch(widget.currentShift!.openTime))}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text('Đơn hàng',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            Text('${widget.currentShift!.totalOrders}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            Text('${_fmt(widget.currentShift!.totalRevenue)}đ',
                style:
                const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ],
      ),
    ),
    _SectionCard(
      title: 'Tiền cuối ca',
      icon: Icons.payments_outlined,
      trailing: ValueListenableBuilder<double>(
        valueListenable: _finalCashNotifier,
        builder: (_, finalCash, ___) => Text(
          '${_fmt(finalCash)}đ',
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 16),
        ),
      ),
      child: Column(
        children: [
          _buildDenomGrid(_closeDenomCtrl),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: NumberInput(
                  controller: _transferCtrl,
                  label: 'Số tiền chuyển khoản (nếu có)',
                  width: double.infinity,
                  autoFormat: true,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    const SizedBox(height: 8),
    _SectionCard(
      title: 'Ghi chú chi phí phát sinh',
      icon: Icons.notes_outlined,
      child: TextField(
        controller: _noteCtrl,
        maxLines: 3,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintText: 'Nhập ghi chú chi phí (nếu có)...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
      ),
    ),
  ]);

  Widget _buildOpenInventoryTab() => Column(children: [
    Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(children: [
        Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Ca đầu tiên trong ngày — nhập số lượng nguyên liệu có trong kho.',
            style: TextStyle(
                fontSize: 12, color: Colors.orange.shade800, height: 1.4),
          ),
        ),
      ]),
    ),
    _buildGroupedInventoryGrid(_openPackCtrl, _openUnitCtrl),
  ]);

  Widget _buildCloseInventoryTab() => Column(children: [
    Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(children: [
        Icon(Icons.inventory_2_outlined,
            color: Colors.blue.shade700, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Kiểm kho cuối ca — nhập số lượng nguyên liệu còn lại.',
            style: TextStyle(
                fontSize: 12, color: Colors.blue.shade800, height: 1.4),
          ),
        ),
      ]),
    ),
    _buildGroupedInventoryGrid(_closePackCtrl, _closeUnitCtrl),
  ]);

  Widget _buildGroupedInventoryGrid(
      Map<int, TextEditingController> packCtrl,
      Map<int, TextEditingController> unitCtrl,
      ) {
    if (_ingredients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
            child: Text('Không có nguyên liệu',
                style: TextStyle(color: Colors.grey, fontSize: 15))),
      );
    }

    final mainList = _ingredients
        .where((i) =>
    (i['ingredientType'] as String?)?.toUpperCase() != 'SUB')
        .toList();
    final subList = _ingredients
        .where(
            (i) => (i['ingredientType'] as String?)?.toUpperCase() == 'SUB')
        .toList();

    return Column(
      children: [
        if (mainList.isNotEmpty)
          _IngredientGroupCard(
            title: 'Nguyên liệu Chính',
            icon: Icons.kitchen_outlined,
            color: Colors.blue,
            ingredients: mainList,
            packCtrl: packCtrl,
            unitCtrl: unitCtrl,
          ),
        if (mainList.isNotEmpty && subList.isNotEmpty)
          const SizedBox(height: 8),
        if (subList.isNotEmpty)
          _IngredientGroupCard(
            title: 'Nguyên liệu Phụ',
            icon: Icons.add_box_outlined,
            color: Colors.deepOrange,
            ingredients: subList,
            packCtrl: packCtrl,
            unitCtrl: unitCtrl,
          ),
      ],
    );
  }

  Widget _buildDenomGrid(Map<int, TextEditingController> ctrlMap) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 14,
        childAspectRatio: 13,
      ),
      itemCount: kDenominations.length,
      itemBuilder: (_, i) {
        final denom = kDenominations[i];
        final fmt = (double v) => v.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
        );

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${fmt(denom.toDouble())}đ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: NumberInput(
                  controller: ctrlMap[denom]!,
                  label: '',
                  width: double.infinity,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IngredientGroupCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Map<String, dynamic>> ingredients;
  final Map<int, TextEditingController> packCtrl;
  final Map<int, TextEditingController> unitCtrl;

  const _IngredientGroupCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.ingredients,
    required this.packCtrl,
    required this.unitCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.9)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('${ingredients.length}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color)),
                ),
              ],
            ),
          ),
          ...ingredients.map((ing) {
            final id = ing['id'] as int;
            final name = ing['name'] as String;
            final unitPerPack = ing['unitPerPack'] as int? ?? 1;
            final imageUrl = ing['imageUrl'] as String?;

            return Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey.shade100))),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                      imageUrl: PosService.buildImageUrl(imageUrl),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _placeholder(),
                    )
                        : _placeholder(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('1 bịch = $unitPerPack lẻ',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  NumberInput(controller: packCtrl[id]!, label: 'Bịch'),
                  const SizedBox(width: 8),
                  NumberInput(controller: unitCtrl[id]!, label: 'Lẻ'),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 44,
    height: 44,
    color: Colors.grey[100],
    child: const Icon(Icons.set_meal, color: Colors.grey, size: 22),
  );
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      if (subtitle != null)
                        Text(subtitle!,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _DenomNotifier extends ValueNotifier<int> {
  final Map<int, TextEditingController> ctrls;
  _DenomNotifier(this.ctrls) : super(0) {
    for (final c in ctrls.values) c.addListener(_update);
  }
  void _update() => notifyListeners();
  @override
  void dispose() {
    for (final c in ctrls.values) c.removeListener(_update);
    super.dispose();
  }
}