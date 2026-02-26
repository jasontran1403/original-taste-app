import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/other/coupons/coupons_add_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_button.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/views/layout/layout.dart';

class CouponsAddScreen extends StatefulWidget {
  const CouponsAddScreen({super.key});

  @override
  State<CouponsAddScreen> createState() => _CouponsAddScreenState();
}

class _CouponsAddScreenState extends State<CouponsAddScreen> with UIMixin {
  CouponsAddController controller = Get.put(CouponsAddController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "COUPONS ADD",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-6', child: Column(children: [couponsStatus(), MySpacing.height(12), dateSchedule()])),
              MyFlexItem(sizes: 'lg-6', child: couponInformation()),
            ],
          ),
        );
      },
    );
  }

  Widget couponsStatus() {
    return MyCard(
      shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
      paddingAll: 0,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: MySpacing.all(24), child: MyText.titleMedium('Coupon Status')),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(12),
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<CouponStatus>(
                    title: MyText.bodyMedium('Active'),
                    visualDensity: VisualDensity.compact,
                    contentPadding: MySpacing.zero,
                    value: CouponStatus.active,
                    groupValue: controller.status,
                    onChanged: (CouponStatus? value) {
                      setState(() {
                        controller.status = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<CouponStatus>(
                    title: MyText.bodyMedium('In Active'),
                    visualDensity: VisualDensity.compact,
                    contentPadding: MySpacing.zero,
                    value: CouponStatus.inactive,
                    groupValue: controller.status,
                    onChanged: (CouponStatus? value) {
                      setState(() {
                        controller.status = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<CouponStatus>(
                    title: MyText.bodyMedium('Future Plan'),
                    visualDensity: VisualDensity.compact,
                    contentPadding: MySpacing.zero,
                    value: CouponStatus.futurePlan,
                    groupValue: controller.status,
                    onChanged: (CouponStatus? value) {
                      setState(() {
                        controller.status = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget dateSchedule() {
    return MyCard(
      shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
      paddingAll: 0,
      borderRadiusAll: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: MySpacing.all(24), child: MyText.titleMedium('Date Schedule')),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium('Start Date'),
                MySpacing.height(8),
                InkWell(
                  onTap: () => controller.pickDate(isStartDate: true),
                  child: AbsorbPointer(
                    child: TextFormField(
                      style: MyTextStyle.labelMedium(),
                      decoration: InputDecoration(
                        hintText: 'dd-mm-yyyy',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 0.5, color: contentTheme.secondary),
                        ),
                        isDense: true,
                        isCollapsed: true,
                        contentPadding: MySpacing.all(16),
                      ),
                      controller: TextEditingController(
                        text: controller.startDate != null ? controller.dateFormat.format(controller.startDate!) : '',
                      ),
                      readOnly: true,
                    ),
                  ),
                ),
                MySpacing.height(20),
                MyText.bodyMedium('End Date'),
                MySpacing.height(4),
                InkWell(
                  onTap: () => controller.pickDate(isStartDate: false),
                  child: AbsorbPointer(
                    child: TextFormField(
                      style: MyTextStyle.labelMedium(),
                      decoration: InputDecoration(
                        hintText: 'dd-mm-yyyy',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(width: 0.5, color: contentTheme.secondary),
                        ),
                        isDense: true,
                        isCollapsed: true,
                        contentPadding: MySpacing.all(16),
                      ),
                      controller: TextEditingController(text: controller.endDate != null ? controller.dateFormat.format(controller.endDate!) : ''),
                      readOnly: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget couponInformation() {
    return MyCard(
      shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
      paddingAll: 0,
      borderRadiusAll: 12,
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: MySpacing.all(20), child: MyText.titleMedium('Coupon Information')),
            Divider(height: 0),
            Padding(
              padding: MySpacing.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    style: MyTextStyle.labelMedium(),
                    controller: controller.codeController,
                    decoration: InputDecoration(
                      labelText: 'Coupon Code',
                      hintText: 'Enter code',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(width: 0.5, color: contentTheme.secondary),
                      ),
                      isDense: true,
                      isCollapsed: true,
                      contentPadding: MySpacing.all(16),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a coupon code' : null,
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: controller.selectedCategory,
                    style: MyTextStyle.labelMedium(),
                    decoration: InputDecoration(
                      labelText: 'Discount Products',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(width: 0.5, color: contentTheme.secondary),
                      ),
                      isDense: true,
                      isCollapsed: true,
                      contentPadding: MySpacing.all(16),
                    ),
                    items: controller.categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                    onChanged: (value) => setState(() => controller.selectedCategory = value),
                    validator: (value) => value == null ? 'Please select a category' : null,
                  ),
                  SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: controller.selectedCountry,
                    style: MyTextStyle.labelMedium(),
                    decoration: InputDecoration(
                      labelText: 'Discount Country',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(width: 0.5, color: contentTheme.secondary),
                      ),
                      isDense: true,
                      isCollapsed: true,
                      contentPadding: MySpacing.all(16),
                    ),
                    items: controller.countries.map((country) => DropdownMenuItem(value: country, child: Text(country))).toList(),
                    onChanged: (value) => setState(() => controller.selectedCountry = value),
                    validator: (value) => value == null ? 'Please select a country' : null,
                  ),
                  SizedBox(height: 16),

                  TextFormField(
                    style: MyTextStyle.labelMedium(),
                    controller: controller.limitController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Coupon Limit',
                      hintText: 'Enter limit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(width: 0.5, color: contentTheme.secondary),
                      ),
                      isDense: true,
                      isCollapsed: true,
                      contentPadding: MySpacing.all(16),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Enter a valid limit' : null,
                  ),
                  SizedBox(height: 24),
                  Text('Coupon Types', style: Theme.of(context).textTheme.titleMedium),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile<String>(
                        value: 'Free Shipping',
                        groupValue: controller.couponType,
                        title: Text('Free Shipping'),
                        onChanged: (value) => setState(() => controller.couponType = value),
                      ),
                      RadioListTile<String>(
                        value: 'Percentage',
                        groupValue: controller.couponType,
                        title: Text('Percentage'),
                        onChanged: (value) => setState(() => controller.couponType = value),
                      ),
                      RadioListTile<String>(
                        value: 'Fixed Amount',
                        groupValue: controller.couponType,
                        title: Text('Fixed Amount'),
                        onChanged: (value) => setState(() => controller.couponType = value),
                      ),
                    ],
                  ),
                  MySpacing.height(16),
                  TextFormField(
                    controller: controller.discountValueController,
                    decoration: InputDecoration(
                      labelText: 'Discount Value',
                      hintText: 'Enter value',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(width: 0.5, color: contentTheme.secondary),
                      ),
                      isDense: true,
                      isCollapsed: true,
                      contentPadding: MySpacing.all(16),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Enter a discount value' : null,
                  ),
                  MySpacing.height(24),
                  MyButton(
                      onPressed: controller.submitForm,
                      backgroundColor: contentTheme.primary,
                      borderRadiusAll: 12,
                      padding: MySpacing.all(16),
                      elevation: 0,
                      child: MyText.labelMedium("Create Coupon",color: contentTheme.onPrimary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
