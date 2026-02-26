import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/users/sellers/seller_create_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/utils/utils.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_list_extension.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:original_taste/views/ui/custom/authentication/widget/custom_text_form_field.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../helper/theme/admin_theme.dart';

class SellerCreateScreen extends StatefulWidget {
  const SellerCreateScreen({super.key});

  @override
  State<SellerCreateScreen> createState() => _SellerCreateScreenState();
}

class _SellerCreateScreenState extends State<SellerCreateScreen> with UIMixin {
  final SellerCreateController controller = Get.put(SellerCreateController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "SELLER ADD",
          child: MyFlex(
            contentPadding: false,
            children: [
              MyFlexItem(sizes: 'lg-3', child: productInfo()),
              MyFlexItem(
                sizes: 'lg-9',
                child: Column(
                  children: [
                    addBrandLogo(),
                    MySpacing.height(20),
                    sellerInformation(),
                    MySpacing.height(20),
                    sellerProductInformation(),
                    MySpacing.height(20),
                    MyContainer(
                      borderRadiusAll: 12,
                      color: contentTheme.secondary.withValues(alpha: 0.1),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MyContainer.bordered(
                            onTap: () {},
                            paddingAll: 12,
                            borderRadiusAll: 12,
                            color: Colors.transparent,
                            borderColor: contentTheme.secondary,
                            child: MyText.bodyMedium("Save Changes"),
                          ),
                          MySpacing.width(12),
                          MyContainer(
                            onTap: () {},
                            paddingAll: 12,
                            borderRadiusAll: 12,
                            color: contentTheme.primary,
                            child: MyText.bodyMedium("Save Changes", color: contentTheme.onPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget productInfo() {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: MySpacing.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                MyContainer(
                  borderRadiusAll: 12,
                  paddingAll: 24,
                  color: contentTheme.secondary.withValues(alpha: 0.1),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(Images.zara, height: 60, width: 60),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PopupMenuButton<String>(
                    icon: Icon(RemixIcons.more_2_fill),
                    itemBuilder:
                        (BuildContext context) => [
                          PopupMenuItem(value: "Download", child: MyText.bodyMedium("Download")),
                          PopupMenuItem(value: "Export", child: MyText.bodyMedium("Export")),
                          PopupMenuItem(value: "Import", child: MyText.bodyMedium("Import")),
                        ],
                  ),
                ),
              ],
            ),
            MySpacing.height(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium("ZARA International", fontWeight: 700),
                    MySpacing.height(4),
                    InkWell(onTap: () {}, child: MyText.bodyMedium("www.zarafashion.co", color: contentTheme.primary)),
                  ],
                ),
                Row(
                  children: [
                    MyContainer(
                      padding: MySpacing.symmetric(horizontal: 6, vertical: 2),
                      borderRadiusAll: 4,
                      color: contentTheme.secondary.withValues(alpha: 0.1),
                      child: Row(children: [Icon(Icons.star, color: Colors.amber, size: 16), MySpacing.width(4), MyText.bodyMedium("4.5")]),
                    ),
                    MySpacing.width(4),
                    MyText.bodyMedium("3.5k"),
                  ],
                ),
              ],
            ),
            MySpacing.height(12),
            Row(
              children: [
                Icon(RemixIcons.map_pin_fill, color: contentTheme.primary, size: 20),
                MySpacing.width(8),
                Expanded(child: MyText("4604, Philli Lane Kiowa IN 47404")),
              ],
            ),
            MySpacing.height(8),
            Row(
              children: [
                Icon(RemixIcons.mail_fill, color: contentTheme.primary, size: 20),
                MySpacing.width(8),
                Expanded(child: MyText.bodyMedium("zarafashionworld@dayrep.com")),
              ],
            ),
            MySpacing.height(8),
            Row(children: [Icon(RemixIcons.phone_fill, color: contentTheme.primary, size: 22), MySpacing.width(8), MyText("+243 812-801-9335")]),
            MySpacing.height(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.bodyMedium("Fashion", fontWeight: 700),
                Row(children: [MyText.bodyMedium("\$200k"), MySpacing.width(4), Icon(Icons.trending_up, color: Colors.green, size: 18)]),
              ],
            ),
            MySpacing.height(12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.8,
                backgroundColor: contentTheme.secondary.withValues(alpha: 0.1),
                color: contentTheme.primary,
                minHeight: 8,
              ),
            ),
            MySpacing.height(16),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [MyText.bodyMedium("865", fontWeight: 700), MySpacing.height(4), MyText.bodyMedium("Item Stock", muted: true)],
                    ),
                  ),
                  const VerticalDivider(thickness: 1),
                  Expanded(child: Column(children: [MyText.bodyMedium("+4.5k", fontWeight: 700), MySpacing.height(4), MyText("Sells", muted: true)])),
                  const VerticalDivider(thickness: 1),
                  Expanded(
                    child: Column(
                      children: [MyText.bodyMedium("+2k", fontWeight: 700), MySpacing.height(4), MyText.bodyMedium("Happy Client", muted: true)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget addBrandLogo() {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Add Brand Logo",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(),
          Padding(
            padding: MySpacing.all(20),
            child: MyContainer.bordered(
              borderRadiusAll: 12,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              onTap: controller.pickFiles,
              paddingAll: 23,
              child: Center(
                heightFactor: 1.5,
                child: Padding(
                  padding: MySpacing.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(RemixIcons.upload_cloud_2_line),
                      MySpacing.height(12),
                      MyContainer(
                        width: 340,
                        alignment: Alignment.center,
                        paddingAll: 0,
                        child: MyText.titleMedium(
                          "Drop files here or click to upload.",
                          fontWeight: 600,
                          muted: true,
                          fontSize: 18,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      MyContainer(
                        alignment: Alignment.center,
                        width: 610,
                        child: MyText.titleMedium(
                          "(This is just a demo dropzone. Selected files are not actually uploaded.)",
                          muted: true,
                          fontWeight: 500,
                          fontSize: 16,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (controller.files.isNotEmpty) ...[
            Padding(
              padding: MySpacing.nTop(20),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                children:
                    controller.files
                        .mapIndexed(
                          (index, file) => MyContainer.bordered(
                            borderRadiusAll: 12,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            paddingAll: 20,
                            child: Row(
                              children: [
                                MyContainer(
                                  height: 44,
                                  width: 44,
                                  borderRadiusAll: 8,
                                  color: contentTheme.onBackground.withAlpha(28),
                                  paddingAll: 0,
                                  child: Icon(controller.getFileIcon(file.name), size: 20),
                                ),
                                MySpacing.width(12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      MyText.bodyMedium(file.name, fontWeight: 700, muted: true),
                                      MySpacing.height(4),
                                      MyText.bodySmall(Utils.getStorageStringFromByte(file.size), fontWeight: 700, muted: true),
                                    ],
                                  ),
                                ),
                                MyContainer.transparent(
                                  onTap: () => controller.removeFile(file),
                                  paddingAll: 4,
                                  child: Icon(Remix.close_line, size: 20, color: contentTheme.danger),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget sellerInformation() {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Seller Information",
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
                  child: CustomTextFormField(labelText: "Brand Title", hintText: 'Enter Title', controller: controller.brandTitleController),
                ),
                MyFlexItem(
                  sizes: 'lg-6',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Product Categories"),
                      MySpacing.height(8),
                      DropdownButtonFormField<String>(
                        value: controller.selectedCategory,
                        isDense: true,
                        style: MyTextStyle.bodyMedium(),
                        dropdownColor: contentTheme.light,
                        decoration: InputDecoration(
                          hintText: "Product Categories",
                          isDense: true,
                          isCollapsed: true,
                          contentPadding: MySpacing.all(12),
                          filled: true,
                          fillColor: AdminTheme.theme.contentTheme.background,
                          border: _border,
                          enabledBorder: _border,
                          focusedBorder: _border,
                          disabledBorder: _border,
                          focusedErrorBorder: _border,
                        ),
                        items:
                            controller.categories.map((String category) {
                              return DropdownMenuItem(value: category, child: MyText.bodyMedium(category));
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            controller.selectedCategory = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-6',
                  child: CustomTextFormField(labelText: "Brand Link", hintText: 'www.***', controller: controller.brandLinkController),
                ),
                MyFlexItem(
                  sizes: 'lg-6',
                  child: CustomTextFormField(
                    labelText: "Location",
                    hintText: 'Add Address',
                    controller: controller.locationController,
                    prefixIcon: Icon(RemixIcons.road_map_fill),
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-6',
                  child: CustomTextFormField(
                    labelText: "Email",
                    hintText: 'Add Email',
                    controller: controller.emailController,
                    prefixIcon: Icon(RemixIcons.mail_line),
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-6',
                  child: CustomTextFormField(
                    labelText: "Phone Number",
                    hintText: 'Phone Number',
                    controller: controller.phoneController,
                    prefixIcon: Icon(RemixIcons.phone_line),
                  ),
                ),
                MyFlexItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RangeSlider(
                        values: controller.currentRangeValues,
                        max: 100,
                        divisions: 100,
                        labels: RangeLabels(
                          controller.currentRangeValues.start.round().toString(),
                          controller.currentRangeValues.end.round().toString(),
                        ),
                        onChanged: (RangeValues values) {
                          setState(() {
                            controller.currentRangeValues = values;
                          });
                        },
                      ),
                      MySpacing.height(6),
                      Row(
                        children: [
                          Expanded(
                            child: MyContainer.bordered(
                              paddingAll: 12,
                              borderRadiusAll: 8,
                              child: Center(child: MyText.bodyMedium('\$${controller.currentRangeValues.start.round()}')),
                            ),
                          ),
                          MySpacing.width(12),
                          Expanded(
                            child: MyContainer.bordered(
                              paddingAll: 12,
                              borderRadiusAll: 8,
                              child: Center(child: MyText.bodyMedium("\$${controller.currentRangeValues.end.round()}")),
                            ),
                          ),
                        ],
                      ),
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

  Widget sellerProductInformation() {
    return MyCard(
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Seller Product Information",
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
                  sizes: 'lg-4',
                  child: CustomTextFormField(labelText: "Items Stock", hintText: '000', controller: controller.itemsStockController),
                ),
                MyFlexItem(
                  sizes: 'lg-4',
                  child: CustomTextFormField(labelText: "Product Sells", hintText: '000', controller: controller.productSellsController),
                ),
                MyFlexItem(
                  sizes: 'lg-4',
                  child: CustomTextFormField(labelText: "Happy Client", hintText: '000', controller: controller.happyClientController),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder get _border =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AdminTheme.theme.contentTheme.secondary, width: 0.5));
}
