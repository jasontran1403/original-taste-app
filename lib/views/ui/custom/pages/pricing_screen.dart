import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/custom/pages/pricing_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/responsive.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:remixicon/remixicon.dart';


class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> with UIMixin {
  PricingController controller = Get.put(PricingController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'pricing_controller',
      builder: (controller) {
        return Layout(
          screenName: "PRICING",
          child: Column(
            children: [
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Column(
                  children: [
                    MyText.titleLarge("Simple Pricing Plans", fontWeight: 700),
                    MySpacing.height(16),
                    MyText.bodyMedium("Get the power and control you need to manage your organization's technical documentation", fontWeight: 600,muted: true),
                  ],
                ),
              ),
              MySpacing.height(24),
              MyFlex(
                children: [
                  MyFlexItem(sizes: 'lg-2.5 md-6 sm-6', child: freePack()),
                  MyFlexItem(sizes: 'lg-2.5 md-6 sm-6', child: professionalPack()),
                  MyFlexItem(sizes: 'lg-2.5 md-6 sm-6', child: businessPack()),
                  MyFlexItem(sizes: 'lg-2.5 md-6 sm-6', child: enterPricePack()),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget feature(String title) {
    return Row(
      children: [
        Icon(RemixIcons.checkbox_circle_line, size: 16, color: contentTheme.primary),
        MySpacing.width(8),
        Expanded(child: MyText.bodyMedium(title, fontWeight: 600, muted: true, maxLines: 1)),
      ],
    );
  }

  Widget packCard({
    required String title,
    required String price,
    required List<String> features,
    bool isPopular = false,
    String buttonText = "Get Started",
  }) {
    return MyCard(
      shadow: MyShadow(elevation: 0.3, position: MyShadowPosition.center),
      paddingAll: 20,
      height: 470,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: MyText.bodyMedium(title, fontWeight: 700)),
              if (isPopular)
                MyContainer(color: contentTheme.primary, paddingAll: 4, child: MyText.bodySmall("Popular", color: contentTheme.onPrimary)),
            ],
          ),
          MySpacing.height(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [MyText.displaySmall(price, fontWeight: 700), MySpacing.width(8), MyText.bodyMedium('/ Month', fontWeight: 600, xMuted: true)],
          ),
          MySpacing.height(20),
          Divider(height: 0, thickness: 1),
          MySpacing.height(20),
          Wrap(spacing: 20, runSpacing: 20, children: features.map((fe) => feature(fe)).toList()),
          Spacer(),
          MyContainer(
            onTap: () {},
            color: contentTheme.primary,
            paddingAll: 12,
            borderRadiusAll: 12,
            child: Center(child: MyText.bodyMedium(buttonText, fontWeight: 600, color: contentTheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  Widget freePack() {
    return packCard(
      title: "FREE PACK",
      price: "\$0",
      features: ["5 GB Storage", "100 GB Bandwidth", "1 Domain", "No Support", "24x7 Support", "1 User"],
    );
  }

  Widget professionalPack() {
    return packCard(
      title: "PROFESSIONAL PACK",
      price: "\$12",
      features: ["50 GB Storage", "900 GB Bandwidth", "1 Domain", "Email Support", "24x7 Support", "5 User"],
      isPopular: true,
    );
  }

  Widget businessPack() {
    return packCard(
      title: "BUSINESS PACK",
      price: "\$29",
      features: ["500 GB Storage", "2.5 TB Bandwidth", "5 Domain", "Email Support", "24x7 Support", "10 User"],
      isPopular: false,
    );
  }

  Widget enterPricePack() {
    return packCard(
      title: "ENTERPRISE PACK",
      price: "\$29",
      features: ["2 TB Storage", "Unlimited Bandwidth", "50 Domain", "Email Support", "24x7 Support", "10 User"],
      isPopular: false,
    );
  }
}