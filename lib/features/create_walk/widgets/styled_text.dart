// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _StyledText extends StatelessWidget {
  const _StyledText({required this.text, required this.style});

  final String text;
  final TextStyleConfig style;

  @override
  Widget build(BuildContext context) {
    if (!style.outlineEnabled) {
      return Text(
        text,
        style: TextStyle(
          fontSize: style.fontSize,
          fontWeight: style.fontWeight,
          color: style.color,
        ),
      );
    }

    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: style.fontSize,
            fontWeight: style.fontWeight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = style.outlineWidth
              ..color = style.outlineColor,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: style.fontSize,
            fontWeight: style.fontWeight,
            color: style.color,
          ),
        ),
      ],
    );
  }
}
