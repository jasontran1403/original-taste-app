import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/users/customers/customer_list_controller.dart';
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

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> with UIMixin {
  final CustomerListController controller = Get.put(CustomerListController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "CUSTOMER LIST",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-3', child: state('assets/svg/users_group_two_rounded.svg', 'All Customer', '+22.63K', '34.4%')),
              MyFlexItem(sizes: 'lg-3', child: state('assets/svg/users_group_two_rounded.svg', 'Orders', '+4.5k', '8.1%')),
              MyFlexItem(sizes: 'lg-3', child: state('assets/svg/users_group_two_rounded.svg', 'Services Request', '+1.03k', '12.6%')),
              MyFlexItem(sizes: 'lg-3', child: state('assets/svg/users_group_two_rounded.svg', 'Invoice & Payment', '\$38,908.00', '45.9%')),
              MyFlexItem(
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
                                "All Customer List",
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
                          dataRowMaxHeight: 90,
                          columnSpacing: 90,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          columns: [
                            DataColumn(label: MyText.labelLarge('Customer Name', fontWeight: 700)),
                            DataColumn(label: MyText.labelLarge('Invoice ID', fontWeight: 700)),
                            DataColumn(label: MyText.labelLarge('Status', fontWeight: 700)),
                            DataColumn(label: MyText.labelLarge('Total Amount', fontWeight: 700)),
                            DataColumn(label: MyText.labelLarge('Amount Due', fontWeight: 700)),
                            DataColumn(label: MyText.labelLarge('Due Date', fontWeight: 700)),
                            DataColumn(label: MyText.labelLarge('Payment Method', fontWeight: 700)),
                            DataColumn(label: MyText.labelLarge('Action', fontWeight: 700)),
                          ],
                          rows: List.generate(controller.customerList.length, (index) {
                            final data = controller.customerList[index];
                            return DataRow(
                              cells: [
                               DataCell(
                                  Row(
                                    children: [
                                      MyContainer.rounded(
                                        height: 44,
                                        width: 44,
                                        paddingAll: 0,
                                        child: Image.asset(data.avatar),
                                      ),
                                      MySpacing.width(12),
                                      MyText.bodyMedium(data.name),
                                    ],
                                  ),
                                ),
                                DataCell(MyText.bodyMedium("#${data.customerId}", fontWeight: 600)),
                                DataCell(MyText.bodyMedium(data.status, fontWeight: 600)),
                                DataCell(MyText.bodyMedium(data.amountPaid, fontWeight: 600)),
                                DataCell(MyText.bodyMedium(data.amountDue.toString(), fontWeight: 600)),
                                DataCell(MyText.bodyMedium(data.date.toString(), fontWeight: 600)),
                                DataCell(MyText.bodyMedium(data.paymentMethod.toString(), fontWeight: 600)),
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
              ),
            ],
          ),
        );
      },
    );
  }

  Widget state(String svgImage, String title, String count, String percentage) {
    return MyCard(
      borderRadiusAll: 12,
      paddingAll: 20,
      shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyContainer(color: contentTheme.primary.withValues(alpha: 0.2), child: SvgPicture.asset(svgImage)),
              MySpacing.width(12),
              MyText.titleMedium(title, fontWeight: 600),
            ],
          ),
          MySpacing.height(12),
          Row(
            children: [
              Expanded(child: MyText.bodyLarge(count, fontWeight: 700, xMuted: true)),
              MyContainer(
                paddingAll: 4,
                borderRadiusAll: 4,
                color: contentTheme.success.withValues(alpha: 0.2),
                child: MyText.bodySmall(percentage, color: contentTheme.success),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
