import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:original_taste/controller/ui/custom/widget_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_list_extension.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:remixicon/remixicon.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../models/chart_model.dart';

class WidgetScreen extends StatefulWidget {
  const WidgetScreen({super.key});

  @override
  State<WidgetScreen> createState() => _WidgetScreenState();
}

class _WidgetScreenState extends State<WidgetScreen> with UIMixin {
  WidgetController controller = Get.put(WidgetController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "WIDGET",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-3 md-6 sm-6', child: stats("Campaign Sent", "13, 647", " 2.3", true, RemixIcons.shopping_bag_4_line)),
              MyFlexItem(sizes: 'lg-3 md-6 sm-6', child: stats("Clicks", "9, 526", "8.1", true, Boxicons.bx_award)),
              MyFlexItem(sizes: 'lg-3 md-6 sm-6', child: stats("Conversions", '976', "0.3", false, Boxicons.bxs_package)),
              MyFlexItem(sizes: 'lg-3 md-6 sm-6', child: stats("New Users", "\$123.6k", "10.6", false, Boxicons.bx_dollar_circle)),
              MyFlexItem(
                sizes: 'lg-2.4 md-6 sm-6',
                child: state2(
                  'assets/svg/3d_duotone.svg',
                  contentTheme.info,
                  "\$59.6k",
                  "Total Income",
                  "8.72",
                  contentTheme.success,
                  Boxicons.bx_doughnut_chart,
                ),
              ),
              MyFlexItem(
                sizes: 'lg-2.4 md-6 sm-6',
                child: state2(
                  'assets/svg/category_duotone.svg',
                  contentTheme.success,
                  "\$24.03k",
                  "Total Expenses",
                  "3.28",
                  contentTheme.danger,
                  Boxicons.bx_bar_chart_alt_2,
                ),
              ),
              MyFlexItem(
                sizes: 'lg-2.4 md-6 sm-6',
                child: state2(
                  'assets/svg/store_duotone.svg',
                  contentTheme.purple,
                  "\$48.7k",
                  "Investments",
                  "5.69",
                  contentTheme.danger,
                  Boxicons.bx_building_house,
                ),
              ),
              MyFlexItem(
                sizes: 'lg-2.4 md-6 sm-6',
                child: state2(
                  'assets/svg/gift_duotone.svg',
                  contentTheme.primary,
                  "\$11.3k",
                  "Savings",
                  "10.58",
                  contentTheme.success,
                  Boxicons.bx_bowl_hot,
                ),
              ),
              MyFlexItem(
                sizes: 'lg-2.4',
                child: state2(
                  'assets/svg/certificate_badge_duotone.svg',
                  contentTheme.warning,
                  "\$5.5k",
                  "Profits",
                  "2.25",
                  contentTheme.success,
                  Boxicons.bx_cricket_ball,
                ),
              ),
              MyFlexItem(sizes: 'lg-6', child: recentProjectSummary()),
              MyFlexItem(sizes: 'lg-6', child: todaySchedules()),
              MyFlexItem(sizes: 'lg-3 md-6 sm-6', child: state3("Campaign Sent", "13,647", Boxicons.bx_layer, contentTheme.primary)),
              MyFlexItem(sizes: 'lg-3 md-6 sm-6', child: state3("New Leads", "9,526", Boxicons.bx_award, contentTheme.success)),
              MyFlexItem(sizes: 'lg-3 md-6 sm-6', child: state3("Deals", "976", Boxicons.bxs_backpack, contentTheme.danger)),
              MyFlexItem(sizes: 'lg-3 md-6 sm-6', child: state3("Booked Revenue", "\$123", Boxicons.bx_dollar_circle, contentTheme.warning)),
              MyFlexItem(
                sizes: 'lg-12',
                child: MyCard(
                  marginAll: 0,
                  shadow: MyShadow(elevation: 0.2),
                  paddingAll: 0,
                  borderRadiusAll: 12,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: MyFlex(
                    contentPadding: false,
                    runSpacing: 0,
                    spacing: 0,
                    children: [MyFlexItem(sizes: 'lg-4', child: conversation()), MyFlexItem(sizes: 'lg-8', child: performance())],
                  ),
                ),
              ),
              MyFlexItem(sizes: 'lg-3 md-6 sm-6', child: state4("Campaign Sent", "13, 647", " 2.3", true, Boxicons.bx_layer,contentTheme.primary)),
              MyFlexItem(sizes: 'lg-3 md-6 sm-6', child: state4("Clicks", "9, 526", "8.1", true, Boxicons.bx_award,contentTheme.success)),
              MyFlexItem(sizes: 'lg-3 md-6 sm-6', child: state4("Conversions", '976', "0.3", false, Boxicons.bxs_backpack,contentTheme.danger)),
              MyFlexItem(
                  sizes: 'lg-3 md-6 sm-6', child: state4("New Users", "\$123.6k", "10.6", false, Boxicons.bx_dollar_circle,contentTheme.warning)),
              MyFlexItem(sizes: 'lg-4', child: myTask()),
              MyFlexItem(sizes: 'lg-4', child: friendsRequest()),
              MyFlexItem(sizes: 'lg-4', child: recentTransactions()),
            ],
          ),
        );
      },
    );
  }

  Widget stats(String title, String value, String percentage, bool isPositive, IconData svgImage) {
    return MyCard(
      shadow: MyShadow(elevation: 0.2, position: MyShadowPosition.center),
      paddingAll: 0,
      borderRadiusAll: 12,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyContainer(
                  height: 56,
                  width: 56,
                  paddingAll: 0,
                  color: contentTheme.primary.withValues(alpha: .2),
                  borderRadiusAll: 12,
                  child: Center(child: Icon(svgImage, size: 28, color: contentTheme.primary)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [MyText.bodySmall(title, muted: true, fontWeight: 600), MySpacing.height(6), MyText.titleLarge(value, fontWeight: 700)],
                ),
              ],
            ),
          ),
          MyContainer(
            color: contentTheme.background.withValues(alpha: .9),
            borderRadiusAll: 0,
            padding: MySpacing.xy(18, 12),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Row(
              children: [
                Icon(
                  isPositive ? Boxicons.bxs_up_arrow : Boxicons.bxs_down_arrow,
                  color: isPositive ? contentTheme.success : contentTheme.danger,
                  size: 12,
                ),
                MySpacing.width(4),
                MyText.bodyMedium('$percentage%', color: isPositive ? contentTheme.success : contentTheme.danger),
                MySpacing.width(8),
                Expanded(child: MyText.bodySmall("Last Month", maxLines: 1)),
                InkWell(onTap: () {}, child: MyText.bodySmall("View More", fontWeight: 600, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget state2(String svgImage, Color svgColor, String counter, String title, String percentile, Color color, IconData icon) {
    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      paddingAll: 0,
      borderRadiusAll: 12,
      child: Stack(
        children: [
          Padding(
            padding: MySpacing.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(svgImage, height: 36, width: 36, colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn)),
                MySpacing.height(20),
                MyText.titleLarge(counter, fontWeight: 800),
                MyText.bodyMedium(title, fontWeight: 600, muted: true),
                MySpacing.height(20),
                MyContainer(paddingAll: 2, color: color.withValues(alpha: 0.2), child: MyText.labelMedium('$percentile%', color: color)),
              ],
            ),
          ),
          Positioned(bottom: -10, right: -5, child: Icon(icon, size: 60, color: contentTheme.secondary.withValues(alpha: 0.4))),
        ],
      ),
    );
  }

  Widget recentProjectSummary() {
    DataRow buildDataRow(String project, String client, List<String> teamAvatars, String deadline, double progress) {
      return DataRow(
        cells: [
          DataCell(MyText.bodyMedium(project)),
          DataCell(MyText.bodyMedium(client)),
          DataCell(
            SizedBox(
              width: 100,
              child: Stack(
                alignment: Alignment.centerRight,
                children:
                    teamAvatars
                        .mapIndexed(
                          (index, image) => Positioned(
                            left: (18 + (20 * index)).toDouble(),
                            child: MyContainer.rounded(
                              paddingAll: 2,
                              child: MyContainer.rounded(
                                bordered: true,
                                paddingAll: 0,
                                child: Image.asset(image, height: 28, width: 28, fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          DataCell(MyText.bodyMedium(deadline)),
          DataCell(
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 50 ? contentTheme.success : (progress > 30 ? Colors.orange : contentTheme.danger),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: MyText.titleMedium("Recent Project Summary", fontWeight: 600)),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    MyText.bodyMedium("Export", fontWeight: 600, color: contentTheme.primary),
                    MySpacing.width(8),
                    Icon(RemixIcons.share_line, color: contentTheme.primary, size: 14),
                  ],
                ),
              ),
            ],
          ),
          MySpacing.height(16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: 50,
              columns: [
                DataColumn(label: MyText.titleMedium('Project', fontWeight: 600)),
                DataColumn(label: MyText.titleMedium('Client', fontWeight: 600)),
                DataColumn(label: MyText.titleMedium('Team', fontWeight: 600)),
                DataColumn(label: MyText.titleMedium('Deadline', fontWeight: 600)),
                DataColumn(label: MyText.titleMedium('Work Progress', fontWeight: 600)),
              ],
              rows: [
                buildDataRow('Zelogy', 'Daniel Olsen', [Images.userAvatars[0], Images.userAvatars[1], Images.userAvatars[2]], '12 April 2024', 33),
                buildDataRow('Shiaz', 'Jack Roldan', [Images.userAvatars[3], Images.userAvatars[4]], '10 April 2024', 74),
                buildDataRow('Holderick', 'Betty Cox', [Images.userAvatars[5], Images.userAvatars[6], Images.userAvatars[7]], '31 March 2024', 50),
                buildDataRow('Feyvux', 'Carlos Johnson', [Images.userAvatars[8], Images.userAvatars[9]], '25 March 2024', 92),
                buildDataRow('Xavlox', 'Lorraine Cox', [Images.userAvatars[10]], '22 March 2024', 48),
                buildDataRow('Mozacav', 'Delores Young', [Images.userAvatars[11], Images.userAvatars[1], Images.userAvatars[0]], '15 March 2024', 21),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget todaySchedules() {
    Widget buildScheduleItem({required String time, required String title, required String duration, required Color alertColor}) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 60, child: MyText.bodyMedium(time, fontWeight: 600)),
          Expanded(
            child: MyContainer(
              paddingAll: 0,
              child: MyCard(
                color: alertColor.withValues(alpha: 0.2),
                shadow: MyShadow(elevation: 0),
                borderRadiusAll: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.bodyMedium(title, fontWeight: 600, color: alertColor),
                    MySpacing.height(8),
                    MyText.bodySmall(duration, color: alertColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return MyCard(
      shadow: MyShadow(elevation: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("Today's Schedules", fontWeight: 600),
          MySpacing.height(16),
          buildScheduleItem(time: '09:00', title: 'Setup Github Repository', duration: '09:00 - 10:00', alertColor: contentTheme.primary),
          MySpacing.height(19),
          buildScheduleItem(time: '10:00', title: 'Design Review - Rasket Admin', duration: '10:00 - 10:30', alertColor: contentTheme.success),
          MySpacing.height(19),
          buildScheduleItem(time: '11:00', title: 'Meeting with BD Team', duration: '11:00 - 12:30', alertColor: contentTheme.info),
          MySpacing.height(19),
          buildScheduleItem(time: '01:00', title: 'Meeting with Design Studio', duration: '01:00 - 02:00', alertColor: contentTheme.warning),
        ],
      ),
    );
  }

  Widget state3(String title, String count, IconData icon, Color color) {
    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      paddingAll: 20,
      borderRadiusAll: 12,
      child: Row(
        children: [
          MyContainer(color: color, borderRadiusAll: 12, child: Icon(icon, color: contentTheme.onPrimary, size: 24)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [MyText.bodyMedium(title, fontWeight: 600, xMuted: true), MySpacing.height(4), MyText.titleLarge(count, fontWeight: 600)],
            ),
          ),
        ],
      ),
    );
  }

  Widget conversation() {
    SfCircularChart totalSalesChart() {
      return SfCircularChart(
        margin: MySpacing.zero,
        legend: Legend(overflowMode: LegendItemOverflowMode.wrap),
        series: controller.salesChart(),
        tooltipBehavior: controller.tooltipBehavior,
        borderWidth: 0,
      );
    }

    return MyContainer.bordered(
      borderRadiusAll: 0,
      paddingAll: 24,
      height: 500,
      border: Border(bottom: BorderSide.none, left: BorderSide.none, top: BorderSide.none, right: BorderSide(color: Colors.grey.shade300)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("Conversation", fontWeight: 600),
          totalSalesChart(),
          Center(
            child: Wrap(
              runAlignment: WrapAlignment.spaceEvenly,
              alignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 40,
              children: [
                Column(
                  children: [
                    MyText.bodyMedium("This Week", fontWeight: 600, muted: true),
                    MySpacing.height(8),
                    MyText.titleLarge("23.5k", fontWeight: 600),
                  ],
                ),
                Column(
                  children: [
                    MyText.bodyMedium("Last Week", fontWeight: 600, muted: true),
                    MySpacing.height(8),
                    MyText.titleLarge("41.05k", fontWeight: 600),
                  ],
                ),
              ],
            ),
          ),
          MyContainer(
            color: contentTheme.background,
            paddingAll: 12,
            onTap: () {},
            child: Center(child: MyText.bodyMedium("View Details", fontWeight: 600)),
          ),
        ],
      ),
    );
  }

  Widget performance() {
    return MyContainer.bordered(
      borderRadiusAll: 0,
      paddingAll: 24,
      border: Border(bottom: BorderSide.none, left: BorderSide.none, top: BorderSide.none, right: BorderSide(color: Colors.grey.shade300)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.titleMedium("Performance", fontWeight: 600),
              Wrap(
                spacing: 16,
                children: [
                  for (var period in TimePeriod.values)
                    MyContainer.bordered(
                      paddingAll: 8,
                      onTap: () => controller.selectPriority(period),
                      color: controller.selectedPeriod == period ? contentTheme.background : contentTheme.disabled,
                      child: MyText.bodySmall(controller.getPeriodLabel(period), fontWeight: controller.selectedPeriod == period ? 600 : 500),
                    ),
                ],
              ),
            ],
          ),
          MySpacing.height(20),
          MyContainer(
            color: contentTheme.info.withValues(alpha: .2),
            width: double.infinity,
            child: MyText.bodyMedium("We regret to inform you that our server is currently experiencing technical difficulties.", fontWeight: 600),
          ),
          MySpacing.height(20),
          SizedBox(
            height: 332,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              margin: MySpacing.zero,
              tooltipBehavior: controller.chart,
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
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
                ColumnSeries<ChartSampleData, dynamic>(
                  animationDuration: 2000,
                  width: 0.5,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                  color: contentTheme.purple,
                  dataSource: controller.chartData,
                  xValueMapper: (ChartSampleData data, _) => data.x,
                  yValueMapper: (ChartSampleData data, _) => data.y,
                  name: 'Page Views',
                ),
                LineSeries<ChartSampleData, dynamic>(
                  dataSource: controller.chartData,
                  xValueMapper: (ChartSampleData data, _) => data.x,
                  yValueMapper: (ChartSampleData data, _) => data.yValue,
                  yAxisName: 'yAxis1',
                  color: contentTheme.success,
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

  Widget state4(String title, String value, String percentage, bool isPositive, IconData icon,Color color) {
    return MyCard(
      shadow: MyShadow(elevation: 0.2, position: MyShadowPosition.center),
      paddingAll: 0,
      borderRadiusAll: 12,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyContainer(
                  height: 56,
                  width: 56,
                  paddingAll: 0,
                  borderRadiusAll: 12,
                  color: color.withValues(alpha: .2),
                  child: Center(child: Icon(icon,size: 32,color: color,)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MyText.bodySmall(title, muted: true, fontWeight: 600),
                    MySpacing.height(6),
                    MyText.titleLarge(value, fontWeight: 700),
                  ],
                )
              ],
            ),
          ),
          MyContainer(
            color: contentTheme.background.withValues(alpha: .9),
            borderRadiusAll: 0,
            padding: MySpacing.xy(18, 12),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Row(
              children: [
                Icon(isPositive ? Boxicons.bxs_up_arrow : Boxicons.bxs_down_arrow,
                    color: isPositive ? contentTheme.success : contentTheme.danger, size: 12),
                MySpacing.width(4),
                MyText.bodyMedium('$percentage%', color: isPositive ? contentTheme.success : contentTheme.danger),
                MySpacing.width(8),
                Expanded(child: MyText.bodySmall("Last Month", maxLines: 1)),
                InkWell(onTap: () {}, child: MyText.bodySmall("View More", fontWeight: 600, overflow: TextOverflow.ellipsis)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget myTask() {
    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      paddingAll: 0,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(16),
            child: Row(
              children: [
                Expanded(child: MyText.titleMedium("My Task", fontWeight: 600)),
                MyContainer(
                  onTap: () {},
                  color: contentTheme.primary,
                  paddingAll: 8,
                  child: Row(
                    children: [
                      Icon(RemixIcons.add_line, size: 16, color: contentTheme.onPrimary),
                      MyText.labelMedium("Create Task", color: contentTheme.onPrimary),
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(height: 0),
          SizedBox(
            height: 350,
            child: ListView.separated(
              itemCount: controller.todoList.length,
              padding: MySpacing.all(16),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                TodoItem todo = controller.todoList[index];
                return TodoItemWidget(
                  item: todo,
                  onChanged: () => controller.toggleCheckbox(index),
                );
              },
              separatorBuilder: (context, index) {
                return MySpacing.height(16);
              },
            ),
          )
        ],
      ),
    );
  }

  Widget friendsRequest() {
    return MyCard(
      shadow: MyShadow(elevation: 0.2),
      paddingAll: 0,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(16),
            child: MyText.titleMedium("Friends Request (${controller.users.length})", fontWeight: 600),
          ),
          Divider(height: 0),
          SizedBox(
            height: 363,
            child: ListView.separated(
              itemCount: controller.users.length,
              padding: MySpacing.all(16),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var user = controller.users[index];
                return Row(
                  children: [
                    MyContainer(
                      height: 36,
                      width: 36,
                      paddingAll: 0,
                      borderRadiusAll: 2,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Image.asset(user['image']!, fit: BoxFit.cover),
                    ),
                    MySpacing.width(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyMedium(user['name']!, fontWeight: 600, color: contentTheme.secondary),
                          MySpacing.height(4),
                          MyText.bodyMedium(user['mutualFriends']!, fontWeight: 600, xMuted: true),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      iconSize: 20,
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'Value1',
                          child: Row(
                            children: [
                              Icon(Boxicons.bxs_user, size: 16),
                              MySpacing.width(6),
                              MyText.bodyMedium('See Profile', fontWeight: 600),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Value2',
                          child: Row(
                            children: [
                              Icon(Boxicons.bxl_telegram, size: 16),
                              MySpacing.width(6),
                              MyText.bodyMedium('Message to Victoria', fontWeight: 600),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Value3',
                          child: Row(
                            children: [
                              Icon(Boxicons.bx_user_x, size: 16),
                              MySpacing.width(6),
                              MyText.bodyMedium('Unfriend Victoria', fontWeight: 600),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'Value4',
                          child: Row(
                            children: [
                              Icon(Boxicons.bx_block, size: 16),
                              MySpacing.width(6),
                              MyText.bodyMedium('Block Victoria', fontWeight: 600),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return MySpacing.height(16);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget recentTransactions() {
    return MyCard(
      shadow: MyShadow(elevation: 0.5),
      paddingAll: 0,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(16),
            child: Row(
              children: [
                Expanded(child: MyText.titleMedium("Recent Transactions", fontWeight: 600)),
                MyContainer(
                  color: contentTheme.primary,
                  paddingAll: 8,
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(RemixIcons.add_line, color: contentTheme.onPrimary, size: 16),
                      MyText.labelMedium("Add", fontWeight: 600, color: contentTheme.onPrimary)
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider(height: 0),
          SizedBox(
            height: 348,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: MyText.titleMedium('Date', fontWeight: 600)),
                  DataColumn(label: MyText.titleMedium('Amount', fontWeight: 600)),
                  DataColumn(label: MyText.titleMedium('Type', fontWeight: 600)),
                  DataColumn(label: MyText.titleMedium('Description', fontWeight: 600)),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(MyText.bodySmall('24 April, 2024', fontWeight: 600)),
                    DataCell(MyText.bodySmall('\$120.55', fontWeight: 600)),
                    DataCell(MyContainer(
                      color: contentTheme.success,
                      paddingAll: 3,
                      child: MyText.bodySmall('Cr', color: contentTheme.onSuccess),
                    )),
                    DataCell(Text('Commissions')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('24 April, 2024')),
                    DataCell(Text('\$9.68')),
                    DataCell(MyContainer(
                      color: contentTheme.success,
                      paddingAll: 3,
                      child: MyText.bodySmall('Cr', color: contentTheme.onSuccess),
                    )),
                    DataCell(Text('Affiliates')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('20 April, 2024')),
                    DataCell(Text('\$105.22')),
                    DataCell(MyContainer(
                      color: contentTheme.danger,
                      paddingAll: 3,
                      child: MyText.bodySmall('Dr', color: contentTheme.onDanger),
                    )),
                    DataCell(Text('Grocery')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('18 April, 2024')),
                    DataCell(Text('\$80.59')),
                    DataCell(MyContainer(
                      color: contentTheme.success,
                      paddingAll: 3,
                      child: MyText.bodySmall('Cr', color: contentTheme.onSuccess),
                    )),
                    DataCell(Text('Refunds')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('18 April, 2024')),
                    DataCell(Text('\$750.95')),
                    DataCell(MyContainer(
                      color: contentTheme.danger,
                      paddingAll: 3,
                      child: MyText.bodySmall('Dr', color: contentTheme.onDanger),
                    )),
                    DataCell(Text('Bill Payments')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('17 April, 2024')),
                    DataCell(Text('\$455.62')),
                    DataCell(MyContainer(
                      color: contentTheme.danger,
                      paddingAll: 3,
                      child: MyText.bodySmall('Dr', color: contentTheme.onDanger),
                    )),
                    DataCell(Text('Electricity')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('17 April, 2024')),
                    DataCell(Text('\$102.77')),
                    DataCell(MyContainer(
                      color: contentTheme.success,
                      paddingAll: 3,
                      child: MyText.bodySmall('Cr', color: contentTheme.onSuccess),
                    )),
                    DataCell(Text('Interest')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('16 April, 2024')),
                    DataCell(Text('\$79.49')),
                    DataCell(MyContainer(
                      color: contentTheme.success,
                      paddingAll: 3,
                      child: MyText.bodySmall('Cr', color: contentTheme.onSuccess),
                    )),
                    DataCell(Text('Refunds')),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('05 April, 2024')),
                    DataCell(Text('\$980.00')),
                    DataCell(MyContainer(
                      color: contentTheme.danger,
                      paddingAll: 3,
                      child: MyText.bodySmall('Dr', color: contentTheme.onDanger),
                    )),
                    DataCell(Text('Shopping')),
                  ]),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}


class TodoItemWidget extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onChanged;

  const TodoItemWidget({super.key, required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Theme(
          data: ThemeData(),
          child: Checkbox(
            value: item.isChecked,
            onChanged: (bool? value) {
              if (value != null) {
                onChanged();
              }
            },
            shape: CircleBorder(),
          ),
        ),
        MySpacing.width(12),
        Expanded(
          child: MyText.bodyMedium(
            item.title,
            decoration: item.isChecked ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
      ],
    );
  }
}