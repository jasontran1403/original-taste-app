import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/users/roles/roles_create_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:original_taste/views/ui/custom/authentication/widget/custom_text_form_field.dart';

import '../../../../helper/theme/admin_theme.dart';

class RolesCreateScreen extends StatefulWidget {
  const RolesCreateScreen({super.key});

  @override
  State<RolesCreateScreen> createState() => _RolesCreateScreenState();
}

class _RolesCreateScreenState extends State<RolesCreateScreen> with UIMixin {
  RolesCreateController controller = Get.put(RolesCreateController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RolesCreateController>(
      init: controller,
      tag: 'roles_edit_controller',
      builder: (_) {
        return Layout(
          screenName: "ROLES EDIT",
          child: MyCard(
             shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
            borderRadiusAll: 12,
            paddingAll: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: MySpacing.all(20),
                  child: MyText.titleMedium(
                    "Roles Information",
                    style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
                  ),
                ),
                Divider(height: 0),
                Padding(
                  padding: MySpacing.all(20),
                  child: MyFlex(
                    contentPadding: false,
                    children: [
                      MyFlexItem(
                        sizes: 'lg-6',
                        child: CustomTextFormField(labelText: "Roles Name", controller: controller.roleNameController, hintText: "Role Name"),
                      ),
                      MyFlexItem(
                        sizes: 'lg-6',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.bodyMedium("Add Workspace"),
                            MySpacing.height(8),
                            InputDecorator(
                              decoration: InputDecoration(
                                hintText: "Add Workspace",
                                isDense: true,
                                isCollapsed: true,
                                contentPadding: MySpacing.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AdminTheme.theme.contentTheme.secondary, width: 0.5),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  isDense: true,
                                  value: controller.selectedWorkspace,
                                  items: [
                                    DropdownMenuItem(value: "Facebook", child: Text("Facebook")),
                                    DropdownMenuItem(value: "Slack", child: Text("Slack")),
                                    DropdownMenuItem(value: "Zoom", child: Text("Zoom")),
                                    DropdownMenuItem(value: "Analytics", child: Text("Analytics")),
                                    DropdownMenuItem(value: "Meet", child: Text("Meet")),
                                    DropdownMenuItem(value: "Mail", child: Text("Mail")),
                                    DropdownMenuItem(value: "Strip", child: Text("Strip")),
                                  ],
                                  onChanged: (val) {
                                    setState(() {
                                      controller.selectedWorkspace = val;
                                    });
                                  },
                                  hint: Text("Select Workspace"),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      MyFlexItem(
                        sizes: 'lg-6',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.bodyMedium("Tag"),
                            MySpacing.height(8),
                            InputDecorator(
                              decoration: InputDecoration(
                                hintText: 'Tag',
                                isCollapsed: true,
                                isDense: true,
                                contentPadding: MySpacing.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: AdminTheme.theme.contentTheme.secondary, width: 0.5),
                                ),
                              ),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children:
                                    controller.allTags.map((tag) {
                                      final bool isSelected = controller.selectedTags.contains(tag);
                                      return FilterChip(
                                        label: MyText.labelMedium(tag),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            if (selected) {
                                              controller.selectedTags.add(tag);
                                            } else {
                                              controller.selectedTags.remove(tag);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      MyFlexItem(
                        sizes: 'lg-6',
                        child: CustomTextFormField(labelText: "User Name", controller: controller.userNameController, hintText: "User Name"),
                      ),
                      MyFlexItem(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.bodyMedium("User Status"),
                            MySpacing.height(12),
                            Row(
                              children: [
                                Radio<String>(
                                  activeColor: contentTheme.primary,
                                  value: "Active",
                                  groupValue: controller.userStatus,
                                  onChanged: (val) {
                                    setState(() {
                                      controller.userStatus = val!;
                                    });
                                  },
                                ),
                                MyText.bodyMedium("Active"),
                                SizedBox(width: 20),
                                Radio<String>(
                                  activeColor: contentTheme.primary,
                                  value: "In Active",
                                  groupValue: controller.userStatus,
                                  onChanged: (val) {
                                    setState(() {
                                      controller.userStatus = val!;
                                    });
                                  },
                                ),
                                MyText.bodyMedium("In Active"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 0),
                MyContainer(
                  marginAll: 20,
                  color: contentTheme.primary,
                  paddingAll: 12,
                  borderRadiusAll: 12,
                  child: MyText.bodyMedium("Save Changes", color: contentTheme.onPrimary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
