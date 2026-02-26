import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/attribute/attribute_edit_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/views/layout/layout.dart';

class AttributeEditScreen extends StatefulWidget {
  const AttributeEditScreen({super.key});

  @override
  State<AttributeEditScreen> createState() => _AttributeEditScreenState();
}

class _AttributeEditScreenState extends State<AttributeEditScreen> with UIMixin {
  AttributeEditController controller = Get.put(AttributeEditController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'attribute_edit_controller',
      builder: (controller) {
        return Layout(
          screenName: "ATTRIBUTE EDIT",
          child: MyCard(
             shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
            borderRadiusAll: 12,
            paddingAll: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: MySpacing.all(20),
                  child: MyText.titleMedium(
                    "Edit Attribute",
                    style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
                  ),
                ),
                Divider(height: 0),
                Padding(padding: MySpacing.all(20), child: attributeInformation()),
                Divider(height: 0),
                Padding(
                  padding: MySpacing.all(20),
                  child: MyContainer(
                    onTap: () {},
                    paddingAll: 12,
                    borderRadiusAll: 12,
                    color: contentTheme.primary,
                    child: MyText.bodyMedium("Edit Change", color: contentTheme.onPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget attributeInformation() {
    return MyFlex(
      contentPadding: false,
      children: [
        MyFlexItem(
          sizes: 'lg-6',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.bodyMedium("Attribute Variant"),
              MySpacing.height(8),
              TextFormField(
                controller: controller.attributeVariantController,
                style: MyTextStyle.bodyMedium(),
                decoration: InputDecoration(
                  border: outlineInputBorder,
                  focusedErrorBorder: outlineInputBorder,
                  errorBorder: outlineInputBorder,
                  focusedBorder: outlineInputBorder,
                  enabledBorder: outlineInputBorder,
                  disabledBorder: outlineInputBorder,
                  contentPadding: MySpacing.all(16),
                  isDense: true,
                  isCollapsed: true,
                  hintText: "Enter Name",
                  hintStyle: MyTextStyle.bodyMedium(),
                ),
              ),
            ],
          ),
        ),
        MyFlexItem(
          sizes: 'lg-6',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.bodyMedium("Attribute Value"),
              MySpacing.height(8),
              TextFormField(
                controller: controller.attributeValueController,
                style: MyTextStyle.bodyMedium(),
                decoration: InputDecoration(
                  border: outlineInputBorder,
                  focusedErrorBorder: outlineInputBorder,
                  errorBorder: outlineInputBorder,
                  focusedBorder: outlineInputBorder,
                  enabledBorder: outlineInputBorder,
                  disabledBorder: outlineInputBorder,
                  contentPadding: MySpacing.all(16),
                  isDense: true,
                  isCollapsed: true,
                  hintText: "Enter Value",
                  hintStyle: MyTextStyle.bodyMedium(),
                ),
              ),
            ],
          ),
        ),
        MyFlexItem(
          sizes: 'lg-6',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.bodyMedium("Attribute ID"),
              MySpacing.height(8),
              TextFormField(
                controller: controller.attributeIDController,
                style: MyTextStyle.bodyMedium(),
                decoration: InputDecoration(
                  border: outlineInputBorder,
                  focusedErrorBorder: outlineInputBorder,
                  errorBorder: outlineInputBorder,
                  focusedBorder: outlineInputBorder,
                  enabledBorder: outlineInputBorder,
                  disabledBorder: outlineInputBorder,
                  contentPadding: MySpacing.all(16),
                  isDense: true,
                  isCollapsed: true,
                  hintText: "Enter ID",
                  hintStyle: MyTextStyle.bodyMedium(),
                ),
              ),
            ],
          ),
        ),
        MyFlexItem(
          sizes: 'lg-6',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.bodyMedium("Option"),
              MySpacing.height(8),
              DropdownButtonFormField<String>(
                dropdownColor: contentTheme.light,
                decoration: InputDecoration(
                  border: outlineInputBorder,
                  focusedErrorBorder: outlineInputBorder,
                  errorBorder: outlineInputBorder,
                  focusedBorder: outlineInputBorder,
                  enabledBorder: outlineInputBorder,
                  disabledBorder: outlineInputBorder,
                  contentPadding: MySpacing.all(12),
                  isDense: true,
                  isCollapsed: true,
                ),
                hint: MyText.bodyMedium("Option"),
                value: controller.selectedCategory,
                onChanged: (value) => setState(() => controller.selectedCategory = value),
                validator: (value) => value == null ? 'Please select a Option' : null,
                items:
                    controller.categories.map((category) {
                      return DropdownMenuItem(value: category, child: MyText.bodyMedium(category));
                    }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
