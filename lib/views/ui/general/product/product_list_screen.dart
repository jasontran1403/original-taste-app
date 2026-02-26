import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/product/product_list_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/views/layout/layout.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> with UIMixin {
  ProductListController controller = Get.put(ProductListController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'product_list_controller',
      builder: (controller) {
        return Layout(
          screenName: "PRODUCT LIST",
          child: MyCard(
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
                          "All Product List",
                          style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily,fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      MyContainer(
                        color: contentTheme.primary,
                        borderRadiusAll: 8,
                        paddingAll: 8,
                        child: MyText.labelMedium("Add Product", fontWeight: 600, color: contentTheme.onPrimary),
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
                if (controller.products.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      sortAscending: true,
                      onSelectAll: (value) => controller.toggleSelectAll(value),
                      headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
                      dataRowMaxHeight: 70,
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
                        DataColumn(label: MyText.labelLarge('Product Name & Size', fontWeight: 700)),
                        DataColumn(label: MyText.labelLarge('Price', fontWeight: 700)),
                        DataColumn(label: MyText.labelLarge('Stock', fontWeight: 700)),
                        DataColumn(label: MyText.labelLarge('Category', fontWeight: 700)),
                        DataColumn(label: MyText.labelLarge('Rating', fontWeight: 700)),
                        DataColumn(label: MyText.labelLarge('Action', fontWeight: 700)),
                      ],
                      rows: List.generate(controller.products.length, (index) {
                        final data = controller.products[index];
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MyText.bodyMedium(data.name),
                                      MySpacing.height(8),
                                      Row(
                                        children: [
                                          MyText.bodyMedium("Size : "),
                                          Wrap(
                                            spacing: 4,
                                            runSpacing: 4,
                                            children: List.generate(data.sizes.length, (i) {
                                              return MyText.bodySmall('${data.sizes[i]}${i != data.sizes.length - 1 ? ',' : ''}', fontWeight: 600);
                                            }),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            DataCell(MyText.bodyMedium("\$${data.price}", fontWeight: 600)),
                            DataCell(
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText.bodyMedium("${data.stock} Item Left", fontWeight: 600),
                                  MySpacing.height(4),
                                  MyText.bodyMedium("${data.sold} Sold", fontWeight: 600),
                                ],
                              ),
                            ),
                            DataCell(MyText.bodyMedium(data.category, fontWeight: 600)),
                            DataCell(
                              Row(
                                children: [
                                  MyContainer(
                                    padding: MySpacing.xy(8, 6),
                                    color: contentTheme.secondary.withValues(alpha: 0.2),
                                    child: Row(
                                      children: [
                                        Icon(Boxicons.bxs_star, size: 16, color: contentTheme.warning),
                                        MySpacing.width(8),
                                        MyText.labelMedium(data.rating.toString(),fontWeight: 700,),
                                      ],
                                    ),
                                  ),
                                  MySpacing.width(12),
                                  MyText.bodyMedium("${data.reviews} Reviews", fontWeight: 600),
                                ],
                              ),
                            ),
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
          ),
        );
      },
    );
  }
}
