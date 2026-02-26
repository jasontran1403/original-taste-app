import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/helper/theme/theme_customizer.dart';

class LayoutController extends MyController {
  bool isHovered = false;
  ThemeCustomizer themeCustomizer = ThemeCustomizer();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final GlobalKey<State<StatefulWidget>> scrollKey = GlobalKey();

  @override
  void onReady() {
    super.onReady();
    ThemeCustomizer.addListener(onChangeTheme);
  }

  void onChangeTheme(ThemeCustomizer oldVal, ThemeCustomizer newVal) {
    themeCustomizer = newVal;
    update();

    if (newVal.rightBarOpen) {
      scaffoldKey.currentState?.openEndDrawer();
    } else {
      scaffoldKey.currentState?.closeEndDrawer();
    }
  }

  void enableNotificationShade() {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom, SystemUiOverlay.top]);
  }

  void disableNotificationShade() {
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    super.dispose();
    ThemeCustomizer.removeListener(onChangeTheme);
  }
}
