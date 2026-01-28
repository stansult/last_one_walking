import 'dart:io';
import 'dart:math' as math;
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
  static const double cardOpacity = 0.68;
  static const double cardBlurSigma = 6;

  // Section text visuals.
  static const SectionStyle headerTitleStyle = SectionStyle(
    showBackground: false,
    backgroundColor: Colors.black,
    backgroundOpacity: 0.25,
    backgroundBlurSigma: 8,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    textStyle: TextStyleConfig(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: Color(0xEE2A1B13),
      outlineEnabled: true,
      outlineColor: Color(0x77FCD9BE),
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
  static const double actionIconSizeCompact = 16;
  static const double actionIconGap = 6;
  static const double actionIconGapCompact = 4;
  static const double actionButtonGap = 10;
  static const double actionButtonGapCompact = 6;
  static const EdgeInsets actionPadding =
      EdgeInsets.symmetric(horizontal: 6, vertical: 6);
  static const double actionFontSize = 14;
  static const double actionFontSizeCompact = 12;

  static const double stepperIconSize = 18;
  static const double stepperIconSizeCompact = 16;
  static const double stepperMinTapSize = 28;
  static const double infoIconSize = 14;
  static const double infoIconSizeCompact = 12;
  static const double infoTapSize = 28;

  static const double radioLeadingWidth = 26;
  static const double radioTitleGap = 8;
  static const EdgeInsets radioContentPadding = EdgeInsets.zero;
  static const double radioTopOffset = 0;

  static const Color changedFieldFillColor = Color(0xFFFFF0D6);
  static const double changedFieldFillOpacity = 0.75;
  static const Color changedFieldBorderColor = Color(0xFFB5731A);
  static const Color numberFieldFillColor = Colors.white;
  static const double numberFieldFillOpacity = 0.7;
  static const double bottomFadeHeight = 12;
  static const Color bottomFadeColor = Color(0x00000000);
  static const double bottomFadeOpacity = 0.7;

  static const double ruleLabelWidth = 120;
  static const double ruleLabelMinWidth = 84;
  static const double ruleLabelGap = 8;
  static const double ruleLabelGapCompact = 4;
  static const double ruleInfoGap = 4;
  static const double ruleInfoGapCompact = 2;
  static const double numberFieldInfoGap = 2;

  static const EdgeInsets numberFieldPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const EdgeInsets numberFieldPaddingCompact =
      EdgeInsets.symmetric(horizontal: 8, vertical: 8);

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
          bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4A3D35)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppVisuals.numberFieldFillColor
              .withOpacity(AppVisuals.numberFieldFillOpacity),
          contentPadding: AppVisuals.numberFieldPadding,
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
  static const double _bottomButtonHeight = 52;
  static const double _bottomBarTopPadding = 10;
  static const double _bottomBarBottomPadding = 24;
  static const double _bottomBarExtraPadding = 10;
  final GlobalKey _bottomBarKey = GlobalKey();
  final GlobalKey _contentEndKey = GlobalKey();
  double _bottomBarHeight = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showBottomFade = false;
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
    final barTop = barBox.localToGlobal(Offset.zero).dy;
    final shouldShow = endBottom > barTop + 0.5;
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
          if (_showBottomFade &&
              MediaQuery.of(context).viewInsets.bottom == 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: _bottomBarHeight == 0
                  ? _bottomButtonHeight +
                      _bottomBarTopPadding +
                      _bottomBarBottomPadding +
                      _bottomBarExtraPadding
                  : _bottomBarHeight,
              height: AppVisuals.bottomFadeHeight,
              child: IgnorePointer(
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
