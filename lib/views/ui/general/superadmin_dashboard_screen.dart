// lib/views/ui/general/superadmin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:original_taste/views/ui/general/seller_retail_dashboard_screen.dart';
import 'package:original_taste/views/ui/general/seller_wholesale_dashboard_screen.dart';
import 'package:original_taste/views/ui/general/super_admin_pos_dashboard_screen.dart';
import '../../../controller/ui/general/super_admin_dashboard_controller.dart';
import '../../../helper/services/super_admin_dashboard_services.dart';

// Không dùng top-level _ct vì nó bị cache khi file load → không update theo dark mode
// Dùng getter _ct ở từng widget thay thế

// ══════════════════════════════════════════════════════════════════
// Screen cha — chứa Layout + toggle POS / Sỉ / Lẻ + period filter
// Route: /superadmin/dashboard
// ══════════════════════════════════════════════════════════════════

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() =>
      _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen>
    with UIMixin {
  late SuperAdminDashboardController controller;

  // Getter — đọc theme mỗi lần build, đúng với dark/light mode hiện tại
  ContentTheme get _ct => AdminTheme.theme.contentTheme;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SuperAdminDashboardController());
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SuperAdminDashboardController>(
      init: controller,
      builder: (c) => Layout(
        screenName: 'DASHBOARD',
        child: Column(
          children: [
            _buildTopBar(c),
            const Divider(height: 0),
            Expanded(child: _buildModeContent(c)),
          ],
        ),
      ),
    );
  }

  // ── Top bar: toggle + period + refresh ───────────────────────

  Widget _buildTopBar(SuperAdminDashboardController c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildModeToggle(c),
          const SizedBox(width: 12),
          // Dropdown xe — chỉ hiện khi mode = POS
          if (c.mode == SuperAdminDashboardMode.pos) ...[
            _PosVehicleDropdown(c: c),
            const SizedBox(width: 12),
          ],
          Expanded(child: _buildPeriodFilter(c)),
        ],
      ),
    );
  }

  // ── Mode toggle: POS / Sỉ / Lẻ ───────────────────────────────

  Widget _buildModeToggle(SuperAdminDashboardController c) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: _ct.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _ct.secondary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _modeTab(c, SuperAdminDashboardMode.pos, 'POS'),
          _modeTab(c, SuperAdminDashboardMode.wholesale, 'Sỉ'),
          _modeTab(c, SuperAdminDashboardMode.retail, 'Lẻ'),
        ],
      ),
    );
  }

  Widget _modeTab(SuperAdminDashboardController c,
      SuperAdminDashboardMode mode, String label) {
    final sel = c.mode == mode;
    return GestureDetector(
      onTap: () => c.setMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? _ct.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: sel ? _ct.onPrimary : _ct.secondary)),
      ),
    );
  }

  // ── Period filter ─────────────────────────────────────────────

  Widget _buildPeriodFilter(SuperAdminDashboardController c) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        ...SuperAdminDashboardPeriod.values
            .where((p) => p != SuperAdminDashboardPeriod.custom)
            .map((p) => _periodChip(c, p)),
        _customChip(c),
      ]),
    );
  }

  Widget _periodChip(
      SuperAdminDashboardController c, SuperAdminDashboardPeriod p) {
    final sel = c.period == p;
    return GestureDetector(
      onTap: () => c.setPeriod(p),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? _ct.primary : _ct.secondary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: sel ? _ct.primary : _ct.secondary.withOpacity(0.22)),
        ),
        child: Text(p.label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: sel ? _ct.onPrimary : null)),
      ),
    );
  }

  Widget _customChip(SuperAdminDashboardController c) {
    final sel = c.period == SuperAdminDashboardPeriod.custom;
    return GestureDetector(
      onTap: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: c.customFrom != null && c.customTo != null
              ? DateTimeRange(start: c.customFrom!, end: c.customTo!)
              : null,
        );
        if (range != null) {
          c.setPeriod(SuperAdminDashboardPeriod.custom,
              from: range.start,
              to: range.end.copyWith(hour: 23, minute: 59, second: 59));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? _ct.primary : _ct.secondary.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: sel ? _ct.primary : _ct.secondary.withOpacity(0.22)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.calendar_today_outlined,
              size: 11, color: sel ? _ct.onPrimary : _ct.secondary),
          const SizedBox(width: 4),
          Text(
            sel && c.customFrom != null
                ? '${DateFormat('dd/MM').format(c.customFrom!)} – ${DateFormat('dd/MM').format(c.customTo!)}'
                : 'Tuỳ chọn',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: sel ? _ct.onPrimary : null),
          ),
        ]),
      ),
    );
  }

  // ── Content theo mode ─────────────────────────────────────────

  Widget _buildModeContent(SuperAdminDashboardController c) {
    // POS: loading/error/data đều do SuperAdminPosDashboardScreen tự xử lý
    if (c.mode == SuperAdminDashboardMode.pos) {
      return const SuperAdminPosDashboardScreen();
    }

    // Wholesale / Retail: loading và error xử lý ở đây
    if (c.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.errorMsg.isNotEmpty) {
      return _buildError(c);
    }
    if (c.data == null) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    return switch (c.mode) {
      SuperAdminDashboardMode.wholesale =>
          SellerWholesaleDashboardScreen(data: c.data!),
      SuperAdminDashboardMode.retail =>
          SellerRetailDashboardScreen(data: c.data!),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildError(SuperAdminDashboardController c) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.error_outline, size: 52, color: _ct.danger),
      MySpacing.height(12),
      MyText.bodyMedium(c.errorMsg, color: _ct.danger),
      MySpacing.height(16),
      ElevatedButton.icon(
        onPressed: c.reload,
        icon: const Icon(Icons.refresh),
        label: const Text('Thử lại'),
      ),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════
// _PosVehicleDropdown
// Dropdown chọn xe POS — có search với debounce 900ms
// ══════════════════════════════════════════════════════════════════

class _PosVehicleDropdown extends StatefulWidget {
  final SuperAdminDashboardController c;
  const _PosVehicleDropdown({required this.c});

  @override
  State<_PosVehicleDropdown> createState() => _PosVehicleDropdownState();
}

class _PosVehicleDropdownState extends State<_PosVehicleDropdown> {
  final LayerLink _layerLink  = LayerLink();
  OverlayEntry?   _overlay;
  bool            _open       = false;
  final TextEditingController _searchCtrl  = TextEditingController();
  final FocusNode             _searchFocus = FocusNode();

  // Đọc theme theo thời gian thực — không cache top-level
  ContentTheme get _ct => AdminTheme.theme.contentTheme;

  @override
  void dispose() {
    // Phải unfocus TRƯỚC khi remove overlay.
    // Nếu TextField trong overlay đang focused khi widget bị unmount,
    // Flutter sẽ gọi EditableTextState.didChangeDependencies trên widget đã deactivated → crash.
    if (_searchFocus.hasFocus) {
      _searchFocus.unfocus();
    }
    _overlay?.remove();
    _overlay = null;
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleDropdown() => _open ? _closeDropdown() : _openDropdown();

  void _openDropdown() {
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    if (mounted) setState(() => _open = true);
    _searchCtrl.clear();
    widget.c.onVehicleSearchChanged('');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeDropdown() {
    // Unfocus trước — tránh EditableText lookup ancestor sau khi unmount
    if (_searchFocus.hasFocus) {
      _searchFocus.unfocus();
    }
    _overlay?.remove();
    _overlay = null;
    // FIX: chỉ setState nếu widget còn mounted
    if (mounted) setState(() => _open = false);
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size      = renderBox.size;

    return OverlayEntry(
      builder: (_) {
        // Đọc theme bên trong builder — luôn fresh
        final ct = AdminTheme.theme.contentTheme;
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _closeDropdown,
          child: Stack(children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            CompositedTransformFollower(
              link:             _layerLink,
              showWhenUnlinked: false,
              offset:           Offset(0, size.height + 4),
              child: Material(
                elevation:    6,
                borderRadius: BorderRadius.circular(10),
                color:        ct.cardBackground,
                child: Container(
                  width: 230,
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color:        ct.cardBackground,
                    border:       Border.all(color: ct.secondary.withOpacity(0.18)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GetBuilder<SuperAdminDashboardController>(
                    builder: (c) {
                      final isSearching = c.vehicleSearching;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ── Search box ─────────────────────────
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              controller: _searchCtrl,
                              focusNode:  _searchFocus,
                              style: TextStyle(fontSize: 12, color: ct.onBackground),
                              decoration: InputDecoration(
                                hintText:  'Tìm xe...',
                                hintStyle: TextStyle(fontSize: 12, color: ct.secondary),
                                prefixIcon: SizedBox(
                                  width: 32,
                                  child: Center(
                                    child: isSearching
                                        ? SizedBox(
                                        width: 14, height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 1.5, color: ct.primary))
                                        : Icon(Icons.search, size: 16, color: ct.secondary),
                                  ),
                                ),
                                isDense:        true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                filled:      true,
                                fillColor:   ct.secondary.withOpacity(0.05),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: BorderSide(
                                      color: ct.secondary.withOpacity(0.25)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: BorderSide(color: ct.primary),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7),
                                  borderSide: BorderSide(
                                      color: ct.secondary.withOpacity(0.2)),
                                ),
                              ),
                              onChanged: (q) {
                                c.onVehicleSearchChanged(q);
                                _overlay?.markNeedsBuild();
                              },
                            ),
                          ),
                          Divider(height: 0, color: ct.secondary.withOpacity(0.12)),
                          // ── List xe (hoặc loading skeleton) ────
                          Flexible(
                            child: isSearching
                            // Loading: hiện shimmer placeholder khi debounce đang đếm
                                ? _buildSearchSkeleton(ct)
                                : c.filteredVehicles.isEmpty
                                ? Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.search_off,
                                    size: 28, color: ct.secondary.withOpacity(0.4)),
                                const SizedBox(height: 6),
                                Text('Không tìm thấy xe',
                                    style: TextStyle(
                                        fontSize: 12, color: ct.secondary)),
                              ]),
                            )
                                : ListView.builder(
                              padding:    EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount:  c.filteredVehicles.length,
                              itemBuilder: (_, i) =>
                                  _buildVehicleItem(c, c.filteredVehicles[i], ct),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }

  // ── Skeleton loading khi đang search ──────────────────────────
  Widget _buildSearchSkeleton(ContentTheme ct) {
    return ListView.builder(
      padding:    EdgeInsets.zero,
      shrinkWrap: true,
      itemCount:  3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: ct.secondary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ct.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                height: 8,
                width: 100,
                decoration: BoxDecoration(
                  color: ct.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ── Vehicle row ───────────────────────────────────────────────
  Widget _buildVehicleItem(
      SuperAdminDashboardController c, PosVehicle v, ContentTheme ct) {
    final sel = c.selectedVehicle?.id == v.id;
    return InkWell(
      onTap: () {
        c.selectVehicle(v);
        _closeDropdown();
      },
      child: Container(
        color: sel ? ct.primary.withOpacity(0.10) : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: v.avatarUrl != null
                ? Image.network(
              v.avatarUrl!,
              width: 28, height: 28, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(ct),
            )
                : _placeholder(ct),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:   12,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color:      sel ? ct.primary : ct.onBackground,
                  )),
              if (v.address != null)
                Text(v.address!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: ct.secondary)),
            ]),
          ),
          if (sel)
            Icon(Icons.check_circle, size: 15, color: ct.primary),
        ]),
      ),
    );
  }

  Widget _placeholder(ContentTheme ct) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(
      color: ct.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Icon(Icons.directions_car_outlined, size: 16, color: ct.primary),
  );

  @override
  Widget build(BuildContext context) {
    final c  = widget.c;
    final ct = AdminTheme.theme.contentTheme; // fresh mỗi lần build

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          height:      34,
          constraints: const BoxConstraints(minWidth: 120, maxWidth: 175),
          padding:     const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: ct.cardBackground,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
                color: _open ? ct.primary : ct.secondary.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color:       ct.secondary.withOpacity(0.08),
                blurRadius:  4,
                offset:      const Offset(0, 1),
              ),
            ],
          ),
          child: Row(children: [
            Icon(Icons.directions_car_outlined,
                size: 15, color: _open ? ct.primary : ct.secondary),
            const SizedBox(width: 6),
            Expanded(
              child: c.vehiclesLoading
                  ? SizedBox(
                  width: 14, height: 14,
                  child: Center(
                    child: SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: ct.primary),
                    ),
                  ))
                  : Text(
                c.selectedVehicle?.name ?? 'Chọn xe',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w600,
                  color:      c.selectedVehicle != null
                      ? ct.onBackground
                      : ct.secondary,
                ),
              ),
            ),
            Icon(
              _open ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              size: 18,
              color: ct.secondary,
            ),
          ]),
        ),
      ),
    );
  }
}