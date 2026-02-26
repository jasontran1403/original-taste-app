import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/orders/order_detail_controller.dart';
import 'package:original_taste/helper/theme/theme_customizer.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_button.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> with UIMixin {
  OrderDetailController controller = Get.put(OrderDetailController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'order_detail_controller',
      builder: (controller) {
        return Layout(
          screenName: "ORDER DETAIL",
          child: MyFlex(
            children: [
              MyFlexItem(
                sizes: 'lg-9',
                child: Column(
                  children: [
                    orderDetail(),
                    MySpacing.height(12),
                    product(),
                    MySpacing.height(12),
                    orderTimeline(),
                    MySpacing.height(12),
                    MyCard(
                      paddingAll: 20,
                       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
                      borderRadiusAll: 12,
                      child: MyFlex(
                        contentPadding: false,
                        children: [
                          MyFlexItem(sizes: 'lg-3', child: stats("Vender", "Catpiller", "assets/svg/shop_2.svg")),
                          MyFlexItem(sizes: 'lg-3', child: stats("Date", "Apr 23, 2024", "assets/svg/calendar.svg")),
                          MyFlexItem(sizes: 'lg-3', child: stats("Paid By", "Gaston Lapierre", "assets/svg/user_circle.svg")),
                          MyFlexItem(sizes: 'lg-3', child: stats("Reference #IMEMO", "#0758267/90", "assets/svg/clipboard_text.svg")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              MyFlexItem(
                sizes: 'lg-3',
                child: Column(children: [orderSummery(), MySpacing.height(12), paymentInformation(), MySpacing.height(12), customerDetails()]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget orderDetail() {
    return MyCard(
      paddingAll: 20,
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyFlex(
            wrapAlignment: WrapAlignment.spaceBetween,
            wrapCrossAlignment: WrapCrossAlignment.start,
            runAlignment: WrapAlignment.spaceBetween,

            children: [
              MyFlexItem(
                sizes: 'lg-6',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MyText.bodyMedium(
                          "#0758267/90",
                          style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        MySpacing.width(12),
                        MyContainer(
                          color: contentTheme.success.withValues(alpha: 0.2),
                          padding: MySpacing.xy(14, 6),
                          child: MyText.bodyMedium(
                            "Paid",
                            style: TextStyle(
                              fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: contentTheme.success,
                            ),
                          ),
                        ),
                        MySpacing.width(12),
                        MyContainer.bordered(
                          borderRadiusAll: 12,
                          borderColor: contentTheme.warning,
                          padding: MySpacing.xy(14, 6),
                          child: MyText.bodyMedium(
                            "In Progress",
                            style: TextStyle(
                              fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: contentTheme.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    MySpacing.height(12),
                    MyText.bodyMedium("Order / Order Details / #0758267/90 - April 23 , 2024 at 6:23 pm"),
                  ],
                ),
              ),
              MyFlexItem(
                sizes: 'lg-6',
                child: Row(
                  spacing: 12,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyContainer.bordered(
                      onTap: () {},
                      borderColor: contentTheme.secondary,
                      padding: MySpacing.xy(16, 12),
                      borderRadiusAll: 12,
                      child: MyText.bodyMedium("Refund"),
                    ),
                    MyContainer.bordered(
                      onTap: () {},
                      borderColor: contentTheme.secondary,
                      padding: MySpacing.xy(16, 12),
                      borderRadiusAll: 12,
                      child: MyText.bodyMedium("Return"),
                    ),
                    MyContainer(
                      onTap: () {},
                      color: contentTheme.primary,
                      padding: MySpacing.xy(16, 12),
                      borderRadiusAll: 12,
                      child: MyText.bodyMedium("Edit Order", color: contentTheme.onPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          MySpacing.height(20),
          MyText.titleMedium(
            "Progress",
            style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          MySpacing.height(20),
          Wrap(spacing: 16, runSpacing: 16, children: controller.steps.map((step) => buildProgressItem(step)).toList()),
          MySpacing.height(20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyContainer.bordered(
                padding: MySpacing.xy(12, 8),
                borderRadiusAll: 12,
                color: ThemeCustomizer.instance.theme == ThemeMode.dark ? Color(0xff22282e) : Color(0xfff9f7f7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Boxicons.bx_arrow_from_left, size: 16),
                    SizedBox(width: 6),
                    MyText.bodyMedium("Estimated shipping date: "),
                    MyText.bodyMedium("Apr 25, 2024"),
                  ],
                ),
              ),

              MyContainer(
                color: contentTheme.primary,
                padding: MySpacing.xy(16, 12),
                borderRadiusAll: 12,
                child: MyText.bodyMedium("Make As Ready To Ship", color: contentTheme.onPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget product() {
    final List<Product> products = [
      Product(
        imagePath: Images.product[1],
        name: 'Men Black Slim Fit T-shirt',
        size: 'M',
        status: 'Ready',
        quantity: 1,
        price: 80.00,
        text: 3.00,
        amount: 83.00,
      ),
      Product(
        imagePath: Images.product[5],
        name: 'Dark Green Cargo Pant',
        size: 'M',
        status: 'Packaging',
        quantity: 3,
        price: 330.00,
        text: 4.00,
        amount: 334.00,
      ),
      Product(
        imagePath: Images.product[8],
        name: 'Men Dark Brown Wallet',
        size: 'S',
        status: 'Ready',
        quantity: 1,
        price: 132.00,
        text: 5.00,
        amount: 137.00,
      ),
      Product(
        imagePath: Images.product[10],
        name: 'Kid\'s Yellow T-shirt',
        size: 'S',
        status: 'Packaging',
        quantity: 2,
        price: 220.00,
        text: 3.00,
        amount: 223.00,
      ),
    ];

    Color getStatusColor(String status) {
      switch (status) {
        case 'Ready':
          return Colors.green;
        case 'Packaging':
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return MyCard(
      paddingAll: 0,
      borderRadiusAll: 12,
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium("Product", style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600)),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateColor.resolveWith((states) => contentTheme.secondary.withValues(alpha: 0.2)),
                columnSpacing: 120,
                columns: [
                  DataColumn(label: MyText.bodyMedium('Product Name & Size')),
                  DataColumn(label: MyText.bodyMedium('Status')),
                  DataColumn(label: MyText.bodyMedium('Quantity')),
                  DataColumn(label: MyText.bodyMedium('Price')),
                  DataColumn(label: MyText.bodyMedium('Text')),
                  DataColumn(label: MyText.bodyMedium('Amount')),
                ],
                rows:
                    products.map((product) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Image.asset(product.imagePath, width: 40, height: 40),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text("Size: ${product.size}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: getStatusColor(product.status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(product.status, style: TextStyle(color: getStatusColor(product.status), fontSize: 13)),
                            ),
                          ),
                          DataCell(Text(product.quantity.toString())),
                          DataCell(Text('\$${product.price.toStringAsFixed(2)}')),
                          DataCell(Text('\$${product.text.toStringAsFixed(2)}')),
                          DataCell(Text('\$${product.amount.toStringAsFixed(2)}')),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget orderTimeline() {
    final timelineItems = [
      TimelineItem(
        icon: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange, padding: MySpacing.all(12)),
        title: "The packing has been started",
        subtitle: "Confirmed by Gaston Lapierre",
        timestamp: "April 23, 2024, 09:40 am",
      ),
      TimelineItem(
        icon: const Icon(Icons.check_circle, color: Colors.green),
        title: "The Invoice has been sent to the customer",
        subtitle: "Invoice email was sent to hello@dundermuffilin.com",
        timestamp: "April 23, 2024, 09:40 am",
        action: TextButton(onPressed: () {}, child: MyText.bodyMedium("Resend Invoice")),
      ),
      TimelineItem(
        icon: const Icon(Icons.check_circle, color: Colors.green),
        title: "The Invoice has been created",
        subtitle: "Invoice created by Gaston Lapierre",
        timestamp: "April 23, 2024, 09:40 am",
        action: MyButton(
          onPressed: () {},
          borderRadiusAll: 4,
          elevation: 0,
          backgroundColor: contentTheme.success,
          child: MyText.bodyMedium("Download Invoice", color: contentTheme.onSecondary),
        ),
      ),
      TimelineItem(
        icon: const Icon(Icons.check_circle, color: Colors.green),
        title: "Order Payment",
        subtitle: "Using Master Card",
        timestamp: "April 23, 2024, 09:40 am",
        extraWidget: Row(
          children: [MyText.bodyMedium("Status:",), MySpacing.width(4), MyText.bodyMedium("Paid")],
        ),
      ),
      TimelineItem(
        icon: const Icon(Icons.check_circle, color: Colors.green),
        title: "4 Order confirm by Gaston Lapierre",
        timestamp: "April 23, 2024, 09:40 am",
        extraWidget: Wrap(
          spacing: 8,
          children: List.generate(4, (i) => Chip(label: MyText.bodyMedium("Order ${i + 1}"))),
        ),
      ),
    ];

    return MyCard(
      paddingAll: 0,
      borderRadiusAll: 12,
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Order Timeline",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 0),
          SizedBox(
            height: 400,
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(16),
              itemCount: timelineItems.length,
              itemBuilder: (context, index) {
                final item = timelineItems[index];
                return TimelineTile(item: item, isFirst: index == 0);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget stats(String title, String subTitle, String svgImage) {
    return Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [MyText.titleMedium(title), MyText.bodyMedium(subTitle)])),
        MyContainer(borderRadiusAll: 12, color: contentTheme.secondary.withValues(alpha: 0.2), child: SvgPicture.asset(svgImage)),
      ],
    );
  }

  Widget buildProgressItem(ProgressStep step) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: step.progress,
            backgroundColor: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
            valueColor: AlwaysStoppedAnimation<Color>(step.color),
            minHeight: 10,
          ),
          MySpacing.height(12),
          step.loading
              ? Row(
                children: [
                  MyText.labelLarge(step.label),
                  MySpacing.width(12),
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(step.color)),
                  ),
                ],
              )
              : MyText.labelLarge(step.label),
        ],
      ),
    );
  }

  Widget orderSummery() {
    Widget orderSummeryWidget(String svg, String title, String subTitle) {
      return Padding(
        padding: MySpacing.x(12),
        child: Row(
          children: [
            SvgPicture.asset(svg, colorFilter: ColorFilter.mode(contentTheme.secondary, BlendMode.srcIn), height: 16),
            MySpacing.width(12),
            Expanded(child: MyText.bodyMedium(title)),
            MySpacing.width(12),
            MyText.bodyMedium(subTitle),
          ],
        ),
      );
    }

    return MyCard(
      paddingAll: 0,
      borderRadiusAll: 12,
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Order Summary",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 0),
          MySpacing.height(12),
          Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              orderSummeryWidget('assets/svg/clipboard_text.svg', 'Sub Total:', '\$777.00'),
              Divider(height: 0),
              orderSummeryWidget('assets/svg/ticket_broken.svg', 'Discount:', '-\$60.00'),
              Divider(height: 0),
              orderSummeryWidget('assets/svg/kick_scooter_broken.svg', 'Delivery Charge:', '\$00.00'),
              Divider(height: 0),
              orderSummeryWidget('assets/svg/calculator_minimalistic_broken.svg', 'Estimated Tax (15.5%):', '\$20.00'),
            ],
          ),
          MySpacing.height(16),
          Padding(
            padding: MySpacing.all(12),
            child: Row(children: [Expanded(child: MyText.bodyMedium("Total Amount")), MySpacing.width(12), MyText.bodyMedium("\$737.00")]),
          ),
        ],
      ),
    );
  }

  Widget paymentInformation() {
    return MyCard(
      paddingAll: 0,
      borderRadiusAll: 12,
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Payment Information",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    MyContainer(
                      paddingAll: 8,
                      borderRadiusAll: 12,
                      color: contentTheme.secondary.withValues(alpha: 0.2),
                      child: SvgPicture.asset('assets/svg/mastercard.svg', height: 32),
                    ),
                    MySpacing.width(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [MyText.bodyMedium("Master Card"), MySpacing.height(6), MyText.bodyMedium("xxxx xxxx xxxx 7812")],
                      ),
                    ),
                    SvgPicture.asset('assets/svg/check_circle.svg', colorFilter: ColorFilter.mode(contentTheme.success, BlendMode.srcIn)),
                  ],
                ),
                MySpacing.height(6),
                Row(
                  children: [
                    MyText.bodyMedium("Transaction ID :"),
                    MySpacing.width(4),
                    Expanded(child: MyText.bodyMedium("#IDN768139059", color: contentTheme.secondary, fontWeight: 600, muted: true,maxLines: 1,)),
                  ],
                ),
                MySpacing.height(6),
                Row(
                  children: [
                    MyText.bodyMedium("Card Holder Name :"),
                    MySpacing.width(4),
                    Expanded(child: MyText.bodyMedium("Gaston Lapierre", color: contentTheme.secondary, fontWeight: 600, muted: true,maxLines: 1,)),
                  ],
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
      paddingAll: 0,
      borderRadiusAll: 12,
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Customer Details",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MyContainer.bordered(
                      paddingAll: 1,
                      borderRadiusAll: 12,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyContainer(
                        paddingAll: 0,
                        borderRadiusAll: 12,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Image.asset(Images.userAvatars[1], height: 50),
                      ),
                    ),
                    MySpacing.width(12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyMedium("Gaston Lapierre"),
                        MySpacing.height(6),
                        MyText.bodyMedium("hello@dundermuffilin.com", color: contentTheme.primary),
                      ],
                    ),
                  ],
                ),
                MySpacing.height(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [MyText.titleMedium('Contact Number', fontWeight: 700, muted: true), Icon(Icons.edit, size: 20)],
                ),
                MySpacing.height(6),
                MyText.bodyMedium('(723) 732-760-5760'),
                MySpacing.height(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [MyText.bodyMedium('Shipping Address', fontWeight: 700, muted: true), Icon(Icons.edit, size: 20)],
                ),

                MySpacing.height(6),

                MyText.bodyMedium('Wilson\'s Jewelers LTD'),
                MyText.bodyMedium('1344 Hershell Hollow Road,'),
                MyText.bodyMedium('Tukwila, WA 98168,'),
                MyText.bodyMedium('United States'),
                MyText.bodyMedium('(723) 732-760-5760'),

                MySpacing.height(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [MyText.bodyMedium('Billing Address', fontWeight: 700, muted: true), Icon(Icons.edit, size: 20)],
                ),
                MySpacing.height(6),
                MyText.bodyMedium('Same as shipping address'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineTile extends StatelessWidget {
  final TimelineItem item;
  final bool isFirst;

  const TimelineTile({super.key, required this.item, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            MyContainer.rounded(width: 40, height: 40, paddingAll: 0, child: Center(child: item.icon)),
            MyContainer(paddingAll: 0, width: 2, height: 80, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: MyContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleMedium(item.title),
                if (item.subtitle != null) Padding(padding: MySpacing.only(top: 4.0), child: MyText.bodyMedium(item.subtitle!)),
                if (item.extraWidget != null) Padding(padding: MySpacing.only(top: 8.0), child: item.extraWidget!),
                if (item.action != null) Padding(padding: MySpacing.only(top: 8.0), child: item.action!),
                Padding(padding: MySpacing.only(top: 8.0), child: MyText.bodyMedium(item.timestamp)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
