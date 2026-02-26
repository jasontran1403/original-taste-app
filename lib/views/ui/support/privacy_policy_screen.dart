import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/support/privacy_policy_controller.dart';
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

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> with UIMixin {
  PrivacyPolicyController controller = Get.put(PrivacyPolicyController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'privacy_policy_controller',
      builder: (controller) {
        return Layout(screenName: 'PRIVACY POLICY', child: Column(
            children: [
              header(),
              MySpacing.height(12),
              privacyPolicyData("Introduction"),
              MySpacing.height(12),
              privacyPolicyData("Information We Collect"),
              MySpacing.height(12),
              privacyPolicyData("Our role in your privacy"),
            ]
        )
        );
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
                  MyText.titleLarge("Privacy Policy", fontWeight: 700, color: contentTheme.onPrimary),
                  MySpacing.height(12),
                  MyText.bodyMedium("Our code of conduct and your pledge to be an upstanding member of the product", color: Colors.white70),
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

  Widget privacyPolicyData(String title) {
    const String privacyPolicyContent = '''
TechFusion Solutions Inc. ("we", "our", "us") respects your privacy and is committed to protecting it through our compliance with this policy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our SaaS product, TechFusion Suite, available at www.techfusion.com (the "Site") or through our applications and services (collectively, "Services"). Please read this privacy policy carefully to understand our policies and practices regarding your information and how we will treat it.
''';

    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
      paddingAll: 24,
      child: Column(
        children: [
          Row(children: [SvgPicture.asset('assets/svg/black_hole_bold.svg'), MySpacing.width(12), MyText.titleMedium(title, fontWeight: 700)]),
          MySpacing.height(20),
          MyText.bodyMedium(privacyPolicyContent,fontWeight: 600,muted: true),
        ],
      ),
    );
  }
}
