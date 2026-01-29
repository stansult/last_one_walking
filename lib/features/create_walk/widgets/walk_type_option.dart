// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _WalkTypeOption extends StatelessWidget {
  const _WalkTypeOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final WinMode value;
  final WinMode groupValue;
  final ValueChanged<WinMode?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onChanged != null;
    final titleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: isEnabled ? null : Colors.black45,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: isEnabled ? Colors.black54 : Colors.black26,
        );

    return InkWell(
      onTap: isEnabled ? () => onChanged?.call(value) : null,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: AppVisuals.radioLeadingWidth,
                child: Radio<WinMode>(
                  value: value,
                  groupValue: groupValue,
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: AppVisuals.radioTitleGap),
              Expanded(child: Text(title, style: titleStyle)),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: AppVisuals.radioLeadingWidth + AppVisuals.radioTitleGap,
            ),
            child: Text(subtitle, style: subtitleStyle),
          ),
        ],
      ),
    );
  }
}
