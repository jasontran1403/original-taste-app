import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/purchase/purchase_return_controller.dart';
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

class PurchaseReturnScreen extends StatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> with UIMixin {
  PurchaseReturnController controller = Get.put(PurchaseReturnController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'purchase_return_controller',
      builder: (controller) {
        return Layout(
          screenName: "RETURN LIST",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-3', child: stats("Pending Review", "210", "assets/svg/check_circle.svg", "6.9", Boxicons.bx_down_arrow_alt)),
              MyFlexItem(sizes: 'lg-3', child: stats("Pending Payment", "608", "assets/svg/close_circle.svg", "13.2", Boxicons.bx_up_arrow_alt)),
              MyFlexItem(sizes: 'lg-3', child: stats("Delivered", "200", "assets/svg/user_plus.svg", "2.1", Boxicons.bx_up_arrow_alt)),
              MyFlexItem(sizes: 'lg-3', child: stats("In Progress", "656", "assets/svg/bag_smile_broken.svg", "3.1", Boxicons.bx_down_arrow_alt)),
              MyFlexItem(child: allOrderItems()),
            ],
          ),
        );
      },
    );
  }

  Widget stats(String title, String count, String image, String rate, IconData rateIcon) {
    final isRateDown = rateIcon == Boxicons.bx_down_arrow_alt;
    final rateColor = isRateDown ? contentTheme.danger : contentTheme.success;
    final rateBackgroundColor = rateColor.withValues(alpha: 0.2);

    Widget buildRateContainer(String rate, IconData icon, Color color, Color bgColor) {
      return MyContainer(
        color: bgColor,
        paddingAll: 2,
        child: Row(children: [Icon(icon, size: 14, color: color), MySpacing.width(2), MyText.bodySmall("$rate%", color: color)]),
      );
    }

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
                Row(
                  children: [
                    MyText.bodyMedium(
                      title,
                      style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    MySpacing.width(8),
                    buildRateContainer(rate, rateIcon, rateColor, rateBackgroundColor),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [MyText.titleLarge(count, xMuted: true), MySpacing.width(8), MyText.bodySmall("Items", muted: true)],
                ),
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

  Widget allOrderItems() {
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
                    "All Order Items",
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
          if (controller.purchaseReturn.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: true,
                headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
                dataRowMaxHeight: 70,
                columnSpacing: 100,
                showBottomBorder: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                columns: [
                  DataColumn(
                    label: Theme(
                      data: ThemeData(),
                      child: Checkbox(
                        value: controller.isAllSelected,
                        activeColor: contentTheme.primary,
                        visualDensity: VisualDensity.compact,
                        onChanged: (value) => controller.toggleSelectAll(value),
                      ),
                    ),
                  ),
                  DataColumn(label: MyText.labelLarge('ID', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Order By', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Items', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Return Date', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Total', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Return Status', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Action', fontWeight: 700)),
                ],
                rows: List.generate(controller.purchaseReturn.length, (index) {
                  final data = controller.purchaseReturn[index];
                  return DataRow(
                    cells: [
                      DataCell(
                        Theme(
                          data: ThemeData(),
                          child: Checkbox(
                            value: controller.selectedCheckboxes[index],
                            activeColor: contentTheme.primary,
                            visualDensity: VisualDensity.compact,
                            onChanged: (value) => controller.toggleCheckbox(index, value),
                          ),
                        ),
                      ),
                      DataCell(MyText.bodyMedium(data.returnId, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.orderBy, fontWeight: 600)),
                      DataCell(
                        Row(
                          children:
                              data.items.map((e) {
                                return MyText.bodyMedium(e, fontWeight: 600);
                              }).toList(),
                        ),
                      ),
                      DataCell(MyText.bodySmall(data.returnDate, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.total, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.returnStatus, fontWeight: 600)),
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
