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
    required this.name,
    required this.minSpeedMph,
    required this.warningSeconds,
    required this.warnings,
    required this.decayMinutes,
  });

  final String name;
  final double minSpeedMph;
  final int warningSeconds;
  final int warnings;
  final int decayMinutes;
}

class CreateWalkScreen extends StatefulWidget {
  const CreateWalkScreen({super.key});

  @override
  State<CreateWalkScreen> createState() => _CreateWalkScreenState();
}

class _CreateWalkScreenState extends State<CreateWalkScreen> {
  static const presets = [
    WalkPreset(
      name: 'Movie',
      minSpeedMph: 3.0,
      warningSeconds: 10,
      warnings: 3,
      decayMinutes: 60,
    ),
    WalkPreset(
      name: 'Book',
      minSpeedMph: 4.0,
      warningSeconds: 30,
      warnings: 3,
      decayMinutes: 60,
    ),
    WalkPreset(
      name: 'Training',
      minSpeedMph: 2.5,
      warningSeconds: 20,
      warnings: 5,
      decayMinutes: 30,
    ),
    WalkPreset(
      name: 'Easy',
      minSpeedMph: 2.0,
      warningSeconds: 25,
      warnings: 6,
      decayMinutes: 20,
    ),
  ];

  int _presetIndex = 0;
  bool _lockWarnings = true;
  late final TextEditingController _minSpeedController;
  late final TextEditingController _warningSecondsController;
  late final TextEditingController _warningsController;
  late final TextEditingController _decayMinutesController;

  @override
  void initState() {
    super.initState();
    final initial = presets[_presetIndex];
    _minSpeedController = TextEditingController(
      text: initial.minSpeedMph.toStringAsFixed(1),
    );
    _warningSecondsController =
        TextEditingController(text: initial.warningSeconds.toString());
    _warningsController = TextEditingController(text: initial.warnings.toString());
    _decayMinutesController =
        TextEditingController(text: initial.decayMinutes.toString());
  }

  @override
  void dispose() {
    _minSpeedController.dispose();
    _warningSecondsController.dispose();
    _warningsController.dispose();
    _decayMinutesController.dispose();
    super.dispose();
  }

  void _applyPreset(WalkPreset preset) {
    _minSpeedController.text = preset.minSpeedMph.toStringAsFixed(1);
    _warningSecondsController.text = preset.warningSeconds.toString();
    _warningsController.text = preset.warnings.toString();
    _decayMinutesController.text = preset.decayMinutes.toString();
    setState(() {
      _lockWarnings = preset.warnings == 3;
    });
  }

  void _createWalk() {
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
      return;
    }

    final summary = 'Min ${minSpeed.toStringAsFixed(1)} mph • '
        '$warningSeconds s warning • '
        '$warnings warnings • '
        '$decayMinutes min decay';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Walk created (stub). $summary'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  child: DropdownButtonFormField<int>(
                    value: _presetIndex,
                    items: [
                      for (var i = 0; i < presets.length; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(presets[i].name),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _presetIndex = value;
                      });
                      _applyPreset(presets[value]);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Rules',
                  child: Column(
                    children: [
                      _NumberField(
                        label: 'Minimum speed (mph)',
                        controller: _minSpeedController,
                        suffix: 'mph',
                        decimal: true,
                      ),
                      const SizedBox(height: 12),
                      _NumberField(
                        label: 'Warning threshold',
                        controller: _warningSecondsController,
                        suffix: 'seconds',
                        decimal: false,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _NumberField(
                              label: 'Warnings allowed',
                              controller: _warningsController,
                              suffix: 'count',
                              decimal: false,
                              enabled: !_lockWarnings,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SwitchListTile(
                              value: _lockWarnings,
                              onChanged: (value) {
                                setState(() {
                                  _lockWarnings = value;
                                  if (value) {
                                    _warningsController.text = '3';
                                  }
                                });
                              },
                              title: const Text('Lock to 3'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _NumberField(
                        label: 'Warning decay',
                        controller: _decayMinutesController,
                        suffix: 'minutes',
                        decimal: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Win condition (placeholder)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Last walker standing (group mode).'),
                      SizedBox(height: 8),
                      Text('Until then, we use a mileage goal to win.'),
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
                    'Rules based on the film; tweak for training.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
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
    required this.suffix,
    required this.decimal,
    this.enabled = true,
  });

  final String label;
  final TextEditingController controller;
  final String suffix;
  final bool decimal;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final formatter = decimal
        ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))
        : FilteringTextInputFormatter.digitsOnly;

    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType:
          TextInputType.numberWithOptions(decimal: decimal, signed: false),
      inputFormatters: [formatter],
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
      ),
    );
  }
}
