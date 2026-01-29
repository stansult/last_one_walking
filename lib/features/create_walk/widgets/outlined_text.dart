// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _OutlinedText extends StatelessWidget {
  const _OutlinedText(
    this.text, {
    required this.fontSize,
    required this.fillColor,
    this.strokeColor = const Color(0xFF2A1B13),
    this.strokeWidth = 1.0,
    this.fontWeight = FontWeight.w600,
  });

  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: fillColor,
          ),
        ),
      ],
    );
  }
}
