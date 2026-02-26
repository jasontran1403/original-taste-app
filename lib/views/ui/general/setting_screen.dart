import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/setting_controller.dart';
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

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> with UIMixin {
  SettingController controller = Get.put(SettingController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'settings_controller',
      builder: (controller) {
        return Layout(
          screenName: "SETTINGS",
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              generalSettings(),
              MySpacing.height(20),
              storeSetting(),
              MySpacing.height(20),
              localizationSettings(),
              MySpacing.height(20),
              MyFlex(
                contentPadding: false,
                children: [
                  MyFlexItem(sizes: 'lg-3', child: categoriesSettings()),
                  MyFlexItem(sizes: 'lg-3', child: reviewsSettings()),
                  MyFlexItem(sizes: 'lg-3', child: vouchersSettings()),
                  MyFlexItem(sizes: 'lg-3', child: taxSettings()),
                ],
              ),
              MySpacing.height(20),
              customerSetting(),
              MySpacing.height(20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 12,
                children: [
                  MyContainer(
                    paddingAll: 12,
                    borderRadiusAll: 8,
                    color: contentTheme.danger,
                    child: MyText.labelMedium("Cancel", color: contentTheme.onDanger),
                  ),
                  MyContainer(
                    paddingAll: 12,
                    borderRadiusAll: 8,
                    color: contentTheme.success,
                    child: MyText.labelMedium("Save Changes", color: contentTheme.onDanger),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget generalSettings() {
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
                SvgPicture.asset("assets/svg/settings.svg"),
                MySpacing.width(12),
                MyText.titleMedium(
                  "General Settings",
                  style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
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
                          hintText: "Title",
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
                  sizes: 'lg-6',
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
                        value: controller.selectedTheme,
                        onChanged: (value) => setState(() => controller.selectedTheme = value),
                        validator: (value) => value == null ? 'Please select a category' : null,
                        items:
                            controller.themes.map((category) {
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
                        hint: MyText.bodyMedium("Select Layout"),
                        value: controller.selectedLayout,
                        onChanged: (value) => setState(() => controller.selectedLayout = value),
                        validator: (value) => value == null || value.isEmpty ? 'Please select a layout' : null,
                        items:
                            controller.layouts.map((layout) {
                              return DropdownMenuItem(value: layout, child: MyText.bodyMedium(layout));
                            }).toList(),
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

  Widget storeSetting() {
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
                SvgPicture.asset("assets/svg/shop_2.svg", height: 20),
                MySpacing.width(12),
                MyText.titleMedium(
                  "General Settings",
                  style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
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
                      MyText.bodyMedium("Store Name"),
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
                      MyText.bodyMedium("Store Owner Full Name"),
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
                          hintText: "Full Name",
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
                      MyText.bodyMedium("Owner Phone number"),
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
                          hintText: "Number",
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
                      MyText.bodyMedium("Owner Email"),
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
                          hintText: "Email",
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
                      MyText.bodyMedium("Full Address"),
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
                          hintText: "Type Address",
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
                      MyText.bodyMedium("Zip-code"),
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
                          hintText: "Zip-code",
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
                      MyText.bodyMedium("City"),
                      MySpacing.height(8),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          border: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          disabledBorder: outlineInputBorder,
                          contentPadding: MySpacing.all(12),
                          isDense: true,
                          isCollapsed: true,
                        ),
                        hint: MyText.bodyMedium("Select City"),
                        value: controller.selectedCity,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              controller.selectedCity = value;
                            });
                          }
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Please select a city' : null,
                        items: _buildGroupedCityItems(),
                      ),
                    ],
                  ),
                ),
                MyFlexItem(
                  sizes: 'lg-4',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText.bodyMedium("Country"),
                      MySpacing.height(8),

                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          border: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          disabledBorder: outlineInputBorder,
                          contentPadding: MySpacing.all(12),
                          isDense: true,
                          isCollapsed: true,
                        ),
                        hint: MyText.bodyMedium("Choose a country"),
                        value: controller.selectedCountry,
                        onChanged: (value) {
                          setState(() {
                            controller.selectedCountry = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Please select a country' : null,
                        items:
                            controller.countries.map((country) {
                              return DropdownMenuItem<String>(value: country, child: MyText.bodyMedium(country));
                            }).toList(),
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

  List<DropdownMenuItem<String>> _buildGroupedCityItems() {
    List<DropdownMenuItem<String>> items = [];

    controller.groupedCities.forEach((country, cities) {
      items.add(DropdownMenuItem<String>(enabled: false, child: MyText.bodyMedium(country, fontWeight: 600, color: Colors.grey)));

      for (var city in cities) {
        items.add(
          DropdownMenuItem<String>(
            value: city['enabled'] ? city['name'] : null,
            enabled: city['enabled'],
            child: MyText.bodyMedium(city['name'], color: city['enabled'] ? Colors.black : Colors.grey),
          ),
        );
      }
    });

    return items;
  }

  Widget localizationSettings() {
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
                SvgPicture.asset("assets/svg/compass.svg"),
                MySpacing.width(12),
                MyText.titleMedium(
                  "General Settings",
                  style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
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
                      MyText.bodyMedium("Country"),
                      MySpacing.height(8),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: "Choose a country",
                          border: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          contentPadding: MySpacing.all(12),
                          isDense: true,
                          isCollapsed: true,
                        ),
                        value: controller.localizationSelectedCountry,
                        onChanged: (value) {
                          setState(() {
                            controller.localizationSelectedCountry = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Please select a country' : null,
                        items:
                            controller.localizationCountries.map((country) {
                              return DropdownMenuItem<String>(value: country, child: MyText.bodyMedium(country));
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
                      MyText.bodyMedium("Language"),
                      MySpacing.height(8),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          hintText: "Choose a language",
                          border: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          contentPadding: MySpacing.all(12),
                          isDense: true,
                          isCollapsed: true,
                        ),
                        value: controller.selectedLanguage,
                        onChanged: (value) {
                          setState(() {
                            controller.selectedLanguage = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Please select a language' : null,
                        items:
                            controller.languages.map((country) {
                              return DropdownMenuItem<String>(value: country, child: MyText.bodyMedium(country));
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
                      MyText.bodyMedium("Currency"),
                      MySpacing.height(8),

                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        style: MyTextStyle.bodyMedium(),
                        decoration: InputDecoration(
                          hintStyle: MyTextStyle.bodyMedium(),
                          hintText: "Select Currency",
                          border: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          contentPadding: MySpacing.all(12),
                          isDense: true,
                          isCollapsed: true,
                        ),
                        value: controller.selectedCurrencyValue,
                        onChanged: (value) {
                          setState(() {
                            controller.selectedCurrencyValue = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Please select a currency' : null,
                        items:
                            controller.currencyOptions.map((currency) {
                              return DropdownMenuItem<String>(value: currency, child: MyText.bodyMedium(currency));
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
                      MyText.bodyMedium("Length Class"),
                      MySpacing.height(8),

                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        style: MyTextStyle.bodyMedium(),
                        decoration: InputDecoration(
                          hintStyle: MyTextStyle.bodyMedium(),
                          hintText: "Select Length",
                          border: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          contentPadding: MySpacing.all(12),
                          isDense: true,
                          isCollapsed: true,
                        ),
                        value: controller.selectedLengthClass,
                        onChanged: (value) {
                          setState(() {
                            controller.selectedLengthClass = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Please select a length unit' : null,
                        items:
                            controller.lengthClassOptions.map((unit) {
                              return DropdownMenuItem<String>(value: unit, child: MyText.bodyMedium(unit));
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
                      MyText.bodyMedium("Weight Class"),
                      MySpacing.height(8),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        style: MyTextStyle.bodyMedium(),
                        decoration: InputDecoration(
                          hintStyle: MyTextStyle.bodyMedium(),
                          hintText: "Select Length",
                          border: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          contentPadding: MySpacing.all(12),
                          isDense: true,
                          isCollapsed: true,
                        ),
                        value: controller.selectedWeightClass,
                        onChanged: (value) {
                          setState(() {
                            controller.selectedWeightClass = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Please select a weight unit' : null,
                        items:
                            controller.weightClassOptions.map((weight) {
                              return DropdownMenuItem<String>(value: weight, child: MyText.bodyMedium(weight));
                            }).toList(),
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

  Widget categoriesSettings() {
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
                SvgPicture.asset("assets/svg/box.svg"),
                MySpacing.width(12),
                MyText.titleMedium(
                  "General Settings",
                  style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium("Category Product Count"),
                MySpacing.height(4),
                Row(
                  children: [
                    Row(
                      children: [
                        Radio<String>(
                          value: "Yes",
                          groupValue: controller.selectedOption,
                          activeColor: contentTheme.primary,
                          onChanged: (value) {
                            setState(() {
                              controller.selectedOption = value;
                            });
                          },
                        ),
                        MyText.bodyMedium("Yes"),
                      ],
                    ),
                    MySpacing.width(20),
                    Row(
                      children: [
                        Radio<String>(
                          value: "No",
                          groupValue: controller.selectedOption,
                          activeColor: contentTheme.primary,
                          onChanged: (value) {
                            setState(() {
                              controller.selectedOption = value;
                            });
                          },
                        ),
                        MyText.bodyMedium("No"),
                      ],
                    ),
                  ],
                ),
                MySpacing.height(8),
                MyText.bodyMedium("Default Items Per Page"),
                MySpacing.height(8),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "000",
                    border: outlineInputBorder,
                    enabledBorder: outlineInputBorder,
                    focusedBorder: outlineInputBorder,
                    isDense: true,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget reviewsSettings() {
    Widget buildRadioGroup({required String title, required String groupValue, required void Function(String?) onChanged}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium(title),
          MySpacing.height(4),
          Row(
            children: [
              Row(
                children: [
                  Radio<String>(value: "Yes", activeColor: contentTheme.primary, groupValue: groupValue, onChanged: onChanged),
                  MyText.bodyMedium("Yes"),
                ],
              ),
              MySpacing.width(20),
              Row(
                children: [
                  Radio<String>(value: "No", activeColor: contentTheme.primary, groupValue: groupValue, onChanged: onChanged),
                  MyText.bodyMedium("No"),
                ],
              ),
            ],
          ),
        ],
      );
    }

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
                SvgPicture.asset("assets/svg/chat_square_check.svg"),
                MySpacing.width(12),
                MyText.titleMedium(
                  "Reviews Settings",
                  style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildRadioGroup(
                  title: "Allow Reviews",
                  groupValue: controller.allowReviews,
                  onChanged:
                      (value) => setState(() {
                        controller.allowReviews = value!;
                      }),
                ),
                MySpacing.height(18),
                buildRadioGroup(
                  title: "Allow Guest Reviews",
                  groupValue: controller.allowGuestReviews,
                  onChanged:
                      (value) => setState(() {
                        controller.allowGuestReviews = value!;
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget vouchersSettings() {
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
                SvgPicture.asset("assets/svg/ticket.svg"),
                MySpacing.width(12),
                MyText.titleMedium(
                  "Vouchers Settings",
                  style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium("Minimum Vouchers"),
                MySpacing.height(8),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "000",
                    border: outlineInputBorder,
                    enabledBorder: outlineInputBorder,
                    focusedBorder: outlineInputBorder,
                    isDense: true,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
                MySpacing.height(8),
                MyText.bodyMedium("Maximum Vouchers"),
                MySpacing.height(8),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "000",
                    border: outlineInputBorder,
                    enabledBorder: outlineInputBorder,
                    focusedBorder: outlineInputBorder,
                    isDense: true,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget taxSettings() {
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
                SvgPicture.asset("assets/svg/ticket_sale.svg"),
                MySpacing.width(12),
                MyText.titleMedium(
                  "Tex Settings",
                  style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyMedium("Price with tax"),
                MySpacing.height(4),
                Row(
                  children: [
                    Row(
                      children: [
                        Radio<String>(
                          value: "Yes",
                          groupValue: controller.selectedTexOption,
                          activeColor: contentTheme.primary,
                          onChanged: (value) {
                            setState(() {
                              controller.selectedTexOption = value;
                            });
                          },
                        ),
                        MyText.bodyMedium("Yes"),
                      ],
                    ),
                    MySpacing.width(20),
                    Row(
                      children: [
                        Radio<String>(
                          value: "No",
                          groupValue: controller.selectedTexOption,
                          activeColor: contentTheme.primary,
                          onChanged: (value) {
                            setState(() {
                              controller.selectedTexOption = value;
                            });
                          },
                        ),
                        MyText.bodyMedium("No"),
                      ],
                    ),
                  ],
                ),
                MySpacing.height(8),
                MyText.bodyMedium("Default Tax Rate"),
                MySpacing.height(8),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "18%",
                    border: outlineInputBorder,
                    enabledBorder: outlineInputBorder,
                    focusedBorder: outlineInputBorder,
                    isDense: true,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget customerSetting() {
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
                SvgPicture.asset("assets/svg/users_group_two_rounded.svg"),
                MySpacing.width(12),
                MyText.titleMedium(
                  "Customer Setting",
                  style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              children: [
                MyFlex(
                  contentPadding: false,
                  children: [
                    MyFlexItem(
                      sizes: 'lg-2.4',
                      child: _radioGroup("Customers Online", controller.online, (v) => setState(() => controller.online = v!)),
                    ),
                    MyFlexItem(
                      sizes: 'lg-2.4',
                      child: _radioGroup("Customers Activity", controller.activity, (v) => setState(() => controller.activity = v!)),
                    ),
                    MyFlexItem(
                      sizes: 'lg-2.4',
                      child: _radioGroup("Customer Searches", controller.searches, (v) => setState(() => controller.searches = v!)),
                    ),
                    MyFlexItem(
                      sizes: 'lg-2.4',
                      child: _radioGroup("Allow Guest Checkout", controller.guestCheckout, (v) => setState(() => controller.guestCheckout = v!)),
                    ),
                    MyFlexItem(
                      sizes: 'lg-2.4',
                      child: _radioGroup("Login Display Price", controller.displayPrice, (v) => setState(() => controller.displayPrice = v!)),
                    ),
                    MyFlexItem(
                      sizes: 'lg-6',
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "1 hours",
                          border: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          focusedBorder: outlineInputBorder,
                          isDense: true,
                          contentPadding: EdgeInsets.all(12),
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
  }

  Widget _radioGroup(String title, YesNo value, Function(YesNo?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(title),
        Row(
          children:
              YesNo.values.map((e) {
                return Expanded(
                  child: RadioListTile<YesNo>(
                    activeColor: contentTheme.primary,
                    contentPadding: MySpacing.zero,
                    visualDensity: VisualDensity.compact,
                    title: MyText.bodyMedium(e.name.toUpperCase()),
                    value: e,
                    groupValue: value,
                    onChanged: onChanged,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
