import 'package:flutter/material.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/theme/theme_customizer.dart';
import 'package:original_taste/helper/theme/theme_type.dart';

enum LeftBarThemeType { light, dark, fullLight }

enum TopBarThemeType { light, dark }

enum ContentThemeColor {
  primary,
  secondary,
  success,
  info,
  warning,
  danger,
  light,
  dark,
  pink,
  green,
  red,
  blue;

  Color get color => AdminTheme.theme.contentTheme.getMappedIntoThemeColor[this]?['color'] ?? Colors.black;

  Color get onColor => AdminTheme.theme.contentTheme.getMappedIntoThemeColor[this]?['onColor'] ?? Colors.white;
}

class LeftBarTheme {
  final Color background, onBackground, labelColor, activeItemColor, activeItemBackground;

  const LeftBarTheme({
    required this.background,
    required this.onBackground,
    required this.labelColor,
    required this.activeItemColor,
    required this.activeItemBackground,
  });

  static const lightLeftBarTheme = LeftBarTheme(
    background: Color(0xff262d34),
    onBackground: Color(0xffa5b3c6),
    labelColor: Color(0xff5b626d),
    activeItemBackground: Color(0xff283643),
    activeItemColor: Color(0xffff6c2f),
  );

  static const darkLeftBarTheme = LeftBarTheme(
    background: Color(0xff262d34),
    onBackground: Color(0xffa5b3c6),
    labelColor: Color(0xff5b626d),
    activeItemBackground: Color(0xff283643),
    activeItemColor: Color(0xffff6c2f),
  );

  static const fullLightLeftBarTheme = LeftBarTheme(
    background: Color(0xffffffff),
    onBackground: Color(0xff555555),
    labelColor: Color(0xff777777),
    activeItemBackground: Color(0xfff0f0f0),
    activeItemColor: Color(0xffff6c2f),
  );

  static LeftBarTheme getThemeFromType(LeftBarThemeType type) {
    switch (type) {
      case LeftBarThemeType.dark:
        return darkLeftBarTheme;
      case LeftBarThemeType.fullLight:
        return fullLightLeftBarTheme;
      case LeftBarThemeType.light:
        return lightLeftBarTheme;
    }
  }
}

class TopBarTheme {
  final Color background;
  final Color onBackground;

  TopBarTheme({this.background = const Color(0xfff9f7f7), this.onBackground = const Color(0xff313a46)});

  static final TopBarTheme lightTopBarTheme = TopBarTheme();

  static final TopBarTheme darkTopBarTheme = TopBarTheme(
    background: Color(0xff22282e),
    onBackground: Color(0xffdcdcdc),
  );
}

class RightBarTheme {
  final Color disabled, onDisabled, activeSwitchBorderColor, inactiveSwitchBorderColor;

  const RightBarTheme({
    this.disabled = const Color(0xffffffff),
    this.activeSwitchBorderColor = const Color(0xff009678),
    this.inactiveSwitchBorderColor = const Color(0xffdee2e6),
    this.onDisabled = const Color(0xff313a46),
  });

  static const lightRightBarTheme = RightBarTheme(
    disabled: Color(0xffffffff),
    onDisabled: Color(0xffdee2e6),
  );

  static const darkRightBarTheme = RightBarTheme(
    disabled: Color(0xff444d57),
    onDisabled: Color(0xff515a65),
  );
}

class ContentTheme {
  final Color background, onBackground;
  final Color primary, onPrimary, secondary, onSecondary, success, onSuccess;
  final Color danger, onDanger, warning, onWarning, info, onInfo;
  final Color light, onLight, dark, onDark;
  final Color purple, onPurple, pink, onPink, red, onRed, blue, onBlue;
  final Color cardBackground, cardShadow, cardBorder, cardText, cardTextMuted;
  final Color title, disabled, onDisabled;

  const ContentTheme({
    this.background = const Color(0xffeef2f7),
    this.onBackground = const Color(0xffF1F1F2),
    this.primary = const Color(0xffff6c2f),
    this.onPrimary = const Color(0xffffffff),
    this.secondary = const Color(0xff5d7186),
    this.onSecondary = const Color(0xffffffff),
    this.success = const Color(0xff1bb394),
    this.onSuccess = const Color(0xffffffff),
    this.danger = const Color(0xffed5565),
    this.onDanger = const Color(0xffffffff),
    this.warning = const Color(0xfff8ac59),
    this.onWarning = const Color(0xff313a46),
    this.info = const Color(0xff23c6c8),
    this.onInfo = const Color(0xffffffff),
    this.light = const Color(0xffeef2f7),
    this.onLight = const Color(0xff323a46),
    this.dark = const Color(0xff313a46),
    this.onDark = const Color(0xffffffff),
    this.purple = const Color(0xff7f56da),
    this.onPurple = const Color(0xffffffff),
    this.pink = const Color(0xffFF1087),
    this.onPink = const Color(0xffffffff),
    this.red = const Color(0xffed5565),
    this.onRed = const Color(0xffffffff),
    this.blue = const Color(0xff1569C7),
    this.onBlue = const Color(0xffffffff),
    this.cardBackground = const Color(0xffffffff),
    this.cardShadow = const Color(0xffffffff),
    this.cardBorder = const Color(0xffffffff),
    this.cardText = const Color(0xff6c757d),
    this.cardTextMuted = const Color(0xff98a6ad),
    this.title = const Color(0xff6c757d),
    this.disabled = const Color(0xffffffff),
    this.onDisabled = const Color(0xffffffff),
  });

  static const lightContentTheme = ContentTheme(
    background: Color(0xffeef2f7),
    onBackground: Color(0xff313a46),
    cardBorder: Color(0xffe8ecf1),
    cardBackground: Color(0xffffffff),
    cardShadow: Color(0xff9aa1ab),
    cardText: Color(0xff6c757d),
    title: Color(0xff6c757d),
    cardTextMuted: Color(0xff98a6ad),
  );

  static const darkContentTheme = ContentTheme(
    background: Color(0xff2f3943),
    onBackground: Color(0xffF1F1F2),
    disabled: Color(0xff444d57),
    onDisabled: Color(0xff515a65),
    cardBorder: Color(0xff464f5b),
    cardBackground: Color(0xff37404a),
    cardShadow: Color(0xff01030E),
    cardText: Color(0xffaab8c5),
    title: Color(0xffaab8c5),
    cardTextMuted: Color(0xff8391a2),
  );

  Map<ContentThemeColor, Map<String, Color>> get getMappedIntoThemeColor => {
    ContentThemeColor.primary:   {'color': primary,   'onColor': onPrimary},
    ContentThemeColor.secondary: {'color': secondary, 'onColor': onSecondary},
    ContentThemeColor.success:   {'color': success,   'onColor': onSuccess},
    ContentThemeColor.danger:    {'color': danger,    'onColor': onDanger},
    ContentThemeColor.warning:   {'color': warning,   'onColor': onWarning},
    ContentThemeColor.info:      {'color': info,      'onColor': onInfo},
    ContentThemeColor.light:     {'color': light,     'onColor': onLight},
    ContentThemeColor.dark:      {'color': dark,      'onColor': onDark},
    ContentThemeColor.pink:      {'color': pink,      'onColor': onPink},
    ContentThemeColor.red:       {'color': red,       'onColor': onRed},
    ContentThemeColor.blue:      {'color': blue,      'onColor': onBlue},
  };
}

class AdminTheme {
  final LeftBarTheme leftBarTheme;
  final RightBarTheme rightBarTheme;
  final TopBarTheme topBarTheme;
  final ContentTheme contentTheme;

  const AdminTheme({
    required this.leftBarTheme,
    required this.topBarTheme,
    required this.rightBarTheme,
    required this.contentTheme,
  });

  // Default: light theme
  static AdminTheme theme = AdminTheme(
    leftBarTheme: LeftBarTheme.lightLeftBarTheme,
    topBarTheme: TopBarTheme.lightTopBarTheme,
    rightBarTheme: RightBarTheme.lightRightBarTheme,
    contentTheme: ContentTheme.lightContentTheme,
  );

  static void setTheme() {
    final instance = ThemeCustomizer.instance;

    theme = AdminTheme(
      // FIX: trước đây cả dark lẫn light đều trả lightLeftBarTheme
      leftBarTheme: switch (instance.leftBarTheme) {
        ThemeMode.dark  => LeftBarTheme.darkLeftBarTheme,
        ThemeMode.light => LeftBarTheme.lightLeftBarTheme,
        _               => LeftBarTheme.fullLightLeftBarTheme, // ThemeMode.system → fullLight
      },
      topBarTheme:   instance.topBarTheme == ThemeMode.dark ? TopBarTheme.darkTopBarTheme      : TopBarTheme.lightTopBarTheme,
      rightBarTheme: instance.theme       == ThemeMode.dark ? RightBarTheme.darkRightBarTheme  : RightBarTheme.lightRightBarTheme,
      contentTheme:  instance.theme       == ThemeMode.dark ? ContentTheme.darkContentTheme    : ContentTheme.lightContentTheme,
    );

    AppTheme.themeType = instance.theme == ThemeMode.light ? ThemeType.light : ThemeType.dark;
    AppTheme.theme = AppTheme.getTheme();
  }
}