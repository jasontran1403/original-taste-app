import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/category/category_create_controller.dart';
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

class CategoryCreateScreen extends StatefulWidget {
  const CategoryCreateScreen({super.key});

  @override
  State<CategoryCreateScreen> createState() => _CategoryCreateScreenState();
}

class _CategoryCreateScreenState extends State<CategoryCreateScreen> with UIMixin {
  CategoryCreateController controller = Get.put(CategoryCreateController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'category_edit_controller',
      builder: (controller) {
        return Layout(
          screenName: "CATEGORY CREATE",
          child: MyFlex(
            children: [
              MyFlexItem(sizes: 'lg-3 md-6', child: productDetail()),
              MyFlexItem(
                sizes: 'lg-9 md-6',
                child: Column(
                  children: [
                    addThumbnailPhoto(),
                    MySpacing.height(20),
                    generalInformation(),
                    MySpacing.height(20),
                    metaOptions(),
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
                            child: MyText.bodyMedium("Save Changes"),
                          ),
                          MySpacing.width(12),
                          MyContainer(
                            onTap: () {},
                            color: contentTheme.primary,
                            borderRadiusAll: 12,
                            padding: MySpacing.xy(flexSpacing * 2, 12),
                            child: MyText.bodyMedium("Cancel", fontWeight: 600, color: contentTheme.onPrimary),
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

  Widget productDetail() {
    return MyCard(
       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
      borderRadiusAll: 12,
      paddingAll: 0,
      child: Column(
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyContainer(color: contentTheme.light, height: 150, borderRadiusAll: 12, child: Center(child: Image.asset("assets/product/p-1.png"))),
                MySpacing.height(20),
                MyText.titleMedium(
                  "Fashion Men , Women & Kid's",
                  style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 18, fontWeight: FontWeight.w600),
                ),
                MySpacing.height(20),
                Wrap(
                  spacing: 32,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyMedium("Created By :"),
                        MySpacing.height(8),
                        MyText.bodyMedium(
                          "Seller",
                          style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyMedium("Stock :"),
                        MySpacing.height(8),
                        MyText.bodyMedium(
                          "46233",
                          style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyMedium("ID :"),
                        MySpacing.height(8),
                        MyText.bodyMedium(
                          "FS16276",
                          style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
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
                  child: MyContainer.bordered(
                    onTap: () {},
                    borderRadiusAll: 12,
                    paddingAll: 10,
                    borderColor: contentTheme.dark,
                    child: Center(child: MyText.bodyMedium("Create Category", fontWeight: 600)),
                  ),
                ),
                MySpacing.width(12),
                Expanded(
                  child: MyContainer(
                    color: contentTheme.primary,
                    borderRadiusAll: 12,
                    paddingAll: 12,
                    child: Center(child: MyText.bodyMedium("Cancel", color: contentTheme.onPrimary)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addThumbnailPhoto() {
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
              "Add Thumbnail Photo",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
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
                        MyText.bodyMedium("1600 x 1200 (4:3) recommended. PNG, JPG and GIF files are allowed"),
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

  Widget generalInformation() {
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
              "General Information",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: MyFlex(
              contentPadding: false,
              children: [
                MyFlexItem(
                  sizes: 'lg-6',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Category Title"),
                      MySpacing.height(8),
                      TextFormField(
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
                          hintText: "Enter title",
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
                      MyText.bodyMedium("Created By"),
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
                        hint: MyText.bodyMedium("Created By"),
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
                  sizes: 'lg-6',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Stock"),
                      MySpacing.height(8),
                      TextFormField(
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
                          hintText: "Stock",
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
                      MyText.bodyMedium("Tag ID"),
                      MySpacing.height(8),
                      TextFormField(
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
                          hintText: "Enter id",
                          hintStyle: MyTextStyle.bodyMedium(),
                        ),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Description"),
                      MySpacing.height(8),
                      TextFormField(
                        maxLines: 8,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget metaOptions() {
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
              "Meta Options",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: MyFlex(
              contentPadding: false,
              children: [
                MyFlexItem(
                  sizes: 'lg-6',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Meta Title"),
                      MySpacing.height(8),
                      TextFormField(
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
                          hintText: "Enter title",
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
                      MyText.bodyMedium("Meta Tag Keyword"),
                      MySpacing.height(8),
                      TextFormField(
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
                          hintText: "Enter word",
                          hintStyle: MyTextStyle.bodyMedium(),
                        ),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Description"),
                      MySpacing.height(8),
                      TextFormField(
                        maxLines: 6,
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
                          hintText: "Type description",
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
