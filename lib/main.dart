import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class AppVisuals {
  // Card visuals.
  static const bool cardShowBackground = true;
  static const Color cardBackgroundColor = Colors.white;
  static const double cardOpacity = 0.74;
  static const double cardBlurSigma = 6;

  // Section text visuals.
  static const SectionStyle headerTitleStyle = SectionStyle(
    showBackground: true,
    backgroundColor: Colors.black,
    backgroundOpacity: 0.25,
    backgroundBlurSigma: 8,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    textStyle: TextStyleConfig(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      outlineEnabled: true,
      outlineColor: Color(0xFF2A1B13),
      outlineWidth: 1.5,
    ),
  );

  static const SectionStyle headerSubtitleStyle = SectionStyle(
    showBackground: false,
    backgroundColor: Colors.black,
    backgroundOpacity: 0.25,
    backgroundBlurSigma: 8,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    textStyle: TextStyleConfig(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      outlineEnabled: true,
      outlineColor: Color(0xFF2A1B13),
      outlineWidth: 1.5,
    ),
  );

  static const SectionStyle footerNoteStyle = SectionStyle(
    showBackground: true,
    backgroundColor: Colors.black,
    backgroundOpacity: 0.25,
    backgroundBlurSigma: 8,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    textStyle: TextStyleConfig(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      outlineEnabled: true,
      outlineColor: Color(0xFF2A1B13),
      outlineWidth: 1.5,
    ),
  );

  static const TextStyleConfig cardTitleTextStyle = TextStyleConfig(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Color(0xFF2A1B13),
    outlineEnabled: false,
    outlineColor: Color(0xFF2A1B13),
    outlineWidth: 1,
  );

  static const Color adaptiveIconBackgroundColor = Color(0xFF2B0F0D);

  static const double actionIconSize = 18;
  static const double actionIconGap = 6;
  static const double actionButtonGap = 10;
  static const EdgeInsets actionPadding =
      EdgeInsets.symmetric(horizontal: 6, vertical: 6);

  static const double stepperIconSize = 18;
  static const double infoIconSize = 18;

  static const double radioLeadingWidth = 26;
  static const double radioTitleGap = 8;
  static const EdgeInsets radioContentPadding = EdgeInsets.zero;

  static const Color changedFieldFillColor = Color(0xFFFFF0D6);
  static const Color changedFieldBorderColor = Color(0xFFB5731A);

  static const bool blurEnabledOnAndroid = false;
  static const bool blurEnabledOniOS = false;

  static bool get useBlur =>
      (Platform.isAndroid && blurEnabledOnAndroid) ||
      (Platform.isIOS && blurEnabledOniOS);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFB5522D);
    return MaterialApp(
      title: 'Last One Walking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F2EC),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: Color(0xFF2A1B13),
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A1B13),
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF3C2D24)),
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF5A4A41)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        useMaterial3: true,
      ),
      home: const CreateWalkScreen(),
    );
  }
}

class WalkPreset {
  const WalkPreset({
    required this.key,
    required this.name,
    required this.minSpeedMph,
    required this.warningSeconds,
    required this.warnings,
    required this.decayMinutes,
  });

  final String key;
  final String name;
  final double minSpeedMph;
  final int warningSeconds;
  final int warnings;
  final int decayMinutes;
}

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
    _goalMilesController = TextEditingController(text: '5');

    _minSpeedController.addListener(_handleFieldChange);
    _warningSecondsController.addListener(_handleFieldChange);
    _warningsController.addListener(_handleFieldChange);
    _decayMinutesController.addListener(_handleFieldChange);
    _lastPresetKey = _selectedPresetKey;
    _setBaselineFromPreset(initial);
  }

  @override
  void dispose() {
    _minSpeedController.dispose();
    _warningSecondsController.dispose();
    _warningsController.dispose();
    _decayMinutesController.dispose();
    _goalMilesController.dispose();
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

  Future<void> _saveCustomPreset() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
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

    if (name == null || name.isEmpty) {
      return;
    }

    final existing = _customPresetByName(name);
    if (existing != null) {
      final overwrite = await showDialog<bool>(
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

    final summary = 'Min ${preset.minSpeedMph.toStringAsFixed(1)} mph • '
        '${preset.warningSeconds} s warning • '
        '${preset.warnings} warnings • '
        '${preset.decayMinutes} min decay'
        '${_winMode == WinMode.solo ? ' • ${goalMiles!.toStringAsFixed(1)} mi goal' : ''}';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Walk created (stub). $summary'),
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

  Future<void> _deleteCustomPreset() async {
    if (!_isCustomPresetKey(_selectedPresetKey)) {
      return;
    }
    final preset = _presetByKey(_selectedPresetKey);
    if (preset == null) {
      return;
    }
    final confirmed = await showDialog<bool>(
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

    return Scaffold(
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                children: [
                const _SectionLabel(
                  text: 'Create Walk',
                  style: AppVisuals.headerTitleStyle,
                ),
                const SizedBox(height: 8),
                const _SectionLabel(
                  text: 'Set your rules for this session. Presets are editable.',
                  style: AppVisuals.headerSubtitleStyle,
                ),
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
                                      style: TextStyle(color: Color(0xFF7A4E3A)),
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
                            child: Wrap(
                              spacing: AppVisuals.actionButtonGap,
                              runSpacing: 4,
                              children: [
                                if (showSave)
                                  _ActionButton(
                                    label: 'Save',
                                    icon: Icons.save_outlined,
                                    onPressed:
                                        saveEnabled ? _saveSelectedPreset : null,
                                  ),
                                if (showSaveAs)
                                  _ActionButton(
                                    label: 'Save as...',
                                    icon: Icons.bookmark_add_outlined,
                                    onPressed:
                                        saveAsEnabled ? _saveCustomPreset : null,
                                  ),
                                if (canDeletePreset)
                                  _ActionButton(
                                    label: 'Delete',
                                    icon: Icons.delete_outline,
                                    onPressed: _deleteCustomPreset,
                                  ),
                              ],
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
                            _RuleRow(
                              label: 'Min. speed',
                              child: _NumberField(
                                label: 'Min. speed',
                                controller: _minSpeedController,
                                suffix: 'mph',
                                decimal: true,
                                infoTitle: 'Minimum speed',
                                infoBody:
                                    'The lowest speed you must maintain to avoid warnings.',
                                step: 0.1,
                                minValue: 0.1,
                                highlightChanged: minSpeedChanged,
                                showLabelInField: false,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _RuleRow(
                              label: 'Warning grace',
                              child: _NumberField(
                                label: 'Warning grace',
                                controller: _warningSecondsController,
                                suffix: 'sec.',
                                decimal: false,
                                infoTitle: 'Warning grace',
                                infoBody:
                                    'How long you can stay below minimum speed before the next warning.',
                                step: 1,
                                minValue: 1,
                                highlightChanged: warningSecondsChanged,
                                showLabelInField: false,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _RuleRow(
                              label: 'Warning erase',
                              child: _NumberField(
                                label: 'Warning erase',
                                controller: _decayMinutesController,
                                suffix: 'min.',
                                decimal: false,
                                infoTitle: 'Warning erase',
                                infoBody:
                                    'Minutes at or above minimum speed to erase one warning.',
                                step: 1,
                                minValue: 1,
                                highlightChanged: decayChanged,
                                showLabelInField: false,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _RuleRow(
                                    label: 'Max warnings',
                                    child: _NumberField(
                                      label: 'Max warnings',
                                      controller: _warningsController,
                                      decimal: false,
                                      infoTitle: 'Max warnings',
                                      infoBody:
                                          'How many warnings you can receive before being ticketed.',
                                      step: 1,
                                      minValue: 1,
                                      highlightChanged: warningsChanged,
                                      showLabelInField: false,
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
                _SectionCard(
                  title: 'Walk type',
                  child: Column(
                    children: [
                      _WalkTypeOption(
                        title: 'Solo walk',
                        subtitle: 'Finish by reaching a distance goal.',
                        value: WinMode.solo,
                        groupValue: _winMode,
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _winMode = value;
                          });
                        },
                      ),
                      if (_winMode == WinMode.solo) ...[
                        const SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.only(
                            left: AppVisuals.radioLeadingWidth +
                                AppVisuals.radioTitleGap,
                          ),
                          child: _NumberField(
                            label: 'Miles to win',
                            controller: _goalMilesController,
                            suffix: 'miles',
                            decimal: true,
                            infoTitle: 'Miles to win',
                            infoBody:
                                'Distance required to end the walk in solo mode.',
                            step: 1,
                            minValue: 1,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      _WalkTypeOption(
                        title: 'Event walk',
                        subtitle: 'Multiplayer mode (coming soon).',
                        value: WinMode.event,
                        groupValue: _winMode,
                        onChanged: null,
                      ),
                    ],
                  ),
                ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
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
                  const SizedBox(height: 12),
                const Center(
                  child: _SectionLabel(
                    text: 'Rules are fully adjustable for practice runs.',
                    style: AppVisuals.footerNoteStyle,
                  ),
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSurface extends StatelessWidget {
  const _CardSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppVisuals.cardShowBackground
            ? AppVisuals.cardBackgroundColor.withOpacity(AppVisuals.cardOpacity)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AppVisuals.useBlur && AppVisuals.cardBlurSigma > 0
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: AppVisuals.cardBlurSigma,
                  sigmaY: AppVisuals.cardBlurSigma,
                ),
                child: child,
              )
            : child,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _CardSurface(
      child: _SectionCardBody(title: title, child: child),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.child,
    required this.expanded,
  });

  final Widget child;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: expanded ? 1 : 0,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _SectionCardBody extends StatelessWidget {
  const _SectionCardBody({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StyledText(text: title, style: AppVisuals.cardTitleTextStyle),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class TextStyleConfig {
  const TextStyleConfig({
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    required this.outlineEnabled,
    required this.outlineColor,
    required this.outlineWidth,
  });

  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final bool outlineEnabled;
  final Color outlineColor;
  final double outlineWidth;
}

class SectionStyle {
  const SectionStyle({
    required this.showBackground,
    required this.backgroundColor,
    required this.backgroundOpacity,
    required this.backgroundBlurSigma,
    required this.padding,
    required this.textStyle,
  });

  final bool showBackground;
  final Color backgroundColor;
  final double backgroundOpacity;
  final double backgroundBlurSigma;
  final EdgeInsets padding;
  final TextStyleConfig textStyle;
}

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

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: child),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

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
          Icon(icon, size: AppVisuals.actionIconSize),
          const SizedBox(width: AppVisuals.actionIconGap),
          Text(label),
        ],
      ),
    );
  }
}

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                const SizedBox(height: 2),
                Text(subtitle, style: subtitleStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    this.highlightChanged = false,
    this.showLabelInField = true,
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
  final bool highlightChanged;
  final bool showLabelInField;

  @override
  Widget build(BuildContext context) {
    final formatter = decimal
        ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))
        : FilteringTextInputFormatter.digitsOnly;

    final showInfo = infoBody != null;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: highlightChanged
            ? AppVisuals.changedFieldBorderColor
            : Colors.black26,
      ),
    );

    final field = TextField(
      controller: controller,
      enabled: enabled,
      keyboardType:
          TextInputType.numberWithOptions(decimal: decimal, signed: false),
      inputFormatters: [formatter],
      decoration: InputDecoration(
        labelText: showLabelInField ? label : null,
        hintText: hintText,
        suffixText: suffix,
        suffixStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7A6B63),
            ),
        fillColor: highlightChanged
            ? AppVisuals.changedFieldFillColor
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
                onPressed:
                    enabled ? () => _adjust(step! * -1, minValue: minValue) : null,
                icon: const Icon(Icons.remove, size: AppVisuals.stepperIconSize),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              )
            : null,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 36, minHeight: 36),
        suffixIcon: step != null
            ? IconButton(
                onPressed: enabled ? () => _adjust(step!, minValue: minValue) : null,
                icon: const Icon(Icons.add, size: AppVisuals.stepperIconSize),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              )
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );

    if (!showInfo) {
      return field;
    }

    return Row(
      children: [
        Expanded(child: field),
        const SizedBox(width: 6),
        IconButton(
          icon: const Icon(Icons.info_outline, size: AppVisuals.infoIconSize),
          tooltip: 'Info',
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(infoTitle ?? label),
                  content: Text(infoBody!),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _adjust(double delta, {double? minValue}) {
    final current = double.tryParse(controller.text) ?? 0;
    var next = current + delta;
    if (minValue != null && next < minValue) {
      next = minValue;
    }
    final text = decimal ? next.toStringAsFixed(1) : next.toStringAsFixed(0);
    controller.text = text;
  }
}
