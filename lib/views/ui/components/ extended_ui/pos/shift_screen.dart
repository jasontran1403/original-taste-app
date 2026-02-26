// lib/views/ui/components/extended_ui/pos/shift_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:original_taste/helper/services/pos_service.dart';
import 'package:intl/intl.dart';

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

class _ShiftScreenState extends State<ShiftScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  // ─── State ───
  bool _isLoading = false;
  bool _isFirstShift = false;
  List<Map<String, dynamic>> _ingredients = [];

  static const List<int> kDenominations = [
    500, 1000, 2000, 5000, 10000, 20000, 50000, 100000, 200000, 500000
  ];

  // Open shift controllers
  final _staffNameCtrl = TextEditingController();
  final Map<int, TextEditingController> _openDenomCtrl = {
    for (final d in kDenominations) d: TextEditingController(text: '0')
  };
  final Map<int, TextEditingController> _openPackCtrl = {};
  final Map<int, TextEditingController> _openUnitCtrl = {};

  // Close shift controllers
  final Map<int, TextEditingController> _closeDenomCtrl = {
    for (final d in kDenominations) d: TextEditingController(text: '0')
  };
  final Map<int, TextEditingController> _closePackCtrl = {};
  final Map<int, TextEditingController> _closeUnitCtrl = {};
  final _noteCtrl = TextEditingController();
  final _transferCtrl = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bool needInventory = (widget.currentShift?.isOpen == true) || _isFirstShift;
    final int tabCount = needInventory ? 2 : 1;

    // Nếu controller chưa tồn tại hoặc length không khớp → tạo mới
    if (_tabController == null || _tabController!.length != tabCount) {
      _tabController?.dispose();
      _tabController = TabController(length: tabCount, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _staffNameCtrl.dispose();
    _noteCtrl.dispose();
    _transferCtrl.dispose();
    for (final c in _openDenomCtrl.values) c.dispose();
    for (final c in _closeDenomCtrl.values) c.dispose();
    for (final c in _openPackCtrl.values) c.dispose();
    for (final c in _openUnitCtrl.values) c.dispose();
    for (final c in _closePackCtrl.values) c.dispose();
    for (final c in _closeUnitCtrl.values) c.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    try {
      final ingredients = await PosService.getIngredients();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final shifts = await PosService.getShiftsByDate(today).catchError((_) => <PosShiftModel>[]);
      final isFirst = shifts.isEmpty;

      for (final ing in ingredients) {
        final id = ing['id'] as int;
        _openPackCtrl[id] = TextEditingController(text: '0');
        _openUnitCtrl[id] = TextEditingController(text: '0');
        _closePackCtrl[id] = TextEditingController(text: '0');
        _closeUnitCtrl[id] = TextEditingController(text: '0');
      }

      if (widget.currentShift?.isOpen == true) {
        for (final inv in widget.currentShift!.openInventory) {
          _closePackCtrl[inv.ingredientId]?.text = '${inv.packQuantity}';
          _closeUnitCtrl[inv.ingredientId]?.text = '${inv.unitQuantity}';
        }
      }

      setState(() {
        _ingredients = ingredients;
        _isFirstShift = isFirst;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double _calcCash(Map<int, TextEditingController> ctrlMap) {
    double total = 0;
    for (final entry in ctrlMap.entries) {
      final qty = int.tryParse(entry.value.text) ?? 0;
      total += entry.key * qty;
    }
    return total;
  }

  List<Map<String, dynamic>> _buildDenomList(Map<int, TextEditingController> ctrlMap) {
    return ctrlMap.entries
        .where((e) => (int.tryParse(e.value.text) ?? 0) > 0)
        .map((e) => {'denomination': e.key, 'quantity': int.parse(e.value.text)})
        .toList();
  }

  List<Map<String, dynamic>> _buildInventoryList(
      Map<int, TextEditingController> packCtrl,
      Map<int, TextEditingController> unitCtrl) {
    return _ingredients.map((ing) {
      final id = ing['id'] as int;
      return {
        'ingredientId': id,
        'packQuantity': int.tryParse(packCtrl[id]?.text ?? '0') ?? 0,
        'unitQuantity': int.tryParse(unitCtrl[id]?.text ?? '0') ?? 0,
      };
    }).toList();
  }

  Future<void> _openShift() async {
    if (_staffNameCtrl.text.trim().isEmpty) {
      _showSnack('Vui lòng nhập tên nhân viên', Colors.orange);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final denoms = _buildDenomList(_openDenomCtrl);
      final inv = _isFirstShift ? _buildInventoryList(_openPackCtrl, _openUnitCtrl) : null;

      final shift = await PosService.openShift(
        staffName: _staffNameCtrl.text.trim(),
        openDenominations: denoms,
        openInventory: inv,
      );
      widget.onShiftChanged(shift);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack('$e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _closeShift() async {
    setState(() => _isLoading = true);
    try {
      final denoms = _buildDenomList(_closeDenomCtrl);
      final inv = _buildInventoryList(_closePackCtrl, _closeUnitCtrl);
      final transfer = double.tryParse(_transferCtrl.text.replaceAll(',', '')) ?? 0;

      final shift = await PosService.closeShift(
        closeDenominations: denoms,
        closeInventory: inv,
        transferAmount: transfer > 0 ? transfer : null,
        note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
      );
      widget.onShiftChanged(null);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack('$e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  String _formatMoney(double v) => v.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final isClosing = widget.currentShift?.isOpen == true;
    final bool needInventory = isClosing || _isFirstShift;

    // Nếu controller chưa sẵn sàng, hiển thị loading
    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          isClosing ? 'Đóng ca' : 'Mở ca',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: isClosing
                ? ElevatedButton.icon(
              icon: const Icon(Icons.stop_circle_outlined, size: 20),
              label: const Text('Đóng ca', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              onPressed: _isLoading ? null : () => _confirmCloseShift(),
            )
                : ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow, size: 20),
              label: const Text('Mở ca', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              onPressed: _isLoading ? null : _openShift,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          tabs: [
            const Tab(text: 'Thông tin ca'),
            if (needInventory) const Tab(text: 'Kiểm kho'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          // Luôn có tab 1: Thông tin ca
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: isClosing ? _buildCloseInfoTab() : _buildOpenInfoTab(),
          ),
          // Chỉ thêm tab 2 khi cần (không dùng else placeholder)
          if (needInventory)
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: isClosing ? _buildCloseInventoryTab() : _buildOpenInventoryTab(),
            ),
        ],
      ),
    );
  }

  // ─── Tab nội dung ───
  Widget _buildOpenInfoTab() {
    return Column(
      children: [
        _SectionCard(
          title: 'Thông tin ca',
          icon: Icons.person_outline,
          child: TextField(
            controller: _staffNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Tên nhân viên đứng ca *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Tiền đầu ca',
          icon: Icons.payments_outlined,
          trailing: ValueListenableBuilder(
            valueListenable: _DenomNotifier(_openDenomCtrl),
            builder: (_, __, ___) => Text(
              '${_formatMoney(_calcCash(_openDenomCtrl))}đ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
            ),
          ),
          child: _buildDenomGrid(_openDenomCtrl),
        ),
      ],
    );
  }

  Widget _buildCloseInfoTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.deepOrange.shade400, Colors.orange.shade300]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Ca đang mở', style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text(widget.currentShift!.staffName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                Text('Mở lúc ${DateFormat('HH:mm dd/MM').format(DateTime.fromMillisecondsSinceEpoch(widget.currentShift!.openTime))}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Đơn hàng', style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text('${widget.currentShift!.totalOrders}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                Text('${_formatMoney(widget.currentShift!.totalRevenue)}đ',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Tiền cuối ca',
          icon: Icons.payments_outlined,
          trailing: ValueListenableBuilder(
            valueListenable: _DenomNotifier(_closeDenomCtrl),
            builder: (_, __, ___) => Text(
              '${_formatMoney(_calcCash(_closeDenomCtrl))}đ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
            ),
          ),
          child: _buildDenomGrid(_closeDenomCtrl),
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Chuyển khoản & Ghi chú',
          icon: Icons.swap_horiz,
          child: Column(
            children: [
              TextField(
                controller: _transferCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Số tiền chuyển khoản (nếu có)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_outlined),
                  suffixText: 'đ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú chi phí phát sinh',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpenInventoryTab() {
    return _SectionCard(
      title: 'Kho đầu ngày',
      icon: Icons.inventory_2_outlined,
      subtitle: 'Ca đầu tiên trong ngày — nhập số lượng nguyên liệu',
      child: _buildInventoryGrid(_openPackCtrl, _openUnitCtrl),
    );
  }

  Widget _buildCloseInventoryTab() {
    return _SectionCard(
      title: 'Kiểm kho cuối ca',
      icon: Icons.inventory_2_outlined,
      subtitle: 'Nhập số lượng nguyên liệu còn lại',
      child: _buildInventoryGrid(_closePackCtrl, _closeUnitCtrl),
    );
  }

  void _confirmCloseShift() {
    showDialog(
      context: context,
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
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              _closeShift();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Đóng ca'),
          ),
        ],
      ),
    );
  }

  // ─── Helper Widgets (giữ nguyên) ───
  Widget _buildDenomGrid(Map<int, TextEditingController> ctrlMap) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 64,
      ),
      itemCount: kDenominations.length,
      itemBuilder: (_, i) {
        final denom = kDenominations[i];
        return Row(
          children: [
            Container(
              width: 90,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                '${_formatMoney(denom.toDouble())}đ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                    fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: ctrlMap[denom],
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  border: OutlineInputBorder(),
                  hintText: '0',
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInventoryGrid(
      Map<int, TextEditingController> packCtrl,
      Map<int, TextEditingController> unitCtrl) {
    if (_ingredients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('Không có nguyên liệu', style: TextStyle(color: Colors.grey))),
      );
    }
    return Column(
      children: _ingredients.map((ing) {
        final id = ing['id'] as int;
        final name = ing['name'] as String;
        final unitPerPack = ing['unitPerPack'] as int? ?? 1;
        final imageUrl = ing['imageUrl'] as String?;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
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
                  errorWidget: (_, __, ___) => Container(
                    width: 44,
                    height: 44,
                    color: Colors.grey[200],
                    child: const Icon(Icons.set_meal, color: Colors.grey),
                  ),
                )
                    : Container(
                  width: 44,
                  height: 44,
                  color: Colors.grey[200],
                  child: const Icon(Icons.set_meal, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('1 bịch = $unitPerPack lẻ',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              _InventoryInput(label: 'Bịch', ctrl: packCtrl[id]!),
              const SizedBox(width: 8),
              _InventoryInput(label: 'Lẻ', ctrl: unitCtrl[id]!),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Helper classes (giữ nguyên) ───
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
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      if (subtitle != null)
                        Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class _InventoryInput extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;

  const _InventoryInput({required this.label, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        SizedBox(
          width: 54,
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              border: OutlineInputBorder(),
              hintText: '0',
            ),
          ),
        ),
      ],
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