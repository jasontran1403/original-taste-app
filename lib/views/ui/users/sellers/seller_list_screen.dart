import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/users/sellers/seller_list_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/models/seller_list_model.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:remixicon/remixicon.dart';

class SellerListScreen extends StatefulWidget {
  const SellerListScreen({super.key});

  @override
  State<SellerListScreen> createState() => _SellerListScreenState();
}

class _SellerListScreenState extends State<SellerListScreen> with UIMixin {
  SellerListController controller = Get.put(SellerListController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "SELLER LIST",
          child: Padding(
            padding: MySpacing.x(20),
            child: GridView.builder(
              itemCount: controller.sellersList.length,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 500,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 530,
              ),
              itemBuilder: (BuildContext context, int index) {
                SellerListModel sellerData = controller.sellersList[index];
                return MyCard(
                  borderRadiusAll: 12,
                  shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
                  paddingAll: 0,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      Padding(
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
                                  child: SvgPicture.asset(sellerData.image, height: 100, width: 100),
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
                                    Row(
                                      children: [
                                        MyText.titleMedium(sellerData.title, fontWeight: 700),
                                        MySpacing.width(4),
                                        MyText.labelMedium("(${sellerData.category})"),
                                      ],
                                    ),
                                    MySpacing.height(4),
                                    InkWell(onTap: () {}, child: MyText.bodyMedium(sellerData.website, color: contentTheme.primary)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    MyContainer(
                                      padding: MySpacing.symmetric(horizontal: 6, vertical: 2),
                                      borderRadiusAll: 4,
                                      color: contentTheme.secondary.withValues(alpha: 0.1),
                                      child: Row(
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 16),
                                          MySpacing.width(4),
                                          MyText.bodyMedium(sellerData.rating.toString()),
                                        ],
                                      ),
                                    ),
                                    MySpacing.width(4),
                                    MyText.bodyMedium(formatNumber(sellerData.reviews)),
                                  ],
                                ),
                              ],
                            ),
                            MySpacing.height(12),
                            Row(
                              children: [
                                Icon(RemixIcons.map_pin_fill, color: contentTheme.primary, size: 20),
                                MySpacing.width(8),
                                Expanded(child: MyText(sellerData.address)),
                              ],
                            ),
                            MySpacing.height(8),
                            Row(
                              children: [
                                Icon(RemixIcons.mail_fill, color: contentTheme.primary, size: 20),
                                MySpacing.width(8),
                                Expanded(child: MyText.bodyMedium(sellerData.email)),
                              ],
                            ),
                            MySpacing.height(8),
                            Row(
                              children: [
                                Icon(RemixIcons.phone_fill, color: contentTheme.primary, size: 22),
                                MySpacing.width(8),
                                MyText(sellerData.phone),
                              ],
                            ),
                            MySpacing.height(16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyText.bodyMedium(sellerData.industry, fontWeight: 700),
                                Row(
                                  children: [
                                    MyText.bodyMedium(sellerData.revenue),
                                    MySpacing.width(4),
                                    Icon(Icons.trending_up, color: Colors.green, size: 18),
                                  ],
                                ),
                              ],
                            ),
                            MySpacing.height(12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: (sellerData.progress) / 100.toDouble(),
                                backgroundColor: contentTheme.secondary.withValues(alpha: 0.1),
                                color: contentTheme.primary,
                                minHeight: 8,
                              ),
                            ),
                            MySpacing.height(16),
                            SizedBox(
                              height: 40,
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          MyText.bodyMedium(sellerData.stock.toString(), fontWeight: 700),
                                          MySpacing.height(4),
                                          MyText.bodyMedium("Item Stock", muted: true),
                                        ],
                                      ),
                                    ),
                                    const VerticalDivider(thickness: 1),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          MyText.bodyMedium("+${formatNumber(sellerData.sells)}", fontWeight: 700),
                                          MySpacing.height(4),
                                          MyText("Sells", muted: true),
                                        ],
                                      ),
                                    ),
                                    const VerticalDivider(thickness: 1,endIndent: 20,),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          MyText.bodyMedium("+${formatNumber(sellerData.happyClient)}", fontWeight: 700),
                                          MySpacing.height(4),
                                          MyText.bodyMedium("Happy Client", muted: true),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 0),
                      Padding(
                        padding: MySpacing.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: MyContainer(
                                onTap: () => {},
                                color: contentTheme.primary,
                                paddingAll: 12,
                                borderRadiusAll: 12,
                                child: Center(child: MyText.bodyMedium("View Profile", color: contentTheme.onPrimary)),
                              ),
                            ),
                            MySpacing.width(12),
                            Expanded(
                              child: MyContainer(
                                onTap: () => {},
                                color: contentTheme.secondary.withValues(alpha: 0.2),
                                paddingAll: 12,
                                borderRadiusAll: 12,
                                child: Center(child: MyText.bodyMedium("View Profile", color: contentTheme.secondary)),
                              ),
                            ),
                            MySpacing.width(12),
                            MyContainer.rounded(
                              onTap: () => controller.toggleLike(index),
                              paddingAll: 8,
                              color: controller.likedIndexes.contains(index) ? contentTheme.primary : contentTheme.primary.withValues(alpha: 0.2),
                              child: Icon(
                                controller.likedIndexes.contains(index) ? RemixIcons.heart_fill : RemixIcons.heart_line,
                                size: 16,
                                color: controller.likedIndexes.contains(index) ? contentTheme.onPrimary : contentTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String formatNumber(int number) {
    if (number >= 1000000) '${_shorten(number / 1000000)}M';
    if (number >= 1000) return '${_shorten(number / 1000)}k';
    return number.toString();
  }

  String _shorten(double value) => value.truncateToDouble() == value ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}
