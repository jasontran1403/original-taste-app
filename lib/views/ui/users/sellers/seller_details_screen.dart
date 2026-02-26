import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/users/sellers/sellers_details_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_star_rating.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:remixicon/remixicon.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SellerDetailsScreen extends StatefulWidget {
  const SellerDetailsScreen({super.key});

  @override
  State<SellerDetailsScreen> createState() => _SellerDetailsScreenState();
}

class _SellerDetailsScreenState extends State<SellerDetailsScreen> with UIMixin {
  SellersDetailsController controller = Get.put(SellersDetailsController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "SELLER LIST",
          child: MyFlex(
            contentPadding: false,
            children: [
              MyFlexItem(
                child: MyCard(
                  borderRadiusAll: 12,
                  shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
                  paddingAll: 0,
                  child: information(),
                ),
              ),
              MyFlexItem(sizes: 'lg-9', child: salesCard()),
              MyFlexItem(sizes: 'lg-3', child: companyReviews()),
              MyFlexItem(sizes: 'lg-8', child: latestAddedProduct()),
              MyFlexItem(
                sizes: 'lg-4',
                child: Column(
                  children: [
                    accountRevenueCard(),
                    MySpacing.height(20),
                    MyFlex(
                      contentPadding: false,
                      children: [
                        MyFlexItem(sizes: 'lg-6', child: orderCards("Order", "assets/svg/cart.svg", "458", "60% Target", 0.6, contentTheme.primary)),
                        MyFlexItem(
                          sizes: 'lg-6',
                          child: orderCards("Users", "assets/svg/user_plus.svg", "870", "80% Target", 0.8, contentTheme.success),
                        ),
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

  Widget information() {
    Widget infoRow(IconData icon, String text) {
      return Row(
        children: [
          MyContainer(
            width: 40,
            height: 40,
            color: contentTheme.secondary.withValues(alpha: 0.1),
            borderRadiusAll: 8,
            paddingAll: 0,
            child: Icon(icon, color: contentTheme.primary, size: 20),
          ),
          MySpacing.width(12),
          Expanded(child: MyText.bodyMedium(text)),
        ],
      );
    }

    Widget buildCategoryRow(
      BuildContext context, {
      required String title,
      required String amount,
      required double progress,
      required Color color,
      required bool isUp,
    }) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.bodyMedium(title),
              Row(
                children: [
                  MyText.bodyMedium(amount),
                  MySpacing.width(4),
                  Icon(
                    isUp ? RemixIcons.arrow_up_line : RemixIcons.arrow_down_line,
                    color: isUp ? contentTheme.success : contentTheme.danger,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
          MySpacing.height(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          MySpacing.height(20),
        ],
      );
    }

    Widget socialButton(IconData icon, Color color) {
      return MyContainer(
        width: 32,
        height: 32,
        paddingAll: 0,
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        child: Center(child: Icon(icon, color: color, size: 20)),
      );
    }

    Widget buildStatBox(String value, String label) {
      return MyContainer(
        padding: MySpacing.all(20),
        color: contentTheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [MyText.bodyLarge(value, fontWeight: 700), MySpacing.height(8), MyText.bodyMedium(label)],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: MySpacing.all(20),
          child: MyFlex(
            contentPadding: false,
            children: [
              MyFlexItem(
                sizes: 'lg-2',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyContainer(
                      padding: MySpacing.symmetric(vertical: 32.0),
                      color: contentTheme.secondary.withValues(alpha: 0.1),
                      width: 225,
                      height: 192,
                      borderRadiusAll: 12,
                      child: Center(child: SvgPicture.asset(Images.zara, width: 70, height: 70, fit: BoxFit.contain)),
                    ),
                    MySpacing.height(20),
                    MyContainer(
                      onTap: () {},
                      color: contentTheme.primary,
                      borderRadiusAll: 12,
                      paddingAll: 12,
                      child: Center(child: MyText.bodyMedium("View Stock Detail", color: contentTheme.onPrimary)),
                    ),
                  ],
                ),
              ),
              MyFlexItem(
                sizes: 'lg-3',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium(
                      "ZARA International",
                      style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    MySpacing.height(12),
                    MyText.bodyMedium("(Most Selling Fashion Brand)"),
                    MySpacing.height(12),
                    MyText.bodyMedium("www.larkon.co", color: contentTheme.primary),
                    MySpacing.height(8),
                    Row(children: [MyStarRating(rating: 4.5, spacing: 4, size: 20), Expanded(child: MyText.bodyMedium("4.5/5 (+23.3K Review)",maxLines: 1,))]),
                    MySpacing.height(8),
                    infoRow(Icons.location_on, '4604, Philli Lane Kiowa IN 47404'),
                    MySpacing.height(8),
                    infoRow(Icons.email, 'zarafashionworld@dayrep.com'),
                    MySpacing.height(8),
                    infoRow(Icons.phone, '+243 812-801-9335'),
                  ],
                ),
              ),
              MyFlexItem(
                sizes: 'lg-7',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleLarge('Profit by Product Category'),
                    MySpacing.height(16),
                    buildCategoryRow(context, title: "Man's Wares", amount: "\$123k", progress: 0.7, color: Colors.blue, isUp: true),
                    buildCategoryRow(context, title: "Woman's Wares", amount: "\$233k", progress: 0.9, color: Colors.green, isUp: true),
                    buildCategoryRow(context, title: "Kid's Wares", amount: "\$110k", progress: 0.6, color: Colors.orange, isUp: true),
                    buildCategoryRow(context, title: "Foot Wares", amount: "\$51k", progress: 0.4, color: Colors.lightBlue, isUp: false),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 0),
        Padding(
          padding: MySpacing.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.titleMedium(
                "Social Media :",
                style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              MySpacing.height(12),
              Wrap(
                spacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  socialButton(RemixIcons.facebook_fill, Colors.blue),
                  socialButton(RemixIcons.instagram_fill, Colors.pink),
                  socialButton(RemixIcons.twitter_fill, Colors.lightBlue),
                  socialButton(RemixIcons.whatsapp_fill, Colors.green),
                  socialButton(Icons.email_outlined, Colors.orange),
                ],
              ),
              MySpacing.height(12),
              MyText.titleMedium(
                "Our Story :",
                style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              MySpacing.height(12),
              MyText.bodyMedium(controller.dummyTexts[0]),
              MySpacing.height(12),
              MyText.titleMedium(
                "Our Mission :",
                style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              MySpacing.height(12),
              MyText.bodyMedium(controller.dummyTexts[1]),
              MySpacing.height(20),
              MyFlex(
                children: [
                  MyFlexItem(sizes: 'lg-3', child: buildStatBox("865", "Item Stock")),
                  MyFlexItem(sizes: 'lg-3', child: buildStatBox("+4.5k", "Sells")),
                  MyFlexItem(sizes: 'lg-3', child: buildStatBox("+2k", "Happy Client")),
                  MyFlexItem(sizes: 'lg-3', child: buildStatBox("+36k", "Followers")),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget salesCard() {
    SfCartesianChart buildCartesianChart() {
      return SfCartesianChart(
        plotAreaBorderWidth: 0,
        primaryXAxis: const NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift, interval: 2, majorGridLines: MajorGridLines(width: 0)),
        primaryYAxis: const NumericAxis(
          labelFormat: '{value}%',
          axisLine: AxisLine(width: 0),
          majorTickLines: MajorTickLines(color: Colors.transparent),
        ),
        series: [
          LineSeries<ChartData, num>(
            dataSource: controller.chartData,
            xValueMapper: (ChartData sales, int index) => sales.x,
            yValueMapper: (ChartData sales, int index) => sales.y,
            name: 'Germany',
            color: contentTheme.success,
            markerSettings: MarkerSettings(isVisible: true),
          ),
          LineSeries<ChartData, num>(
            dataSource: controller.chartData,
            name: 'England',
            color: contentTheme.primary,
            xValueMapper: (ChartData sales, int index) => sales.x,
            yValueMapper: (ChartData sales, int index) => sales.y2,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
        legend: Legend(overflowMode: LegendItemOverflowMode.wrap),
        tooltipBehavior: controller.tooltipBehavior,
      );
    }

    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MyText.titleLarge("\$5,563.786"),
                        MySpacing.width(12),
                        MyContainer(
                          paddingAll: 3,
                          color: contentTheme.success.withValues(alpha: 0.2),
                          child: Row(
                            children: [
                              Icon(RemixIcons.arrow_up_line, color: contentTheme.success, size: 12),
                              MyText.bodySmall("4.53%", color: contentTheme.success),
                            ],
                          ),
                        ),
                      ],
                    ),
                    MySpacing.height(12),
                    RichText(
                      text: TextSpan(
                        style: MyTextStyle.bodyMedium(),
                        children: [
                          TextSpan(text: 'Gained '),
                          TextSpan(text: '\$378.56', style: TextStyle(color: contentTheme.success)),
                          TextSpan(text: ' This Month !'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              MyContainer(
                width: 48,
                height: 48,
                paddingAll: 0,
                color: contentTheme.secondary.withValues(alpha: 0.15),
                borderRadiusAll: 12,
                child: Icon(Icons.bar_chart, size: 32, color: contentTheme.primary),
              ),
            ],
          ),
          MySpacing.height(12),
          buildCartesianChart(),
        ],
      ),
    );
  }

  Widget companyReviews() {
    Widget buildStarRow() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: contentTheme.warning, size: 28),
          Icon(Icons.star, color: contentTheme.warning, size: 28),
          Icon(Icons.star, color: contentTheme.warning, size: 28),
          Icon(Icons.star, color: contentTheme.warning, size: 28),
          Icon(Icons.star_half, color: contentTheme.warning, size: 28),
        ],
      );
    }

    Widget buildProgressRow(String label, double value) {
      return Row(
        children: [
          SizedBox(width: 60, child: MyText.bodyMedium(label, fontWeight: 600)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 10,
              ),
            ),
          ),
        ],
      );
    }

    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 20,
      height: 424,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
            child: MyText.titleMedium(
              "Company Reviews",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          MyContainer(
            color: contentTheme.secondary.withValues(alpha: 0.1),
            borderRadiusAll: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildStarRow(), MySpacing.width(12), MyText.bodyMedium('4.5 Out of 5')],
            ),
          ),
          Center(child: MyText.bodyMedium("Based on +23.5k Review", color: contentTheme.primary)),
          buildProgressRow('5 star :', 0.80),
          buildProgressRow('4 star :', 0.50),
          buildProgressRow('3 star :', 0.30),
          buildProgressRow('2 star :', 0.20),
          buildProgressRow('1 star :', 0.10),
          Center(child: InkWell(onTap: () {}, child: MyText.bodyMedium("How do we calculate ratings ?", color: contentTheme.primary))),
        ],
      ),
    );
  }

  Widget latestAddedProduct() {
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
                    "All Customer List",
                    style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                MySpacing.width(12),
                PopupMenuButton(
                  onSelected: controller.onSelectedOption,
                  itemBuilder: (BuildContext context) {
                    return ["Download", "Export", "Import"].map((behavior) {
                      return PopupMenuItem(
                        value: behavior,
                        height: 32,
                        child: MyText.bodySmall(behavior.toString(), color: theme.colorScheme.onSurface, fontWeight: 600),
                      );
                    }).toList();
                  },
                  child: MyContainer.bordered(
                    padding: MySpacing.xy(12, 8),
                    borderRadiusAll: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        MyText.labelMedium(controller.selectedOption.toString()),
                        MySpacing.width(4),
                        Icon(Boxicons.bx_chevron_down, size: 16, color: theme.colorScheme.onSurface),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
              dataRowMaxHeight: 70,
              columnSpacing: 90,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              columns: [
                DataColumn(label: MyText.labelLarge('Product Name & Size', fontWeight: 700)),
                DataColumn(label: MyText.labelLarge('Tag ID', fontWeight: 700)),
                DataColumn(label: MyText.labelLarge('Category', fontWeight: 700)),
                DataColumn(label: MyText.labelLarge('Add Date', fontWeight: 700)),
                DataColumn(label: MyText.labelLarge('Item Published', fontWeight: 700)),
              ],
              rows: List.generate(controller.latestAddedProduct.length, (index) {
                final data = controller.latestAddedProduct[index];

                Color badgeColor;
                Color textColor;
                IconData icon;

                switch (data['status']['type']) {
                  case 'success':
                    badgeColor = contentTheme.success.withValues(alpha: 0.2);
                    textColor = contentTheme.success;
                    icon = Icons.check_circle_outline;
                    break;
                  case 'pending':
                    badgeColor = contentTheme.secondary.withValues(alpha: 0.2);
                    textColor = contentTheme.secondary;
                    icon = Icons.hourglass_empty;
                    break;
                  case 'draft':
                  default:
                    badgeColor = contentTheme.danger.withValues(alpha: 0.2);
                    textColor = contentTheme.danger;
                    icon = Icons.schedule;
                }

                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyContainer(
                            height: 50,
                            width: 50,
                            paddingAll: 0,
                            color: contentTheme.secondary.withValues(alpha: 0.1),
                            child: Image.asset(data['image']),
                          ),
                          MySpacing.width(12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [MyText.bodyLarge(data['productName']), MyText.bodyMedium('Variants: ${data['variants']}', muted: true)],
                          ),
                        ],
                      ),
                    ),
                    DataCell(MyText.bodyMedium("${data['tagId']}", fontWeight: 600)),
                    DataCell(MyText.bodyMedium(data['category'], fontWeight: 600)),
                    DataCell(MyText.bodyMedium(data['addDate'], fontWeight: 600)),
                    DataCell(
                      MyContainer(
                        padding: MySpacing.symmetric(horizontal: 8, vertical: 4),
                        borderRadiusAll: 4,
                        color: badgeColor,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 14, color: textColor),
                            MySpacing.width(4),
                            MyText.bodyMedium(data['status']['label'], style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500)),
                          ],
                        ),
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

  Widget accountRevenueCard() {
    return MyContainer(
      borderRadiusAll: 12,
      paddingAll: 20,
      color: contentTheme.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyContainer(
                paddingAll: 20,
                borderRadiusAll: 12,
                color: contentTheme.secondary.withValues(alpha: 0.2),
                child: MyText.bodyMedium('1', fontWeight: 700, color: contentTheme.onSecondary),
              ),
              MySpacing.width(12),
              MyText.titleMedium("Account Revenue", fontWeight: 700, color: contentTheme.onSecondary),
            ],
          ),
          MySpacing.height(12),
          MyText.titleLarge("\$5,324,000", color: contentTheme.warning, fontWeight: 700),
          MySpacing.height(12),
          MyText.bodyMedium("Accounting revenue refers to the income earned by a company", color: contentTheme.secondary),
          MySpacing.height(12),
          Row(
            children: [
              MyText.bodyMedium("+870", color: contentTheme.onSecondary),
              MySpacing.width(4),
              MyText.bodyMedium("Customer", color: contentTheme.background),
            ],
          ),
        ],
      ),
    );
  }

  Widget orderCards(String title, String svgImage, String count, String target, double progress, Color color) {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              children: [
                MyText.titleMedium(
                  title,
                  style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                MySpacing.height(12),
                MyContainer(
                  color: contentTheme.secondary.withValues(alpha: 0.1),
                  paddingAll: 0,
                  height: 60,
                  width: 60,
                  borderRadiusAll: 12,
                  child: Padding(padding: MySpacing.all(12), child: SvgPicture.asset(svgImage)),
                ),
                MySpacing.height(12),
                MyText.titleMedium(count),
                MySpacing.height(12),
                MyText.titleMedium(target),
                MySpacing.height(12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [MyText.bodyMedium("VIew More"), MySpacing.width(8), Icon(RemixIcons.arrow_right_line, size: 16)],
            ),
          ),
        ],
      ),
    );
  }
}
