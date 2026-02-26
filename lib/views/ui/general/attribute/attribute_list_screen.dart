import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/attribute/attribute_list_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

class AttributeListScreen extends StatefulWidget {
  const AttributeListScreen({super.key});

  @override
  State<AttributeListScreen> createState() => _AttributeListScreenState();
}

class _AttributeListScreenState extends State<AttributeListScreen> with UIMixin {
  AttributeListController controller = Get.put(AttributeListController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'attribute_edit_controller',
      builder: (controller) {
        return Layout(screenName: "ATTRIBUTE LIST", child: allAttributeList());
      },
    );
  }

  Widget allAttributeList() {
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
                    "All Attribute List",
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
          if (controller.attributeList.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: true,
                headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
                dataRowMaxHeight: 70,
                columnSpacing: 75,
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
                  DataColumn(label: MyText.labelLarge('Variant', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Value', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Option', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Created On', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Published', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Action', fontWeight: 700)),
                ],
                rows: List.generate(controller.attributeList.length, (index) {
                  final data = controller.attributeList[index];
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
                      DataCell(MyText.bodyMedium(data.code, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.variant, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.value, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.option, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.createdAt, fontWeight: 600)),
                      DataCell(Switch(value: data.published, onChanged: (value) => controller.togglePublished(data))),
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
