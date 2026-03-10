// lib/views/ui/general/super_admin_pos_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../controller/ui/general/super_admin_dashboard_controller.dart';
import '../../../helper/services/super_admin_dashboard_services.dart';

final _ct = AdminTheme.theme.contentTheme;

const _kColors = [
  Color(0xFF2563EB), Color(0xFF16A34A), Color(0xFFD946EF), Color(0xFFEA580C),
  Color(0xFF0891B2), Color(0xFF7C3AED), Color(0xFFF59E0B), Color(0xFFE11D48),
];
Color _col(int i) => _kColors[i % _kColors.length];

// ══════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════

class SuperAdminPosDashboardScreen extends StatefulWidget {
  const SuperAdminPosDashboardScreen({super.key});

  @override
  State<SuperAdminPosDashboardScreen> createState() =>
      _SuperAdminPosDashboardScreenState();
}

class _SuperAdminPosDashboardScreenState
    extends State<SuperAdminPosDashboardScreen> {
  final ScrollController _scrollCtrl =
  ScrollController(keepScrollOffset: false);

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Formatters ────────────────────────────────────────────────
  String _cur(double v) => NumberFormat('#,###', 'vi_VN').format(v);
  String _num(num v) => NumberFormat('#,###', 'vi_VN').format(v);
  String _date(int? ts) => ts == null
      ? '—'
      : DateFormat('dd/MM HH:mm')
      .format(DateTime.fromMillisecondsSinceEpoch(ts));

  IconData _srcIcon(String s) => switch (s) {
    'SHOPEE_FOOD' => Icons.delivery_dining_outlined,
    'GRAB_FOOD' => Icons.two_wheeler_outlined,
    _ => Icons.storefront_outlined,
  };

  Color _srcColor(String s) => switch (s) {
    'SHOPEE_FOOD' => const Color(0xFFEE4D2D),
    'GRAB_FOOD' => const Color(0xFF00B14F),
    _ => const Color(0xFF2563EB),
  };

  String _srcLabel(String s) => switch (s) {
    'SHOPEE_FOOD' => 'ShopeeFood',
    'GRAB_FOOD' => 'GrabFood',
    _ => 'Offline',
  };

  Color _stColor(String s) => switch (s) {
    'COMPLETED' => Colors.green,
    'CANCELLED' => Colors.red,
    'PENDING' => Colors.orange,
    _ => Colors.grey,
  };

  String _stLabel(String s) => switch (s) {
    'COMPLETED' => 'Hoàn thành',
    'CANCELLED' => 'Đã hủy',
    'PENDING' => 'Chờ xử lý',
    _ => s,
  };

  String _pmLabel(String? m) => switch (m) {
    'CASH' => 'Tiền mặt',
    'BANK_TRANSFER' => 'Chuyển khoản',
    'TRANSFER' => 'Chuyển khoản',
    'MOMO' => 'MoMo',
    'VNPAY' => 'VNPay',
    'ZALOPAY' => 'ZaloPay',
    _ => m ?? '—',
  };

  Color _pmColor(String? m) => switch (m) {
    'CASH' => const Color(0xFF16A34A),
    'BANK_TRANSFER' => const Color(0xFF2563EB),
    'MOMO' => const Color(0xFFAE2070),
    'VNPAY' => const Color(0xFF0056A2),
    'ZALOPAY' => const Color(0xFF006AF5),
    _ => Colors.grey,
  };

  // ══════════════════════════════════════════════════════════════
  // BUILD — listen đúng SuperAdminDashboardController
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SuperAdminDashboardController>(
      builder: (c) {
        // Sync nếu period/reloadKey thay đổi
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) c.syncPosIfNeeded();
        });

        if (c.posIsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.posErrorMsg.isNotEmpty) {
          return _buildError(c);
        }
        if (c.posData == null) {
          return const Center(child: Text('Không có dữ liệu'));
        }
        return _buildBody(c);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BODY
  // ══════════════════════════════════════════════════════════════

  Widget _buildBody(SuperAdminDashboardController c) {
    final d = c.posData!;
    return RefreshIndicator(
      color: _ct.primary,
      onRefresh: () async {
        if (!mounted) return;
        c.pullRefresh();
        await Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 80));
          return mounted && c.posIsLoading;
        });
      },
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('super_admin_pos_dashboard_scroll'),
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;
            return Column(children: [
              _buildCards(d, animKey: c.posAnimationKey, isNarrow: isNarrow),
              const SizedBox(height: 14),
              if (isNarrow) ...[
                _buildChart(d),
                const SizedBox(height: 14),
                _SuperAdminPieCard(data: d),
              ] else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: _buildChart(d)),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: _SuperAdminPieCard(data: d)),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
              _buildTopProducts(d),
              const SizedBox(height: 14),
              _buildRecentOrders(d, isNarrow: isNarrow),
              const SizedBox(height: 16),
            ]);
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 4 STAT CARDS
  // ══════════════════════════════════════════════════════════════

  Widget _buildCards(SuperAdminPosDashboardModel d,
      {required int animKey, bool isNarrow = false}) {
    final os = d.orderSummary;
    final rs = d.revenueSummary;
    final cards = [
      _SuperAdminStatCard(
        key: ValueKey('pos_c1_$animKey'),
        icon: Icons.storefront_outlined,
        color: const Color(0xFF2563EB),
        label: 'Offline',
        value: os.offlineOrders.toDouble(),
        isCurrency: false,
        line1: 'Số đơn',
        line2: '',
      ),
      _SuperAdminStatCard(
        key: ValueKey('pos_c2_$animKey'),
        icon: Icons.delivery_dining_outlined,
        color: const Color(0xFFEE4D2D),
        label: 'ShopeeFood',
        value: os.shopeeFoodOrders.toDouble(),
        isCurrency: false,
        line1: 'Số đơn',
        line2: '',
      ),
      _SuperAdminStatCard(
        key: ValueKey('pos_c3_$animKey'),
        icon: Icons.two_wheeler_outlined,
        color: const Color(0xFF00B14F),
        label: 'GrabFood',
        value: os.grabFoodOrders.toDouble(),
        isCurrency: false,
        line1: 'Số đơn',
        line2: '',
      ),
      _SuperAdminStatCard(
        key: ValueKey('pos_c4_$animKey'),
        icon: Icons.attach_money_outlined,
        color: const Color(0xFF7C3AED),  // tím indigo — khác hẳn 3 card kia
        label: 'Doanh thu',
        value: rs.totalRevenue,
        isCurrency: true,
        line1: '',
        line2: '',
      ),
    ];

    if (isNarrow) {
      return Column(children: [
        Row(children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 10),
          Expanded(child: cards[1]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: cards[2]),
          const SizedBox(width: 10),
          Expanded(child: cards[3]),
        ]),
      ]);
    }
    return Row(children: [
      Expanded(child: cards[0]),
      const SizedBox(width: 10),
      Expanded(child: cards[1]),
      const SizedBox(width: 10),
      Expanded(child: cards[2]),
      const SizedBox(width: 10),
      Expanded(child: cards[3]),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  // TIME-SERIES CHART
  // ══════════════════════════════════════════════════════════════

  Widget _buildChart(SuperAdminPosDashboardModel d) {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 16,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title('Đơn hàng theo thời gian'),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: d.ordersByTime.isEmpty
              ? Center(
              child: MyText.bodyMedium('Không có dữ liệu', muted: true))
              : SfCartesianChart(
            primaryXAxis: CategoryAxis(
                labelRotation: -30,
                majorGridLines: const MajorGridLines(width: 0)),
            primaryYAxis: NumericAxis(
                name: 'orders',
                numberFormat: NumberFormat.compact()),
            axes: [
              NumericAxis(
                name: 'revenue',
                opposedPosition: true,
                numberFormat: NumberFormat.compactCurrency(
                    locale: 'vi', symbol: ''),
                majorGridLines: const MajorGridLines(width: 0),
              )
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
            legend:
            Legend(isVisible: true, position: LegendPosition.top),
            series: [
              ColumnSeries<SuperAdminPosOrderByTimeModel, String>(
                name: 'Đơn hàng',
                dataSource: d.ordersByTime,
                xValueMapper: (e, _) => e.timeBucket,
                yValueMapper: (e, _) => e.orderCount,
                yAxisName: 'orders',
                color: _ct.primary,
                width: 0.5,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(3)),
              ),
              LineSeries<SuperAdminPosOrderByTimeModel, String>(
                name: 'Doanh thu',
                dataSource: d.ordersByTime,
                xValueMapper: (e, _) => e.timeBucket,
                yValueMapper: (e, _) => e.revenue,
                yAxisName: 'revenue',
                color: const Color(0xFF16A34A),
                markerSettings:
                const MarkerSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // TOP PRODUCTS TABLE
  // ══════════════════════════════════════════════════════════════

  Widget _buildTopProducts(SuperAdminPosDashboardModel d) {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 0,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Row(children: [
            Icon(Icons.fastfood_outlined, size: 15, color: _ct.primary),
            const SizedBox(width: 6),
            _title('Top sản phẩm'),
          ]),
        ),
        const Divider(height: 0),
        _prodRow(
            rank: 0,
            name: 'Sản phẩm',
            qty: 'SL',
            revenue: 'Doanh thu',
            orders: 'Đơn',
            isHeader: true),
        const Divider(height: 0),
        if (d.topProducts.isEmpty)
          Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                  child: Text('Không có dữ liệu',
                      style:
                      TextStyle(fontSize: 12, color: _ct.secondary))))
        else
          ...d.topProducts.asMap().entries.map((e) => Column(children: [
            _prodRow(
                rank: e.key + 1,
                name: e.value.productName,
                qty: _num(e.value.totalQuantity),
                revenue: _cur(e.value.totalRevenue),
                orders: _num(e.value.orderCount)),
            if (e.key < d.topProducts.length - 1)
              Divider(
                  height: 0,
                  color: _ct.secondary.withOpacity(0.07)),
          ])),
      ]),
    );
  }

  // FIX: dùng Expanded thay SizedBox cố định → tránh overflow
  Widget _prodRow({
    required int rank,
    required String name,
    required String qty,
    required String revenue,
    required String orders,
    bool isHeader = false,
  }) {
    final hs = TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700, color: _ct.secondary);
    return Container(
      color: isHeader ? _ct.secondary.withOpacity(0.06) : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        if (isHeader)
          SizedBox(
              width: 28,
              child: Text('#', style: hs, textAlign: TextAlign.center))
        else
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: rank <= 3
                  ? _ct.primary.withOpacity(0.13)
                  : _ct.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
                child: Text('$rank',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color:
                        rank <= 3 ? _ct.primary : _ct.secondary))),
          ),
        Expanded(
            flex: 5,
            child: Text(name,
                overflow: TextOverflow.ellipsis,
                style: isHeader
                    ? hs
                    : TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w500))),
        // FIX: Expanded thay vì SizedBox(width: 60) — không overflow
        Expanded(
            flex: 2,
            child: Text(qty,
                textAlign: TextAlign.center,
                style: isHeader ? hs : const TextStyle(fontSize: 12))),
        Expanded(
            flex: 3,
            child: Text(revenue,
                textAlign: TextAlign.right,
                style: isHeader
                    ? hs
                    : TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _ct.primary))),
        Expanded(
            flex: 2,
            child: Text(orders,
                textAlign: TextAlign.center,
                style: isHeader
                    ? hs
                    : TextStyle(fontSize: 11, color: _ct.secondary))),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // RECENT ORDERS TABLE
  // ══════════════════════════════════════════════════════════════

  Widget _buildRecentOrders(SuperAdminPosDashboardModel d,
      {bool isNarrow = false}) {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 0,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(children: [
            Icon(Icons.receipt_long_outlined, size: 15, color: _ct.primary),
            const SizedBox(width: 6),
            _title('Đơn hàng gần đây'),
          ]),
        ),
        const Divider(height: 0),
        _orderHeader(isNarrow: isNarrow),
        const Divider(height: 0),
        if (d.recentOrders.isEmpty)
          Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                  child: MyText.bodyMedium('Không có đơn hàng', muted: true)))
        else
          ...d.recentOrders.map((o) => Column(children: [
            _orderRow(o, isNarrow: isNarrow),
            Divider(
                height: 0, color: _ct.secondary.withOpacity(0.08)),
          ])),
      ]),
    );
  }

  Widget _orderHeader({bool isNarrow = false}) {
    final s = TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700, color: _ct.secondary);
    return Container(
      color: _ct.secondary.withOpacity(0.06),
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: isNarrow
          ? Row(children: [
        Expanded(flex: 3, child: Text('Mã đơn', style: s)),
        Expanded(flex: 3, child: Text('Nguồn', style: s)),
        Expanded(flex: 3, child: Text('Tổng tiền', style: s)),
        Expanded(
            flex: 2,
            child: Text('Trạng thái',
                style: s, textAlign: TextAlign.center)),
      ])
          : Row(children: [
        Expanded(flex: 2, child: Text('Mã đơn', style: s)),
        Expanded(flex: 2, child: Text('Nguồn', style: s)),
        Expanded(flex: 2, child: Text('Thời gian', style: s)),
        Expanded(flex: 2, child: Text('Tổng tiền', style: s)),
        Expanded(flex: 2, child: Text('Thanh toán', style: s)),
        Expanded(
            flex: 2,
            child: Text('Trạng thái',
                style: s, textAlign: TextAlign.center)),
      ]),
    );
  }

  Widget _orderRow(SuperAdminPosRecentOrderModel o,
      {bool isNarrow = false}) {
    final src = _srcColor(o.orderSource);
    final sc = _stColor(o.status);
    final pmLabel = _pmLabel(o.paymentMethod);

    return Container(
      color: src.withOpacity(0.04),
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: isNarrow
          ? Row(children: [
        Expanded(
            flex: 3,
            child: _SuperAdminOrderIdCell(
                code: o.orderCode, color: src, fontSize: 11)),
        Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(_srcIcon(o.orderSource),
                      size: 11, color: src),
                  const SizedBox(width: 3),
                  Flexible(
                      child: Text(_srcLabel(o.orderSource),
                          style: TextStyle(
                              fontSize: 11,
                              color: src,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis)),
                ]),
                Text(_date(o.createdAt),
                    style: TextStyle(
                        fontSize: 10,
                        color: src.withOpacity(0.65))),
              ],
            )),
        Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_cur(o.finalAmount),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: src)),
                _badge(pmLabel, src),
              ],
            )),
        Expanded(
            flex: 2,
            child: Center(
                child: _badge(_stLabel(o.status), sc))),
      ])
          : Row(children: [
        Expanded(
            flex: 2,
            child: _SuperAdminOrderIdCell(
                code: o.orderCode, color: src, fontSize: 12)),
        Expanded(
            flex: 2,
            child: Row(children: [
              Icon(_srcIcon(o.orderSource), size: 13, color: src),
              const SizedBox(width: 4),
              Flexible(
                  child: Text(_srcLabel(o.orderSource),
                      style: TextStyle(
                          fontSize: 11,
                          color: src,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis)),
            ])),
        Expanded(
            flex: 2,
            child: Text(_date(o.createdAt),
                style: TextStyle(
                    fontSize: 11,
                    color: src.withOpacity(0.75)))),
        Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_cur(o.finalAmount),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: src)),
                if (o.totalAmount != o.finalAmount)
                  Text('Gốc: ${_cur(o.totalAmount)}',
                      style: TextStyle(
                          fontSize: 10,
                          color: src.withOpacity(0.55),
                          decoration:
                          TextDecoration.lineThrough)),
              ],
            )),
        Expanded(flex: 2, child: _badge(pmLabel, src)),
        Expanded(
            flex: 2,
            child:
            Center(child: _badge(_stLabel(o.status), sc))),
      ]),
    );
  }

  // ── Error ──────────────────────────────────────────────────────

  Widget _buildError(SuperAdminDashboardController c) {
    return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, size: 52, color: _ct.danger),
          MySpacing.height(12),
          MyText.bodyMedium(c.posErrorMsg, color: _ct.danger),
          MySpacing.height(16),
          ElevatedButton.icon(
            onPressed: c.reload,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ]));
  }

  // ── Helpers ────────────────────────────────────────────────────

  Widget _title(String t) => Text(t,
      style: TextStyle(
          fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: _ct.primary));

  Widget _badge(String label, Color color) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5)),
    child: Text(label,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color)),
  );
}

// ══════════════════════════════════════════════════════════════════
// _SuperAdminPieCard
// ══════════════════════════════════════════════════════════════════

class _SuperAdminPieCard extends StatefulWidget {
  final SuperAdminPosDashboardModel data;
  const _SuperAdminPieCard({required this.data});

  @override
  State<_SuperAdminPieCard> createState() => _SuperAdminPieCardState();
}

class _SuperAdminPieCardState extends State<_SuperAdminPieCard> {
  int _mode = 0;
  int _chartKey = 0;

  static const _kSourceColors = {
    'OFFLINE': Color(0xFF2563EB),
    'SHOPEE_FOOD': Color(0xFFEE4D2D),
    'GRAB_FOOD': Color(0xFF00B14F),
  };
  static const _kCatColors = {
    'HOT': Color(0xFFEA580C),
    'COLD': Color(0xFF0891B2),
    'COMBO': Color(0xFF7C3AED),
  };

  Color _pieColor(String key, int i) {
    final map = _mode == 0 ? _kSourceColors : _kCatColors;
    return map[key] ?? _col(i);
  }

  void _toggleMode(int v) {
    if (v == _mode) return;
    setState(() {
      _mode = v;
      _chartKey++;
    });
  }

  String _cur(double v) => NumberFormat('#,###', 'vi_VN').format(v);
  String _num(num v) => NumberFormat('#,###', 'vi_VN').format(v);

  Widget _title(String t) {
    final ct = AdminTheme.theme.contentTheme;
    return Text(t,
        style: TextStyle(
            fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: ct.primary));
  }

  @override
  Widget build(BuildContext context) {
    final ct = AdminTheme.theme.contentTheme;
    final d = widget.data;
    final items = _mode == 0
        ? d.paymentBreakdown.sourcePieItems
        : d.paymentBreakdown.categoryPieItems;
    final totalCount = items.fold<int>(0, (s, e) => s + e.count);

    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 16,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _title('Phân tích đơn hàng')),
          _SuperAdminPieModeToggle(mode: _mode, onChanged: _toggleMode),
        ]),
        const SizedBox(height: 10),
        SizedBox(
          height: 210,
          child: items.isEmpty || totalCount == 0
              ? Center(
              child: MyText.bodyMedium('Không có dữ liệu', muted: true))
              : SfCircularChart(
            key: ValueKey(_chartKey),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: [
              DoughnutSeries<SuperAdminPosPieItemModel, String>(
                dataSource: items,
                xValueMapper: (m, _) => m.label,
                yValueMapper: (m, _) => m.count.toDouble(),
                pointColorMapper: (m, i) =>
                    _pieColor(m.key, i),
                dataLabelMapper: (m, _) => totalCount > 0
                    ? '${(m.count / totalCount * 100).toStringAsFixed(1)}%'
                    : '',
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition:
                  ChartDataLabelPosition.outside,
                  textStyle: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
                animationDuration: 800,
                innerRadius: '55%',
                radius: '85%',
              )
            ],
          ),
        ),
        if (items.isNotEmpty && totalCount > 0) ...[
          const Divider(height: 14),
          ...items.asMap().entries.map((e) {
            final color = _pieColor(e.value.key, e.key);
            return Padding(
              padding:
              const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle)),
                const SizedBox(width: 7),
                Expanded(
                    child: Text(e.value.label,
                        style:
                        const TextStyle(fontSize: 11))),
                Text('${_num(e.value.count)} đơn',
                    style: TextStyle(
                        fontSize: 10, color: ct.secondary)),
                const SizedBox(width: 8),
                Text(_cur(e.value.amount),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ]),
            );
          }),
        ],
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// _SuperAdminPieModeToggle
// ══════════════════════════════════════════════════════════════════

class _SuperAdminPieModeToggle extends StatelessWidget {
  final int mode;
  final ValueChanged<int> onChanged;

  const _SuperAdminPieModeToggle(
      {required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ct = AdminTheme.theme.contentTheme;
    return Container(
      decoration: BoxDecoration(
        color: ct.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(0, 'Nguồn', ct),
        _btn(1, 'Loại', ct),
      ]),
    );
  }

  Widget _btn(int idx, String label, dynamic ct) {
    final active = mode == idx;
    return GestureDetector(
      onTap: () => onChanged(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? ct.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : ct.secondary,
            )),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// _SuperAdminStatCard
// ══════════════════════════════════════════════════════════════════

class _SuperAdminStatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, line1, line2;
  final double value;
  final bool isCurrency;

  const _SuperAdminStatCard({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.isCurrency,
    required this.line1,
    required this.line2,
  });

  String _fmt(double v) => isCurrency
      ? NumberFormat('#,###', 'vi_VN').format(v)
      : NumberFormat('#,###', 'vi_VN').format(v.toInt());

  String _fmtCompact(double v) {
    if (v >= 1000000000) {
      final ty = v / 1000000000;
    return ty % 1 == 0
    ? '${ty.toInt()} Tỷ'
        : '${ty.toStringAsFixed(1)} Tỷ';
    } else if (v >= 1000000) {
    final tr = v / 1000000;
    return tr % 1 == 0
    ? '${tr.toInt()} Tr'
        : '${tr.toStringAsFixed(1)} Tr';
    } else if (v >= 1000) {
    final k = v / 1000;
    return k % 1 == 0
    ? '${k.toInt()}K'
        : '${k.toStringAsFixed(1)}K';
    }
    return NumberFormat('#,###', 'vi_VN').format(v.toInt());
  }


  @override
  Widget build(BuildContext context) {
    final ct = AdminTheme.theme.contentTheme;
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 0,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 20, color: color)),
            const Spacer(),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ),
          ]),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOut,
            builder: (_, v, __) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                isCurrency ? _fmtCompact(v) : _fmt(v),
                style: TextStyle(
                    fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Hiện số đầy đủ ở dòng nhỏ bên dưới nếu là currency
          if (isCurrency && value >= 1000)
            Text(
              'Chi tiết ${NumberFormat('#,###', 'vi_VN').format(value.toInt())}',
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.6)),
            ),
          const SizedBox(height: 4),
          if (line1.isNotEmpty)
            Text(line1, style: TextStyle(fontSize: 11, color: ct.secondary)),
          const SizedBox(height: 2),
          if (line2.isNotEmpty)
            Text(line2, style: TextStyle(fontSize: 11, color: ct.secondary)),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// _SuperAdminOrderIdCell
// ══════════════════════════════════════════════════════════════════

class _SuperAdminOrderIdCell extends StatelessWidget {
  final String code;
  final Color color;
  final double fontSize;

  const _SuperAdminOrderIdCell({
    required this.code,
    required this.color,
    this.fontSize = 11,
  });

  List<String> _parseLines() {
    final parts = code.split('-');
    if (parts.isEmpty) return [code];
    final rest = parts.skip(1).toList();
    if (rest.isEmpty) return [code];
    final isDateFirst =
        rest.isNotEmpty && RegExp(r'^\d{8}$').hasMatch(rest[0]);
    return isDateFirst ? rest : rest;
  }

  @override
  Widget build(BuildContext context) {
    final lines = _parseLines();
    final boldStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color);
    final mutedStyle = TextStyle(
        fontSize: fontSize - 1,
        fontWeight: FontWeight.w500,
        color: color.withOpacity(0.75));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < lines.length; i++)
          Text(lines[i],
              style: i == 0 ? boldStyle : mutedStyle,
              overflow: TextOverflow.ellipsis),
      ],
    );
  }
}