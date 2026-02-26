import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/users/customers/customer_details_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:remixicon/remixicon.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> with UIMixin {
  final CustomerDetailsController controller = Get.put(CustomerDetailsController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "CUSTOMER DETAILS",
          child: MyFlex(
            contentPadding: false,
            children: [
              MyFlexItem(
                sizes: 'lg-4',
                child: Column(children: [userDetails(), MySpacing.height(20), customerDetails(), MySpacing.height(20), latestInvoice()]),
              ),
              MyFlexItem(
                sizes: 'lg-8',
                child: Column(
                  children: [
                    MyFlex(
                      contentPadding: false,
                      children: [
                        MyFlexItem(sizes: 'lg-4', child: state('Total Download', '234', 'assets/svg/bill_list.svg')),
                        MyFlexItem(sizes: 'lg-4', child: state('Total Order', '219', 'assets/svg/box.svg')),
                        MyFlexItem(sizes: 'lg-4', child: state('Total Expense', '\$2,189', 'assets/svg/chat_round.svg')),
                      ],
                    ),
                    MySpacing.height(20),
                    transactionHistory(),
                    MySpacing.height(20),
                    MyFlex(
                      contentPadding: false,
                      children: [
                        MyFlexItem(sizes: 'lg-6', child: pointsEarnedCard()),
                        MyFlexItem(sizes: 'lg-6', child: Column(children: [paymentArrived(), MySpacing.height(20), accountSummaryCard()])),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget userDetails() {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 0,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              MyContainer(paddingAll: 0, borderRadiusAll: 0, height: 120, width: double.infinity, color: contentTheme.primary),
              Positioned(
                bottom: -40,
                left: 20,
                child: MyContainer.rounded(
                  paddingAll: 2,
                  child: MyContainer.rounded(paddingAll: 0, height: 80, width: 80, child: Image.asset(Images.userAvatars[0])),
                ),
              ),
            ],
          ),
          MySpacing.height(50),

          Padding(
            padding: MySpacing.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [MyText.titleMedium("Michael A. Miner"), MySpacing.width(5), Icon(Icons.verified, color: contentTheme.success, size: 18)],
                ),
                MySpacing.height(8),
                MyText.bodyMedium("@michael_cus_2024", color: contentTheme.blue),
                MySpacing.height(8),
                MyText.bodyMedium("Email: michaelaminer@dayrep.com"),
                MyText.bodyMedium("Phone: +28 (57) 760-010-27"),
              ],
            ),
          ),
          Divider(height: 32),
          Padding(
            padding: MySpacing.nTop(20),
            child: Row(
              children: [
                Expanded(
                  child: MyContainer(
                    onTap: () {},
                    color: contentTheme.primary,
                    borderRadiusAll: 12,
                    paddingAll: 12,
                    child: Center(child: MyText.bodyMedium("Send Message", color: contentTheme.onPrimary)),
                  ),
                ),
                MySpacing.width(12),
                Expanded(
                  child: MyContainer(
                    onTap: () {},
                    color: contentTheme.secondary.withValues(alpha: 0.2),
                    borderRadiusAll: 12,
                    paddingAll: 12,
                    child: Center(child: MyText.bodyMedium("Analytics", color: contentTheme.secondary)),
                  ),
                ),
                MySpacing.width(12),
                MyContainer(
                  onTap: () {},
                  paddingAll: 8,
                  borderRadiusAll: 8,
                  color: contentTheme.secondary.withValues(alpha: 0.2),
                  child: Icon(Icons.edit, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget customerDetails() {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 0,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: MySpacing.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium('Customer Details', fontWeight: 700),
                MyContainer(
                  padding: MySpacing.symmetric(horizontal: 8, vertical: 4),
                  color: contentTheme.success.withValues(alpha: 0.2),
                  child: MyText.labelMedium('Active User', color: contentTheme.success, fontWeight: 600),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: MySpacing.nBottom(20),
                child: Row(
                  children: [Expanded(flex: 2, child: MyText('Account ID:', fontWeight: 700)), Expanded(flex: 3, child: MyText('#AC-278699'))],
                ),
              ),
              MySpacing.height(16),
              Divider(height: 0),
              MySpacing.height(12),
              Padding(
                padding: MySpacing.x(20),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: MyText.bodyMedium('Invoice Email:', fontWeight: 700)),
                    Expanded(flex: 3, child: MyText.bodyMedium('michaelaminer@dayrep.com')),
                  ],
                ),
              ),
              MySpacing.height(12),
              Divider(height: 0),
              MySpacing.height(12),
              Padding(
                padding: MySpacing.x(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: MyText.bodyMedium('Delivery Address:', fontWeight: 700)),
                    Expanded(flex: 3, child: MyText.bodyMedium('62, rue des Nations Unies 22000 SAINT-BRIEUC')),
                  ],
                ),
              ),
              MySpacing.height(12),
              Divider(height: 0),
              MySpacing.height(12),
              Padding(
                padding: MySpacing.x(20),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: MyText.bodyMedium('Language:', fontWeight: 700)),
                    Expanded(flex: 3, child: MyText.bodyMedium('English')),
                  ],
                ),
              ),
              MySpacing.height(12),
              Divider(height: 0),
              MySpacing.height(12),
              Padding(
                padding: MySpacing.nTop(20),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: MyText.bodyMedium('Latest Invoice Id:', fontWeight: 700)),
                    Expanded(flex: 3, child: MyText.bodyMedium('#INV2540')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget latestInvoice() {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 0,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyLarge('Latest Invoice', fontWeight: 700),
                      SizedBox(height: 4),
                      MyText.bodyMedium('Total 234 file, 2.5GB space used', muted: true),
                    ],
                  ),
                ),

                MyContainer(
                  color: contentTheme.primary,
                  paddingAll: 12,
                  borderRadiusAll: 12,
                  child: MyText.bodyMedium("View All", color: contentTheme.onPrimary),
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: MySpacing.all(12),
            child: Column(
              spacing: 12,
              children:
                  controller.invoices.map((invoice) {
                    return MyContainer(
                      color: contentTheme.secondary.withValues(alpha: 0.05),
                      borderRadiusAll: 12,
                      child: Row(
                        children: [
                          MyContainer.rounded(
                            color: contentTheme.primary.withValues(alpha: 0.2),
                            height: 40,
                            width: 40,
                            paddingAll: 10,
                            child: SvgPicture.asset('assets/svg/file_download.svg', height: 12, width: 12),
                          ),
                          MySpacing.width(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText.bodyMedium('Invoice Id ${invoice['id']}'),
                                MySpacing.height(2),
                                MyText.bodySmall(invoice['date']!, xMuted: true),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: Icon(Icons.more_vert, size: 16),
                            itemBuilder:
                                (BuildContext context) => [
                                  const PopupMenuItem(value: 'download', child: MyText.labelMedium('Download')),
                                  const PopupMenuItem(value: 'share', child: MyText.labelMedium('Share')),
                                ],
                            onSelected: (value) {
                              // Handle action
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget state(String title, String count, String svgImage) {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 20,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [MyText.titleMedium(title, fontWeight: 700), MySpacing.height(12), MyText.bodyMedium(count)],
            ),
          ),
          MyContainer(paddingAll: 12, borderRadiusAll: 12, color: contentTheme.primary.withValues(alpha: 0.1), child: SvgPicture.asset(svgImage)),
        ],
      ),
    );
  }

  Widget transactionHistory() {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 0,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: MySpacing.all(20), child: MyText.titleMedium("Transaction History", fontWeight: 700)),
          Divider(height: 0),
          MyContainer(
            color: contentTheme.secondary.withValues(alpha: 0.1),
            padding: MySpacing.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(flex: 2, child: MyText.bodyMedium('Invoice ID')),
                Expanded(flex: 2, child: MyText.bodyMedium('Status')),
                Expanded(child: SizedBox()),
                Expanded(flex: 2, child: MyText.bodyMedium('Total Amount')),
                Expanded(flex: 2, child: MyText.bodyMedium('Due Date')),
                Expanded(flex: 2, child: MyText.bodyMedium('Payment Method')),
              ],
            ),
          ),
          Divider(height: 0),
          Column(
            children:
                controller.transactions.map((transaction) {
                  return MyContainer(
                    padding: MySpacing.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: InkWell(onTap: () {}, child: MyText(transaction['id']!))),
                        Expanded(flex: 2, child: _buildStatusBadge(transaction['status']!)),
                        Expanded(child: SizedBox()),
                        Expanded(flex: 2, child: MyText.bodyMedium(transaction['amount']!)),
                        Expanded(flex: 2, child: MyText.bodyMedium(transaction['dueDate']!)),
                        Expanded(flex: 2, child: MyText.bodyMedium(transaction['method']!)),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        bgColor = contentTheme.success.withValues(alpha: 0.1);
        textColor = contentTheme.success;
        break;
      case 'pending':
        bgColor = contentTheme.blue.withValues(alpha: 0.1);
        textColor = contentTheme.blue;
        break;
      case 'cancel':
        bgColor = contentTheme.danger.withValues(alpha: 0.1);
        textColor = contentTheme.danger;
        break;
      default:
        bgColor = contentTheme.dark.withValues(alpha: 0.1);
        textColor = contentTheme.dark;
    }

    return MyContainer(paddingAll: 8, color: bgColor, borderRadiusAll: 12, child: Center(child: MyText(status, color: textColor)));
  }

  Widget pointsEarnedCard() {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 0,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Image.asset("assets/user-profile.png",height: 473,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on, color: contentTheme.primary),
              MySpacing.width(6),
              MyText.bodyMedium('3,764 ', fontWeight: 700),
              MyText.bodyMedium('Points Earned'),
            ],
          ),
          MySpacing.height(8),
          MyText.bodyMedium('Collect reward points with each purchase.', textAlign: TextAlign.center),
          MySpacing.height(12),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Row(
              children: [
                Expanded(
                  child: MyContainer(
                    onTap: () {},
                    paddingAll: 12,
                    borderRadiusAll: 12,
                    color: contentTheme.primary,
                    child: Center(child: MyText.bodyMedium("Earn Point", color: contentTheme.onPrimary)),
                  ),
                ),
                MySpacing.width(12),
                Expanded(
                  child: MyContainer(
                    onTap: () {},
                    paddingAll: 12,
                    borderRadiusAll: 12,
                    color: contentTheme.secondary.withValues(alpha: 0.1),
                    child: Center(child: MyText.bodyMedium("View Items", color: contentTheme.secondary)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentArrived() {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 20,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          MyContainer.rounded(
            color: contentTheme.secondary.withValues(alpha: 0.1),
            paddingAll: 12,
            child: Icon(RemixIcons.arrow_down_line, color: contentTheme.secondary),
          ),
          MySpacing.width(12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [MyText.bodyMedium("Payment Arrived", fontWeight: 700), MySpacing.height(6), MyText.bodyMedium("23 min ago")],
            ),
          ),
          MyText.bodyLarge("\$1,340", fontWeight: 700),
        ],
      ),
    );
  }

  Widget accountSummaryCard() {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 0,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: MySpacing.all(16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MyContainer.rounded(paddingAll: 0, child: Image.asset(Images.userAvatars[0], height: 48, width: 48, fit: BoxFit.cover)),
                    MySpacing.width(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [MyText.titleMedium('Michael A. Miner'), SizedBox(height: 2), MyText.bodyMedium('Welcome Back', muted: true)],
                      ),
                    ),
                    IconButton(icon: Icon(Icons.settings, size: 24, color: Colors.grey), onPressed: () {}),
                  ],
                ),

                MySpacing.height(24),
                Row(
                  children: [
                    MyText.bodyMedium('All Account '),
                    const Icon(Icons.circle, size: 8, color: Colors.grey),
                    MySpacing.width(4),
                    MyText.bodyMedium('Total Balance'),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Row(children: [MyText.bodyMedium('UTS'), MySpacing.width(4), Icon(Icons.arrow_downward, size: 16, color: Colors.red)]),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [MyText.titleLarge('\$4,700', fontWeight: 700), MySpacing.width(8), MyText.bodyMedium('+\$232')],
                ),

                MySpacing.height(24),
                SizedBox(
                    height: 240,
                    child: buildCartesianChart()),
              ],
            ),
          ),

          const Divider(height: 0),

          Padding(
            padding: MySpacing.all(20),
            child: Row(
              children: [
                Expanded(
                  child: MyContainer(
                    onTap: () {},
                    color: contentTheme.primary,
                    borderRadiusAll: 12,
                    paddingAll: 12,
                    child: Center(child: MyText.bodyMedium("Send", color: contentTheme.onPrimary)),
                  ),
                ),
                MySpacing.width(12),
                Expanded(
                  child: MyContainer(
                    onTap: () {},
                    color: contentTheme.secondary.withValues(alpha: 0.1),
                    borderRadiusAll: 12,
                    paddingAll: 12,
                    child: Center(child: MyText.bodyMedium("Receive", color: contentTheme.secondary)),
                  ),
                ),
                MySpacing.width(12),
                MyContainer.rounded(
                  height: 40,
                  width: 40,
                  paddingAll: 0,
                  onTap: () {},
                  color: contentTheme.secondary.withValues(alpha: 0.2),
                  child: Icon(Icons.add, color: contentTheme.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SfCartesianChart buildCartesianChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: const CategoryAxis(majorGridLines: MajorGridLines(width: 0), labelPlacement: LabelPlacement.onTicks),
      primaryYAxis: const NumericAxis(
        minimum: 30,
        maximum: 80,
        axisLine: AxisLine(width: 0),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        majorTickLines: MajorTickLines(size: 0),
      ),
      series: _buildSplineSeries(),
      tooltipBehavior: controller.tooltipBehavior,
    );
  }

  List<SplineSeries<ChartSampleData, String>> _buildSplineSeries() {
    return <SplineSeries<ChartSampleData, String>>[
      SplineSeries<ChartSampleData, String>(
        dataSource: controller.chartData,
        xValueMapper: (ChartSampleData sales, int index) => sales.x,
        yValueMapper: (ChartSampleData sales, int index) => sales.y,
        markerSettings: const MarkerSettings(isVisible: true),
        name: 'High',
      ),
    ];
  }
}
