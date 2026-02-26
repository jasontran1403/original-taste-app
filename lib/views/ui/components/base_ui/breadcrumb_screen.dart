import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:remixicon/remixicon.dart';
import 'package:original_taste/controller/ui/components/base_ui/breadcrumb_controller.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

class BreadcrumbScreen extends StatefulWidget {
  const BreadcrumbScreen({super.key});

  @override
  State<BreadcrumbScreen> createState() => _BreadcrumbScreenState();
}

class _BreadcrumbScreenState extends State<BreadcrumbScreen> with UIMixin {
  BreadcrumbController controller = Get.put(BreadcrumbController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'breadcrumb_controller',
      builder: (controller) {
        return Layout(
            screenName: "BREADCRUMB",
            child: MyFlex(children: [MyFlexItem(child: example()), MyFlexItem(child: withIcon())]));
      },
    );
  }

  Widget withIcon() {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.titleMedium("Example", fontWeight: 600),
                MySpacing.height(12),
                MyText.bodySmall("Optionally you can also specify the icon with your breadcrumb item.", fontWeight: 600),
              ],
            ),
          ),
          Padding(
            padding: MySpacing.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyContainer(
                  paddingAll: 12,
                  color: contentTheme.secondary.withAlpha(10),
                  child: Row(children: [Icon(Remix.home_5_line, size: 16), MySpacing.width(12), MyText.bodyMedium("Home", xMuted: true)]),
                ),
                MySpacing.height(20),
                MyContainer(
                  paddingAll: 12,
                  color: contentTheme.secondary.withAlpha(10),
                  child: Row(
                    children: [
                      Icon(Remix.home_5_line, size: 16),
                      MySpacing.width(12),
                      MyText.bodyMedium("Home", xMuted: true),
                      MySpacing.width(4),
                      Icon(Remix.arrow_right_s_line, size: 16),
                      MySpacing.width(4),
                      MyText.bodyMedium("Library", xMuted: true),
                    ],
                  ),
                ),
                MySpacing.height(20),
                MyContainer(
                  paddingAll: 12,
                  color: contentTheme.secondary.withAlpha(10),
                  child: Row(
                    children: [
                      Icon(Remix.home_5_line, size: 16),
                      MySpacing.width(12),
                      MyText.bodyMedium("Home", xMuted: true),
                      MySpacing.width(4),
                      Icon(Remix.arrow_right_s_line, size: 16),
                      MySpacing.width(4),
                      MyText.bodyMedium("Library", xMuted: true),
                      Icon(Remix.arrow_right_s_line, size: 16),
                      MySpacing.width(4),
                      MyText.bodyMedium("Data", xMuted: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget example() {
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
            child: MyText.titleMedium("Example", fontWeight: 600),
          ),
          Padding(
            padding: MySpacing.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium("Home", xMuted: true),
                MySpacing.height(20),
                Row(
                  children: [
                    MyText.bodyMedium("Home", xMuted: true),
                    MySpacing.width(4),
                    Icon(Remix.arrow_right_s_line, size: 16),
                    MySpacing.width(4),
                    MyText.bodyMedium("Library", xMuted: true),
                  ],
                ),
                MySpacing.height(20),
                Row(
                  children: [
                    MyText.bodyMedium("Home", xMuted: true),
                    MySpacing.width(4),
                    Icon(Remix.arrow_right_s_line, size: 16),
                    MySpacing.width(4),
                    MyText.bodyMedium("Library", xMuted: true),
                    Icon(Remix.arrow_right_s_line, size: 16),
                    MySpacing.width(4),
                    MyText.bodyMedium("Data", xMuted: true),
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
