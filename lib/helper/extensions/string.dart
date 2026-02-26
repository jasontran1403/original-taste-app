import 'dart:ui';
import 'package:original_taste/helper/services/localization/translator.dart';

extension StringUtil on String {
  Color get toColor {
    String hex = replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse("0x$hex"));
  }

  String maxLength(int length) {
    if (this.length <= length) return this;
    return substring(0, length);
  }

  String toParagraph([bool addDash = false]) {
    return addDash ? "-\t$this" : "\t$this";
  }

  bool toBool([bool defaultValue = false]) {
    final lower = toLowerCase();
    if (lower == '1' || lower == 'true') return true;
    if (lower == '0' || lower == 'false') return false;
    return defaultValue;
  }

  int? toInt([int? defaultValue]) {
    return int.tryParse(this) ?? defaultValue;
  }

  double toDouble([double defaultValue = 0]) {
    return double.tryParse(this) ?? defaultValue;
  }

  String get capitalizeWords {
    return split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
  }

  String? get nullIfEmpty => isEmpty ? null : this;
}

extension NullableStringUtil on String? {
  String get toStringOrEmpty => this ?? '';
}

extension StringLocalization on String {
  String tr() => Translator.translate(this);
}
