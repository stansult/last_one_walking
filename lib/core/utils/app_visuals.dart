import 'dart:io';

import 'package:flutter/material.dart';

class AppVisuals {
  // Card visuals.
  static const bool cardShowBackground = true;
  static const Color cardBackgroundColor = Colors.white;
  static const double cardOpacity = 0.68;
  static const double cardBlurSigma = 6;

  // Section text visuals.
  static const SectionStyle headerTitleStyle = SectionStyle(
    showBackground: false,
    backgroundColor: Colors.black,
    backgroundOpacity: 0.25,
    backgroundBlurSigma: 8,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    textStyle: TextStyleConfig(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: Color(0xEE2A1B13),
      outlineEnabled: true,
      outlineColor: Color(0x77FCD9BE),
      outlineWidth: 1.5,
    ),
  );

  static const SectionStyle headerSubtitleStyle = SectionStyle(
    showBackground: false,
    backgroundColor: Colors.black,
    backgroundOpacity: 0.25,
    backgroundBlurSigma: 8,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    textStyle: TextStyleConfig(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      outlineEnabled: true,
      outlineColor: Color(0xFF2A1B13),
      outlineWidth: 1.5,
    ),
  );

  static const SectionStyle footerNoteStyle = SectionStyle(
    showBackground: true,
    backgroundColor: Colors.black,
    backgroundOpacity: 0.25,
    backgroundBlurSigma: 8,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    textStyle: TextStyleConfig(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      outlineEnabled: true,
      outlineColor: Color(0xFF2A1B13),
      outlineWidth: 1.5,
    ),
  );

  static const TextStyleConfig cardTitleTextStyle = TextStyleConfig(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2A1B13),
    outlineEnabled: false,
    outlineColor: Color(0xFF2A1B13),
    outlineWidth: 1,
  );

  static const Color adaptiveIconBackgroundColor = Color(0xFF2B0F0D);

  static const double actionIconSize = 18;
  static const double actionIconSizeCompact = 16;
  static const double actionIconGap = 6;
  static const double actionIconGapCompact = 4;
  static const double actionButtonGap = 10;
  static const double actionButtonGapCompact = 6;
  static const EdgeInsets actionPadding =
      EdgeInsets.symmetric(horizontal: 6, vertical: 6);
  static const double actionFontSize = 14;
  static const double actionFontSizeCompact = 12;

  static const double stepperIconSize = 18;
  static const double stepperIconSizeCompact = 16;
  static const double stepperMinTapSize = 28;
  static const double infoIconSize = 14;
  static const double infoIconSizeCompact = 12;
  static const double infoTapSize = 28;

  static const double radioLeadingWidth = 26;
  static const double radioTitleGap = 8;
  static const EdgeInsets radioContentPadding = EdgeInsets.zero;
  static const double radioTopOffset = 0;

  static const Color changedFieldFillColor = Color(0xFFFFF0D6);
  static const double changedFieldFillOpacity = 0.75;
  static const Color changedFieldBorderColor = Color(0xFFB5731A);
  static const Color numberFieldFillColor = Colors.white;
  static const double numberFieldFillOpacity = 0.7;
  static const double bottomFadeHeight = 18;
  static const Color bottomFadeColor = Color(0x22020202);
  static const double bottomFadeOpacity = 0.85;

  static const double ruleLabelWidth = 120;
  static const double ruleLabelMinWidth = 84;
  static const double ruleLabelGap = 8;
  static const double ruleLabelGapCompact = 4;
  static const double ruleInfoGap = 4;
  static const double ruleInfoGapCompact = 2;
  static const double numberFieldInfoGap = 2;

  static const EdgeInsets numberFieldPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const EdgeInsets numberFieldPaddingCompact =
      EdgeInsets.symmetric(horizontal: 8, vertical: 8);

  static const bool blurEnabledOnAndroid = false;
  static const bool blurEnabledOniOS = false;

  static bool get useBlur =>
      (Platform.isAndroid && blurEnabledOnAndroid) ||
      (Platform.isIOS && blurEnabledOniOS);
}

class TextStyleConfig {
  const TextStyleConfig({
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    required this.outlineEnabled,
    required this.outlineColor,
    required this.outlineWidth,
  });

  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final bool outlineEnabled;
  final Color outlineColor;
  final double outlineWidth;

  TextStyle toTextStyle() => TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
}

class SectionStyle {
  const SectionStyle({
    required this.showBackground,
    required this.backgroundColor,
    required this.backgroundOpacity,
    required this.backgroundBlurSigma,
    required this.padding,
    required this.textStyle,
  });

  final bool showBackground;
  final Color backgroundColor;
  final double backgroundOpacity;
  final double backgroundBlurSigma;
  final EdgeInsets padding;
  final TextStyleConfig textStyle;
}
