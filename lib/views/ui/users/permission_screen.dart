import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/users/permission_controller.dart';
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

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with UIMixin {
  final PermissionController controller = PermissionController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "PERMISSION",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-3', child: stats("Employees", "54", "assets/svg/users_group_two_rounded.svg")),
              MyFlexItem(sizes: 'lg-3', child: stats("Assigned Manager", "13", "assets/svg/backpack_bold_duotone.svg")),
              MyFlexItem(sizes: 'lg-3', child: stats("Project", "19", "assets/svg/rocket_2_bold_duotone.svg")),
              MyFlexItem(sizes: 'lg-3', child: stats("License Used", "36/50", "assets/svg/notebook_bold_duotone.svg")),
              MyFlexItem(child: allPermissionsList()),
            ],
          ),
        );
      },
    );
  }

  Widget allPermissionsList() {
    return MyCard(
      borderRadiusAll: 12,
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
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
                    style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
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
          DataTable(
            columnSpacing: 140,
            sortAscending: true,
            headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
            dataRowMaxHeight: 60,
            columns: [
              DataColumn(label: MyText.bodyMedium("Name", fontWeight: 700)),
              DataColumn(label: MyText.bodyMedium("Assigned To", fontWeight: 700)),
              DataColumn(label: MyText.bodyMedium("Created", fontWeight: 700)),
              DataColumn(label: MyText.bodyMedium("Updated", fontWeight: 700)),
              DataColumn(label: MyText.bodyMedium("Action", fontWeight: 700)),
            ],
            rows:
                controller.tasks.asMap().entries.map((e) {
                  final task = e.value;
                  return DataRow(
                    cells: [
                      DataCell(MyText.bodyMedium(task.name)),
                      DataCell(
                        Row(
                          spacing: 4,
                          children:
                              task.roles.map((role) {
                                return Chip(
                                  label: MyText.labelMedium(role.title, color: role.textColor),
                                  backgroundColor: role.color,
                                  padding: MySpacing.symmetric(horizontal: 6),
                                );
                              }).toList(),
                        ),
                      ),
                      DataCell(MyText.bodyMedium(task.created)),
                      DataCell(MyText.bodyMedium(task.updated)),
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
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget stats(String title, String subTitle, String svgIcon) {
    return MyCard(
      borderRadiusAll: 12,
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 20,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [MyText.titleMedium(title, fontWeight: 700, xMuted: true), MySpacing.height(12), MyText.bodyMedium(subTitle)],
            ),
          ),
          MyContainer(
            borderRadiusAll: 12,
            color: contentTheme.primary.withValues(alpha: 0.12),
            child: SvgPicture.asset(svgIcon, colorFilter: ColorFilter.mode(contentTheme.primary, BlendMode.srcIn), height: 30, width: 30),
          ),
        ],
      ),
    );
  }
}
