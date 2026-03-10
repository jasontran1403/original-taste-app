// lib/views/ui/general/seller_wholesale_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

import '../../../controller/ui/general/super_admin_dashboard_controller.dart';
import '../../../helper/services/super_admin_dashboard_services.dart';

final _ct = AdminTheme.theme.contentTheme;

const _kPaymentColors = [
  Color(0xFF2563EB),
  Color(0xFF16A34A),
  Color(0xFFD946EF),
  Color(0xFFEA580C),
  Color(0xFF0891B2),
  Color(0xFF7C3AED),
  Color(0xFFF59E0B),
  Color(0xFFE11D48),
];

Color _paymentColor(int i) => _kPaymentColors[i % _kPaymentColors.length];

class SellerWholesaleDashboardScreen extends StatefulWidget {
  final SuperAdminRestaurantDashboardModel data;

  const SellerWholesaleDashboardScreen({super.key, required this.data});

  @override
  State<SellerWholesaleDashboardScreen> createState() => _SellerWholesaleDashboardScreenState();
}

class _SellerWholesaleDashboardScreenState extends State<SellerWholesaleDashboardScreen> with UIMixin {
  String? _activeRegion;
  final MapShapeLayerController _mapController = MapShapeLayerController();
  // keepScrollOffset: false → tắt PageStorage lookup hoàn toàn
  // đây là nguyên nhân thực sự của lỗi "Looking up a deactivated widget's ancestor"
  final ScrollController _scrollCtrl = ScrollController(keepScrollOffset: false);

  String _fmtCurrency(double v) => NumberFormat('#,###', 'vi_VN').format(v);
  String _fmtNum(num v) => NumberFormat('#,###', 'vi_VN').format(v);
  String _fmtDate(int? ts) {
    if (ts == null) return '—';
    return DateFormat('dd/MM HH:mm').format(DateTime.fromMillisecondsSinceEpoch(ts));
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<SuperAdminDashboardController>();
    return RefreshIndicator(
      color: _ct.primary,
      onRefresh: () async {
        if (!mounted) return;
        c.pullRefresh();
        await Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 80));
          return mounted && c.isLoading;
        });
      },
      child: SingleChildScrollView(
        key: const PageStorageKey<String>('wholesale_dashboard_scroll'),
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 600;
            final d = widget.data;
            return Column(children: [
              _buildCards(d, isNarrow: isNarrow),
              const SizedBox(height: 14),
              if (isNarrow) ...[
                _buildChart(d),
                const SizedBox(height: 14),
                _buildPaymentPie(d),
              ] else
                IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Expanded(flex: 3, child: _buildChart(d)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildPaymentPie(d)),
                ])),
              const SizedBox(height: 14),
              if (isNarrow) ...[
                _buildRegionChart(d),
                const SizedBox(height: 14),
                _buildTopProducts(d),
              ] else
                IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Expanded(flex: 3, child: _buildRegionChart(d)),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: _buildTopProducts(d)),
                ])),
              const SizedBox(height: 14),
              if (isNarrow) ...[
                _buildTopUsers(d),
                const SizedBox(height: 14),
                _buildTopCustomers(d),
              ] else
                IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Expanded(child: _buildTopUsers(d)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTopCustomers(d)),
                ])),
              const SizedBox(height: 14),
              _buildRecentOrders(d, isNarrow: isNarrow),
              const SizedBox(height: 16),
            ]);
          },
        ),
      ),
    );
  }

  // =====================================================================
  // STAT CARDS
  // =====================================================================
  Widget _buildCards(SuperAdminRestaurantDashboardModel d, {bool isNarrow = false}) {
    final cards = [
      _StatCard(
        icon: Icons.receipt_long_outlined, color: _ct.primary, title: 'Đơn hàng',
        value: d.orderSummary.totalOrders, isCurrency: false,
        line1: 'Hoàn thành: ${_fmtNum(d.orderSummary.completedOrders)}',
        line2: 'Đang xử lý: ${_fmtNum(d.orderSummary.activeOrders)}',
      ),
      _StatCard(
        icon: Icons.people_outline, color: _ct.success, title: 'Khách hàng',
        value: d.customerSummary.total, isCurrency: false,
        line1: 'Mới (lần đầu): ${_fmtNum(d.customerSummary.newCustomers)}',
        line2: 'Quay lại: ${_fmtNum(d.customerSummary.returningCustomers)}',
      ),
      _StatCard(
        icon: Icons.check_circle_outline, color: Colors.green, title: 'Doanh thu',
        value: d.revenueSummary.completedRevenue, isCurrency: true,
        line1: 'CK: ${_fmtCurrency(d.revenueSummary.totalDiscount)}',
        line2: 'VAT: ${_fmtCurrency(d.revenueSummary.totalVat)}',
      ),
      _StatCard(
        icon: Icons.pending_outlined, color: Colors.orange, title: 'Thống kê',
        value: d.revenueSummary.pendingRevenue, isCurrency: true,
        line1: 'Hủy: ${_fmtNum(d.orderSummary.cancelledOrders)} đơn',
        line2: 'Thất bại: ${_fmtNum(d.orderSummary.failedOrders)} đơn',
      ),
    ];
    if (isNarrow) {
      return Column(children: [
        Row(children: [
          Expanded(child: cards[0]), const SizedBox(width: 10), Expanded(child: cards[1]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: cards[2]), const SizedBox(width: 10), Expanded(child: cards[3]),
        ]),
      ]);
    }
    return Row(children: [
      Expanded(child: cards[0]), const SizedBox(width: 10),
      Expanded(child: cards[1]), const SizedBox(width: 10),
      Expanded(child: cards[2]), const SizedBox(width: 10),
      Expanded(child: cards[3]),
    ]);
  }

  // =====================================================================
  // TIME SERIES CHART
  // =====================================================================
  Widget _buildChart(SuperAdminRestaurantDashboardModel d) {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 16,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Đơn hàng theo thời gian'),
        const SizedBox(height: 12),
        SizedBox(
          height: 320,
          child: d.ordersByTime.isEmpty
              ? Center(child: MyText.bodyMedium('Không có dữ liệu', muted: true))
              : SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelRotation: -30,
              majorGridLines: const MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              name: 'orders',
              numberFormat: NumberFormat.compact(),
            ),
            axes: [
              NumericAxis(
                name: 'revenue',
                opposedPosition: true,
                numberFormat: NumberFormat.compactCurrency(locale: 'vi', symbol: ''),
                majorGridLines: const MajorGridLines(width: 0),
              ),
            ],
            tooltipBehavior: TooltipBehavior(enable: true),
            legend: Legend(isVisible: true, position: LegendPosition.top),
            series: [
              ColumnSeries<SuperAdminOrderByTimeModel, String>(
                name: 'Đơn hàng',
                dataSource: d.ordersByTime,
                xValueMapper: (e, _) => e.timeBucket,
                yValueMapper: (e, _) => e.orderCount,
                color: _ct.primary,
                width: 0.5,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              ),
              LineSeries<SuperAdminOrderByTimeModel, String>(
                name: 'Doanh thu',
                dataSource: d.ordersByTime,
                xValueMapper: (e, _) => e.timeBucket,
                yValueMapper: (e, _) => e.revenue,
                yAxisName: 'revenue',
                color: Colors.green,
                markerSettings: const MarkerSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // =====================================================================
  // PAYMENT PIE CHART
  // =====================================================================
  Widget _buildPaymentPie(SuperAdminRestaurantDashboardModel d) {
    final methods = d.paymentBreakdown.methods;
    final total = d.paymentBreakdown.totalAmount;

    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 16,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('Phương thức thanh toán'),
        const SizedBox(height: 12),
        if (methods.isEmpty)
          SizedBox(
            height: 260,
            child: Center(child: MyText.bodyMedium('Không có dữ liệu', muted: true)),
          )
        else
          SizedBox(
            height: 260,
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
              ),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: [
                DoughnutSeries<SuperAdminPaymentMethodItem, String>(
                  dataSource: methods,
                  xValueMapper: (m, i) => m.label,
                  yValueMapper: (m, _) => m.amount,
                  pointColorMapper: (m, i) => _paymentColor(i),
                  dataLabelMapper: (m, _) => total > 0
                      ? '${(m.amount / total * 100).toStringAsFixed(1)}%'
                      : '',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                  innerRadius: '55%',
                  radius: '85%',
                ),
              ],
            ),
          ),
        if (methods.isNotEmpty) ...[
          const Divider(height: 16),
          ...methods.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: _paymentColor(e.key), shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
              Expanded(child: Text(e.value.label, style: const TextStyle(fontSize: 11))),
              Text('${e.value.count} đơn',
                  style: TextStyle(fontSize: 10, color: _ct.secondary)),
              const SizedBox(width: 8),
              Text(_fmtCurrency(e.value.amount),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                      color: _paymentColor(e.key))),
            ]),
          )),
        ],
      ]),
    );
  }

  // =====================================================================
  // REGION CHART (BẢN ĐỒ)
  // =====================================================================
  Widget _buildRegionChart(SuperAdminRestaurantDashboardModel d) {
    final regions = d.regionBreakdown;

    const Map<String, List<double>> provinceCoords = {
      'Tuyên Quang': [22.1469, 105.2282],
      'Cao Bằng': [22.6657, 106.2522],
      'Lai Châu': [22.3860, 103.4711],
      'Lào Cai': [22.3364, 104.1500],
      'Thái Nguyên': [21.5928, 105.8442],
      'Điện Biên': [21.3860, 103.0230],
      'Lạng Sơn': [21.8537, 106.7615],
      'Sơn La': [21.1022, 103.7289],
      'Phú Thọ': [21.3450, 105.0500],
      'Bắc Ninh': [21.1861, 106.0763],
      'Quảng Ninh': [21.0064, 107.2925],
      'Hà Nội': [21.0285, 105.8542],
      'Hưng Yên': [20.6466, 106.0511],
      'Ninh Bình': [20.2506, 105.9745],
      'Hải Phòng': [20.8449, 106.6881],
      'Thanh Hóa': [19.8078, 105.7764],
      'Nghệ An': [19.2342, 104.9200],
      'Hà Tĩnh': [18.3559, 105.8877],
      'Quảng Trị': [16.8163, 106.6600],
      'Huế': [16.4637, 107.5909],
      'Đà Nẵng': [16.0544, 108.2022],
      'Quảng Ngãi': [15.1214, 108.8040],
      'Gia Lai': [13.9810, 108.0000],
      'Khánh Hòa': [12.2388, 109.1967],
      'Đắk Lắk': [12.6667, 108.0500],
      'Lâm Đồng': [11.5753, 108.1429],
      'Đồng Nai': [11.0686, 107.1676],
      'Hồ Chí Minh': [10.8231, 106.6297],
      'Tây Ninh': [11.3352, 106.1099],
      'Đồng Tháp': [10.4938, 105.6882],
      'Vĩnh Long': [10.2397, 105.9571],
      'Cần Thơ': [10.0452, 105.7469],
      'An Giang': [10.5216, 105.1259],
      'Cà Mau': [9.1769, 105.1500],
      'Phú Yên': [13.0882, 109.0929],
    };

    final markers = regions.where((r) => provinceCoords.containsKey(r.region)).toList();

    Color dotColor(int count) {
      if (count > 100) return const Color(0xFF2563EB);
      if (count >= 51) return const Color(0xFF16A34A);
      return const Color(0xFFEA580C);
    }

    final mapSource = MapShapeSource.asset(
      'assets/data/vietnam_map.json',
      shapeDataField: 'name',
    );

    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 16,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _sectionTitle('Đơn hàng theo vị trí'),
          const Spacer(),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: 420,
          child: SfMaps(
            layers: <MapLayer>[
              MapShapeLayer(
                source: mapSource,
                controller: _mapController,
                loadingBuilder: (BuildContext context) {
                  return const Center(
                    child: SizedBox(
                      width: 28, height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                },
                strokeColor: Colors.white,
                strokeWidth: 0.5,
                color: _ct.secondary.withOpacity(0.1),
                initialMarkersCount: markers.length,
                markerBuilder: (BuildContext context, int index) {
                  final r = markers[index];
                  final coord = provinceCoords[r.region]!;
                  final color = dotColor(r.orderCount);
                  final isActive = _activeRegion == r.region;

                  return MapMarker(
                    latitude: coord[0],
                    longitude: coord[1],
                    alignment: Alignment.center,
                    child: _RegionDot(
                      color: color,
                      isActive: isActive,
                      onTap: () {
                        setState(() {
                          _activeRegion = isActive ? null : r.region;
                        });
                        _mapController.updateMarkers(
                            List.generate(markers.length, (i) => i));
                        showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (_) => Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() => _activeRegion = null);
                                  Navigator.pop(context);
                                },
                                child: const SizedBox.expand(),
                              ),
                              Center(
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: color.withOpacity(0.25),
                                          blurRadius: 20,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 10, height: 10,
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle, color: color),
                                            ),
                                            const SizedBox(width: 7),
                                            Text(r.region,
                                              style: TextStyle(fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: _ct.primary),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text('${r.orderCount} đơn hàng',
                                          style: TextStyle(fontSize: 13, color: color,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).then((_) {
                          setState(() => _activeRegion = null);
                          _mapController.updateMarkers(
                              List.generate(markers.length, (i) => i));
                        });
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(const Color(0xFFEA580C), '< 50 đơn'),
            const SizedBox(width: 16),
            _legendDot(const Color(0xFF16A34A), '51–100 đơn'),
            const SizedBox(width: 16),
            _legendDot(const Color(0xFF2563EB), '> 100 đơn'),
          ],
        ),
      ]),
    );
  }

  // =====================================================================
  // TOP TABLES
  // =====================================================================
  Widget _buildTopProducts(SuperAdminRestaurantDashboardModel d) {
    return _TopTable(
      title: 'Top sản phẩm',
      icon: Icons.fastfood_outlined,
      headers: const ['Sản phẩm', 'SL', 'Doanh thu'],
      rows: d.topProducts.map((p) => [
        p.productName,
        _fmtNum(p.totalQuantity),
        _fmtCurrency(p.totalRevenue),
      ]).toList(),
    );
  }

  Widget _buildTopUsers(SuperAdminRestaurantDashboardModel d) {
    return _TopTable(
      title: 'Top nhân viên',
      icon: Icons.badge_outlined,
      headers: const ['Nhân viên', 'Đơn', 'Doanh thu'],
      rows: d.topUsers.map((u) => [
        u.fullName.isNotEmpty ? u.fullName : u.userName,
        _fmtNum(u.orderCount),
        _fmtCurrency(u.totalRevenue),
      ]).toList(),
    );
  }

  Widget _buildTopCustomers(SuperAdminRestaurantDashboardModel d) {
    return _TopTable(
      title: 'Top khách hàng',
      icon: Icons.group_outlined,
      headers: const ['Khách hàng', 'Đơn', 'Chi tiêu'],
      rows: d.topCustomers.map((cu) => [
        cu.customerName,
        _fmtNum(cu.orderCount),
        _fmtCurrency(cu.totalSpent),
      ]).toList(),
    );
  }

  // =====================================================================
  // RECENT ORDERS
  // =====================================================================
  Widget _buildRecentOrders(SuperAdminRestaurantDashboardModel d, {bool isNarrow = false}) {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 0,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: _sectionTitle('Đơn hàng mới nhất'),
        ),
        const Divider(height: 0),
        _recentOrderHeader(isNarrow: isNarrow),
        const Divider(height: 0),
        if (d.recentOrders.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: MyText.bodyMedium('Không có đơn hàng', muted: true)),
          )
        else
          ...d.recentOrders.map((o) => Column(children: [
            _recentOrderRow(o, isNarrow: isNarrow),
            Divider(height: 0, color: _ct.secondary.withOpacity(0.08)),
          ])),
      ]),
    );
  }

  Widget _recentOrderHeader({bool isNarrow = false}) {
    final s = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _ct.secondary);
    return Container(
      color: _ct.secondary.withOpacity(0.06),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: isNarrow
          ? Row(children: [
        Expanded(flex: 3, child: Text('Mã đơn',     style: s)),
        Expanded(flex: 3, child: Text('Khách hàng', style: s)),
        Expanded(flex: 3, child: Text('Tổng tiền',  style: s)),
        Expanded(flex: 2, child: Text('Trạng thái', style: s, textAlign: TextAlign.center)),
      ])
          : Row(children: [
        Expanded(flex: 2, child: Text('Mã đơn',          style: s)),
        Expanded(flex: 2, child: Text('Khách hàng',      style: s)),
        Expanded(flex: 1, child: Text('Thời gian',       style: s)),
        Expanded(flex: 2, child: Text('Tổng / CK / VAT', style: s)),
        Expanded(flex: 1, child: Text('Trạng thái', style: s, textAlign: TextAlign.center)),
      ]),
    );
  }

  Widget _recentOrderRow(SuperAdminDashboardRecentOrderModel o, {bool isNarrow = false}) {
    final color = _statusColor(o.status);
    final label = _statusLabel(o.status);
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
      child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: isNarrow
          ? Row(children: [
        Expanded(flex: 3, child: _OrderIdCell(code: o.orderCode, color: _ct.primary, fontSize: 11)),
        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(o.customerName?.isNotEmpty == true ? o.customerName! : 'Khách lẻ',
              style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
          Text(_fmtDate(o.createdAt),
              style: TextStyle(fontSize: 10, color: _ct.secondary)),
        ])),
        Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_fmtCurrency(o.finalAmount),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _ct.primary)),
          Text('CK: -${_fmtCurrency(o.discountAmount)}',
              style: TextStyle(fontSize: 10, color: _ct.secondary)),
        ])),
        Expanded(flex: 2, child: Center(child: badge)),
      ])
          : Row(children: [
        Expanded(flex: 2, child: _OrderIdCell(code: o.orderCode, color: _ct.primary, fontSize: 12)),
        Expanded(flex: 2, child: Text(
            o.customerName?.isNotEmpty == true ? o.customerName! : 'Khách lẻ',
            style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
        Expanded(flex: 1, child: Text(_fmtDate(o.createdAt),
            style: TextStyle(fontSize: 11, color: _ct.secondary))),
        Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_fmtCurrency(o.finalAmount),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ct.primary)),
          Text('CK: -${_fmtCurrency(o.discountAmount)}  VAT: +${_fmtCurrency(o.vatAmount)}',
              style: TextStyle(fontSize: 10, color: _ct.secondary)),
        ])),
        Expanded(flex: 1, child: Center(child: badge)),
      ]),
    );
  }

  // =====================================================================
  // HELPERS
  // =====================================================================
  Widget _sectionTitle(String t) => Text(t,
    style: TextStyle(
      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
      fontWeight: FontWeight.w700, fontSize: 14, color: _ct.primary,
    ),
  );

  Color _statusColor(String s) => switch (s) {
    'COMPLETED'  => Colors.green,
    'CANCELLED'  => Colors.red,
    'FAILED'     => Colors.red,
    'PENDING'    => Colors.orange,
    'DELIVERING' => Colors.blue,
    _            => Colors.grey,
  };

  String _statusLabel(String s) => switch (s) {
    'COMPLETED'  => 'Hoàn thành',
    'CANCELLED'  => 'Đã hủy',
    'FAILED'     => 'Thất bại',
    'PENDING'    => 'Chờ xử lý',
    'CONFIRMED'  => 'Xác nhận',
    'PREPARING'  => 'Đang làm',
    'READY'      => 'Sẵn sàng',
    'DELIVERING' => 'Giao hàng',
    _            => s,
  };

  Widget _legendDot(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 10, height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(fontSize: 11, color: _ct.secondary)),
    ],
  );
}

// =====================================================================
// REUSABLE WIDGETS
// =====================================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, line1, line2;
  final num value;
  final bool isCurrency;

  const _StatCard({
    required this.icon, required this.color, required this.title,
    required this.value, required this.isCurrency,
    required this.line1, required this.line2,
  });

  String _fmt(double v) => isCurrency
      ? NumberFormat('#,###', 'vi_VN').format(v)
      : NumberFormat('#,###', 'vi_VN').format(v.toInt());

  @override
  Widget build(BuildContext context) {
    return MyCard(
      borderRadiusAll: 12, paddingAll: 0,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, size: 20, color: color),
            ),
            const Spacer(),
            Flexible(child: Text(title, textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: _ct.secondary,
                    fontWeight: FontWeight.w500))),
          ]),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOut,
            builder: (_, v, __) => Text(_fmt(v), style: TextStyle(
                fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          ),
          const SizedBox(height: 6),
          Text(line1, style: TextStyle(fontSize: 11, color: _ct.secondary)),
          Text(line2, style: TextStyle(fontSize: 11, color: _ct.secondary)),
        ]),
      ),
    );
  }
}

class _TopTable extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> headers;
  final List<List<String>> rows;

  const _TopTable({
    required this.title, required this.icon,
    required this.headers, required this.rows,
  });

  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    return MyCard(
      borderRadiusAll: 12, paddingAll: 0,
      shadow: MyShadow(elevation: 0.5, position: MyShadowPosition.bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(children: [
            Icon(icon, size: 15, color: _ct.primary),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(
                fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                fontWeight: FontWeight.w700, fontSize: 13, color: _ct.primary)),
          ]),
        ),
        const Divider(height: 0),
        _tableRow(context, headers, isHeader: true, isMobile: isMobile),
        const Divider(height: 0),
        if (rows.isEmpty)
          Padding(padding: const EdgeInsets.all(16),
              child: Center(child: Text('Không có dữ liệu',
                  style: TextStyle(fontSize: 12, color: _ct.secondary))))
        else
          ...rows.asMap().entries.map((e) => Column(children: [
            _tableRow(context, e.value, rank: e.key + 1, isMobile: isMobile),
            if (e.key < rows.length - 1)
              Divider(height: 0, color: _ct.secondary.withOpacity(0.07)),
          ])),
      ]),
    );
  }

  Widget _tableRow(BuildContext context, List<String> cells,
      {bool isHeader = false, int rank = 0, required bool isMobile}) {
    return Container(
      color: isHeader ? _ct.secondary.withOpacity(0.06) : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: Row(children: [
        if (!isHeader)
          Container(
            width: 22, height: 22, margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: rank <= 3 ? _ct.primary.withOpacity(0.12) : _ct.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(child: Text('$rank', style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: rank <= 3 ? _ct.primary : _ct.secondary))),
          )
        else
          const SizedBox(width: 30),
        Expanded(flex: 3, child: Text(cells[0], overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: isHeader ? 11 : 12,
                fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500))),
        if (isMobile && !isHeader)
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(cells[1], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(_shortMoney(cells[2]),
                style: TextStyle(fontSize: 11, color: _ct.primary, fontWeight: FontWeight.w700)),
          ]))
        else ...[
          Expanded(flex: 1, child: Text(cells[1], textAlign: TextAlign.center,
              style: TextStyle(fontSize: isHeader ? 11 : 12,
                  fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal))),
          Expanded(flex: 2, child: Text(cells[2], textAlign: TextAlign.right,
              style: TextStyle(fontSize: isHeader ? 11 : 12,
                  fontWeight: isHeader ? FontWeight.w700 : FontWeight.w600,
                  color: isHeader ? null : _ct.primary))),
        ],
      ]),
    );
  }

  String _shortMoney(String value) {
    final clean = value.replaceAll('đ', '').replaceAll('.', '').replaceAll(',', '').trim();
    final number = double.tryParse(clean) ?? 0;
    if (number >= 1e9) return '${(number / 1e9).toStringAsFixed(2)} T';
    if (number >= 1e6) return '${(number / 1e6).toStringAsFixed(2)} Tr';
    if (number >= 1e3) return '${(number / 1e3).toStringAsFixed(0)} K';
    return number.toStringAsFixed(0);
  }
}

// =====================================================================
// REGION DOT (BẢN ĐỒ MARKER)
// =====================================================================

class _RegionDot extends StatefulWidget {
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _RegionDot({
    required this.color, required this.isActive, required this.onTap,
  });

  @override
  State<_RegionDot> createState() => _RegionDotState();
}

class _RegionDotState extends State<_RegionDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  static const double _baseSize = 14.0;
  static const double _activeSize = 42.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pulse = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.isActive) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_RegionDot old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isActive && old.isActive) {
      _ctrl.stop();
      _ctrl.animateBack(0, duration: const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final t = _pulse.value;
          final dotSize = widget.isActive
              ? _activeSize - (_activeSize - _baseSize) * 0.15 * (1 - t)
              : _baseSize;
          final glowBlur   = widget.isActive ? 8.0 + 16.0 * t : 3.0;
          final glowSpread = widget.isActive ? 2.0 + 6.0 * t  : 0.0;
          final glowAlpha  = widget.isActive ? 0.5 + 0.4 * t  : 0.35;
          final containerSize = dotSize + 24;

          return SizedBox(
            width: containerSize, height: containerSize,
            child: Center(child: Container(
              width: dotSize, height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                border: Border.all(color: Colors.white,
                    width: widget.isActive ? 3.0 : 2.0),
                boxShadow: [
                  BoxShadow(color: widget.color.withOpacity(glowAlpha),
                      blurRadius: glowBlur, spreadRadius: glowSpread),
                  if (widget.isActive)
                    BoxShadow(color: widget.color.withOpacity(0.2 * t),
                        blurRadius: glowBlur * 2.5, spreadRadius: glowSpread * 2),
                ],
              ),
            )),
          );
        },
      ),
    );
  }
}

// =====================================================================
// ORDER ID CELL
// =====================================================================

class _OrderIdCell extends StatelessWidget {
  final String code;
  final Color color;
  final double fontSize;

  const _OrderIdCell({
    required this.code,
    required this.color,
    this.fontSize = 11,
  });

  List<String> _parseLines() {
    final parts = code.split('-');
    if (parts.isEmpty) return [code];
    // Bỏ prefix đầu tiên (ORD, POS, ...)
    final rest = parts.skip(1).toList();
    if (rest.isEmpty) return [code];
    return rest;
  }

  @override
  Widget build(BuildContext context) {
    final lines = _parseLines();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < lines.length; i++)
          Text(
            lines[i],
            style: TextStyle(
              fontSize: i == 0 ? fontSize : fontSize - 1,
              fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
              color: i == 0 ? color : color.withOpacity(0.70),
            ),
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}