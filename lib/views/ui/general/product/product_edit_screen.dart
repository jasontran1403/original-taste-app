import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/product/product_edit_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_list_extension.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/helper/widgets/responsive.dart';
import 'package:original_taste/views/layout/layout.dart';

class ProductEditScreen extends StatefulWidget {
  const ProductEditScreen({super.key});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> with UIMixin {
  ProductEditController controller = Get.put(ProductEditController());

  final Map<String, Color> colorMap = {
    "dark": Colors.black,
    "yellow": Colors.yellow,
    "white": Colors.white,
    "red": Colors.red,
    "green": Colors.green,
    "blue": Colors.blue,
    "sky": Colors.lightBlue,
    "gray": Colors.grey,
  };
  @override
  late OutlineInputBorder outlineInputBorder;

  @override
  void initState() {
    outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.4)),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'product_create_controller',
      builder: (controller) {
        return Layout(
          screenName: "CREATE PRODUCT",
          child: MyFlex(
            children: [
              MyFlexItem(
                sizes: 'xl-3 lg-6',
                child: MyCard(
                   shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
                  borderRadiusAll: 12,
                  paddingAll: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyContainer(
                        borderRadiusAll: 12,
                        height: 314,
                        color: contentTheme.light,
                        child: Center(child: Image.asset('assets/product/p-1.png')),
                      ),
                      MySpacing.height(20),
                      Row(
                        children: [
                          MyText.bodyLarge(
                            "Men Black Slim Fit T-shirt",
                            maxLines: 1,
                            style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
                          ),
                          MySpacing.width(8),
                          Expanded(
                            child: MyText.bodyMedium(
                              "(Fashion)",
                              fontWeight: 600,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withAlpha(160),
                              ),
                            ),
                          ),
                        ],
                      ),
                      MySpacing.height(12),
                      MyText.bodyMedium("Prise:", fontWeight: 600),
                      MySpacing.height(2),
                      Row(
                        spacing: 12,
                        children: [
                          MyText.bodyLarge(
                            "\$100",
                            style: TextStyle(
                              fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface.withAlpha(160),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          MyText.bodyLarge("\$80", fontWeight: 700),
                          MyText.bodySmall("(30% Off)"),
                        ],
                      ),
                      MySpacing.height(12),
                      MyText.bodyMedium("Size:", fontWeight: 600),
                      MySpacing.height(12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            controller.sizes.keys.map((size) {
                              final isSelected = controller.sizes[size]!;
                              return MyContainer(
                                paddingAll: 0,
                                onTap: () => controller.toggleSize(size),
                                width: 36,
                                height: 36,
                                color: isSelected ? contentTheme.dark.withValues(alpha: 0.4) : contentTheme.secondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                                alignment: Alignment.center,
                                child: MyText.bodyMedium(size, color: isSelected ? contentTheme.onPrimary : null),
                              );
                            }).toList(),
                      ),
                      MySpacing.height(12),
                      MyText.bodyMedium("Color:", fontWeight: 600),
                      MySpacing.height(12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            controller.selectedColors.keys.map((key) {
                              return MyContainer(
                                onTap: () => controller.toggleColor(key),
                                width: 36,
                                height: 36,
                                paddingAll: 0,
                                color:
                                    controller.selectedColors[key]!
                                        ? contentTheme.dark.withValues(alpha: 0.4)
                                        : contentTheme.secondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                                child: Center(child: Icon(Icons.circle, size: 20, color: colorMap[key])),
                              );
                            }).toList(),
                      ),

                    ],
                  ),
                ),
              ),
              MyFlexItem(
                sizes: 'xl-9 lg-6',
                child: Column(
                  children: [
                    addProductPhoto(),
                    MySpacing.height(20),
                    productInformation(),
                    MySpacing.height(20),
                    pricingDetails(),
                    MySpacing.height(20),
                    MyContainer(
                      paddingAll: 20,
                      borderRadiusAll: 12,
                      color: contentTheme.light,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          MyContainer.bordered(
                            onTap: () {},
                            color: Colors.transparent,
                            borderRadiusAll: 12,
                            padding: MySpacing.xy(flexSpacing * 1.5, 10),
                            borderColor: contentTheme.dark,
                            child: MyText.bodyMedium("Reset"),
                          ),
                          MySpacing.width(12),
                          MyContainer(
                            color: contentTheme.primary,
                            borderRadiusAll: 12,
                            padding: MySpacing.xy(flexSpacing * 2, 12),
                            child: MyText.bodyMedium("Save", fontWeight: 600, color: contentTheme.onPrimary),
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

  Widget addProductPhoto() {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Add Product Photo",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: MyContainer.bordered(
              onTap: controller.pickFiles,
              borderRadiusAll: 12,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (controller.files.isEmpty)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MySpacing.height(32),
                        Icon(Boxicons.bx_cloud_upload, size: 48, color: contentTheme.primary),
                        MySpacing.height(32),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: [
                            MyText.bodyLarge(
                              "Drop your images here, or",
                              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 28),
                            ),
                            MyText.bodyLarge(
                              "click to browser",
                              style: TextStyle(
                                fontFamily: GoogleFonts.hankenGrotesk(color: contentTheme.primary).fontFamily,
                                color: contentTheme.primary,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                        MySpacing.height(12),
                        MyText.bodyMedium("1600 x 1200 (4:3) recommended. PNG, JPG and GIF files are allowed",textAlign: TextAlign.center),
                        MySpacing.height(40),
                      ],
                    ),
                  if (controller.files.isNotEmpty) ...[
                    MySpacing.height(16),
                    Wrap(
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
                                  width: 120,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MyContainer(
                                        height: 44,
                                        width: 44,
                                        borderRadiusAll: 8,
                                        color: contentTheme.onBackground.withAlpha(28),
                                        paddingAll: 0,
                                        child: Icon(controller.getFileIcon(file.name), size: 20),
                                      ),
                                      MySpacing.height(12),
                                      MyText.bodyMedium(file.name, fontWeight: 700, muted: true, maxLines: 2, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget productInformation() {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Product Information",
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
                  sizes: 'lg-6 md-6',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Product Name"),
                      MySpacing.height(8),
                      TextFormField(
                        style: MyTextStyle.bodyMedium(),
                        controller: controller.productNameController,
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
                          hintText: "Items Name",
                          hintStyle: MyTextStyle.bodyMedium(),
                        ),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-6 md-6',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Product Category"),
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
                        hint: MyText.bodyMedium("Select Categories"),
                        value: controller.selectedCategory,
                        onChanged: (value) => setState(() => controller.selectedCategory = value),
                        validator: (value) => value == null ? 'Please select a category' : null,
                        items:
                            controller.categories.map((category) {
                              return DropdownMenuItem(value: category, child: MyText.bodyMedium(category));
                            }).toList(),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4 md-4',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Brand"),
                      MySpacing.height(8),
                      TextFormField(
                        style: MyTextStyle.bodyMedium(),
                        controller: controller.brandController,
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
                          hintText: "Brand Name",
                          hintStyle: MyTextStyle.bodyMedium(),
                        ),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4 md-4',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Weight"),
                      MySpacing.height(8),
                      TextFormField(
                        style: MyTextStyle.bodyMedium(),
                        controller: controller.weightController,
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
                          hintText: "In gm & kg",
                          hintStyle: MyTextStyle.bodyMedium(),
                        ),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4 md-4',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Gender"),
                      MySpacing.height(8),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          border: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          errorBorder: outlineInputBorder,
                          focusedErrorBorder: outlineInputBorder,
                          contentPadding: EdgeInsets.all(12),
                          isDense: true,
                          isCollapsed: true,
                        ),
                        hint: Text("Select Gender", style: TextStyle(fontSize: 14)),
                        value: controller.selectedGender,
                        onChanged: (value) => setState(() => controller.selectedGender = value),
                        validator: (value) => value == null ? 'Please select a gender' : null,
                        items:
                            controller.genders.map((gender) {
                              return DropdownMenuItem(value: gender, child: Text(gender, style: TextStyle(fontSize: 14)));
                            }).toList(),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Size:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            controller.availableSizes.map((size) {
                              final isSelected = controller.selectedSizeOptions.contains(size);
                              return MyContainer(
                                paddingAll: 0,
                                onTap: () => controller.toggleSizeOption(size),
                                width: 36,
                                height: 36,
                                color: isSelected ? contentTheme.dark.withValues(alpha: 0.4) : contentTheme.secondary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                                alignment: Alignment.center,
                                child: MyText.bodyMedium(size, color: isSelected ? contentTheme.onPrimary : null),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-8',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Colors:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            controller.availableColors.entries.map((entry) {
                              final colorName = entry.key;
                              final colorValue = Color(entry.value);
                              final isSelected = controller.selectedColorOptions.contains(colorName);
                              return MyContainer(
                                onTap: () => controller.toggleColorOption(colorName),
                                width: 36,
                                height: 36,
                                paddingAll: 0,
                                borderRadius: BorderRadius.circular(10),
                                color: isSelected ? contentTheme.dark.withValues(alpha: 0.4) : contentTheme.secondary.withValues(alpha: 0.2),
                                border: Border.all(color: Colors.grey),
                                child: Center(child: Icon(Icons.circle, size: 20, color: colorValue)),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),

                MyFlexItem(
                  child: TextFormField(
                    maxLines: 8,
                    controller: controller.descriptionController,
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
                      hintText: "Short description about product",
                      hintStyle: MyTextStyle.bodyMedium(),
                    ),
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Tag Number"),
                      MySpacing.height(8),
                      TextFormField(
                        controller: controller.tagNumberController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                          hintText: "Short description about product",
                          hintStyle: MyTextStyle.bodyMedium(),
                        ),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Stock"),
                      MySpacing.height(8),
                      TextFormField(
                        controller: controller.stockController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                          hintText: "Quality",
                          hintStyle: MyTextStyle.bodyMedium(),
                        ),
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

  Widget pricingDetails() {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Pricing Details",
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Price"),
                      MySpacing.height(8),
                      TextFormField(
                        controller: controller.priceController,
                        style: MyTextStyle.bodyMedium(),
                        decoration: InputDecoration(
                          border: outlineInputBorder,
                          focusedErrorBorder: outlineInputBorder,
                          errorBorder: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          disabledBorder: outlineInputBorder,
                          contentPadding: MySpacing.all(16),
                          prefixIcon: MyContainer.bordered(
                            margin: MySpacing.right(12),
                            paddingAll: 0,
                            borderColor: contentTheme.secondary.withValues(alpha: 0.1),
                            alignment: Alignment.center,
                            color: contentTheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                            border: Border(right: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.1))),
                            child: Icon(Boxicons.bx_dollar, color: contentTheme.secondary),
                          ),
                          prefixIconConstraints: BoxConstraints(maxHeight: 42, minWidth: 50, maxWidth: 50),
                          isDense: true,
                          isCollapsed: true,
                          hintText: "000",
                          hintStyle: MyTextStyle.bodyMedium(),
                        ),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Discount"),
                      MySpacing.height(8),
                      TextFormField(
                        style: MyTextStyle.bodyMedium(),
                        controller:controller.discountController,
                        decoration: InputDecoration(
                          border: outlineInputBorder,
                          focusedErrorBorder: outlineInputBorder,
                          errorBorder: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          disabledBorder: outlineInputBorder,
                          contentPadding: MySpacing.all(16),
                          prefixIcon: MyContainer.bordered(
                            margin: MySpacing.right(12),
                            paddingAll: 0,
                            borderColor: contentTheme.secondary.withValues(alpha: 0.1),
                            alignment: Alignment.center,
                            color: contentTheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                            border: Border(right: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.1))),
                            child: Icon(Boxicons.bxs_discount, color: contentTheme.secondary),
                          ),
                          prefixIconConstraints: BoxConstraints(maxHeight: 42, minWidth: 50, maxWidth: 50),
                          isDense: true,
                          isCollapsed: true,
                          hintText: "000",
                          hintStyle: MyTextStyle.bodyMedium(),
                        ),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Tex"),
                      MySpacing.height(8),
                      TextFormField(
                        style: MyTextStyle.bodyMedium(),
                        controller: controller.texController,
                        decoration: InputDecoration(
                          border: outlineInputBorder,
                          focusedErrorBorder: outlineInputBorder,
                          errorBorder: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          disabledBorder: outlineInputBorder,
                          contentPadding: MySpacing.all(16),
                          prefixIcon: MyContainer.bordered(
                            margin: MySpacing.right(12),
                            paddingAll: 0,
                            borderColor: contentTheme.secondary.withValues(alpha: 0.1),
                            alignment: Alignment.center,
                            color: contentTheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                            border: Border(right: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.1))),
                            child: Icon(Boxicons.bxs_file, color: contentTheme.secondary),
                          ),
                          prefixIconConstraints: BoxConstraints(maxHeight: 42, minWidth: 50, maxWidth: 50),
                          isDense: true,
                          isCollapsed: true,
                          hintText: "000",
                          hintStyle: MyTextStyle.bodyMedium(),
                        ),
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
}
