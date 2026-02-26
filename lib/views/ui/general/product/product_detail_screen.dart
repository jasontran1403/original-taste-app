import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/product/product_detail_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_list_extension.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_star_rating.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with UIMixin {
  ProductDetailController controller = Get.put(ProductDetailController());

  final List<Map<String, dynamic>> colors = [
    {'id': 'dark', 'color': Colors.black},
    {'id': 'yellow', 'color': Colors.amber},
    {'id': 'white', 'color': Colors.white, 'border': Colors.grey},
    {'id': 'green', 'color': Colors.green},
  ];

  final List<String> sizes = ['S', 'M', 'XL', 'XXL'];

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'product_detail_controller',
      builder: (controller) {
        return Layout(
          screenName: "PRODUCT DETAILS",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'xl-4 lg-6', child: imageSelection()),
              MyFlexItem(sizes: 'xl-8 lg-6', child: details()),
              MyFlexItem(child: detailState()),
              MyFlexItem(sizes: 'lg-6', child: itemDetail()),
              MyFlexItem(sizes: 'lg-6', child: topReviewFromWorld()),
            ],
          ),
        );
      },
    );
  }

  Widget imageSelection() {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              children: [
                MyContainer(
                  borderRadiusAll: 12,
                  paddingAll: 0,
                  color: contentTheme.light,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.asset(controller.selectedImage, fit: BoxFit.cover, height: 450),
                ),
                MySpacing.height(20),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    runSpacing: 4,
                    spacing: 4,
                    children:
                        controller.images
                            .mapIndexed(
                              (index, image) => SizedBox(
                                height: 96,
                                width: 96,
                                child: Stack(
                                  children: [
                                    MyContainer(
                                      color: contentTheme.light,
                                      onTap: () {
                                        controller.onChangeImage(image);
                                      },
                                      height: 96,
                                      width: 96,
                                      border: Border.all(color: contentTheme.primary, width: 2),
                                      borderRadiusAll: 8,
                                      paddingAll: 0,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Image.asset(image, fit: BoxFit.cover),
                                    ),
                                    MyContainer(
                                      onTap: () {
                                        controller.onChangeImage(image);
                                      },
                                      color: image != controller.selectedImage ? contentTheme.light.withValues(alpha: 0.6) : Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Row(
              spacing: 12,
              children: [
                Expanded(
                  child: MyContainer(
                    color: contentTheme.primary,
                    padding: MySpacing.xy(20, 10),
                    borderRadiusAll: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Boxicons.bx_cart, color: contentTheme.onPrimary, size: 20),
                        MySpacing.width(12),
                        Expanded(child: MyText.bodyMedium('Add to cart', color: contentTheme.onPrimary, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: MyContainer(
                    color: contentTheme.light,
                    padding: MySpacing.xy(20, 10),
                    borderRadiusAll: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Boxicons.bx_shopping_bag, color: contentTheme.dark, size: 20),
                        MySpacing.width(12),
                        Expanded(child: MyText.bodyMedium('Buy Now', color: contentTheme.dark, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ),

                MyContainer(
                  onTap: () {},
                  color: contentTheme.danger.withValues(alpha: 0.1),
                  borderRadiusAll: 12,
                  padding: MySpacing.xy(20, 8),
                  child: SvgPicture.asset('assets/svg/heart_broken.svg', colorFilter: ColorFilter.mode(contentTheme.danger, BlendMode.srcIn)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget details() {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            color: contentTheme.success,
            padding: MySpacing.xy(20, 6),
            borderRadiusAll: 8,
            child: MyText.bodyMedium("New Arrival", color: contentTheme.onSuccess),
          ),
          MySpacing.height(12),
          MyText.titleLarge("Men Black Slim Fit T-shirt"),
          MySpacing.height(20),
          Row(
            children: [
              MyStarRating(rating: 4.5, size: 22),
              MySpacing.width(12),
              MyText.bodyLarge("4.5", fontWeight: 600),
              MySpacing.width(2),
              MyText.bodyMedium("(55 Review)", muted: true),
            ],
          ),
          MySpacing.height(20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MyText.titleLarge("\$80.00", fontWeight: 700),
              MySpacing.width(12),
              MyText.bodyMedium(
                "\$100.00",
                style: TextStyle(
                  fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w600,
                ),
              ),
              MySpacing.width(12),
              MyText.bodySmall(
                "(30% off)",
                style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 12, color: contentTheme.danger),
              ),
            ],
          ),
          MySpacing.height(12),
          MyFlex(
            contentPadding: false,
            children: [
              MyFlexItem(
                sizes: 'lg-4',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MyText.titleMedium(
                          "Color",
                          style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        MySpacing.width(4),
                        MyText.titleMedium(
                          "> Dark",
                          style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 14, color: contentTheme.dark.withAlpha(200)),
                        ),
                      ],
                    ),
                    MySpacing.height(12),
                    Wrap(
                      spacing: 10,
                      children:
                          colors.map((colorData) {
                            final id = colorData['id'];
                            final color = colorData['color'];
                            return GestureDetector(
                              onTap: () => controller.toggleColor(id),
                              child: MyContainer(
                                width: 36,
                                height: 36,
                                paddingAll: 0,
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    controller.isSelected(id)
                                        ? contentTheme.dark.withValues(alpha: 0.4)
                                        : contentTheme.secondary.withValues(alpha: 0.2),
                                child: Center(child: Icon(Icons.circle, color: color, size: 20)),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              MyFlexItem(
                sizes: 'lg-6',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        MyText.titleMedium(
                          "Size",
                          style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        MySpacing.width(4),
                        MyText.titleMedium(
                          "> M",
                          style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 14, color: contentTheme.dark.withAlpha(200)),
                        ),
                      ],
                    ),
                    MySpacing.height(12),
                    Wrap(
                      spacing: 10,
                      children:
                          sizes.map((size) {
                            final selected = controller.isSelectedSize(size);
                            return GestureDetector(
                              onTap: () => controller.toggleSize(size),
                              child: MyContainer(
                                width: 36,
                                height: 36,
                                paddingAll: 0,
                                borderRadius: BorderRadius.circular(10),
                                color: selected ? contentTheme.dark.withValues(alpha: 0.4) : contentTheme.secondary.withValues(alpha: 0.2),
                                child: Center(child: MyText.bodyMedium(size, color: selected ? contentTheme.onPrimary : null)),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          MySpacing.height(12),
          MyText.titleMedium(
            'Quantity :',
            style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          MySpacing.height(12),
          MyContainer.bordered(
            paddingAll: 8,
            borderRadiusAll: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyContainer(
                  onTap: () => controller.decrementQuantity(),
                  color: contentTheme.light,
                  borderRadiusAll: 4,
                  paddingAll: 0,
                  height: 24,
                  width: 24,
                  child: Center(child: MyText.bodyMedium('-')),
                ),
                SizedBox(width: 40, child: Center(child: MyText.bodyMedium(controller.isQuantity.toString(), fontWeight: 600))),
                MyContainer(
                  onTap: () => controller.incrementQuantity(),
                  color: contentTheme.light,
                  borderRadiusAll: 4,
                  paddingAll: 0,
                  height: 24,
                  width: 24,
                  child: Center(child: MyText.bodyMedium('+')),
                ),
              ],
            ),
          ),
          MySpacing.height(24),
          Row(children: [Icon(Boxicons.bx_check, color: contentTheme.success, size: 16), MySpacing.width(8), MyText.bodyMedium("In Stock")]),
          MySpacing.height(8),
          Row(
            children: [
              Icon(Boxicons.bx_check, color: contentTheme.success, size: 16),
              MySpacing.width(8),
              MyText.bodyMedium("Free delivery available"),
            ],
          ),
          MySpacing.height(8),
          Row(
            children: [
              Icon(Boxicons.bx_check, color: contentTheme.success, size: 16),
              MySpacing.width(8),
              MyText.bodyMedium("Sales 10% Off Use Code: CODE123"),
            ],
          ),
          MySpacing.height(24),
          MyText.titleLarge(
            "Description :",
            style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          MySpacing.height(12),
          RichText(
            text: TextSpan(
              style: MyTextStyle.bodyMedium(),
              children: [
                TextSpan(
                  text:
                      'Top in sweatshirt fabric made from a cotton blend with a soft brushed inside. '
                      'Relaxed fit with dropped shoulders, long sleeves and ribbing around the neckline, cuffs and hem. '
                      'Small metal text applique. ',
                ),
                TextSpan(
                  text: 'Read more',
                  style: MyTextStyle.bodyMedium(color: contentTheme.primary),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
              ],
            ),
          ),
          MySpacing.height(24),
          MyText.titleLarge(
            "Available offers :",
            style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          MySpacing.height(12),
          _buildBankOffer(title: 'Bank Offer', description: '10% instant discount on Bank Debit Cards, up to \$30 on orders of \$50 and above'),
          SizedBox(height: 8),
          _buildBankOffer(
            title: 'Bank Offer',
            description: 'Grab our exclusive offer now and save 20% on your next purchase! Don\'t miss out, shop today!',
          ),
        ],
      ),
    );
  }

  Widget _buildBankOffer({required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Boxicons.bxs_bookmarks, color: Colors.green, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: MyTextStyle.bodyMedium(),
              children: [TextSpan(text: '$title ', style: TextStyle(fontWeight: FontWeight.w600)), TextSpan(text: description)],
            ),
          ),
        ),
      ],
    );
  }

  Widget detailState() {
    Widget details(String svgImage, String title, String subTitle) {
      return Row(
        children: [
          MyContainer(color: contentTheme.light, paddingAll: 12, borderRadiusAll: 12, child: SvgPicture.asset(svgImage)),
          MySpacing.width(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium(title, overflow: TextOverflow.ellipsis),
                MySpacing.height(8),
                MyText.bodyMedium(subTitle, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      );
    }

    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 20,
      borderRadiusAll: 12,
      child: MyFlex(
        contentPadding: false,
        children: [
          MyFlexItem(
            sizes: 'lg-3 md-6',
            child: details("assets/svg/kick_scooter.svg", "Free shipping for all orders over \$200", "Only in this week"),
          ),
          MyFlexItem(sizes: 'lg-3 md-6', child: details("assets/svg/ticket.svg", "Special discounts for customers", "Coupons up to \$ 100")),
          MyFlexItem(sizes: 'lg-3 md-6', child: details("assets/svg/gift.svg", "Free gift wrapping", "With 100 letters custom note")),
          MyFlexItem(sizes: 'lg-3 md-6', child: details("assets/svg/headphones.svg", "Expert Customer Service", "8:00 - 20:00, 7 days/wee")),
        ],
      ),
    );
  }

  Widget itemDetail() {
    Widget itemDetailWidget(String title, String subTitle) {
      return Row(children: [MyText("$title :"), MySpacing.width(8), Expanded(child: MyText(subTitle, overflow: TextOverflow.ellipsis))]);
    }

    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Items Detail",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              spacing: 16,
              children: [
                itemDetailWidget("Product Dimensions", "53.3 x 40.6 x 6.4 cm; 500 Grams"),
                itemDetailWidget("Date First Available", "22 September 2023"),
                itemDetailWidget("Department", "Men"),
                itemDetailWidget("Manufacturer", "Greensboro, NC 27401 Prospa-Pal"),
                itemDetailWidget("ASIN", "B0CJMML118"),
                itemDetailWidget("Item model number", "1137AZ"),
                itemDetailWidget("Country of Origin", "U.S.A"),
                itemDetailWidget("Manufacturer", "Suite 941 89157 Baumbach Views, Gilbertmouth, TX 31542-2135"),
                itemDetailWidget("Packer", "Apt. 726 80915 Hung Stream, Rowetown, WV 44364"),
                itemDetailWidget("Importer", "Apt. 726 80915 Hung Stream, Rowetown, WV 44364"),
                itemDetailWidget("Item Weight", "500 g"),
                itemDetailWidget("Item Dimensions LxWxH", "53.3 x 40.6 x 6.4 Centimeters"),
                itemDetailWidget("Generic Name", "T-Shirt"),
                itemDetailWidget("Best Sellers Rank", "#13 in Clothing & Accessories"),
                InkWell(
                  onTap: () {},
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MyText.bodyMedium("View more details", color: contentTheme.primary, decoration: TextDecoration.underline),
                      MySpacing.width(4),
                      Icon(Boxicons.bx_arrow_to_right, color: contentTheme.primary, size: 16),
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

  Widget topReviewFromWorld() {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      paddingAll: 0,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Top Review From World",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MyContainer.rounded(height: 60, width: 60, paddingAll: 0, child: Image.asset(Images.userAvatars[6], fit: BoxFit.cover)),
                    MySpacing.width(12),
                    MyText.titleMedium(
                      "Henny K. Mark",
                      style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                MySpacing.height(16),
                Row(children: [MyStarRating(rating: 4.5, size: 20), MySpacing.width(12), MyText.bodyMedium("Excellent Quality")]),
                MySpacing.height(16),
                MyText.bodyMedium("Reviewed in Canada on 16 November 2023", fontWeight: 700, xMuted: true),
                MySpacing.height(4),
                MyText.bodyMedium(
                  "Medium thickness. Did not shrink after wash. Good elasticity . XL size Perfectly fit for 5.10 height and heavy body. Did not fade after wash. Only for maroon colour t-shirt colour lightly gone in first wash but not faded. I bought 5 tshirt of different colours. Highly recommended in so low price.",
                ),
                MySpacing.height(16),
                Row(
                  children: [
                    InkWell(onTap: () {}, child: Row(children: [Icon(Boxicons.bx_like, size: 16), MySpacing.width(6), MyText.bodyMedium("Helpful")])),
                    MySpacing.width(12),
                    InkWell(onTap: () {}, child: MyText.bodyMedium("Report")),
                  ],
                ),
                MySpacing.height(16),
                Divider(height: 0),
                MySpacing.height(16),
                Row(
                  children: [
                    MyContainer.rounded(height: 60, width: 60, paddingAll: 0, child: Image.asset(Images.userAvatars[4], fit: BoxFit.cover)),
                    MySpacing.width(12),
                    MyText.titleMedium(
                      "Jorge Herry",
                      style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                MySpacing.height(16),
                Row(children: [MyStarRating(rating: 4.5, size: 20), MySpacing.width(12), MyText.bodyMedium("Good Quality")]),
                MySpacing.height(16),
                MyText.bodyMedium("Reviewed in U.S.A on 21 December 2023", fontWeight: 700, xMuted: true),
                MySpacing.height(4),
                MyText.bodyMedium(
                  "I liked the tshirt, it's pure cotton & skin friendly, but the size is smaller to compare standard size. best rated",
                ),
                MySpacing.height(16),
                Row(
                  children: [
                    InkWell(onTap: () {}, child: Row(children: [Icon(Boxicons.bx_like, size: 16), MySpacing.width(6), MyText.bodyMedium("Helpful")])),
                    MySpacing.width(12),
                    InkWell(onTap: () {}, child: MyText.bodyMedium("Report")),
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
