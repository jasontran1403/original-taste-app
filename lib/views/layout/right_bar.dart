import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/layout/right_bar_controller.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/theme/theme_customizer.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';

class RightBar extends StatefulWidget {
  const RightBar({super.key});

  @override
  State<RightBar> createState() => _RightBarState();
}

class _RightBarState extends State<RightBar> with UIMixin {
  final RightBarController controller = Get.put(RightBarController());

  @override
  Widget build(BuildContext context) {
    final customizer = ThemeCustomizer.instance;
    return GetBuilder<RightBarController>(
      init: controller,
      tag: 'rightBar_controller',
      builder: (_) {
        return MyContainer(
          width: 280,
          color: theme.colorScheme.primary,
          paddingAll: 0,
          borderRadiusAll: 0,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: MyContainer(
                  borderRadiusAll: 0,
                  padding: MySpacing.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_buildColorScheme(customizer), MySpacing.height(24), _buildMenuColor(customizer)],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return MyContainer(
      height: 60,
      alignment: Alignment.centerLeft,
      padding: MySpacing.x(24),
      borderRadiusAll: 0,
      color: contentTheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: MyText.bodyMedium("Theme Settings", color: contentTheme.onPrimary, fontWeight: 700)),
          InkWell(onTap: () => Navigator.of(context).pop(), child: Icon(Icons.close, size: 18, color: contentTheme.onPrimary)),
        ],
      ),
    );
  }

  Widget _buildColorScheme(ThemeCustomizer customizer) {
    ThemeMode selectedTheme = customizer.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium("Color Scheme", fontWeight: 700, muted: true),
        MySpacing.height(12),
        Column(
          children: [
            Row(
              children: [
                Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: selectedTheme,
                  onChanged: (value) {
                    ThemeCustomizer.setTheme(value!);
                  },
                  activeColor: contentTheme.primary,
                ),
                MyText.bodyMedium("Light", fontWeight: 600),
              ],
            ),
            Row(
              children: [
                Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: selectedTheme,
                  onChanged: (value) {
                    ThemeCustomizer.setTheme(value!);
                  },
                  activeColor: contentTheme.primary,
                ),
                MyText.bodyMedium("Dark", fontWeight: 600),
              ],
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildMenuColor(ThemeCustomizer customizer) {
    ThemeMode selectedMenuTheme = customizer.leftBarTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium("Menu Color", fontWeight: 700, muted: true),
        MySpacing.height(12),
        Column(
          children: [
            Row(
              children: [
                Radio<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: selectedMenuTheme,
                  onChanged: (value) {
                    ThemeCustomizer.setLeftBarTheme(value!);
                  },
                  activeColor: contentTheme.primary,
                ),
                MyText.bodyMedium("Light", fontWeight: 600),
              ],
            ),
            Row(
              children: [
                Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: selectedMenuTheme,
                  onChanged: (value) {
                    ThemeCustomizer.setLeftBarTheme(value!);
                  },
                  activeColor: contentTheme.primary,
                ),
                MyText.bodyMedium("Dark", fontWeight: 600),
              ],
            ),
          ],
        ),
      ],
    );
  }

}
