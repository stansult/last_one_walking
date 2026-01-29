// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
part of '../create_walk_screen.dart';

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.controller,
    required this.decimal,
    this.suffix,
    this.hintText,
    this.enabled = true,
    this.infoTitle,
    this.infoBody,
    this.step,
    this.minValue,
    this.maxValue,
    this.highlightChanged = false,
    this.showLabelInField = true,
    this.showInfoIcon = true,
    this.textStyle,
    this.contentPadding,
    this.stepperIconSize,
    this.stepperMinTapSize,
    this.maxLength,
    this.inlineSuffix = true,
  });

  final String label;
  final TextEditingController controller;
  final bool decimal;
  final String? suffix;
  final String? hintText;
  final bool enabled;
  final String? infoTitle;
  final String? infoBody;
  final double? step;
  final double? minValue;
  final double? maxValue;
  final bool highlightChanged;
  final bool showLabelInField;
  final bool showInfoIcon;
  final TextStyle? textStyle;
  final EdgeInsets? contentPadding;
  final double? stepperIconSize;
  final double? stepperMinTapSize;
  final int? maxLength;
  final bool inlineSuffix;

  @override
  Widget build(BuildContext context) {
    final formatter = decimal
        ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}$'))
        : FilteringTextInputFormatter.digitsOnly;
    final inputFormatters = <TextInputFormatter>[formatter];
    if (maxLength != null) {
      inputFormatters.add(LengthLimitingTextInputFormatter(maxLength));
    }

    final showInfo = infoBody != null;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: highlightChanged
            ? AppVisuals.changedFieldBorderColor
            : Colors.black26,
      ),
    );

    void hideKeyboard() {
      FocusManager.instance.primaryFocus?.unfocus();
      FocusScope.of(context).unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }

    final buttonSize = stepperMinTapSize ?? AppVisuals.stepperMinTapSize;
    final iconSize = stepperIconSize ?? AppVisuals.stepperIconSize;

    void clampControllerValue() {
      final current = double.tryParse(controller.text);
      if (current == null) {
        return;
      }
      var next = current;
      if (minValue != null && next < minValue!) {
        next = minValue!;
      }
      if (maxValue != null && next > maxValue!) {
        next = maxValue!;
      }
      final text =
          decimal ? next.toStringAsFixed(1) : next.toStringAsFixed(0);
      if (controller.text != text) {
        controller.text = text;
      }
    }

    final unitText = (suffix ?? '').trimLeft();
    final showInlineSuffix = inlineSuffix && step != null;

    final field = ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final current = double.tryParse(value.text);
        final isAtMin = current != null &&
            minValue != null &&
            current <= minValue! + 0.0001;
        final isAtMax = current != null &&
            maxValue != null &&
            current >= maxValue! - 0.0001;

        final Widget? suffixWidget = showInlineSuffix
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (unitText.isNotEmpty)
                    Text(
                      unitText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF7A6B63),
                          ),
                    ),
                  if (step != null) const SizedBox(width: 2),
                  if (step != null)
                    IconButton(
                      onPressed: (enabled && !isAtMax)
                          ? () {
                              hideKeyboard();
                              _adjust(
                                step!,
                                minValue: minValue,
                                maxValue: maxValue,
                              );
                            }
                          : null,
                      icon: Icon(Icons.add, size: iconSize),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      disabledColor: Colors.black26,
                      constraints: BoxConstraints(
                        minWidth: buttonSize,
                        minHeight: buttonSize,
                      ),
                    ),
                ],
              )
            : null;

        return Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              clampControllerValue();
            }
          },
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType:
                TextInputType.numberWithOptions(decimal: decimal, signed: false),
            inputFormatters: inputFormatters,
            style: textStyle,
            decoration: InputDecoration(
              labelText: showLabelInField ? label : null,
              hintText: hintText,
              suffixText: showInlineSuffix ? null : suffix,
              suffixStyle: showInlineSuffix
                  ? null
                  : Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF7A6B63),
                      ),
              contentPadding: contentPadding ?? AppVisuals.numberFieldPadding,
          fillColor: highlightChanged
              ? AppVisuals.changedFieldFillColor
                  .withOpacity(AppVisuals.changedFieldFillOpacity)
              : null,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(
                  color: highlightChanged
                      ? AppVisuals.changedFieldBorderColor
                      : Theme.of(context).colorScheme.primary,
                  width: 1.4,
                ),
              ),
              disabledBorder: border,
              prefixIcon: step != null
                  ? IconButton(
                      onPressed: (enabled && !isAtMin)
                          ? () {
                              hideKeyboard();
                              _adjust(
                                step! * -1,
                                minValue: minValue,
                                maxValue: maxValue,
                              );
                            }
                          : null,
                      icon: Icon(Icons.remove, size: iconSize),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      disabledColor: Colors.black26,
                      constraints: BoxConstraints.tightFor(
                        width: buttonSize,
                        height: buttonSize,
                      ),
                    )
                  : null,
          prefixIconConstraints:
              BoxConstraints.tightFor(width: buttonSize, height: buttonSize),
          suffixIcon: suffixWidget ??
              (step != null
                  ? IconButton(
                          onPressed: (enabled && !isAtMax)
                              ? () {
                                  hideKeyboard();
                                  _adjust(
                                    step!,
                                    minValue: minValue,
                                    maxValue: maxValue,
                                  );
                                }
                              : null,
                      icon: Icon(Icons.add, size: iconSize),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      disabledColor: Colors.black26,
                      constraints: BoxConstraints.tightFor(
                        width: buttonSize,
                        height: buttonSize,
                      ),
                    )
                  : null),
          suffixIconConstraints: BoxConstraints(
            minWidth: showInlineSuffix ? 0 : buttonSize,
            minHeight: buttonSize,
          ),
            ),
          ),
        );
      },
    );

    if (!showInfo || !showInfoIcon) {
      return field;
    }

    return Row(
      children: [
        Expanded(child: field),
        const SizedBox(width: AppVisuals.numberFieldInfoGap),
        SizedBox(
          width: AppVisuals.infoTapSize,
          height: AppVisuals.infoTapSize,
          child: Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon:
                  const Icon(Icons.info_outline, size: AppVisuals.infoIconSize),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              tooltip: 'Info',
              onPressed: () {
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
              },
            ),
          ),
        ),
      ],
    );
  }

  void _adjust(double delta, {double? minValue, double? maxValue}) {
    final current = double.tryParse(controller.text) ?? 0;
    var next = current + delta;
    if (minValue != null && next < minValue) {
      next = minValue;
    }
    if (maxValue != null && next > maxValue) {
      next = maxValue;
    }
    final text = decimal ? next.toStringAsFixed(1) : next.toStringAsFixed(0);
    controller.text = text;
  }
}
