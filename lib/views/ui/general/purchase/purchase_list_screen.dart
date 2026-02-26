import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/purchase/purchase_list_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> with UIMixin {
  PurchaseListController controller = Get.put(PurchaseListController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'purchase_list_controller',
      builder: (controller) {
        return Layout(screenName: "PURCHASE LIST", child: allWarehouseList());
      },
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
                    "All Purchase Items",
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
          if (controller.purchaseList.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: true,
                headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
                dataRowMaxHeight: 70,
                columnSpacing: 50,
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
                  DataColumn(label: MyText.labelLarge('Purchase Status', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Date', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Total', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Payment Method', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Payment Status', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Action', fontWeight: 700)),
                ],
                rows: List.generate(controller.purchaseList.length, (index) {
                  final data = controller.purchaseList[index];
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
                      DataCell(MyText.bodyMedium(data.orderId, fontWeight: 600)),
                      DataCell(
                        Row(
                          children: [
                            MyContainer.rounded(
                              paddingAll: 0,
                              height: 44,
                              width: 44,
                              child: Image.asset(Images.userAvatars[index % Images.userAvatars.length + 1]),
                            ),
                            MySpacing.width(12),
                            MyText.bodyMedium(data.orderBy, fontWeight: 600),
                          ],
                        ),
                      ),
                      DataCell(
                        Row(
                          spacing: 12,
                          children:
                              data.items.map((e) {
                                return MyText.bodyMedium(e.toString(), fontWeight: 600);
                              }).toList(),
                        ),
                      ),
                      DataCell(
                        MyContainer(
                          color: contentTheme.success,
                          padding: MySpacing.xy(12, 4),
                          child: MyText.bodySmall(data.purchaseStatus, fontWeight: 600, color: contentTheme.onPrimary),
                        ),
                      ),
                      DataCell(MyText.bodyMedium(data.date, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.total, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.paymentMethod, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.paymentStatus, fontWeight: 600)),
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
