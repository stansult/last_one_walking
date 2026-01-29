// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.showIcon = true,
    this.showLabel = true,
    this.iconSize,
    this.iconGap,
    this.fontSize,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool showIcon;
  final bool showLabel;
  final double? iconSize;
  final double? iconGap;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: AppVisuals.actionPadding,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) Icon(icon, size: iconSize ?? AppVisuals.actionIconSize),
          if (showIcon && showLabel)
            SizedBox(width: iconGap ?? AppVisuals.actionIconGap),
          if (showLabel)
            Text(
              label,
              style: TextStyle(fontSize: fontSize ?? AppVisuals.actionFontSize),
            ),
        ],
      ),
    );
  }
}
