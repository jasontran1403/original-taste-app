import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/category/category_list_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> with UIMixin {
  CategoryListController controller = Get.put(CategoryListController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'category_list_controller',
      builder: (controller) {
        return Layout(
          screenName: "CATEGORY LIST",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-3 md-6', child: states("assets/product/p-1.png", "Fashion Categories")),
              MyFlexItem(sizes: 'lg-3 md-6', child: states("assets/product/p-6.png", "Electronics Headphone")),
              MyFlexItem(sizes: 'lg-3 md-6', child: states("assets/product/p-7.png", "Foot Wares")),
              MyFlexItem(sizes: 'lg-3 md-6', child: states("assets/product/p-9.png", "Eye Ware & Sunglass")),
              MyFlexItem(child: categoryList()),
            ],
          ),
        );
      },
    );
  }

  Widget states(String image, String title) {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 20,
      child: Column(
        children: [
          MyContainer(borderRadiusAll: 12, color: contentTheme.light, height: 110, width: double.infinity, child: Image.asset(image)),
          MySpacing.height(12),
          MyText.titleMedium(title, fontWeight: 700),
        ],
      ),
    );
  }

  Widget categoryList() {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Row(
              children: [
                Expanded(
                  child: MyText.titleMedium(
                    "All Categories List",
                    style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                MyContainer(
                  onTap: () {},
                  color: contentTheme.primary,
                  paddingAll: 8,
                  borderRadiusAll: 12,
                  child: MyText.bodyMedium("Add Product", color: contentTheme.onPrimary),
                ),
                MySpacing.width(12),
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
                    padding: MySpacing.xy(12, 8),
                    borderRadiusAll: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        MyText.labelMedium(controller.selectedOption.toString()),
                        MySpacing.width(4),
                        Icon(Boxicons.bx_chevron_down, size: 16, color: theme.colorScheme.onSurface),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortAscending: true,
              onSelectAll: (value) => controller.toggleSelectAll(value),
              headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
              dataRowMaxHeight: 90,
              columnSpacing: 115,
              showBottomBorder: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              columns: [
                DataColumn(
                  label: Theme(
                    data: ThemeData(),
                    child: Checkbox(
                      value: controller.isAllSelected,
                      activeColor: contentTheme.primary,
                      visualDensity: VisualDensity.compact,
                      onChanged: (value) => controller.toggleSelectAll(value),
                    ),
                  ),
                ),
                DataColumn(label: MyText.labelLarge('Categories', fontWeight: 700)),
                DataColumn(label: MyText.labelLarge('Starting Price', fontWeight: 700)),
                DataColumn(label: MyText.labelLarge('Create by', fontWeight: 700)),
                DataColumn(label: MyText.labelLarge('ID', fontWeight: 700)),
                DataColumn(label: MyText.labelLarge('Product Stock', fontWeight: 700)),
                DataColumn(label: MyText.labelLarge('Action', fontWeight: 700)),
              ],
              rows: List.generate(controller.categoryList.length, (index) {
                final data = controller.categoryList[index];
                return DataRow(
                  cells: [
                    DataCell(
                      Theme(
                        data: ThemeData(),
                        child: Checkbox(
                          value: controller.selectedCheckboxes[index],
                          activeColor: contentTheme.primary,
                          visualDensity: VisualDensity.compact,
                          onChanged: (value) => controller.toggleCheckbox(index, value),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          MyContainer(
                            height: 56,
                            width: 56,
                            paddingAll: 0,
                            borderRadiusAll: 12,
                            color: contentTheme.light,
                            child: Image.asset(data.image),
                          ),
                          MySpacing.width(12),
                          MyText.bodyMedium(data.category),
                        ],
                      ),
                    ),
                    DataCell(MyText.bodyMedium("\$${data.price}", fontWeight: 600)),
                    DataCell(MyText.bodyMedium(data.createdBy, fontWeight: 600)),
                    DataCell(MyText.bodyMedium(data.categoryId, fontWeight: 600)),
                    DataCell(MyText.bodyMedium(data.stock.toString(), fontWeight: 600)),
                    DataCell(
                      Row(
                        spacing: 12,
                        children: [
                          MyContainer(
                            color: contentTheme.secondary.withValues(alpha: 0.1),
                            padding: MySpacing.xy(12, 8),
                            borderRadiusAll: 8,
                            child: SvgPicture.asset(
                              'assets/svg/eye.svg',
                              height: 16,
                              width: 16,
                              colorFilter: ColorFilter.mode(contentTheme.secondary, BlendMode.srcIn),
                            ),
                          ),
                          MyContainer(
                            color: contentTheme.primary.withValues(alpha: 0.1),
                            padding: MySpacing.xy(12, 8),
                            borderRadiusAll: 8,
                            child: SvgPicture.asset('assets/svg/pen_2.svg', height: 16, width: 16),
                          ),
                          MyContainer(
                            color: contentTheme.danger.withValues(alpha: 0.1),
                            padding: MySpacing.xy(12, 8),
                            borderRadiusAll: 8,
                            child: SvgPicture.asset(
                              'assets/svg/trash_bin_2.svg',
                              height: 16,
                              width: 16,
                              colorFilter: ColorFilter.mode(contentTheme.danger, BlendMode.srcIn),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
