// lib/views/ui/general/pos_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/controller/ui/general/dashboard_controller.dart';
import 'package:original_taste/helper/services/dashboard_services.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

final _ct = AdminTheme.theme.contentTheme;

const _kColors = [
  Color(0xFF2563EB), Color(0xFF16A34A), Color(0xFFD946EF), Color(0xFFEA580C),
  Color(0xFF0891B2), Color(0xFF7C3AED), Color(0xFFF59E0B), Color(0xFFE11D48),
];
Color _col(int i) => _kColors[i % _kColors.length];

class PosDashboardScreen extends StatefulWidget {
  const PosDashboardScreen({super.key});

  @override
  State<PosDashboardScreen> createState() => _PosDashboardScreenState();
}

class _PosDashboardScreenState extends State<PosDashboardScreen> {
  // ScrollController riêng → dispose đúng cách, tránh lỗi
  // "Looking up a deactivated widget's ancestor is unsafe"
  // keepScrollOffset: false → tắt PageStorage lookup, fix lỗi deactivated widget
  final ScrollController _scrollCtrl = ScrollController(keepScrollOffset: false);

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _cur(double v) => NumberFormat('#,###', 'vi_VN').format(v);
  String _num(num v)    => NumberFormat('#,###', 'vi_VN').format(v);
  String _date(int? ts) => ts == null ? '—'
      : DateFormat('dd/MM HH:mm').format(DateTime.fromMillisecondsSinceEpoch(ts));

  IconData _srcIcon(String s)  => switch (s) {
    'SHOPEE_FOOD' => Icons.delivery_dining_outlined,
    'GRAB_FOOD'   => Icons.two_wheeler_outlined,
    _             => Icons.storefront_outlined,
  };
  Color    _srcColor(String s) => switch (s) {
    'SHOPEE_FOOD' => const Color(0xFFEE4D2D), // cam — khớp pie
    'GRAB_FOOD'   => const Color(0xFF00B14F), // xanh lá — khớp pie
    _             => const Color(0xFF2563EB), // xanh dương Offline — khớp pie
  };
  String   _srcLabel(String s) => switch (s) {
    'SHOPEE_FOOD' => 'ShopeeFood',
    'GRAB_FOOD'   => 'GrabFood',
    _             => 'Offline',
  };
  Color  _stColor(String s) => switch (s) {
    'COMPLETED' => Colors.green,
    'CANCELLED' => Colors.red,
    'PENDING'   => Colors.orange,
    _           => Colors.grey,
  };
  String _stLabel(String s) => switch (s) {
    'COMPLETED' => 'Hoàn thành',
    'CANCELLED' => 'Đã hủy',
    'PENDING'   => 'Chờ xử lý',
    _           => s,
  };
  String _pmLabel(String? m) => switch (m) {
    'CASH'                    => 'Tiền mặt',
    'BANK_TRANSFER'           => 'Chuyển khoản',
    'TRANSFER'                => 'Chuyển khoản', // backend alias
    'MOMO'                    => 'MoMo',
    'VNPAY'                   => 'VNPay',
    'ZALOPAY'                 => 'ZaloPay',
    _                         => m ?? '—',
  };
  Color _pmColor(String? m) => switch (m) {
    'CASH'          => const Color(0xFF16A34A),  // xanh lá
    'BANK_TRANSFER' => const Color(0xFF2563EB),  // xanh dương
    'MOMO'          => const Color(0xFFAE2070),  // hồng MoMo
    'VNPAY'         => const Color(0xFF0056A2),  // xanh VNPay
    'ZALOPAY'       => const Color(0xFF006AF5),  // xanh ZaloPay
    _               => Colors.grey,
  };

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
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
  // BODY + PULL TO REFRESH
  // ══════════════════════════════════════════════════════════════

  Widget _buildBody(DashboardController c) {
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
        key: const PageStorageKey<String>('pos_dashboard_scroll'),
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _buildCards(d, animKey: c.posAnimationKey),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(flex: 3, child: _buildChart(d)),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _PieCard(data: d)),
            ]),
          ),
          const SizedBox(height: 14),
          _buildTopProducts(d),
          const SizedBox(height: 14),
          _buildRecentOrders(d),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // 4 STAT CARDS
  // ValueKey(animKey) → Flutter tạo lại widget → TweenAnimationBuilder restart
  // ══════════════════════════════════════════════════════════════

  Widget _buildCards(PosDashboardModel d, {required int animKey}) {
    final os = d.orderSummary;
    final rs = d.revenueSummary;
    return Row(children: [
      Expanded(child: _StatCard(
        key: ValueKey('pos_c1_$animKey'),
        icon: Icons.storefront_outlined, color: _ct.primary, label: 'Offline',
        value: os.offlineOrders.toDouble(), isCurrency: false,
        line1: 'Hoàn thành: ${_num(os.completedOrders)}',
        line2: 'Đã hủy: ${_num(os.cancelledOrders)}',
      )),
      const SizedBox(width: 10),
      Expanded(child: _StatCard(
        key: ValueKey('pos_c2_$animKey'),
        icon: Icons.delivery_dining_outlined, color: const Color(0xFFEE4D2D), label: 'ShopeeFood',
        value: os.shopeeFoodOrders.toDouble(), isCurrency: false,
        line1: 'Tổng đơn: ${_num(os.totalOrders)}',
        line2: 'Chờ xử lý: ${_num(os.pendingOrders)}',
      )),
      const SizedBox(width: 10),
      Expanded(child: _StatCard(
        key: ValueKey('pos_c3_$animKey'),
        icon: Icons.two_wheeler_outlined, color: const Color(0xFF00B14F), label: 'GrabFood',
        value: os.grabFoodOrders.toDouble(), isCurrency: false,
        line1: 'Offline: ${_cur(rs.offlineRevenue)}',
        line2: 'Shopee: ${_cur(rs.shopeeFoodRevenue)}',
      )),
      const SizedBox(width: 10),
      Expanded(child: _StatCard(
        key: ValueKey('pos_c4_$animKey'),
        icon: Icons.attach_money_outlined, color: const Color(0xFF16A34A), label: 'Tổng doanh thu',
        value: rs.totalRevenue, isCurrency: true,
        line1: 'Grab: ${_cur(rs.grabFoodRevenue)}',
        line2: 'Tổng: ${_num(os.totalOrders)} đơn',
      )),
    ]);
  }

  // ══════════════════════════════════════════════════════════════
  // TIME-SERIES CHART
  // ══════════════════════════════════════════════════════════════

  Widget _buildChart(PosDashboardModel d) {
    return MyCard(
      borderRadiusAll: 12, paddingAll: 16,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _title('Đơn hàng theo thời gian'),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: d.ordersByTime.isEmpty
              ? Center(child: MyText.bodyMedium('Không có dữ liệu', muted: true))
              : SfCartesianChart(
            primaryXAxis: CategoryAxis(labelRotation: -30,
                majorGridLines: const MajorGridLines(width: 0)),
            primaryYAxis: NumericAxis(name: 'orders',
                numberFormat: NumberFormat.compact()),
            axes: [NumericAxis(
              name: 'revenue', opposedPosition: true,
              numberFormat: NumberFormat.compactCurrency(locale: 'vi', symbol: ''),
              majorGridLines: const MajorGridLines(width: 0),
            )],
            tooltipBehavior: TooltipBehavior(enable: true),
            legend: Legend(isVisible: true, position: LegendPosition.top),
            series: [
              ColumnSeries<PosOrderByTimeModel, String>(
                name: 'Đơn hàng', dataSource: d.ordersByTime,
                xValueMapper: (e, _) => e.timeBucket,
                yValueMapper: (e, _) => e.orderCount,
                yAxisName: 'orders', color: _ct.primary, width: 0.5,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              ),
              LineSeries<PosOrderByTimeModel, String>(
                name: 'Doanh thu', dataSource: d.ordersByTime,
                xValueMapper: (e, _) => e.timeBucket,
                yValueMapper: (e, _) => e.revenue,
                yAxisName: 'revenue', color: const Color(0xFF16A34A),
                markerSettings: const MarkerSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // Pie chart đã tách thành _PieCard widget riêng (bên dưới)
  // để quản lý animation key độc lập khi toggle Nguồn / Loại

  // ══════════════════════════════════════════════════════════════
  // TOP PRODUCTS TABLE
  // ══════════════════════════════════════════════════════════════

  Widget _buildTopProducts(PosDashboardModel d) {
    return MyCard(
      borderRadiusAll: 12, paddingAll: 0,
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
        _prodRow(rank: 0, name: 'Sản phẩm', qty: 'SL',
            revenue: 'Doanh thu', orders: 'Đơn', isHeader: true),
        const Divider(height: 0),
        if (d.topProducts.isEmpty)
          Padding(padding: const EdgeInsets.all(20),
              child: Center(child: Text('Không có dữ liệu',
                  style: TextStyle(fontSize: 12, color: _ct.secondary))))
        else
          ...d.topProducts.asMap().entries.map((e) => Column(children: [
            _prodRow(rank: e.key + 1, name: e.value.productName,
                qty: _num(e.value.totalQuantity), revenue: _cur(e.value.totalRevenue),
                orders: _num(e.value.orderCount)),
            if (e.key < d.topProducts.length - 1)
              Divider(height: 0, color: _ct.secondary.withOpacity(0.07)),
          ])),
      ]),
    );
  }

  Widget _prodRow({
    required int rank, required String name, required String qty,
    required String revenue, required String orders, bool isHeader = false,
  }) {
    final hs = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _ct.secondary);
    return Container(
      color: isHeader ? _ct.secondary.withOpacity(0.06) : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(children: [
        if (isHeader)
          SizedBox(width: 28, child: Text('#', style: hs, textAlign: TextAlign.center))
        else
          Container(
            width: 24, height: 24, margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: rank <= 3 ? _ct.primary.withOpacity(0.13) : _ct.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(child: Text('$rank', style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: rank <= 3 ? _ct.primary : _ct.secondary))),
          ),
        Expanded(flex: 5, child: Text(name, overflow: TextOverflow.ellipsis,
            style: isHeader ? hs : TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        SizedBox(width: 60, child: Text(qty, textAlign: TextAlign.center,
            style: isHeader ? hs : const TextStyle(fontSize: 12))),
        SizedBox(width: 120, child: Text(revenue, textAlign: TextAlign.right,
            style: isHeader ? hs : TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ct.primary))),
        SizedBox(width: 60, child: Text(orders, textAlign: TextAlign.center,
            style: isHeader ? hs : TextStyle(fontSize: 11, color: _ct.secondary))),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // RECENT ORDERS TABLE
  // ══════════════════════════════════════════════════════════════

  Widget _buildRecentOrders(PosDashboardModel d) {
    return MyCard(
      borderRadiusAll: 12, paddingAll: 0,
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
        _orderHeader(),
        const Divider(height: 0),
        if (d.recentOrders.isEmpty)
          Padding(padding: const EdgeInsets.all(24),
              child: Center(child: MyText.bodyMedium('Không có đơn hàng', muted: true)))
        else
          ...d.recentOrders.map((o) => Column(children: [
            _orderRow(o),
            Divider(height: 0, color: _ct.secondary.withOpacity(0.08)),
          ])),
      ]),
    );
  }

  Widget _orderHeader() {
    final s = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _ct.secondary);
    return Container(
      color: _ct.secondary.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Expanded(flex: 2, child: Text('Mã đơn',                   style: s)),
        Expanded(flex: 2, child: Text('Nguồn',                    style: s)),
        Expanded(flex: 2, child: Text('Thời gian',                style: s)),
        Expanded(flex: 2, child: Text('Tổng tiền',                style: s)),
        Expanded(flex: 2, child: Text('Thanh toán',              style: s)),
        Expanded(flex: 2, child: Text('Trạng thái',               style: s, textAlign: TextAlign.center)),
      ]),
    );
  }

  Widget _orderRow(PosRecentOrderModel o) {
    final src     = _srcColor(o.orderSource);
    final sc      = _stColor(o.status);
    final pm      = o.paymentMethod;
    final pmLabel = _pmLabel(pm);

    return Container(
      color: src.withOpacity(0.04),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(children: [
        // Mã đơn — màu source
        Expanded(flex: 2, child: Text(o.orderCode,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: src),
            overflow: TextOverflow.ellipsis)),
        // Nguồn
        Expanded(flex: 2, child: Row(children: [
          Icon(_srcIcon(o.orderSource), size: 13, color: src),
          const SizedBox(width: 4),
          Flexible(child: Text(_srcLabel(o.orderSource),
              style: TextStyle(fontSize: 11, color: src, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis)),
        ])),
        // Thời gian — màu source muted
        Expanded(flex: 2, child: Text(_date(o.createdAt),
            style: TextStyle(fontSize: 11, color: src.withOpacity(0.75)))),
        // Tổng tiền — màu source
        Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_cur(o.finalAmount),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: src)),
          if (o.totalAmount != o.finalAmount)
            Text('Gốc: ${_cur(o.totalAmount)}',
                style: TextStyle(fontSize: 10, color: src.withOpacity(0.55),
                    decoration: TextDecoration.lineThrough)),
        ])),
        // Phương thức thanh toán — màu theo nguồn
        Expanded(flex: 2, child: _badge(pmLabel, src)),
        // Trạng thái
        Expanded(flex: 2, child: Center(child: _badge(_stLabel(o.status), sc))),
      ]),
    );
  }

  // ── Error ─────────────────────────────────────────────────────

  Widget _buildError(DashboardController c) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
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

  // ── Helpers ───────────────────────────────────────────────────

  Widget _title(String t) => Text(t, style: TextStyle(
      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
      fontWeight: FontWeight.w700, fontSize: 14, color: _ct.primary));

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(5)),
    child: Text(label, textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}

// ══════════════════════════════════════════════════════════════════
// _PieCard — StatefulWidget riêng để quản lý animation key nội bộ
// Mỗi lần toggle Nguồn ↔ Loại → _chartKey tăng → SfCircularChart
// bị dispose + recreate → animation entry chạy lại từ đầu
// ══════════════════════════════════════════════════════════════════

class _PieCard extends StatefulWidget {
  final PosDashboardModel data;
  const _PieCard({required this.data});

  @override
  State<_PieCard> createState() => _PieCardState();
}

class _PieCardState extends State<_PieCard> {
  int  _mode     = 0; // 0 = Nguồn, 1 = Loại
  int  _chartKey = 0; // tăng mỗi lần toggle → rebuild SfCircularChart → animation restart

  static const _kSourceColors = {
    'OFFLINE':     Color(0xFF2563EB),
    'SHOPEE_FOOD': Color(0xFFEE4D2D),
    'GRAB_FOOD':   Color(0xFF00B14F),
  };
  static const _kCatColors = {
    'HOT':   Color(0xFFEA580C),
    'COLD':  Color(0xFF0891B2),
    'COMBO': Color(0xFF7C3AED),
  };

  Color _pieColor(String key, int i) {
    final map = _mode == 0 ? _kSourceColors : _kCatColors;
    return map[key] ?? _col(i);
  }

  void _toggleMode(int v) {
    if (v == _mode) return;
    setState(() {
      _mode     = v;
      _chartKey++;   // ← key mới → Flutter dispose widget cũ, tạo mới → animation chạy lại
    });
  }

  String _cur(double v) => NumberFormat('#,###', 'vi_VN').format(v);
  String _num(num v)    => NumberFormat('#,###', 'vi_VN').format(v);

  Widget _title(String t) {
    final ct = AdminTheme.theme.contentTheme;
    return Text(t, style: TextStyle(
        fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
        fontWeight: FontWeight.w700, fontSize: 14, color: ct.primary));
  }

  @override
  Widget build(BuildContext context) {
    final ct      = AdminTheme.theme.contentTheme;
    final d       = widget.data;
    final isSource = _mode == 0;
    final items   = isSource
        ? d.paymentBreakdown.sourcePieItems
        : d.paymentBreakdown.categoryPieItems;
    final totalCount = items.fold<int>(0, (s, e) => s + e.count);

    return MyCard(
      borderRadiusAll: 12, paddingAll: 16,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header + toggle
        Row(children: [
          Expanded(child: _title('Phân tích đơn hàng')),
          _PieModeToggle(mode: _mode, onChanged: _toggleMode),
        ]),
        const SizedBox(height: 10),

        // Donut chart — ValueKey(_chartKey) đảm bảo Flutter tạo lại widget
        // khi key đổi → animation entry của SfCircularChart chạy lại
        SizedBox(
          height: 210,
          child: items.isEmpty || totalCount == 0
              ? Center(child: MyText.bodyMedium('Không có dữ liệu', muted: true))
              : SfCircularChart(
            key: ValueKey(_chartKey),
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: [DoughnutSeries<PosPieItemModel, String>(
              dataSource: items,
              xValueMapper: (m, _) => m.label,
              yValueMapper: (m, _) => m.count.toDouble(),
              pointColorMapper: (m, i) => _pieColor(m.key, i),
              dataLabelMapper: (m, _) => totalCount > 0
                  ? '${(m.count / totalCount * 100).toStringAsFixed(1)}%' : '',
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside,
                textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
              animationDuration: 800,
              innerRadius: '55%', radius: '85%',
            )],
          ),
        ),

        // Legend rows
        if (items.isNotEmpty && totalCount > 0) ...[
          const Divider(height: 14),
          ...items.asMap().entries.map((e) {
            final color = _pieColor(e.value.key, e.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Container(width: 10, height: 10,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 7),
                Expanded(child: Text(e.value.label,
                    style: const TextStyle(fontSize: 11))),
                Text('${_num(e.value.count)} đơn',
                    style: TextStyle(fontSize: 10, color: ct.secondary)),
                const SizedBox(width: 8),
                Text(_cur(e.value.amount), style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: color)),
              ]),
            );
          }),
        ],

        // Payment methods (always shown)
        // const Divider(height: 18),
        // Row(children: [
        //   Icon(Icons.payment_outlined, size: 12, color: ct.secondary),
        //   const SizedBox(width: 5),
        //   Text('Phương thức thanh toán',
        //       style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
        //           color: ct.secondary)),
        // ]),
        // const SizedBox(height: 7),
        // ...d.paymentBreakdown.methods.asMap().entries.map((e) => Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 3),
        //   child: Row(children: [
        //     Container(width: 8, height: 8,
        //         decoration: BoxDecoration(color: _col(e.key), shape: BoxShape.circle)),
        //     const SizedBox(width: 6),
        //     Expanded(child: Text(e.value.label,
        //         style: const TextStyle(fontSize: 11))),
        //     Text('${e.value.count} đơn',
        //         style: TextStyle(fontSize: 10, color: ct.secondary)),
        //     const SizedBox(width: 8),
        //     Text(_cur(e.value.amount), style: TextStyle(
        //         fontSize: 11, fontWeight: FontWeight.w600, color: _col(e.key))),
        //   ]),
        // )),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// _PieModeToggle — compact toggle: Nguồn / Loại
// ══════════════════════════════════════════════════════════════════

class _PieModeToggle extends StatelessWidget {
  final int mode;
  final ValueChanged<int> onChanged;

  const _PieModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final ct = AdminTheme.theme.contentTheme;
    return Container(
      decoration: BoxDecoration(
        color: ct.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(context, 0, 'Nguồn', ct),
        _btn(context, 1, 'Loại',  ct),
      ]),
    );
  }

  Widget _btn(BuildContext context, int idx, String label, dynamic ct) {
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
        child: Text(label, style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: active ? Colors.white : ct.secondary,
        )),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// _StatCard — ValueKey từ ngoài → rebuild khi animKey đổi
// ══════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color    color;
  final String   label, line1, line2;
  final double   value;
  final bool     isCurrency;

  const _StatCard({
    super.key,
    required this.icon, required this.color, required this.label,
    required this.value, required this.isCurrency,
    required this.line1, required this.line2,
  });

  String _fmt(double v) => isCurrency
      ? NumberFormat('#,###', 'vi_VN').format(v)
      : NumberFormat('#,###', 'vi_VN').format(v.toInt());

  @override
  Widget build(BuildContext context) {
    final ct = AdminTheme.theme.contentTheme;
    return MyCard(
      borderRadiusAll: 12, paddingAll: 0,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, size: 20, color: color)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(5)),
              child: Text(label, style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ),
          ]),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOut,
            builder: (_, v, __) => Text(_fmt(v), style: TextStyle(
                fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          ),
          const SizedBox(height: 8),
          Text(line1, style: TextStyle(fontSize: 11, color: ct.secondary)),
          const SizedBox(height: 2),
          Text(line2, style: TextStyle(fontSize: 11, color: ct.secondary)),
        ]),
      ),
    );
  }
}