// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _PresetActionRow extends StatelessWidget {
  const _PresetActionRow({
    required this.showSave,
    required this.saveEnabled,
    required this.showSaveAs,
    required this.saveAsEnabled,
    required this.canDelete,
    required this.onSave,
    required this.onSaveAs,
    required this.onDelete,
  });

  final bool showSave;
  final bool saveEnabled;
  final bool showSaveAs;
  final bool saveAsEnabled;
  final bool canDelete;
  final VoidCallback onSave;
  final VoidCallback onSaveAs;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final textStyle = theme.textTheme.bodyMedium ??
            const TextStyle(fontSize: AppVisuals.actionFontSize);

        double measureLabel(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          return painter.width;
        }

        final labels = <String>[
          if (showSave) 'Save',
          if (showSaveAs) 'Save as...',
          if (canDelete) 'Delete',
        ];

        final baseIcon = AppVisuals.actionIconSize;
        final baseGap = AppVisuals.actionIconGap;
        final baseButtonGap = AppVisuals.actionButtonGap;
        final baseFont = AppVisuals.actionFontSize;

        final compactIcon = AppVisuals.actionIconSizeCompact;
        final compactGap = AppVisuals.actionIconGapCompact;
        final compactButtonGap = AppVisuals.actionButtonGapCompact;
        final compactFont = AppVisuals.actionFontSizeCompact;

        double totalWidth({
          required bool showIcons,
          required bool showLabels,
          required double iconSize,
          required double iconGap,
          required double fontSize,
          required double buttonGap,
        }) {
          final style = textStyle.copyWith(fontSize: fontSize);
          var width = 0.0;
          for (var i = 0; i < labels.length; i++) {
            if (showLabels) {
              width += measureLabel(labels[i], style);
            }
            if (showIcons && showLabels) {
              width += iconSize + iconGap;
            } else if (showIcons && !showLabels) {
              width += iconSize;
            }
            width += AppVisuals.actionPadding.horizontal;
            if (i != labels.length - 1) {
              width += buttonGap;
            }
          }
          return width;
        }

        var showIcons = true;
        var showLabels = true;
        var iconSize = baseIcon;
        var iconGap = baseGap;
        var fontSize = baseFont;
        var buttonGap = baseButtonGap;

        var needed = totalWidth(
          showIcons: showIcons,
          showLabels: showLabels,
          iconSize: iconSize,
          iconGap: iconGap,
          fontSize: fontSize,
          buttonGap: buttonGap,
        );

        if (needed > constraints.maxWidth) {
          iconSize = compactIcon;
          iconGap = compactGap;
          fontSize = compactFont;
          buttonGap = compactButtonGap;
          needed = totalWidth(
            showIcons: showIcons,
            showLabels: showLabels,
            iconSize: iconSize,
            iconGap: iconGap,
            fontSize: fontSize,
            buttonGap: buttonGap,
          );
        }

        if (needed > constraints.maxWidth) {
          showIcons = false;
          needed = totalWidth(
            showIcons: showIcons,
            showLabels: showLabels,
            iconSize: iconSize,
            iconGap: iconGap,
            fontSize: fontSize,
            buttonGap: buttonGap,
          );
        }

        if (needed > constraints.maxWidth) {
          showLabels = false;
          showIcons = true;
        }

        final buttons = <Widget>[
          if (showSave)
            _ActionButton(
              label: 'Save',
              icon: Icons.save_outlined,
              onPressed: saveEnabled ? onSave : null,
              showIcon: showIcons,
              showLabel: showLabels,
              iconSize: iconSize,
              iconGap: iconGap,
              fontSize: fontSize,
            ),
          if (showSaveAs)
            _ActionButton(
              label: 'Save as...',
              icon: Icons.bookmark_add_outlined,
              onPressed: saveAsEnabled ? onSaveAs : null,
              showIcon: showIcons,
              showLabel: showLabels,
              iconSize: iconSize,
              iconGap: iconGap,
              fontSize: fontSize,
            ),
          if (canDelete)
            _ActionButton(
              label: 'Delete',
              icon: Icons.delete_outline,
              onPressed: onDelete,
              showIcon: showIcons,
              showLabel: showLabels,
              iconSize: iconSize,
              iconGap: iconGap,
              fontSize: fontSize,
            ),
        ];

        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              if (i > 0) SizedBox(width: buttonGap),
              buttons[i],
            ],
          ],
        );
      },
    );
  }
}
