import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/support/help_center_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:remixicon/remixicon.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> with UIMixin {
  HelpCenterController controller = Get.put(HelpCenterController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'help_center_controller',
      builder: (controller) {
        return Layout(screenName: 'HELP CENTER', child: Column(children: [header(), MySpacing.height(12), helpCenterData()]));
      },
    );
  }

  Widget header() {
    return SizedBox(
      height: 158,
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(Images.smallImages[1]), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          MyContainer(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(alpha: 0.65),
            borderRadiusAll: 12,
            clipBehavior: Clip.antiAlias,
          ),
          Center(
            child: Padding(
              padding: MySpacing.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyText.titleLarge("Help Center", fontWeight: 700, color: contentTheme.onPrimary),
                  MySpacing.height(12),
                  MyText.bodyLarge("How can we help you ?", color: Colors.white70),
                  MySpacing.height(24),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.7,
                    child: TextFormField(
                      style: MyTextStyle.bodyMedium(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(100)),
                        filled: true,
                        fillColor: contentTheme.disabled,
                        contentPadding: MySpacing.all(20),
                        isDense: true,
                        isCollapsed: true,
                        hintText: "Search....",
                        prefixIcon: Icon(RemixIcons.search_line, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget helpCenterData() {
    return GridView.builder(
      itemCount: controller.cardData.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 550,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 240,
      ),
      itemBuilder: (context, index) {
        final item = controller.cardData[index];
        return MyCard(
          shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
          paddingAll: 24,
          borderRadiusAll: 12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyContainer(
                borderRadiusAll: 16,
                color: contentTheme.primary.withValues(alpha: 0.3),
                paddingAll: 16,
                child: Icon(item['icon'], color: contentTheme.primary, size: 24),
              ),
              MySpacing.height(12),
              MyText.titleMedium(item['title'], fontWeight: 700),
              MySpacing.height(12),
              MyText.bodyMedium(item['desc'],maxLines: 2,overflow: TextOverflow.ellipsis),
              MySpacing.height(12),
              Row(
                children: [
                  MyContainer.rounded(height: 44, width: 44, paddingAll: 0, child: Image.asset(item['avatar'])),
                  MySpacing.width(12),
                  MyText.bodyMedium(item['author']),
                  MySpacing.width(12),
                  MyText.bodyMedium('${item['videoCount']} Video', color: contentTheme.primary),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
