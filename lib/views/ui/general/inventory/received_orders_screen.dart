import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/inventory/received_orders_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

class ReceivedOrdersScreen extends StatefulWidget {
  const ReceivedOrdersScreen({super.key});

  @override
  State<ReceivedOrdersScreen> createState() => _ReceivedOrdersScreenState();
}

class _ReceivedOrdersScreenState extends State<ReceivedOrdersScreen> with UIMixin {
  ReceivedOrdersController controller = Get.put(ReceivedOrdersController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'received_orders_controller',
      builder: (controller) {
        return Layout(
          screenName: "RECEIVED ORDERS",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-3 md-6', child: stats("Pending Review", "210", "assets/svg/clipboard_remove_broken.svg")),
              MyFlexItem(sizes: 'lg-3 md-6', child: stats("Pending Payment", "608", "assets/svg/reorder_broken.svg")),
              MyFlexItem(sizes: 'lg-3 md-6', child: stats("Delivered", "200", "assets/svg/bag_cross_broken.svg")),
              MyFlexItem(sizes: 'lg-3 md-6', child: stats("In Progress", "656", "assets/svg/users_group_two_rounded_broken.svg")),
              MyFlexItem(child: allWarehouseList()),
            ],
          ),
        );
      },
    );
  }

  Widget stats(String title, String count, String image) {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 24,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium(
                  title,
                  style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                MyText.titleLarge(count, xMuted: true),
              ],
            ),
          ),
          MyContainer(
            color: contentTheme.primary.withValues(alpha: 0.12),
            paddingAll: 0,
            height: 56,
            width: 56,
            borderRadiusAll: 12,
            child: Center(child: SvgPicture.asset(image, height: 32)),
          ),
        ],
      ),
    );
  }

  Widget allWarehouseList() {
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
                    "All Product List",
                    style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
                  ),
                ),
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
          if (controller.receivedOrder.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: true,
                headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
                dataRowMaxHeight: 70,
                columnSpacing: 140,
                showBottomBorder: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                columns: [
                  DataColumn(label: MyText.labelLarge('Order ID', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Customer', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Items', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Amount', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Payment Status', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Received Status', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Action', fontWeight: 700)),
                ],
                rows: List.generate(controller.receivedOrder.length, (index) {
                  final data = controller.receivedOrder[index];
                  return DataRow(
                    cells: [
                      DataCell(MyText.bodyMedium(data.orderId, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.customer, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.items.toString(), fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.amount, fontWeight: 600)),
                      DataCell(
                        MyContainer(
                          color: data.paymentStatus == 'COD' ? contentTheme.warning : contentTheme.secondary,
                          padding: MySpacing.xy(14, 6),
                          child: MyText.bodySmall(
                            data.paymentStatus,
                            fontWeight: 600,
                            color: data.paymentStatus == 'COD' ? contentTheme.onWarning : contentTheme.onSecondary,
                          ),
                        ),
                      ),
                      DataCell(
                        MyContainer(
                          color:
                              data.receivedStatus == 'Delivered'
                                  ? contentTheme.success.withValues(alpha: 0.2)
                                  : data.receivedStatus == 'Failed'
                                  ? contentTheme.danger.withValues(alpha: 0.2)
                                  : data.receivedStatus == 'Pending'
                                  ? contentTheme.warning.withValues(alpha: 0.2)
                                  : null,
                          padding: MySpacing.xy(14, 6),
                          child: MyText.bodySmall(
                            data.receivedStatus,
                            fontWeight: 600,
                            color:
                                data.receivedStatus == 'Delivered'
                                    ? contentTheme.success
                                    : data.receivedStatus == 'Failed'
                                    ? contentTheme.danger
                                    : data.receivedStatus == 'Pending'
                                    ? contentTheme.warning
                                    : null,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          spacing: 12,
                          children: [
                            MyContainer(
                              color: contentTheme.secondary.withValues(alpha: 0.1),
                              padding: MySpacing.xy(12, 8),
                              borderRadiusAll: 8,
                              child: SvgPicture.asset(
                                'assets/svg/eye.svg',
                                height: 16,
                                width: 16,
                                colorFilter: ColorFilter.mode(contentTheme.secondary, BlendMode.srcIn),
                              ),
                            ),
                            MyContainer(
                              color: contentTheme.primary.withValues(alpha: 0.1),
                              padding: MySpacing.xy(12, 8),
                              borderRadiusAll: 8,
                              child: SvgPicture.asset('assets/svg/pen_2.svg', height: 16, width: 16),
                            ),
                            MyContainer(
                              color: contentTheme.danger.withValues(alpha: 0.1),
                              padding: MySpacing.xy(12, 8),
                              borderRadiusAll: 8,
                              child: SvgPicture.asset(
                                'assets/svg/trash_bin_2.svg',
                                height: 16,
                                width: 16,
                                colorFilter: ColorFilter.mode(contentTheme.danger, BlendMode.srcIn),
                              ),
                            ),
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
