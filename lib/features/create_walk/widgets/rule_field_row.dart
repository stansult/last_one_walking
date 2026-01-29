// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _RuleFieldRow extends StatelessWidget {
  const _RuleFieldRow({
    required this.label,
    required this.valueSample,
    required this.unit,
    required this.controller,
    required this.decimal,
    required this.step,
    required this.minValue,
    required this.highlightChanged,
    this.maxValue,
    this.infoTitle,
    this.infoBody,
    this.forceInfoIconSize,
  });

  final String label;
  final String valueSample;
  final String unit;
  final TextEditingController controller;
  final bool decimal;
  final double step;
  final double minValue;
  final double? maxValue;
  final bool highlightChanged;
  final String? infoTitle;
  final String? infoBody;
  final double? forceInfoIconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodyMedium;
    final valueStyle =
        theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
    final suffixStyle = theme.textTheme.bodySmall?.copyWith(
          color: const Color(0xFF7A6B63),
        );

    void showInfo() {
      if (infoBody == null) {
        return;
      }
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
          return AlertDialog(
            title: Text(infoTitle ?? label),
            content: Text(infoBody!),
          );
        },
      ).then((_) => hideKeyboard());
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final basePadding = AppVisuals.numberFieldPadding;
        final compactPadding = AppVisuals.numberFieldPaddingCompact;
        final infoIconSize = forceInfoIconSize ?? AppVisuals.infoIconSize;
        final infoIconSizeCompact =
            forceInfoIconSize ?? AppVisuals.infoIconSizeCompact;
        final infoButtonSize = AppVisuals.infoTapSize;
        final stepperButtonSize = AppVisuals.stepperMinTapSize;
        final labelGap = AppVisuals.ruleLabelGap;
        final labelGapCompact = AppVisuals.ruleLabelGapCompact;
        var infoGap = AppVisuals.ruleInfoGap;

        double measureText(String text, TextStyle? style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            textDirection: TextDirection.ltr,
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          return painter.width;
        }

        double fieldMinWidth({
          required EdgeInsets padding,
          required double buttonSize,
        }) {
          final valueWidth = measureText(valueSample, valueStyle);
          final unitWidth =
              unit.isEmpty ? 0 : measureText(unit.trimLeft(), suffixStyle);
          return valueWidth +
              unitWidth +
              padding.horizontal +
              buttonSize * 2 +
              8;
        }

        bool showInfoIcon = infoBody != null;
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

        if (maxWidth < minTotal) {
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

        if (maxWidth < minTotal) {
          final availableLabelWidth = maxWidth -
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

        if (maxWidth < minTotal && showInfoIcon) {
          showInfoIcon = false;
          minTotal = totalWidth(
            includeInfo: false,
            labelWidth: currentLabelWidth,
            labelGapValue: currentLabelGap,
            fieldMin: currentFieldMinWidth,
          );
        }

        final labelWidget = InkWell(
          onTap: infoBody != null ? showInfo : null,
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: currentLabelWidth,
            child: Text(
              label,
              style: labelStyle,
              softWrap: true,
            ),
          ),
        );

        final fieldWidget = ConstrainedBox(
          constraints: BoxConstraints(minWidth: currentFieldMinWidth),
          child: _NumberField(
            label: label,
            controller: controller,
            decimal: decimal,
            suffix: unit.isEmpty ? null : unit,
            step: step,
            minValue: minValue,
            maxValue: maxValue,
            highlightChanged: highlightChanged,
            showLabelInField: false,
            showInfoIcon: false,
            textStyle: valueStyle,
            contentPadding: currentPadding,
            stepperIconSize: currentStepperIconSize,
            stepperMinTapSize: AppVisuals.stepperMinTapSize,
            maxLength: valueSample.length,
          ),
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            labelWidget,
            SizedBox(width: currentLabelGap),
            Expanded(child: fieldWidget),
            if (showInfoIcon) ...[
              SizedBox(width: infoGap),
              SizedBox(
                width: AppVisuals.infoTapSize,
                height: AppVisuals.infoTapSize,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: showInfo,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    icon: Icon(
                      Icons.info_outline,
                      size: useCompact ? currentInfoIconSize : infoIconSize,
                    ),
                    tooltip: 'Info',
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
