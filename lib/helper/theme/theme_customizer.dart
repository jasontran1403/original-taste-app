import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:original_taste/helper/services/localization/language.dart';
import 'package:original_taste/helper/services/localization/translator.dart';
import 'package:original_taste/helper/services/json_decoder.dart';
import 'package:original_taste/helper/services/navigation_service.dart';
import 'package:original_taste/helper/theme/admin_theme.dart';
import 'package:original_taste/helper/theme/app_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ThemeChangeCallback = void Function(ThemeCustomizer oldVal, ThemeCustomizer newVal);

class ThemeCustomizer {
  ThemeCustomizer();

  static final List<ThemeChangeCallback> _notifier = [];

  Language currentLanguage = Language.languages.first;

  ThemeMode theme = ThemeMode.light;
  ThemeMode leftBarTheme = ThemeMode.light;
  ThemeMode rightBarTheme = ThemeMode.light;
  ThemeMode topBarTheme = ThemeMode.light;

  bool rightBarOpen = false;
  bool leftBarCondensed = true;
  bool isBoxedLayout = false;

  static ThemeCustomizer instance = ThemeCustomizer();
  static ThemeCustomizer oldInstance = ThemeCustomizer();

  static Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? json = prefs.getString('theme_customizer');

    instance = fromJSON(json);
    await initLanguage();
  }

  static Future<void> initLanguage() async {
    await changeLanguage(instance.currentLanguage);
  }

  String toJSON() => jsonEncode({'theme': theme.name});

  static ThemeCustomizer fromJSON(String? json) {
    instance = ThemeCustomizer();
    if (json?.trim().isNotEmpty ?? false) {
      JSONDecoder decoder = JSONDecoder(json!);
      instance.theme = decoder.getEnum('theme', ThemeMode.values, ThemeMode.light);
    }
    return instance;
  }

  static void addListener(ThemeChangeCallback callback) {
    _notifier.add(callback);
  }

  static void removeListener(ThemeChangeCallback callback) {
    _notifier.remove(callback);
  }

  static void _notify() {
    AdminTheme.setTheme();
    if (NavigationService.globalContext != null) {
      Provider.of<AppNotifier>(NavigationService.globalContext!, listen: false).updateTheme(instance);
    }
    for (var value in _notifier) {
      value(oldInstance, instance);
    }
  }

  static void notify() {
    for (var callback in _notifier) {
      callback(oldInstance, instance);
    }
  }

  static void setTheme(ThemeMode theme) {
    _cloneInstance();
    instance.theme = instance.leftBarTheme = instance.rightBarTheme = instance.topBarTheme = theme;
    _notify();
  }

  static void setLeftBarTheme(ThemeMode theme) {
    _cloneInstance();
    instance.leftBarTheme = theme;
    _notify();
  }

  static void setTopBarTheme(ThemeMode theme) {
    _cloneInstance();
    instance.topBarTheme = theme;
    _notify();
  }

  static Future<void> changeLanguage(Language language) async {
    _cloneInstance();
    instance.currentLanguage = language;
    await Translator.changeLanguage(language);
  }

  static void openRightBar(bool opened) {
    instance.rightBarOpen = opened;
    _notify();
  }

  static void toggleLeftBarCondensed() {
    instance.leftBarCondensed = !instance.leftBarCondensed;
    _notify();
  }

  static void toggleLayoutMode() {
    _cloneInstance();
    instance.isBoxedLayout = !instance.isBoxedLayout;
    _notify();
  }

  static void _cloneInstance() {
    oldInstance = instance.clone();
  }

  ThemeCustomizer clone() {
    var tc = ThemeCustomizer();
    tc.theme = theme;
    tc.rightBarTheme = rightBarTheme;
    tc.leftBarTheme = leftBarTheme;
    tc.topBarTheme = topBarTheme;
    tc.rightBarOpen = rightBarOpen;
    tc.leftBarCondensed = leftBarCondensed;
    tc.currentLanguage = currentLanguage.clone();
    tc.isBoxedLayout = isBoxedLayout;
    return tc;
  }

  @override
  String toString() {
    return 'ThemeCustomizer{theme: $theme}';
  }
}
