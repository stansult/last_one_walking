// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.style});

  final String text;
  final SectionStyle style;

  @override
  Widget build(BuildContext context) {
    final textWidget = _StyledText(text: text, style: style.textStyle);
    if (!style.showBackground) {
      return textWidget;
    }

    final content = Container(
      padding: style.padding,
      color: style.backgroundColor.withOpacity(style.backgroundOpacity),
      child: textWidget,
    );

    if (!AppVisuals.useBlur || style.backgroundBlurSigma <= 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: style.backgroundBlurSigma,
          sigmaY: style.backgroundBlurSigma,
        ),
        child: content,
      ),
    );
  }
}
