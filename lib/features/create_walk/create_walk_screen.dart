// ignore_for_file: dead_code, deprecated_member_use, unnecessary_non_null_assertion, unused_element, unused_element_parameter
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/app_visuals.dart';
import '../active_walk/active_walk_screen.dart';
import 'models/walk_preset.dart';
part 'widgets/card_surface.dart';
part 'widgets/section_card.dart';
part 'widgets/collapsible_section.dart';
part 'widgets/section_card_body.dart';
part 'widgets/section_label.dart';
part 'widgets/styled_text.dart';
part 'widgets/rule_field_row.dart';
part 'widgets/action_button.dart';
part 'widgets/preset_action_row.dart';
part 'widgets/walk_type_option.dart';
part 'widgets/solo_walk_row.dart';
part 'widgets/outlined_text.dart';
part 'widgets/number_field.dart';




enum WinMode { solo, event }

class CreateWalkScreen extends StatefulWidget {
  const CreateWalkScreen({super.key});

  @override
  State<CreateWalkScreen> createState() => _CreateWalkScreenState();
}

class _CreateWalkScreenState extends State<CreateWalkScreen>
    with SingleTickerProviderStateMixin {
  static const _basePresets = [
    WalkPreset(
      key: 'movie',
      name: 'Movie',
      minSpeedMph: 3.0,
      warningSeconds: 10,
      warnings: 3,
      decayMinutes: 60,
    ),
    WalkPreset(
      key: 'book',
      name: 'Book',
      minSpeedMph: 4.0,
      warningSeconds: 30,
      warnings: 3,
      decayMinutes: 60,
    ),
    WalkPreset(
      key: 'training',
      name: 'Training',
      minSpeedMph: 2.5,
      warningSeconds: 20,
      warnings: 5,
      decayMinutes: 30,
    ),
    WalkPreset(
      key: 'easy',
      name: 'Easy',
      minSpeedMph: 2.0,
      warningSeconds: 25,
      warnings: 6,
      decayMinutes: 20,
    ),
  ];

  static const _customPresetKey = '_custom';
  final List<WalkPreset> _customPresets = [];
  String _selectedPresetKey = _basePresets.first.key;
  bool _isApplyingPreset = false;
  static const double _bottomButtonHeight = 52;
  static const double _bottomBarTopPadding = 10;
  static const double _bottomBarBottomPadding = 24;
  static const double _bottomBarExtraPadding = 10;
  final GlobalKey _bottomBarKey = GlobalKey();
  final GlobalKey _contentEndKey = GlobalKey();
  double _bottomBarHeight = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showBottomFade = false;
  double? _fadeLeft;
  double? _fadeWidth;
  late final TextEditingController _minSpeedController;
  late final TextEditingController _warningSecondsController;
  late final TextEditingController _warningsController;
  late final TextEditingController _decayMinutesController;
  late final TextEditingController _goalMilesController;
  WinMode _winMode = WinMode.solo;
  bool _rulesExpanded = false;
  String? _lastPresetKey;
  double _baselineMinSpeed = 0;
  int _baselineWarningSeconds = 0;
  int _baselineWarnings = 0;
  int _baselineDecayMinutes = 0;

  @override
  void initState() {
    super.initState();
    final initial = _basePresets.first;
    _minSpeedController = TextEditingController(
      text: initial.minSpeedMph.toStringAsFixed(1),
    );
    _warningSecondsController =
        TextEditingController(text: initial.warningSeconds.toString());
    _warningsController = TextEditingController(text: initial.warnings.toString());
    _decayMinutesController =
        TextEditingController(text: initial.decayMinutes.toString());
                          _goalMilesController = TextEditingController(text: '5.0');

    _minSpeedController.addListener(_handleFieldChange);
    _warningSecondsController.addListener(_handleFieldChange);
    _warningsController.addListener(_handleFieldChange);
    _decayMinutesController.addListener(_handleFieldChange);
    _lastPresetKey = _selectedPresetKey;
    _setBaselineFromPreset(initial);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hideKeyboard();
    });
    _scrollController.addListener(_updateBottomFadeFromLayout);
  }

  void _updateBottomBarHeight() {
    final context = _bottomBarKey.currentContext;
    if (context == null) {
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }
    final newHeight = box.size.height;
    if ((_bottomBarHeight - newHeight).abs() < 0.5) {
      return;
    }
    setState(() {
      _bottomBarHeight = newHeight;
    });
  }

  void _scheduleBottomFadeUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBottomFadeFromLayout();
    });
  }

  void _updateBottomFadeFromLayout() {
    if (!mounted) {
      return;
    }
    final endContext = _contentEndKey.currentContext;
    final barContext = _bottomBarKey.currentContext;
    if (endContext == null || barContext == null) {
      return;
    }
    final endBox = endContext.findRenderObject() as RenderBox?;
    final barBox = barContext.findRenderObject() as RenderBox?;
    if (endBox == null || barBox == null || !endBox.hasSize || !barBox.hasSize) {
      return;
    }
    final endBottom = endBox.localToGlobal(Offset.zero).dy + endBox.size.height;
    final endLeft = endBox.localToGlobal(Offset.zero).dx;
    final barTop = barBox.localToGlobal(Offset.zero).dy;
    final shouldShow = endBottom > barTop + 0.5;
    final nextFadeLeft = endLeft;
    final nextFadeWidth = endBox.size.width;
    if ((_fadeLeft ?? -1) != nextFadeLeft ||
        (_fadeWidth ?? -1) != nextFadeWidth) {
      setState(() {
        _fadeLeft = nextFadeLeft;
        _fadeWidth = nextFadeWidth;
      });
    }
    if (_showBottomFade == shouldShow) {
      return;
    }
    setState(() => _showBottomFade = shouldShow);
  }

  @override
  void dispose() {
    _minSpeedController.dispose();
    _warningSecondsController.dispose();
    _warningsController.dispose();
    _decayMinutesController.dispose();
    _goalMilesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyPreset(WalkPreset preset) {
    _isApplyingPreset = true;
    _minSpeedController.text = preset.minSpeedMph.toStringAsFixed(1);
    _warningSecondsController.text = preset.warningSeconds.toString();
    _warningsController.text = preset.warnings.toString();
    _decayMinutesController.text = preset.decayMinutes.toString();
    setState(() {
      _selectedPresetKey = preset.key;
      _lastPresetKey = preset.key;
      _setBaselineFromPreset(preset);
    });
    _isApplyingPreset = false;
  }

  void _handleFieldChange() {
    if (_isApplyingPreset) {
      return;
    }
    setState(() {});
    _syncPresetSelection();
  }

  void _syncPresetSelection() {
    final minSpeed = double.tryParse(_minSpeedController.text);
    final warningSeconds = int.tryParse(_warningSecondsController.text);
    final warnings = int.tryParse(_warningsController.text);
    final decayMinutes = int.tryParse(_decayMinutesController.text);

    if (_isCustomPresetKey(_selectedPresetKey)) {
      return;
    }

    if (minSpeed == null ||
        warningSeconds == null ||
        warnings == null ||
        decayMinutes == null) {
      if (_selectedPresetKey != _customPresetKey) {
        setState(() {
          _lastPresetKey = _selectedPresetKey;
          _selectedPresetKey = _customPresetKey;
        });
      }
      return;
    }

    WalkPreset? matched;
    for (final preset in [..._basePresets, ..._customPresets]) {
      final speedMatch = (preset.minSpeedMph - minSpeed).abs() < 0.01;
      if (speedMatch &&
          preset.warningSeconds == warningSeconds &&
          preset.warnings == warnings &&
          preset.decayMinutes == decayMinutes) {
        matched = preset;
        break;
      }
    }

    if (matched != null) {
      if (_selectedPresetKey != matched.key) {
        setState(() {
          _selectedPresetKey = matched!.key;
          _lastPresetKey = matched!.key;
        });
      }
    } else if (_selectedPresetKey != _customPresetKey) {
      setState(() {
        _lastPresetKey = _selectedPresetKey;
        _selectedPresetKey = _customPresetKey;
      });
    }
  }

  bool _isBasePresetKey(String key) {
    return _basePresets.any((preset) => preset.key == key);
  }

  bool _isCustomPresetKey(String key) {
    return _customPresets.any((preset) => preset.key == key);
  }

  String _normalizeName(String name) => name.trim().toLowerCase();

  bool _isReservedPresetName(String name) {
    final normalized = _normalizeName(name);
    if (normalized == 'custom') {
      return true;
    }
    return _basePresets
        .map((preset) => _normalizeName(preset.name))
        .contains(normalized);
  }

  WalkPreset? _customPresetByName(String name) {
    final normalized = _normalizeName(name);
    for (final preset in _customPresets) {
      if (_normalizeName(preset.name) == normalized) {
        return preset;
      }
    }
    return null;
  }

  WalkPreset? _presetFromInputs(String name, String key) {
    final minSpeed = double.tryParse(_minSpeedController.text);
    final warningSeconds = int.tryParse(_warningSecondsController.text);
    final warnings = int.tryParse(_warningsController.text);
    final decayMinutes = int.tryParse(_decayMinutesController.text);

    if (minSpeed == null ||
        minSpeed <= 0 ||
        warningSeconds == null ||
        warningSeconds <= 0 ||
        warnings == null ||
        warnings <= 0 ||
        decayMinutes == null ||
        decayMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid positive numbers for all fields.'),
        ),
      );
      return null;
    }

    return WalkPreset(
      key: key,
      name: name,
      minSpeedMph: minSpeed,
      warningSeconds: warningSeconds,
      warnings: warnings,
      decayMinutes: decayMinutes,
    );
  }

  void _hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  Future<T?> _withKeyboardDismissed<T>(Future<T?> Function() action) async {
    _hideKeyboard();
    final result = await action();
    _hideKeyboard();
    return result;
  }

  Future<void> _saveCustomPreset() async {
    final controller = TextEditingController();
    final name = await _withKeyboardDismissed(() {
      return showDialog<String>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              final trimmed = controller.text.trim();
              final canSubmit =
                  trimmed.isNotEmpty && !_isReservedPresetName(trimmed);
              return AlertDialog(
                title: const Text('Save preset'),
                content: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.words,
                  autocorrect: false,
                  enableSuggestions: false,
                  smartDashesType: SmartDashesType.disabled,
                  smartQuotesType: SmartQuotesType.disabled,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Preset name',
                    hintText: 'My Training',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: canSubmit
                        ? () => Navigator.of(context).pop(trimmed)
                        : null,
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );
    });

    if (name == null || name.isEmpty) {
      return;
    }

    final existing = _customPresetByName(name);
    if (existing != null) {
      final overwrite = await _withKeyboardDismissed(() {
        return showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Overwrite preset?'),
              content: Text('Replace the existing "$name" preset?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Overwrite'),
                ),
              ],
            );
          },
        );
      });

      if (overwrite != true) {
        return;
      }

      final updated = _presetFromInputs(existing.name, existing.key);
      if (updated == null) {
        return;
      }

      setState(() {
        final index =
            _customPresets.indexWhere((preset) => preset.key == existing.key);
        if (index != -1) {
          _customPresets[index] = updated;
        }
      _selectedPresetKey = updated.key;
      _lastPresetKey = updated.key;
      _setBaselineFromPreset(updated);
    });
      return;
    }

    final key = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final preset = _presetFromInputs(name, key);
    if (preset == null) {
      return;
    }

    setState(() {
      _customPresets.add(preset);
      _selectedPresetKey = preset.key;
      _lastPresetKey = preset.key;
      _setBaselineFromPreset(preset);
    });
  }

  void _createWalk() {
    final preset = _presetFromInputs('Current', 'current');
    if (preset == null) {
      return;
    }

    final goalMiles = double.tryParse(_goalMilesController.text);
    if (_winMode == WinMode.solo && (goalMiles == null || goalMiles <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid mileage goal to win.'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ActiveWalkScreen(
          preset: preset,
          goalMiles: _winMode == WinMode.solo ? goalMiles : null,
        ),
      ),
    );
  }

  WalkPreset? _presetByKey(String key) {
    for (final preset in [..._basePresets, ..._customPresets]) {
      if (preset.key == key) {
        return preset;
      }
    }
    return null;
  }

  WalkPreset? _comparisonPreset() {
    if (_selectedPresetKey != _customPresetKey) {
      return _presetByKey(_selectedPresetKey);
    }
    final fallbackKey = _lastPresetKey ?? _basePresets.first.key;
    return _presetByKey(fallbackKey);
  }

  void _setBaselineFromPreset(WalkPreset preset) {
    _baselineMinSpeed = preset.minSpeedMph;
    _baselineWarningSeconds = preset.warningSeconds;
    _baselineWarnings = preset.warnings;
    _baselineDecayMinutes = preset.decayMinutes;
  }

  bool _isFieldChangedFromBaseline({
    required double? currentNumber,
    required double baselineNumber,
    double epsilon = 0.01,
  }) {
    if (currentNumber == null) {
      return false;
    }
    return (currentNumber - baselineNumber).abs() > epsilon;
  }

  bool _isFieldChanged({
    required double? currentNumber,
    required double? presetNumber,
    double epsilon = 0.01,
  }) {
    if (currentNumber == null || presetNumber == null) {
      return false;
    }
    return (currentNumber - presetNumber).abs() > epsilon;
  }

  bool _currentValuesValid() {
    final minSpeed = double.tryParse(_minSpeedController.text);
    final warningSeconds = int.tryParse(_warningSecondsController.text);
    final warnings = int.tryParse(_warningsController.text);
    final decayMinutes = int.tryParse(_decayMinutesController.text);
    return minSpeed != null &&
        minSpeed > 0 &&
        warningSeconds != null &&
        warningSeconds > 0 &&
        warnings != null &&
        warnings > 0 &&
        decayMinutes != null &&
        decayMinutes > 0;
  }

  bool _valuesMatchPreset(WalkPreset preset) {
    final minSpeed = double.tryParse(_minSpeedController.text);
    final warningSeconds = int.tryParse(_warningSecondsController.text);
    final warnings = int.tryParse(_warningsController.text);
    final decayMinutes = int.tryParse(_decayMinutesController.text);

    if (minSpeed == null ||
        warningSeconds == null ||
        warnings == null ||
        decayMinutes == null) {
      return false;
    }

    final speedMatch = (preset.minSpeedMph - minSpeed).abs() < 0.01;
    return speedMatch &&
        preset.warningSeconds == warningSeconds &&
        preset.warnings == warnings &&
        preset.decayMinutes == decayMinutes;
  }

  void _saveSelectedPreset() {
    if (!_isCustomPresetKey(_selectedPresetKey)) {
      return;
    }
    final current = _presetByKey(_selectedPresetKey);
    if (current == null) {
      return;
    }
    final updated = _presetFromInputs(current.name, current.key);
    if (updated == null) {
      return;
    }

    setState(() {
      final index =
          _customPresets.indexWhere((preset) => preset.key == current.key);
      if (index != -1) {
        _customPresets[index] = updated;
      }
      _lastPresetKey = current.key;
      _setBaselineFromPreset(updated);
    });
  }

  double _infoIconSizeForWidth(double width) {
    return width < 360
        ? AppVisuals.infoIconSizeCompact
        : AppVisuals.infoIconSize;
  }

  Future<void> _deleteCustomPreset() async {
    if (!_isCustomPresetKey(_selectedPresetKey)) {
      return;
    }
    final preset = _presetByKey(_selectedPresetKey);
    if (preset == null) {
      return;
    }
    final confirmed = await _withKeyboardDismissed(() {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete preset?'),
            content: Text('Remove "${preset.name}" from your presets?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    });

    if (confirmed != true) {
      return;
    }

    setState(() {
      _customPresets.removeWhere((item) => item.key == preset.key);
      _selectedPresetKey = _basePresets.first.key;
    });
    _applyPreset(_basePresets.first);
  }

  @override
  Widget build(BuildContext context) {
    final showCustomOption = _selectedPresetKey == _customPresetKey;
    final isBaseSelected = _isBasePresetKey(_selectedPresetKey);
    final isCustomSelected = _isCustomPresetKey(_selectedPresetKey);
    final selectedPreset = _presetByKey(_selectedPresetKey);
    final isDirty =
        selectedPreset == null ? true : !_valuesMatchPreset(selectedPreset);
    final isValid = _currentValuesValid();
    final showSave = isCustomSelected;
    final saveEnabled = isCustomSelected && isDirty && isValid;
    final showSaveAs = true;
    final saveAsEnabled = isValid && (!isBaseSelected || isDirty);
    final canDeletePreset = isCustomSelected;
    final comparison = _comparisonPreset();
    if (comparison != null &&
        comparison.key != _lastPresetKey &&
        _selectedPresetKey != _customPresetKey) {
      _setBaselineFromPreset(comparison);
      _lastPresetKey = comparison.key;
    }
    final minSpeedChanged = _isFieldChangedFromBaseline(
      currentNumber: double.tryParse(_minSpeedController.text),
      baselineNumber: _baselineMinSpeed,
    );
    final warningSecondsChanged = _isFieldChangedFromBaseline(
      currentNumber: double.tryParse(_warningSecondsController.text),
      baselineNumber: _baselineWarningSeconds.toDouble(),
      epsilon: 0.5,
    );
    final warningsChanged = _isFieldChangedFromBaseline(
      currentNumber: double.tryParse(_warningsController.text),
      baselineNumber: _baselineWarnings.toDouble(),
      epsilon: 0.5,
    );
    final decayChanged = _isFieldChangedFromBaseline(
      currentNumber: double.tryParse(_decayMinutesController.text),
      baselineNumber: _baselineDecayMinutes.toDouble(),
      epsilon: 0.5,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBottomBarHeight();
      _updateBottomFadeFromLayout();
    });
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/create.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: NotificationListener<SizeChangedLayoutNotification>(
                onNotification: (_) {
                  _scheduleBottomFadeUpdate();
                  return false;
                },
                child: ListView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    0,
                  ),
                  children: [
                    SizeChangedLayoutNotifier(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionLabel(
                            text: 'Create Walk',
                            style: AppVisuals.headerTitleStyle,
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(height: 24),
                          _SectionCard(
                            title: 'Rules',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Preset',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedPresetKey,
                                        items: [
                                          for (final preset in _basePresets)
                                            DropdownMenuItem(
                                              value: preset.key,
                                              child: Text(preset.name),
                                            ),
                                          if (_customPresets.isNotEmpty)
                                            for (final preset in _customPresets)
                                              DropdownMenuItem(
                                                value: preset.key,
                                                child: Text(
                                                  preset.name,
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    color: Color(0xFF7A4E3A),
                                                  ),
                                                ),
                                              ),
                                          if (showCustomOption)
                                            const DropdownMenuItem(
                                              value: _customPresetKey,
                                              child: Text(
                                                'Custom',
                                                style: TextStyle(
                                                  color: Color(0xFF7A4E3A),
                                                ),
                                              ),
                                            ),
                                        ],
                                        onChanged: (value) {
                                          if (value == null) {
                                            return;
                                          }
                                          if (value == _customPresetKey) {
                                            setState(() {
                                              _lastPresetKey ??= _selectedPresetKey;
                                              _selectedPresetKey = value;
                                            });
                                            return;
                                          }
                                          final preset = _presetByKey(value);
                                          if (preset != null) {
                                            _applyPreset(preset);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _PresetActionRow(
                                        showSave: showSave,
                                        saveEnabled: saveEnabled,
                                        showSaveAs: showSaveAs,
                                        saveAsEnabled: saveAsEnabled,
                                        canDelete: canDeletePreset,
                                        onSave: _saveSelectedPreset,
                                        onSaveAs: _saveCustomPreset,
                                        onDelete: _deleteCustomPreset,
                                      ),
                                    ),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        FocusScope.of(context).unfocus();
                                        setState(() {
                                          _rulesExpanded = !_rulesExpanded;
                                        });
                                        _scheduleBottomFadeUpdate();
                                      },
                                      icon: Icon(
                                        _rulesExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                _CollapsibleSection(
                                  expanded: _rulesExpanded,
                                  child: Column(
                                    children: [
                                      _RuleFieldRow(
                                        label: 'Min. speed',
                                        valueSample: '00.0',
                                        unit: ' mph',
                                        controller: _minSpeedController,
                                        decimal: true,
                                        step: 0.1,
                                        minValue: 0.1,
                                        maxValue: 10.0,
                                        highlightChanged: minSpeedChanged,
                                        infoTitle: 'Minimum speed',
                                        infoBody:
                                            'The lowest speed you must maintain to avoid warnings.',
                                        forceInfoIconSize: _infoIconSizeForWidth(
                                          MediaQuery.of(context).size.width,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _RuleFieldRow(
                                        label: 'Warning grace',
                                        valueSample: '000',
                                        unit: ' sec.',
                                        controller: _warningSecondsController,
                                        decimal: false,
                                        step: 1,
                                        minValue: 10.0,
                                        maxValue: 120.0,
                                        highlightChanged: warningSecondsChanged,
                                        infoTitle: 'Warning grace',
                                        infoBody:
                                            'How long you can stay below minimum speed before the next warning.',
                                        forceInfoIconSize: _infoIconSizeForWidth(
                                          MediaQuery.of(context).size.width,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      _RuleFieldRow(
                                        label: 'Warning erase',
                                        valueSample: '000',
                                        unit: ' min.',
                                        controller: _decayMinutesController,
                                        decimal: false,
                                        step: 1,
                                        minValue: 10.0,
                                        maxValue: 120.0,
                                        highlightChanged: decayChanged,
                                        infoTitle: 'Warning erase',
                                        infoBody:
                                            'Minutes at or above minimum speed to erase one warning.',
                                        forceInfoIconSize: _infoIconSizeForWidth(
                                          MediaQuery.of(context).size.width,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _RuleFieldRow(
                                              label: 'Max warnings',
                                              valueSample: '00',
                                              unit: '',
                                              controller: _warningsController,
                                              decimal: false,
                                              step: 1,
                                              minValue: 3.0,
                                              maxValue: 10.0,
                                              highlightChanged: warningsChanged,
                                              infoTitle: 'Max warnings',
                                              infoBody:
                                                  'How many warnings you can receive before being ticketed.',
                                              forceInfoIconSize: _infoIconSizeForWidth(
                                                MediaQuery.of(context).size.width,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 16),
                          KeyedSubtree(
                            key: _contentEndKey,
                            child: _SectionCard(
                              title: 'Walk type',
                              child: Column(
                                children: [
                                  _SoloWalkRow(
                                    groupValue: _winMode,
                                    onChanged: (value) {
                                      if (value == null) {
                                        return;
                                      }
                                      setState(() {
                                        _winMode = value;
                                      });
                                    },
                                    goalMilesController: _goalMilesController,
                                    infoIconSize: _infoIconSizeForWidth(
                                      MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _WalkTypeOption(
                                    title: 'Group event',
                                    subtitle: 'Multiplayer mode (coming soon).',
                                    value: WinMode.event,
                                    groupValue: _winMode,
                                    onChanged: null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            Positioned(
              left: _fadeLeft ?? 0,
              bottom: _bottomBarHeight == 0
                  ? _bottomButtonHeight +
                      _bottomBarTopPadding +
                      _bottomBarBottomPadding +
                      _bottomBarExtraPadding
                  : _bottomBarHeight,
              height: AppVisuals.bottomFadeHeight,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  opacity: _showBottomFade ? 1 : 0,
                  child: SizedBox(
                    width: _fadeWidth ?? MediaQuery.of(context).size.width,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppVisuals.bottomFadeColor.withOpacity(0),
                            AppVisuals.bottomFadeColor
                                .withOpacity(AppVisuals.bottomFadeOpacity),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Material(
        color: Colors.transparent,
        elevation: 0,
        child: SafeArea(
          key: _bottomBarKey,
          top: false,
          minimum: const EdgeInsets.fromLTRB(
            20,
            _bottomBarTopPadding,
            20,
            _bottomBarBottomPadding,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: _bottomBarExtraPadding),
            child: SizedBox(
              height: _bottomButtonHeight,
              child: FilledButton(
                onPressed: _createWalk,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Create Walk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}




























