import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/users/roles/roles_list_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

class RolesListScreen extends StatefulWidget {
  const RolesListScreen({super.key});

  @override
  State<RolesListScreen> createState() => _RolesListScreenState();
}

class _RolesListScreenState extends State<RolesListScreen> with UIMixin {
  RolesListController controller = Get.put(RolesListController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'roles_list_controller',
      builder: (controller) {
        return Layout(
          screenName: "ROLES LIST",
          child: MyCard(
            borderRadiusAll: 12,
            shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    sortAscending: true,
                    headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
                    dataRowMaxHeight: 70,
                    columnSpacing: 135,
                    showBottomBorder: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    columns: [
                      DataColumn(label: MyText.labelLarge('Role', fontWeight: 700)),
                      DataColumn(label: MyText.labelLarge('Workspace', fontWeight: 700)),
                      DataColumn(label: MyText.labelLarge('Tags', fontWeight: 700)),
                      DataColumn(label: MyText.labelLarge('Users', fontWeight: 700)),
                      DataColumn(label: MyText.labelLarge('Status', fontWeight: 700)),
                      DataColumn(label: MyText.labelLarge('Action', fontWeight: 700)),
                    ],
                    rows: List.generate(controller.roleList.length, (index) {
                      final data = controller.roleList[index];
                      return DataRow(
                        cells: [
                          DataCell(MyText.bodyMedium(data.role)),
                          DataCell(MyText.bodyMedium(data.workSpace)),
                          DataCell(
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children:
                                  data.tag.map((e) {
                                    return MyContainer.bordered(paddingAll: 4, child: MyText.bodyMedium(e.toString()));
                                  }).toList(),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 150,
                              height: 44,
                              child: Stack(
                                children:
                                    (data.users).asMap().entries.map<Widget>((entry) {
                                      final index = entry.key;
                                      final user = entry.value.toString();
                                      final double overlapOffset = 27;

                                      return Positioned(
                                        left: index * overlapOffset,
                                        child:
                                            user.contains('assets/')
                                                ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(22),
                                                  child: Image.asset(user, height: 32, width: 32, fit: BoxFit.cover),
                                                )
                                                : MyContainer.rounded(
                                                  paddingAll: 0,
                                                  height: 32,
                                                  width: 32,
                                                  color: controller.getRandomBgColor(),
                                                  child: Center(child: MyText.bodyMedium(user, textAlign: TextAlign.center)),
                                                ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                          DataCell(
                            Switch(
                              value: data.active,
                              onChanged: (value) {
                                controller.userActiveToggle(data, value);
                              },
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
          ),
        );
      },
    );
  }
}
