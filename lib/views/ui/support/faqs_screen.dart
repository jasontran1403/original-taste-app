import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/support/faqs_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:remixicon/remixicon.dart';

import '../../../helper/widgets/my_container.dart' show MyContainer;

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen> with UIMixin {
  FaqsController controller = Get.put(FaqsController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'faqs_controller',
      builder: (controller) {
        return Layout(screenName: "FAQs", child: Column(children: [header(), MySpacing.height(12), faqsData()]));
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
                  MyText.titleLarge("Frequently Asked Questions", fontWeight: 700, color: contentTheme.onPrimary),
                  MySpacing.height(12),
                  MyText.bodyMedium(
                    "We're here to help with any questions you have about plans, pricing, and supported features.",
                    color: Colors.white70,
                  ),
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

  Widget faqsData() {
    return MyCard(
      shadow: MyShadow(elevation: 0.3, position: MyShadowPosition.center),
      child: Column(
        children: [
          MyFlex(
            children: [
              MyFlexItem(
                sizes: "lg-6",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium("General", fontWeight: 600),
                    MySpacing.height(16),
                    ExpansionPanelList(
                      elevation: 1,
                      expandedHeaderPadding: EdgeInsets.all(0),
                      materialGapSize: 0.4,
                      expansionCallback: (int index, bool isExpanded) => setState(() => controller.dataExpansionPanel1[index] = isExpanded),
                      animationDuration: Duration(milliseconds: 500),
                      children: <ExpansionPanel>[
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder:
                              (BuildContext context, bool isExpanded) => title(isExpanded, "Can I use Dummy FAQs for my website or project?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[1], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel1[0],
                        ),
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder:
                              (BuildContext context, bool isExpanded) => title(isExpanded, "Are Dummy FAQs suitable for customer support purposes?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[1], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel1[1],
                        ),
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (BuildContext context, bool isExpanded) => title(isExpanded, "Do Dummy FAQs require attribution?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[1], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel1[2],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MyFlexItem(
                sizes: "lg-6",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium("Payments", fontWeight: 600),
                    MySpacing.height(16),
                    ExpansionPanelList(
                      elevation: 1,
                      materialGapSize: 0.4,
                      expandedHeaderPadding: EdgeInsets.all(0),
                      expansionCallback: (int index, bool isExpanded) => setState(() => controller.dataExpansionPanel2[index] = isExpanded),
                      animationDuration: Duration(milliseconds: 500),
                      children: <ExpansionPanel>[
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder:
                              (BuildContext context, bool isExpanded) => title(isExpanded, "Can I test my website/app with Dummy Payments?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[1], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel2[0],
                        ),
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (BuildContext context, bool isExpanded) => title(isExpanded, "Are Dummy Payments secure?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[1], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel2[1],
                        ),
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder:
                              (BuildContext context, bool isExpanded) =>
                                  title(isExpanded, "How can I differentiate between a Dummy Payment and a real one?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[1], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel2[2],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MyFlexItem(
                sizes: "lg-6",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium("Refunds", fontWeight: 600),
                    MySpacing.height(16),
                    ExpansionPanelList(
                      elevation: 1,
                      materialGapSize: 0.4,
                      expandedHeaderPadding: EdgeInsets.all(0),
                      expansionCallback: (int index, bool isExpanded) => setState(() => controller.dataExpansionPanel3[index] = isExpanded),
                      animationDuration: Duration(milliseconds: 500),
                      children: <ExpansionPanel>[
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (BuildContext context, bool isExpanded) => title(isExpanded, "How do I request a refund?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[1], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel3[0],
                        ),
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (BuildContext context, bool isExpanded) => title(isExpanded, "What is the refund policy?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[1], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel3[1],
                        ),
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (BuildContext context, bool isExpanded) => title(isExpanded, "How long does it take to process a refund?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[1], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel3[2],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MyFlexItem(
                sizes: "lg-6",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium("Support", fontWeight: 600),
                    MySpacing.height(16),
                    ExpansionPanelList(
                      elevation: 1,
                      materialGapSize: 0.4,
                      expandedHeaderPadding: EdgeInsets.all(0),
                      expansionCallback: (int index, bool isExpanded) => setState(() => controller.dataExpansionPanel4[index] = isExpanded),
                      animationDuration: Duration(milliseconds: 1200),
                      children: <ExpansionPanel>[
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (BuildContext context, bool isExpanded) => title(isExpanded, "How do I contact customer support?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[1], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel4[0],
                        ),
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (BuildContext context, bool isExpanded) => title(isExpanded, "Is customer support available 24/7?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[1], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel4[1],
                        ),
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder:
                              (BuildContext context, bool isExpanded) =>
                                  title(isExpanded, "How long does it take to receive a response from customer support?"),
                          body: Padding(
                            padding: MySpacing.all(20),
                            child: MyText.bodyMedium(controller.dummyTexts[2], muted: true, fontWeight: 600, fontSize: 13),
                          ),
                          isExpanded: controller.dataExpansionPanel4[2],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          MySpacing.height(MediaQuery.of(context).size.height / 12),
          MyText.titleMedium("Can't find a questions?", fontWeight: 600, fontSize: 18),
          MySpacing.height(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyContainer(
                onTap: () {},
                color: contentTheme.success,
                paddingAll: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RemixIcons.mail_line, size: 16, color: contentTheme.onSuccess),
                    MySpacing.width(8),
                    MyText.labelMedium("Email us your question", fontWeight: 600, color: contentTheme.onSuccess),
                  ],
                ),
              ),
              MySpacing.width(12),
              MyContainer(
                onTap: () {},
                color: contentTheme.info,
                paddingAll: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(RemixIcons.twitter_x_line, size: 16, color: contentTheme.onSuccess),
                    MySpacing.width(8),
                    MyText.labelMedium("Send us a tweet", fontWeight: 600, color: contentTheme.onSuccess),
                  ],
                ),
              ),
            ],
          ),
          MySpacing.height(MediaQuery.of(context).size.height / 12),
        ],
      ),
    );
  }

  Widget title(bool isExpanded, title) {
    return Padding(
      padding: MySpacing.all(14),
      child: MyText.titleSmall(title, color: isExpanded ? contentTheme.primary : theme.colorScheme.onSurface, fontWeight: isExpanded ? 600 : 500),
    );
  }
}
