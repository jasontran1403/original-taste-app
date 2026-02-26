import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/components/base_ui/collapse_controller.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

class CollapseScreen extends StatefulWidget {
  const CollapseScreen({super.key});

  @override
  State<CollapseScreen> createState() => _CollapseScreenState();
}

class _CollapseScreenState extends State<CollapseScreen> with UIMixin {
  CollapseController controller = Get.put(CollapseController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'collapse_controller',
      builder: (controller) {
        return Layout(
          screenName: "COLLAPSE",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-6', child: collapse()),
              MyFlexItem(sizes: 'lg-6', child: collapseHorizontal()),
              MyFlexItem(sizes: 'lg-6', child: multipleTargets()),
            ],
          ),
        );
      },
    );
  }

  Widget collapse() {
    return MyCard(
      shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MyContainer(
            color: contentTheme.secondary.withValues(alpha: 0.1),
            width: double.infinity,
            borderRadiusAll: 0,
            child: MyText.titleMedium("Collapse", fontWeight: 700, muted: true),
          ),
          Padding(
            padding: MySpacing.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    MyContainer(
                      onTap: controller.onCollapse,
                      color: contentTheme.primary,
                      padding: MySpacing.xy(12, 8),
                      child: MyText.bodySmall("Link with href", fontWeight: 600, color: contentTheme.onPrimary),
                    ),
                    MySpacing.width(12),
                    MyContainer(
                      onTap: controller.onCollapse,
                      color: contentTheme.primary,
                      padding: MySpacing.xy(12, 8),
                      child: MyText.bodySmall("Button with data-bs-target", fontWeight: 600, color: contentTheme.onPrimary),
                    ),
                  ],
                ),

                MySpacing.height(20),
                if (controller.isCollapse)
                  MyCard(child: MyText.bodyMedium(controller.dummyTexts[0], maxLines: 3, xMuted: true, fontWeight: 600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget collapseHorizontal() {
    return MyCard(
      shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            color: contentTheme.secondary.withValues(alpha: 0.1),
            width: double.infinity,
            borderRadiusAll: 0,
            child: MyText.titleMedium("Collapse Horizontal", fontWeight: 700, muted: true),
          ),
          Padding(
            padding: MySpacing.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyContainer(
                  onTap: controller.onCollapseHorizontal,
                  color: contentTheme.primary,
                  padding: MySpacing.xy(12, 8),
                  child: MyText.bodySmall("Button with data-bs-target", fontWeight: 600, color: contentTheme.onPrimary),
                ),
                MySpacing.height(20),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: controller.isCollapseHorizontal ? 0 : 300,
                  child: Visibility(
                    visible: !controller.isCollapseHorizontal,
                    child: MyCard(child: MyText.bodyMedium(controller.dummyTexts[1], xMuted: true, maxLines: 3)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget multipleTargets() {
    return MyCard(
      shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            color: contentTheme.secondary.withValues(alpha: 0.1),
            width: double.infinity,
            borderRadiusAll: 0,
            child: MyText.titleMedium("Multiple Targets", fontWeight: 700, muted: true),
          ),
          Padding(
            padding: MySpacing.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    MyContainer(
                      onTap: controller.togglePanel1,
                      color: contentTheme.primary,
                      padding: MySpacing.xy(12, 8),
                      child: MyText.bodySmall("Toggle first element", fontWeight: 600, color: contentTheme.onPrimary),
                    ),
                    MyContainer(
                      onTap: controller.togglePanel2,
                      color: contentTheme.primary,
                      padding: MySpacing.xy(12, 8),
                      child: MyText.bodySmall("Toggle second element", fontWeight: 600, color: contentTheme.onPrimary),
                    ),
                    MyContainer(
                      onTap: controller.toggleAllPanels,
                      color: contentTheme.primary,
                      padding: MySpacing.xy(12, 8),
                      child: MyText.bodySmall("Toggle both element", fontWeight: 600, color: contentTheme.onPrimary),
                    ),
                  ],
                ),
                if (controller.isPanel1Expanded || controller.isPanel2Expanded) MySpacing.height(20),
                Row(
                  children: [
                    if (controller.isPanel1Expanded)
                      Expanded(
                        child: MyCard(child: MyText.bodyMedium(controller.dummyTexts[0], maxLines: 3, xMuted: true, fontWeight: 600)),
                      ),
                    if (controller.isPanel1Expanded) MySpacing.width(20),
                    if (controller.isPanel2Expanded)
                      Expanded(
                        child: MyCard(child: MyText.bodyMedium(controller.dummyTexts[1], maxLines: 3, xMuted: true, fontWeight: 600)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
