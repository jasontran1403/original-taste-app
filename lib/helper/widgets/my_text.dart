// ignore_for_file: annotate_overrides, overridden_fields
import 'package:flutter/material.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';

class MyText extends StatelessWidget {
  //Key

  final Key? key;
  final String text;
  final TextStyle? style;
  final int? fontWeight;
  final bool muted, xMuted;
  final double? letterSpacing;
  final Color? color;
  final TextDecoration decoration;
  final double? height;
  final double wordSpacing;
  final double? fontSize;
  final MyTextType textType;

  //Text Style
  final TextAlign? textAlign;
  final int? maxLines;
  final Locale? locale;
  final TextOverflow? overflow;
  final String? semanticsLabel;
  final bool? softWrap;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;
  final TextHeightBehavior? textHeightBehavior;
  final double? textScaleFactor;
  final TextWidthBasis? textWidthBasis;

  const MyText(
    this.text, {
    this.style,
    this.fontWeight = 500,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing = 0.15,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.bodyMedium,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.displayLarge(
    this.text, {
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.displayLarge,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.displayMedium(
    this.text, {
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.displayMedium,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.displaySmall(
    this.text, {
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.displaySmall,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.headlineLarge(
    this.text, {
    this.style,
    this.fontWeight = 500,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.headlineLarge,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.headlineMedium(
    this.text, {
    this.style,
    this.fontWeight = 500,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.headlineMedium,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.headlineSmall(
    this.text, {
    this.style,
    this.fontWeight = 500,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.headlineSmall,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.titleLarge(
    this.text, {
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.titleLarge,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.titleMedium(
    this.text, {
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.titleMedium,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.titleSmall(
    this.text, {
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.titleSmall,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.labelLarge(
    this.text, {
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.labelLarge,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.labelMedium(
    this.text, {
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.labelMedium,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.labelSmall(
    this.text, {
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.labelSmall,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.bodyLarge(
    this.text, {
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.bodyLarge,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.bodyMedium(
    this.text, {
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.bodyMedium,
    this.key,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  const MyText.bodySmall(
    this.text, {
    this.key,
    this.style,
    this.fontWeight,
    this.muted = false,
    this.xMuted = false,
    this.letterSpacing,
    this.color,
    this.decoration = TextDecoration.none,
    this.height,
    this.wordSpacing = 0,
    this.fontSize,
    this.textType = MyTextType.bodySmall,
    this.textAlign,
    this.maxLines,
    this.locale,
    this.overflow,
    this.semanticsLabel,
    this.softWrap,
    this.strutStyle,
    this.textDirection,
    this.textHeightBehavior,
    this.textScaleFactor,
    this.textWidthBasis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          style ??
          MyTextStyle.getStyle(
            textStyle: style,
            color: color,
            fontWeight: fontWeight ?? MyTextStyle.defaultTextFontWeight[textType] ?? 500,
            muted: muted,
            letterSpacing: letterSpacing ?? MyTextStyle.defaultLetterSpacing[textType] ?? 0.15,
            height: height,
            xMuted: xMuted,
            decoration: decoration,
            wordSpacing: wordSpacing,
            fontSize: fontSize ?? MyTextStyle.defaultTextSize[textType],
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      locale: locale,
      overflow: overflow,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      strutStyle: strutStyle,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textWidthBasis: textWidthBasis,
      key: key,
    );
  }
}
