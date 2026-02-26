import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/inventory/warehouse_controller.dart';
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
import 'package:original_taste/views/ui/general/inventory/import_warehouse_screen.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({super.key});

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> with UIMixin {
  WarehouseController controller = Get.put(WarehouseController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'warehouse_controller',
      builder: (controller) {
        return Layout(
          screenName: "WAREHOUSE LIST",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-3 md-6', child: stats("Total Product Items", "3521", "assets/svg/box_broken.svg")),
              MyFlexItem(sizes: 'lg-3 md-6', child: stats("In Stock Product", "1311", "assets/svg/reorder_broken.svg")),
              MyFlexItem(sizes: 'lg-3 md-6', child: stats("Out Of Stock Product", "231", "assets/svg/bag_cross_broken.svg")),
              MyFlexItem(sizes: 'lg-3 md-6', child: stats("Total Visited Customer", "2334", "assets/svg/users_group_two_rounded_broken.svg")),
              MyFlexItem(child: allWarehouseList())
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [MyText.titleLarge(count, xMuted: true), MySpacing.width(8), MyText.bodySmall("(items)")],
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
                // Import button
                InkWell(
                  onTap: () {
                    Get.to(() => const ImportWarehouseScreen());
                  },
                  child: MyContainer(
                    color: contentTheme.success,
                    padding: MySpacing.xy(16, 10),
                    borderRadiusAll: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Boxicons.bx_import, size: 18, color: Colors.white),
                        MySpacing.width(8),
                        MyText.bodyMedium('Import', color: Colors.white, fontWeight: 600),
                      ],
                    ),
                  ),
                ),
                MySpacing.width(12),
                PopupMenuButton(
                  onSelected: controller.onSelectedOption,
                  itemBuilder: (BuildContext context) {
                    return ["Download", "Export"].map((behavior) {
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
                )
              ],
            ),
          ),
          Divider(height: 0),
          if (controller.warehouseList.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: true,
                onSelectAll: (value) => controller.toggleSelectAll(value),
                headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
                dataRowMaxHeight: 70,
                columnSpacing: 37,
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
                  DataColumn(label: MyText.labelLarge('Warehouse ID', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Warehouse Name', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Location', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Manager', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Contact Number', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Stock Available', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Stock Shipping', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Warehouse Revenue', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Action', fontWeight: 700)),
                ],
                rows: List.generate(controller.warehouseList.length, (index) {
                  final data = controller.warehouseList[index];
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
                      DataCell(MyText.bodyMedium(data.warehouseId, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.warehouseName, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.location, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.manager, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.contactNumber, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.stockAvailable.toString(), fontWeight: 600)),
                      DataCell(MyText.labelMedium(data.stockShipping.toString(), fontWeight: 600)),
                      DataCell(MyText.labelMedium(data.warehouseRevenue, fontWeight: 600)),
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