import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
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

class _CreateWalkScreenState extends State<CreateWalkScreen> {
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
    });
    _isApplyingPreset = false;
  }

  void _handleFieldChange() {
    if (_isApplyingPreset) {
      return;
    }
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
        });
      }
    } else if (_selectedPresetKey != _customPresetKey) {
      setState(() {
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
    final canSavePreset =
        _selectedPresetKey == _customPresetKey || _isCustomPresetKey(_selectedPresetKey);
    final canDeletePreset = _isCustomPresetKey(_selectedPresetKey);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF6E7D6),
                  Color(0xFFF6F2EC),
                  Color(0xFFEFE3DA),
                ],
              ),
            ),
          ),
          SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                children: [
                  const Text('Create Walk', style: TextStyle(fontSize: 36)),
                  const SizedBox(height: 8),
                  Text(
                    'Set your rules for this session. Presets are editable.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: 'Preset',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
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
                                child: Text('Custom'),
                              ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            if (value == _customPresetKey) {
                              setState(() {
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: canSavePreset ? _saveCustomPreset : null,
                              icon: const Icon(Icons.bookmark_add_outlined),
                              label: const Text('Save'),
                            ),
                            const SizedBox(width: 12),
                            if (canDeletePreset)
                              TextButton.icon(
                                onPressed: _deleteCustomPreset,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Delete'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Rules',
                    child: Column(
                      children: [
                        _NumberField(
                          label: 'Minimum speed',
                          controller: _minSpeedController,
                          suffix: 'miles per hour',
                          decimal: true,
                          infoTitle: 'Minimum speed',
                          infoBody:
                              'The lowest speed you must maintain to avoid warnings.',
                          step: 0.1,
                          minValue: 0.1,
                        ),
                        const SizedBox(height: 12),
                        _NumberField(
                          label: 'Warning grace',
                          controller: _warningSecondsController,
                          suffix: 'seconds',
                          decimal: false,
                          infoTitle: 'Warning grace',
                          infoBody:
                              'How long you can stay below minimum speed before the next warning.',
                          step: 1,
                          minValue: 1,
                        ),
                        const SizedBox(height: 12),
                        _NumberField(
                          label: 'Warning decay',
                          controller: _decayMinutesController,
                          suffix: 'minutes',
                          decimal: false,
                          infoTitle: 'Warning decay',
                          infoBody:
                              'Minutes at or above minimum speed to erase one warning.',
                          step: 1,
                          minValue: 1,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _NumberField(
                                label: 'Warnings allowed',
                                controller: _warningsController,
                                decimal: false,
                                infoTitle: 'Warnings allowed',
                                infoBody:
                                    'How many warnings you can receive before being ticketed.',
                                step: 1,
                                minValue: 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Win condition',
                    child: Column(
                      children: [
                        RadioListTile<WinMode>(
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
                          title: const Text('Solo walk'),
                          subtitle:
                              const Text('Finish by reaching a distance goal.'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (_winMode == WinMode.solo) ...[
                          const SizedBox(height: 8),
                          _NumberField(
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
                        ],
                        const SizedBox(height: 8),
                        RadioListTile<WinMode>(
                          value: WinMode.event,
                          groupValue: _winMode,
                          onChanged: null,
                          title: const Text('Event walk'),
                          subtitle:
                              const Text('Multiplayer mode (coming soon).'),
                          contentPadding: EdgeInsets.zero,
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
                      child: const Text('Create Walk'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Rules are fully adjustable for practice runs.',
                      style: Theme.of(context).textTheme.bodyMedium,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final formatter = decimal
        ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))
        : FilteringTextInputFormatter.digitsOnly;

    final showInfo = infoBody != null;

    final field = TextField(
      controller: controller,
      enabled: enabled,
      keyboardType:
          TextInputType.numberWithOptions(decimal: decimal, signed: false),
      inputFormatters: [formatter],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: suffix,
        suffixStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7A6B63),
            ),
        prefixIcon: step != null
            ? IconButton(
                onPressed:
                    enabled ? () => _adjust(step! * -1, minValue: minValue) : null,
                icon: const Icon(Icons.remove),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              )
            : null,
        prefixIconConstraints:
            const BoxConstraints(minWidth: 36, minHeight: 36),
        suffixIcon: step != null
            ? IconButton(
                onPressed: enabled ? () => _adjust(step!, minValue: minValue) : null,
                icon: const Icon(Icons.add),
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
          icon: const Icon(Icons.info_outline),
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
