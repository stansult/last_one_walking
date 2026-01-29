// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _SoloWalkRow extends StatelessWidget {
  const _SoloWalkRow({
    required this.groupValue,
    required this.onChanged,
    required this.goalMilesController,
    required this.infoIconSize,
  });

  final WinMode groupValue;
  final ValueChanged<WinMode?> onChanged;
  final TextEditingController goalMilesController;
  final double infoIconSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final theme = Theme.of(context);
        final labelStyle = theme.textTheme.bodyLarge;
        final valueStyle =
            theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
        final suffixStyle = theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7A6B63),
            );

        void showInfo() {
          void hideKeyboard() {
            FocusManager.instance.primaryFocus?.unfocus();
            FocusScope.of(context).unfocus();
            SystemChannels.textInput.invokeMethod('TextInput.hide');
          }
          hideKeyboard();
          showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (context) {
              return const AlertDialog(
                title: Text('Miles to win'),
                content: Text('Distance required to end the walk in solo mode.'),
              );
            },
          ).then((_) => hideKeyboard());
        }

        double measureText(String text, TextStyle? style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          return painter.width;
        }

        const valueSample = '000.0';
        const unit = ' miles';
        final basePadding = AppVisuals.numberFieldPadding;
        final compactPadding = AppVisuals.numberFieldPaddingCompact;
        final infoIconSizeCompact = infoIconSize;
        final infoButtonSize = AppVisuals.infoTapSize;
        final stepperButtonSize = AppVisuals.stepperMinTapSize;
        final labelGap = AppVisuals.ruleLabelGap;
        final labelGapCompact = AppVisuals.ruleLabelGapCompact;
        var infoGap = AppVisuals.ruleInfoGap;

        double fieldMinWidth({
          required EdgeInsets padding,
          required double buttonSize,
        }) {
          final valueWidth = measureText(valueSample, valueStyle);
          final unitWidth = measureText(unit.trimLeft(), suffixStyle);
          return valueWidth +
              unitWidth +
              padding.horizontal +
              buttonSize * 2 +
              8;
        }

        bool showInfoIcon = true;
        bool useCompact = false;
        double currentLabelWidth = AppVisuals.ruleLabelWidth;
        double currentLabelGap = labelGap;
        double currentInfoIconSize = infoIconSize;
        EdgeInsets currentPadding = basePadding;
        double currentStepperIconSize = AppVisuals.stepperIconSize;

        double currentFieldMinWidth = fieldMinWidth(
          padding: currentPadding,
          buttonSize: stepperButtonSize,
        );

        double totalWidth({
          required bool includeInfo,
          required double labelWidth,
          required double labelGapValue,
          required double fieldMin,
        }) {
          return labelWidth +
              labelGapValue +
              fieldMin +
              (includeInfo ? infoGap + infoButtonSize : 0);
        }

        double minTotal = totalWidth(
          includeInfo: showInfoIcon,
          labelWidth: currentLabelWidth,
          labelGapValue: currentLabelGap,
          fieldMin: currentFieldMinWidth,
        );

        if (constraints.maxWidth < minTotal) {
          useCompact = true;
          currentLabelGap = labelGapCompact;
          currentPadding = compactPadding;
          currentStepperIconSize = AppVisuals.stepperIconSizeCompact;
          currentInfoIconSize = infoIconSizeCompact;
          infoGap = AppVisuals.ruleInfoGapCompact;
          currentFieldMinWidth = fieldMinWidth(
            padding: currentPadding,
            buttonSize: stepperButtonSize,
          );
          minTotal = totalWidth(
            includeInfo: showInfoIcon,
            labelWidth: currentLabelWidth,
            labelGapValue: currentLabelGap,
            fieldMin: currentFieldMinWidth,
          );
        }

        if (constraints.maxWidth < minTotal) {
          final availableLabelWidth = constraints.maxWidth -
              currentLabelGap -
              currentFieldMinWidth -
              (showInfoIcon ? infoGap + infoButtonSize : 0);
          currentLabelWidth = availableLabelWidth
              .clamp(0, AppVisuals.ruleLabelWidth)
              .toDouble();
          if (currentLabelWidth < AppVisuals.ruleLabelMinWidth) {
            currentLabelWidth = math.max(0, availableLabelWidth);
          }
          minTotal = totalWidth(
            includeInfo: showInfoIcon,
            labelWidth: currentLabelWidth,
            labelGapValue: currentLabelGap,
            fieldMin: currentFieldMinWidth,
          );
        }

        if (constraints.maxWidth < minTotal && showInfoIcon) {
          showInfoIcon = false;
          minTotal = totalWidth(
            includeInfo: false,
            labelWidth: currentLabelWidth,
            labelGapValue: currentLabelGap,
            fieldMin: currentFieldMinWidth,
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: currentLabelWidth,
              child: Row(
                children: [
                  SizedBox(
                    width: AppVisuals.radioLeadingWidth,
                    child: Radio<WinMode>(
                      value: WinMode.solo,
                      groupValue: groupValue,
                      onChanged: onChanged,
                    ),
                  ),
                  const SizedBox(width: AppVisuals.radioTitleGap),
                  Expanded(
                    child: Text('Solo', style: labelStyle),
                  ),
                ],
              ),
            ),
            SizedBox(width: currentLabelGap),
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: currentFieldMinWidth),
                child: _NumberField(
                  label: 'Miles to win',
                  controller: goalMilesController,
                  suffix: unit,
                  decimal: true,
                  infoBody: 'Distance required to end the walk in solo mode.',
                  step: 1,
                  minValue: 0.1,
                  maxValue: 100.0,
                  showLabelInField: false,
                  showInfoIcon: false,
                  maxLength: 5,
                  contentPadding: currentPadding,
                  stepperIconSize: currentStepperIconSize,
                  stepperMinTapSize: AppVisuals.stepperMinTapSize,
                ),
              ),
            ),
            if (showInfoIcon) ...[
              SizedBox(width: infoGap),
              SizedBox(
                width: AppVisuals.infoTapSize,
                height: AppVisuals.infoTapSize,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    icon: Icon(
                      Icons.info_outline,
                      size: useCompact ? currentInfoIconSize : infoIconSize,
                    ),
                    tooltip: 'Info',
                    onPressed: showInfo,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
