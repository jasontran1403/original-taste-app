import 'dart:math';
import 'package:flutter/material.dart';

class Generator {
  static const Color starColor = Color(0xfff9c700);
  static const Color goldColor = Color(0xffFFDF00);
  static const Color silverColor = Color(0xffC0C0C0);

  static const String _dummyText =
      "Lorem ipsum, or lipsum as it is sometimes known, is dummy text used in laying out print, graphic or web designs. "
      "The passage is attributed to an unknown typesetter in the 15th century who is thought to have scrambled parts of Cicero's De Finibus Bonorum et Malorum for use in a type specimen book. "
      "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. "
      "If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. "
      "All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. "
      "It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable.";

  static const String _emojiText = "😀 😃 😄 😁 😆 😅 😂 🤣 😍 🥰 😘 😠 😡 💩 👻 🧐 🤓 😎 😋 😛 😝 😜 😢 😭 😤 🥱 😴 😾";

  static String randomString(int length) {
    final rand = Random();
    return String.fromCharCodes(List.generate(length, (_) => rand.nextInt(33) + 89));
  }

  static String getDummyText(int words, {bool withTab = false, bool withEmoji = false, bool withStop = true}) {
    final rand = Random();
    final allWords = _dummyText.split('')..addAll(withEmoji ? _emojiText.split(" ") : []);
    final size = allWords.length;

    final buffer = StringBuffer();
    if (withTab) buffer.write('\t\t\t\t');

    String firstWord = allWords[rand.nextInt(size)];
    firstWord = '${firstWord[0].toUpperCase()}${firstWord.substring(1)}';
    buffer.write('$firstWord ');

    for (int i = 1; i < words; i++) {
      buffer.write(allWords[rand.nextInt(size)]);
      if (i != words - 1) buffer.write(' ');
    }

    if (withStop) buffer.write('.');
    return buffer.toString();
  }

  static String getParagraphsText({
    int paragraph = 1,
    int words = 20,
    int noOfNewLine = 1,
    bool withHyphen = false,
    bool withEmoji = false,
  }) {
    final buffer = StringBuffer();

    for (int i = 0; i < paragraph; i++) {
      buffer.write(withHyphen ? '\t\t-\t\t' : '\t\t\t\t');
      buffer.write(getDummyText(words, withEmoji: withEmoji));

      if (i < paragraph - 1) {
        buffer.write('\n' * noOfNewLine);
      }
    }

    return buffer.toString();
  }

  static String getTextFromSeconds({
    int time = 0,
    bool withZeros = true,
    bool withHours = true,
    bool withMinutes = true,
    bool withSpace = true,
  }) {
    final hours = time ~/ 3600;
    final minutes = (time % 3600) ~/ 60;
    final seconds = time % 60;

    final sep = withSpace ? ' : ' : ':';
    final buffer = StringBuffer();

    if (withHours && hours > 0) {
      buffer.write(withZeros && hours < 10 ? '0$hours$sep' : '$hours$sep');
    }

    if (withMinutes) {
      buffer.write(withZeros && minutes < 10 ? '0$minutes$sep' : '$minutes$sep');
    }

    buffer.write(withZeros && seconds < 10 ? '0$seconds' : '$seconds');
    return buffer.toString();
  }

  static Widget buildOverlaysProfile({
    double size = 50,
    required List<String> images,
    bool enabledOverlayBorder = false,
    Color overlayBorderColor = Colors.white,
    double overlayBorderThickness = 1,
    double leftFraction = 0.7,
    double topFraction = 0,
  }) {
    double leftOffset = 0;
    double topOffset = 0;

    final List<Widget> overlays = [];

    for (int i = 0; i < images.length; i++) {
      final imageWidget = Container(
        decoration:
            enabledOverlayBorder
                ? BoxDecoration(border: Border.all(color: overlayBorderColor, width: overlayBorderThickness), shape: BoxShape.circle)
                : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.asset(images[i], height: size, width: size, fit: BoxFit.cover),
        ),
      );

      if (i == 0) {
        overlays.add(imageWidget);
      } else {
        leftOffset += size * leftFraction;
        topOffset += size * topFraction;

        overlays.add(Positioned(left: leftOffset, top: topOffset, child: imageWidget));
      }
    }

    final totalWidth = leftOffset + size + (images.length * overlayBorderThickness);
    final totalHeight = topOffset + size + (images.length * overlayBorderThickness);

    return SizedBox(width: totalWidth, height: totalHeight, child: Stack(clipBehavior: Clip.none, children: overlays));
  }
}
