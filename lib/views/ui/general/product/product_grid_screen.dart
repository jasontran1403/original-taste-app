import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/general/product/product_grid_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_button.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_star_rating.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/models/product_grid_model.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:remixicon/remixicon.dart';

class ProductGridScreen extends StatefulWidget {
  const ProductGridScreen({super.key});

  @override
  State<ProductGridScreen> createState() => _ProductGridScreenState();
}

class _ProductGridScreenState extends State<ProductGridScreen> with UIMixin {
  ProductGridController controller = Get.put(ProductGridController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'product_grid_controller',
      builder: (controller) {
        return Layout(
          screenName: "PRODUCT GRID",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-3', child: searchTetField()),
              MyFlexItem(sizes: 'lg-9', child: filterOption()),
              MyFlexItem(sizes: 'lg-3', child: category()),
              MyFlexItem(sizes: 'lg-9', child: grid()),
            ],
          ),
        );
      },
    );
  }

  Widget searchTetField() {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 20,
      child: TextFormField(
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(12),
          isCollapsed: true,
          isDense: true,
          hintText: "Search ...",
          hintStyle: MyTextStyle.bodyMedium(),
          prefixIcon: Icon(Boxicons.bx_search_alt),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.3)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.3)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.3)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.3)),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.3)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 0.3)),
        ),
      ),
    );
  }

  Widget filterOption() {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      child: MyFlex(
        children: [
          MyFlexItem(
            sizes: 'md-6',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MyText.bodyMedium("Categories"),
                    MySpacing.width(12),
                    Icon(RemixIcons.arrow_right_s_line, size: 16),
                    MySpacing.width(12),
                    MyText.bodyMedium("All Product"),
                  ],
                ),
                MySpacing.height(8),
                Row(
                  children: [
                    MyText.bodyMedium("Showing all"),
                    MySpacing.width(12),
                    MyText.bodyMedium("5,786"),
                    MySpacing.width(12),
                    MyText.bodyMedium("items results"),
                  ],
                ),
              ],
            ),
          ),
          MyFlexItem(
            sizes: 'md-6',
            child: Wrap(
              runAlignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              alignment: WrapAlignment.end,
              spacing: 12,
              children: [
                MyContainer.bordered(
                  borderRadiusAll: 12,
                  paddingAll: 12,
                  borderColor: contentTheme.dark,
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Boxicons.bx_cog, size: 18), MySpacing.width(8), MyText.bodyMedium("More Setting")],
                  ),
                ),
                MyContainer.bordered(
                  borderRadiusAll: 12,
                  paddingAll: 12,
                  borderColor: contentTheme.dark,
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Boxicons.bx_filter_alt, size: 18), MySpacing.width(8), MyText.bodyMedium("More Setting")],
                  ),
                ),
                MyContainer(
                  paddingAll: 12,
                  color: contentTheme.success,
                  borderRadiusAll: 12,
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Boxicons.bx_plus, size: 18, color: contentTheme.onSuccess),
                      MySpacing.width(8),
                      MyText.bodyMedium("New Product", color: contentTheme.onSuccess),
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

  Widget category() {
    Widget categories() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            onTap: () => controller.toggleCategoryVisibility(),
            borderRadiusAll: 12,
            paddingAll: 12,
            color: contentTheme.light,
            child: Row(
              children: [
                Expanded(child: MyText.titleMedium("Categories")),
                Icon(controller.showCategories ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
          if (controller.showCategories) MySpacing.height(12),
          if (controller.showCategories)
            ...controller.categories.keys.map((category) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Theme(
                    data: ThemeData(visualDensity: VisualDensity.compact),
                    child: Checkbox(
                      visualDensity: VisualDensity.compact,
                      activeColor: contentTheme.primary,
                      value: controller.categories[category],
                      onChanged: (value) => controller.toggleCategory(category, value),
                    ),
                  ),
                  MySpacing.width(12),
                  Expanded(child: MyText.bodyMedium(category)),
                ],
              );
            }),
        ],
      );
    }

    Widget productPrice() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            onTap: () => setState(() => controller.showPrices = !controller.showPrices),
            borderRadiusAll: 12,
            paddingAll: 12,
            color: contentTheme.light,
            child: Row(
              children: [
                Expanded(child: MyText.titleMedium("Price")),
                Icon(controller.showPrices ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
          if (controller.showPrices) MySpacing.height(12),
          if (controller.showPrices) ...[
            ...controller.priceOptions.keys.map((key) {
              return Row(
                children: [
                  Theme(
                    data: ThemeData(),
                    child: Checkbox(
                      visualDensity: VisualDensity.compact,
                      activeColor: contentTheme.primary,
                      value: controller.priceOptions[key],
                      onChanged: (value) => controller.togglePrice(key, value),
                    ),
                  ),
                  Expanded(child: MyText.bodyMedium(key)),
                ],
              );
            }),

            MySpacing.height(12),
            MyText.bodyMedium("Custom Price Range :"),
            MySpacing.height(12),
            RangeSlider(
              values: controller.currentRangeValues,
              max: 100,
              divisions: 100,
              activeColor: contentTheme.primary,
              inactiveColor: contentTheme.primary,
              labels: RangeLabels(controller.currentRangeValues.start.round().toString(), controller.currentRangeValues.end.round().toString()),
              onChanged: (RangeValues values) {
                setState(() => controller.currentRangeValues = values);
              },
            ),
            Row(
              children: [
                Expanded(
                  child: MyContainer.bordered(
                    borderRadiusAll: 12,
                    paddingAll: 8,
                    child: Center(child: MyText.bodyMedium("\$${controller.currentRangeValues.start.round()}")),
                  ),
                ),
                MySpacing.width(20),
                MyText.titleMedium("to", fontWeight: 700),
                MySpacing.width(20),
                Expanded(
                  child: MyContainer.bordered(
                    borderRadiusAll: 12,
                    paddingAll: 8,
                    child: Center(child: MyText.bodyMedium("\$${controller.currentRangeValues.end.round()}")),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    }

    Widget gender() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            onTap: () => setState(() => controller.showGenderOptions = !controller.showGenderOptions),
            borderRadiusAll: 12,
            paddingAll: 12,
            color: contentTheme.light,
            child: Row(
              children: [
                Expanded(child: MyText.titleMedium("Gender")),
                Icon(controller.showGenderOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),

          if (controller.showGenderOptions) ...[
            MySpacing.height(8),
            ...controller.genderOptions.keys.map((key) {
              return Row(
                children: [
                  Theme(
                    data: ThemeData(),
                    child: Checkbox(
                      activeColor: contentTheme.primary,
                      visualDensity: VisualDensity.compact,
                      value: controller.genderOptions[key],
                      onChanged: (value) => controller.toggleGender(key, value),
                    ),
                  ),
                  Expanded(child: MyText.bodyMedium(key)),
                ],
              );
            }),
          ],
        ],
      );
    }

    Widget sizeAndFit() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            onTap: () => setState(() => controller.showSizeOptions = !controller.showSizeOptions),
            borderRadiusAll: 12,
            paddingAll: 12,
            color: contentTheme.light,
            child: Row(
              children: [
                Expanded(child: MyText.titleMedium("Size")),
                Icon(controller.showSizeOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),
          if (controller.showSizeOptions) ...[
            MySpacing.height(8),
            MyText.bodyMedium('"For better results, select gender and category"'),
            MySpacing.height(12),
            ...controller.sizeOptions.keys.map((key) {
              return Row(
                children: [
                  Theme(
                    data: ThemeData(),
                    child: Checkbox(
                      visualDensity: VisualDensity.compact,
                      activeColor: contentTheme.primary,
                      value: controller.sizeOptions[key],
                      onChanged: (value) => controller.toggleSize(key, value),
                    ),
                  ),
                  MySpacing.width(8),
                  Expanded(child: MyText.bodyMedium(key)),
                ],
              );
            }),
            MyButton.text(
              onPressed: () {},
              padding: EdgeInsets.zero,
              splashColor: Colors.transparent,
              msPadding: WidgetStatePropertyAll(EdgeInsetsGeometry.zero),
              child: MyText.bodyMedium("More", decoration: TextDecoration.underline),
            ),
          ],
        ],
      );
    }

    Widget rating() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyContainer(
            onTap: () => setState(() => controller.showRatingOptions = !controller.showRatingOptions),
            borderRadiusAll: 12,
            paddingAll: 12,
            color: contentTheme.light,
            child: Row(
              children: [
                Expanded(child: MyText.titleMedium("Rating")),
                Icon(controller.showRatingOptions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16),
              ],
            ),
          ),

          if (controller.showRatingOptions) ...[
            MySpacing.height(8),
            ...controller.ratingOptions.keys.map((key) {
              return Row(
                children: [
                  Theme(
                    data: ThemeData(),
                    child: Checkbox(
                      activeColor: contentTheme.primary,
                      visualDensity: VisualDensity.compact,
                      value: controller.ratingOptions[key],
                      onChanged: (value) => controller.toggleRating(key, value),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text(key.split(" ")[0]),
                        const SizedBox(width: 4),
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Flexible(child: MyText.bodyMedium(key.split(" ").skip(1).join(" "))),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      );
    }

    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [categories(), productPrice(), gender(), sizeAndFit(), rating()],
      ),
    );
  }

  Widget grid() {
    return GridView.builder(
      itemCount: controller.productGrid.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          mainAxisExtent: 450,
      ),
      itemBuilder: (context, index) {
        ProductGridModel grid = controller.productGrid[index];
        return MyCard(
          paddingAll: 0,
          borderRadiusAll: 8,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shadow: MyShadow(position: MyShadowPosition.bottom, elevation: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: MyContainer.rounded(
                  paddingAll: 0,
                  borderRadiusAll: 8,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  height: 270,
                  child: Image.asset(grid.image, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: MySpacing.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleMedium(grid.name,maxLines: 1,),
                    MySpacing.height(12),
                    Row(
                      children: [
                        MyStarRating(rating: grid.rating, size: 20),
                        MySpacing.width(12),
                        Expanded(child: MyText.bodyMedium("${grid.rating} (${grid.review} Review)",maxLines: 1,)),
                      ],
                    ),
                    MySpacing.height(12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        MyText.bodyLarge("\$${grid.originalPrice}", decoration: TextDecoration.lineThrough, xMuted: true, fontWeight: 700),
                        MySpacing.width(12),
                        MyText.bodyLarge("\$${grid.discountedPrice}", fontWeight: 700, muted: true),
                        MySpacing.width(12),
                        Expanded(child: MyText.bodyMedium("(${grid.discountPercentage}% off)",maxLines: 1,)),
                      ],
                    ),
                    MySpacing.height(12),
                    Row(
                      children: [
                        PopupMenuButton(
                          onSelected: controller.onSelectedOption,
                          itemBuilder: (BuildContext context) {
                            return ["Download", "Export", "Import"].map((behavior) {
                              return PopupMenuItem(
                                value: behavior,
                                height: 32,
                                child: MyText.bodySmall(behavior.toString(), color: theme.colorScheme.onSurface, fontWeight: 600),
                              );
                            }).toList();
                          },
                          child: MyContainer.bordered(
                            padding: MySpacing.xy(16, 12),
                            borderRadiusAll: 12,
                            borderColor: contentTheme.primary,
                            color: contentTheme.primary.withValues(alpha: 0.15),
                            child: Icon(Boxicons.bx_dots_horizontal, size: 16, color: contentTheme.primary),
                          ),
                        ),
                        MySpacing.width(12),
                        Expanded(
                          child: MyContainer.bordered(
                            borderRadiusAll: 12,
                            padding: MySpacing.xy(16, 12),
                            borderColor: contentTheme.dark,
                            border: Border.all(width: 0.5, color: contentTheme.dark),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Boxicons.bx_cart, size: 16), MySpacing.width(12), Expanded(child: MyText.bodyMedium("Add to cart", fontWeight: 600,maxLines: 1,))],
                            ),
                          ),
                        ),
                      ],
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
}
