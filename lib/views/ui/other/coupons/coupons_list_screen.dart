import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/other/coupons/coupons_list_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/models/coupons_list_model.dart';
import 'package:original_taste/views/layout/layout.dart';

class CouponsListScreen extends StatefulWidget {
  const CouponsListScreen({super.key});

  @override
  State<CouponsListScreen> createState() => _CouponsListScreenState();
}

class _CouponsListScreenState extends State<CouponsListScreen> with UIMixin {
  CouponsListController controller = Get.put(CouponsListController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "COUPONS LIST",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-3', child: firstStateCard()),
              MyFlexItem(sizes: 'lg-3', child: secondStateCard()),
              MyFlexItem(sizes: 'lg-6', child: thirdStateCard()),
              MyFlexItem(child: allProductList()),
            ],
          ),
        );
      },
    );
  }

  Widget firstStateCard() {
    return MyContainer(
      borderRadiusAll: 12,
      paddingAll: 24,
      color: contentTheme.primary.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("4 Coupons", fontWeight: 700),
          MySpacing.height(4),
          MyText.bodyMedium("Small nice summer coupons pack", fontWeight: 400),
          MySpacing.height(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [MyText.titleLarge("\$140.00", color: contentTheme.primary), MySpacing.height(12), MyText.bodyMedium("Duration: 1 year")],
                ),
              ),
              MyContainer(
                onTap: () {},
                color: contentTheme.primary,
                borderRadiusAll: 12,
                paddingAll: 12,
                child: MyText.bodyMedium("Buy Now", color: contentTheme.onPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget secondStateCard() {
    return MyContainer(
      borderRadiusAll: 12,
      paddingAll: 24,
      color: contentTheme.info.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.titleMedium("8 Coupons", fontWeight: 700),
          MySpacing.height(4),
          MyText.bodyMedium("Medium nice summer coupons pack", fontWeight: 400),
          MySpacing.height(12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [MyText.titleLarge("\$235.00", color: contentTheme.info), MySpacing.height(12), MyText.bodyMedium("Duration: 1 year")],
                ),
              ),
              MyContainer(
                onTap: () {},
                color: contentTheme.info,
                borderRadiusAll: 12,
                paddingAll: 12,
                child: MyText.bodyMedium("Buy Now", color: contentTheme.onPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget thirdStateCard() {
    return MyContainer(
      borderRadiusAll: 12,
      color: contentTheme.primary.withValues(alpha: 0.2),
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset('assets/svg/bag_smile_bold.svg', height: 50),
              MySpacing.width(20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.titleLarge("30% Special discounts for customers", fontWeight: 700, muted: true),
                  MySpacing.height(4),
                  MyText.bodyMedium("25 November - 2 December"),
                ],
              ),
            ],
          ),
          MyContainer(
            onTap: () {},
            color: contentTheme.primary,
            borderRadiusAll: 12,
            paddingAll: 12,
            child: MyText.bodyMedium("View Plan", color: contentTheme.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget allProductList() {
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
                    "All Product List",
                    style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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
          if (controller.couponList.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator()))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: true,
                onSelectAll: (value) => controller.toggleSelectAll(value),
                headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
                dataRowMaxHeight: 70,
                columnSpacing: 70,
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
                  DataColumn(label: MyText.labelLarge('Product Name & Type', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Price', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Discount', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Code', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Start Date', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('End Date', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Status', fontWeight: 700)),
                  DataColumn(label: MyText.labelLarge('Action', fontWeight: 700)),
                ],
                rows: List.generate(controller.couponList.length, (index) {
                  CouponsListModel data = controller.couponList[index];
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
                              children: [MyText.bodyMedium(data.name), MySpacing.height(8), MyText.bodyMedium(data.category)],
                            ),
                          ],
                        ),
                      ),
                      DataCell(MyText.bodyMedium("\$${data.price}", fontWeight: 600)),
                      DataCell(MyText.bodyMedium("${data.discount}", fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.sku, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.startDate, fontWeight: 600)),
                      DataCell(MyText.bodyMedium(data.endDate, fontWeight: 600)),
                      DataCell(
                        MyContainer(
                          padding: MySpacing.xy(8, 4),
                          borderRadiusAll: 8,
                          color: data.status == 'Active' ? contentTheme.success.withValues(alpha: 0.1) : contentTheme.danger.withValues(alpha: 0.1),
                          child: MyText.bodyMedium(
                            data.status,
                            fontWeight: 600,
                            color: data.status == 'Active' ? contentTheme.success : contentTheme.danger,
                          ),
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
    );
  }
}
