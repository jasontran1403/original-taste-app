import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/dashboard_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/models/chart_model.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard> with UIMixin {
  DashboardController controller = Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'dashboard_controller',
      builder: (controller) {
        return Layout(
          screenName: "WELCOME!",
          child: MyFlex(
            children: [
              MyFlexItem(
                sizes: 'xl-5 lg-6',
                child: Column(
                  children: [
                    MyContainer(
                      color: contentTheme.primary.withValues(alpha: 0.2),
                      borderRadiusAll: 12,
                      width: double.infinity,
                      child: MyText.bodyMedium(
                        "We regret to inform you that our server is currently experiencing technical difficulties.",
                        fontWeight: 600,
                        maxLines: 1,
                      ),
                    ),
                    MySpacing.height(20),
                    stats(),
                  ],
                ),
              ),
              MyFlexItem(sizes: 'xl-7 lg-6', child: performance()),
              MyFlexItem(sizes: 'lg-4', child: conversions()),
              MyFlexItem(sizes: 'lg-4', child: sessionsByCountry()),
              MyFlexItem(sizes: 'lg-4', child: topPages()),
              MyFlexItem(child: recentOrders()),
            ],
          ),
        );
      },
    );
  }

  Widget stats() {
    return MyFlex(
      contentPadding: false,
      children: [
        MyFlexItem(
          sizes: 'lg-6 md-6 sm-6',
          child: stateWidget(SvgPicture.asset('assets/svg/cart.svg'), "Total Orders", "13,647", "2.3", Boxicons.bxs_up_arrow),
        ),
        MyFlexItem(
          sizes: 'lg-6 md-6 sm-6',
          child: stateWidget(Icon(Boxicons.bx_award, color: contentTheme.primary), "New Leads", "9,526", "8.1", Boxicons.bxs_up_arrow),
        ),
        MyFlexItem(
          sizes: 'lg-6 md-6 sm-6',
          child: stateWidget(Icon(Boxicons.bxs_backpack, color: contentTheme.primary), "Deals", "976", "0.3", Boxicons.bxs_down_arrow),
        ),
        MyFlexItem(
          sizes: 'lg-6 md-6 sm-6',
          child: stateWidget(
            Icon(Boxicons.bx_dollar_circle, color: contentTheme.primary),
            "Booked Revenue",
            "\$123.6k",
            "10.6",
            Boxicons.bxs_down_arrow,
          ),
        ),
      ],
    );
  }

  Widget stateWidget(Widget icon, String title, String subTitle, String percentile, IconData trendsIcon) {
    return MyContainer(
      paddingAll: 0,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyContainer(color: contentTheme.primary.withValues(alpha: 0.25), borderRadiusAll: 12, child: icon),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [MyText.bodyMedium(title, maxLines: 1), MyText.titleLarge(subTitle, fontWeight: 700)],
                  ),
                ),
              ],
            ),
          ),
          MyContainer(
            color: contentTheme.secondary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Row(
              children: [
                Icon(trendsIcon, size: 14, color: trendsIcon == Boxicons.bxs_down_arrow ? contentTheme.danger : contentTheme.success),
                MySpacing.width(8),
                MyText.labelMedium(
                  '$percentile%',
                  fontWeight: 600,
                  color: trendsIcon == Boxicons.bxs_down_arrow ? contentTheme.danger : contentTheme.success,
                ),
                MySpacing.width(8),
                Expanded(child: MyText.labelMedium("Last Month", fontWeight: 600, maxLines: 1)),
                MyText.labelMedium("View More", fontWeight: 700),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget performance() {
    return MyContainer(
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: MyText.titleMedium("Performance", fontWeight: 600)),
              Wrap(
                spacing: 4,
                runSpacing: 8,
                children:
                    DurationFilter.values.map((filter) {
                      bool isSelected = controller.selectedFilter == filter;
                      return MyContainer.bordered(
                        onTap: () => controller.updateFilter(filter),
                        borderRadiusAll: 8,
                        paddingAll: isSelected ? 9 : 8,
                        bordered: !isSelected,
                        borderColor: contentTheme.secondary.withValues(alpha: 0.1),
                        color: isSelected ? contentTheme.secondary.withValues(alpha: 0.1) : null,
                        child: MyText.bodyMedium(filter.label, fontWeight: 600),
                      );
                    }).toList(),
              ),
            ],
          ),
          MySpacing.height(12),
          SizedBox(
            height: 314,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              tooltipBehavior: controller.chart,
              axes: <ChartAxis>[
                NumericAxis(
                  numberFormat: NumberFormat.compact(),
                  majorGridLines: const MajorGridLines(width: 0),
                  opposedPosition: true,
                  name: 'yAxis1',
                  interval: 1000,
                  minimum: 0,
                  maximum: 7000,
                ),
              ],
              series: [
                ColumnSeries<ChartSampleData, String>(
                  animationDuration: 2000,
                  width: 0.5,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                  color: contentTheme.primary,
                  dataSource: controller.chartData,
                  xValueMapper: (ChartSampleData data, _) => data.x,
                  yValueMapper: (ChartSampleData data, _) => data.y,
                  name: 'Page View',
                ),
                LineSeries<ChartSampleData, String>(
                  animationDuration: 4500,
                  animationDelay: 2000,
                  color: contentTheme.success,
                  dataSource: controller.chartData,
                  xValueMapper: (ChartSampleData data, _) => data.x,
                  yValueMapper: (ChartSampleData data, _) => data.yValue,
                  yAxisName: 'yAxis1',
                  markerSettings: const MarkerSettings(isVisible: true),
                  name: 'Clicks',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget conversions() {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: 0.2),
      paddingAll: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("Conversions", style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600)),
          SizedBox(
            height: 217,
            child: SfCircularChart(
              legend: Legend(isVisible: false),
              centerY: '60%',
              series: <DoughnutSeries<ChartSampleData, String>>[
                DoughnutSeries<ChartSampleData, String>(
                  dataSource: controller.conversionsData,
                  xValueMapper: (ChartSampleData data, int index) => data.x,
                  yValueMapper: (ChartSampleData data, int index) => data.y,
                  innerRadius: '70%',
                  radius: '100%',
                  startAngle: 230,
                  endAngle: 130,
                  dataLabelMapper: (ChartSampleData data, int index) => data.text,
                  dataLabelSettings: const DataLabelSettings(isVisible: true, labelPosition: ChartDataLabelPosition.outside),
                ),
              ],
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
          MySpacing.height(12),
          Center(
            child: Wrap(
              spacing: 70,
              children: [
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [MyText.bodyMedium("This Week"), MyText.titleMedium("23.5K")]),
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [MyText.bodyMedium("This Week"), MyText.titleMedium("23.5K")]),
              ],
            ),
          ),
          MySpacing.height(12),
          MyContainer(
            onTap: () {},
            color: contentTheme.secondary.withValues(alpha: 0.2),
            borderRadiusAll: 12,
            paddingAll: 12,
            child: Center(
              child: MyText.bodyMedium(
                "View Details",
                style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sessionsByCountry() {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium(
            "Sessions by Country",
            style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
          ),
          MySpacing.height(26),
          SfMaps(
            layers: <MapLayer>[
              MapShapeLayer(
                loadingBuilder: (BuildContext context) {
                  return const SizedBox(height: 25, width: 25, child: CircularProgressIndicator(strokeWidth: 3));
                },
                source: controller.mapSource2,
                initialMarkersCount: 7,
                markerBuilder: (_, int index) {
                  return MapMarker(
                    longitude: controller.worldClockData[index].longitude,
                    latitude: controller.worldClockData[index].latitude,
                    alignment: Alignment.topCenter,
                    offset: Offset(0, -4),
                    size: Size(150, 150),
                    child: ClockWidget(countryName: controller.worldClockData[index].countryName, date: controller.worldClockData[index].date),
                  );
                },
                strokeWidth: 0,
                color: theme.colorScheme.brightness == Brightness.light ? Color.fromRGBO(71, 70, 75, 0.2) : Color.fromRGBO(71, 70, 75, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget topPages() {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: 0.2),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium("Top Pages", style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600)),
                MyContainer(
                  onTap: () {},
                  paddingAll: 8,
                  color: contentTheme.primary.withValues(alpha: 0.2),
                  child: MyText.labelMedium("View All", color: contentTheme.primary),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowMinHeight: 40,
              columnSpacing: 80,
              headingRowHeight: 40,
              headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withValues(alpha: 0.15)),
              columns: const [
                DataColumn(label: MyText.bodyMedium('Page Path', fontWeight: 700, muted: true)),
                DataColumn(label: MyText.bodyMedium('Page Views', fontWeight: 700, muted: true)),
                DataColumn(label: MyText.bodyMedium('Exit Rate', fontWeight: 700, muted: true)),
              ],
              rows:
                  controller.pageDataList.map((data) {
                    return DataRow(
                      cells: [
                        DataCell(MyText.bodyMedium(data.path)),
                        DataCell(MyText.bodyMedium(data.views.toString())),
                        DataCell(MyText.bodyMedium('${data.exitRate.toStringAsFixed(2)}%')),
                      ],
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget recentOrders() {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Row(
              children: [
                Expanded(
                  child: MyText.titleMedium(
                    "Recent Order",
                    style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                MyContainer(
                  color: contentTheme.primary.withValues(alpha: 0.2),
                  borderRadiusAll: 8,
                  paddingAll: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Boxicons.bx_plus, color: contentTheme.primary, size: 14),
                      MyText.labelMedium("Add Product", fontWeight: 600, color: contentTheme.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          if (controller.recentOrder.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: true,
                headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
                dataRowMaxHeight: 50,
                columnSpacing: 65,
                showBottomBorder: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                columns: [
                  DataColumn(label: MyText.labelLarge('Order Id', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Date', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Product', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Customer Name', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Email ID', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Phone No.', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Address', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Payment Type', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Status', fontWeight: 700)),
                ],
                rows: List.generate(controller.recentOrder.length, (index) {
                  final data = controller.recentOrder[index];
                  return DataRow(
                    cells: [
                      DataCell(MyText.bodyMedium(data.orderId, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.date, fontWeight: 600)),
                      DataCell(SizedBox(height: 32, width: 32, child: Image.asset(data.productImage))),
                      DataCell(MyText.bodyMedium(data.customerName, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.email, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.phone, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.address, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.paymentType, fontWeight: 600)),
                      DataCell(
                        Row(
                          children: [
                            MyContainer.rounded(paddingAll: 6, color: data.status == 'Completed' ? contentTheme.success : contentTheme.primary),
                            MySpacing.width(8),
                            MyText.bodyMedium(data.status, fontWeight: 600),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key, required this.countryName, required this.date});

  final String countryName;
  final DateTime date;

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  late String _currentTime;
  late DateTime _date;
  Timer? _timer;

  @override
  void initState() {
    _date = widget.date;
    _currentTime = _getFormattedDateTime(widget.date);
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime(_date));
    super.initState();
  }

  @override
  void dispose() {
    _timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red))),
        Text(widget.countryName, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
        Center(child: Text(_currentTime, style: Theme.of(context).textTheme.labelSmall!.copyWith(letterSpacing: 0.5, fontWeight: FontWeight.w500))),
      ],
    );
  }

  void _updateTime(DateTime currentDate) {
    _date = currentDate.add(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _currentTime = DateFormat('hh:mm:ss a').format(_date);
    });
  }

  String _getFormattedDateTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss a').format(dateTime);
  }
}
