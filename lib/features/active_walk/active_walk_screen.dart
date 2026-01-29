// ignore_for_file: deprecated_member_use, unnecessary_brace_in_string_interps
import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../create_walk/models/walk_preset.dart';

class ActiveWalkScreen extends StatefulWidget {
  const ActiveWalkScreen({
    super.key,
    required this.preset,
    required this.goalMiles,
  });

  final WalkPreset preset;
  final double? goalMiles;

  @override
  State<ActiveWalkScreen> createState() => _ActiveWalkScreenState();
}

class _ActiveWalkScreenState extends State<ActiveWalkScreen> {
  static bool _debugExtensionsRegistered = false;
  Timer? _countdownTimer;
  int _countdown = 0;
  bool _hasStarted = false;

  double _currentSpeed = 0.0;
  double _currentMiles = 0.0;
  int? _graceSecondsRemaining;
  int? _eraseSecondsRemaining;
  int _warningsLeft = 0;

  @override
  void initState() {
    super.initState();
    _registerDebugExtensions();
    _currentSpeed = widget.preset.minSpeedMph;
    _currentMiles = 0.0;
    _warningsLeft = widget.preset.warnings;
    _graceSecondsRemaining = null;
    _eraseSecondsRemaining = null;
  }

  void _registerDebugExtensions() {
    if (kReleaseMode || _debugExtensionsRegistered) {
      return;
    }
    _debugExtensionsRegistered = true;

    developer.registerExtension(
      'last_one_walking.setSpeed',
      (method, parameters) async {
        final raw = parameters['value'];
        final value = raw == null ? null : double.tryParse(raw);
        if (value == null) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.invalidParams,
            'Missing or invalid value',
          );
        }
        if (mounted) {
          setState(() {
            _currentSpeed = value;
          });
        }
        return developer.ServiceExtensionResponse.result(
          '{"ok":true}',
        );
      },
    );

    developer.registerExtension(
      'last_one_walking.setMiles',
      (method, parameters) async {
        final raw = parameters['value'];
        final value = raw == null ? null : double.tryParse(raw);
        if (value == null) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.invalidParams,
            'Missing or invalid value',
          );
        }
        if (mounted) {
          setState(() {
            _currentMiles = value;
          });
        }
        return developer.ServiceExtensionResponse.result('{"ok":true}');
      },
    );

    developer.registerExtension(
      'last_one_walking.setWarningsLeft',
      (method, parameters) async {
        final raw = parameters['value'];
        final value = raw == null ? null : int.tryParse(raw);
        if (value == null) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.invalidParams,
            'Missing or invalid value',
          );
        }
        if (mounted) {
          setState(() {
            _warningsLeft = value;
          });
        }
        return developer.ServiceExtensionResponse.result('{"ok":true}');
      },
    );

    developer.registerExtension(
      'last_one_walking.setGrace',
      (method, parameters) async {
        final raw = parameters['value'];
        final value = raw == null ? null : int.tryParse(raw);
        if (value == null) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.invalidParams,
            'Missing or invalid value',
          );
        }
        if (mounted) {
          setState(() {
            _graceSecondsRemaining = value;
          });
        }
        return developer.ServiceExtensionResponse.result('{"ok":true}');
      },
    );

    developer.registerExtension(
      'last_one_walking.setErase',
      (method, parameters) async {
        final raw = parameters['value'];
        final value = raw == null ? null : int.tryParse(raw);
        if (value == null) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.invalidParams,
            'Missing or invalid value',
          );
        }
        if (mounted) {
          setState(() {
            _eraseSecondsRemaining = value;
          });
        }
        return developer.ServiceExtensionResponse.result('{"ok":true}');
      },
    );

    developer.registerExtension(
      'last_one_walking.setStarted',
      (method, parameters) async {
        final raw = parameters['value'];
        final value = raw == null ? null : int.tryParse(raw);
        if (value == null) {
          return developer.ServiceExtensionResponse.error(
            developer.ServiceExtensionResponse.invalidParams,
            'Missing or invalid value',
          );
        }
        if (mounted) {
          setState(() {
            _hasStarted = value != 0;
            if (_hasStarted) {
              _countdown = 0;
            }
          });
        }
        return developer.ServiceExtensionResponse.result('{"ok":true}');
      },
    );

    developer.registerExtension(
      'last_one_walking.stop',
      (method, parameters) async {
        if (mounted) {
          setState(() {
            _currentSpeed = 0.0;
          });
        }
        return developer.ServiceExtensionResponse.result(
          '{"ok":true}',
        );
      },
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<bool> _confirmExit() async {
    if (!_hasStarted && _countdown == 0) {
      return true;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('End walk?'),
          content: const Text('Are you sure you want to give up?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No, wait...'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, give up!'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _startCountdown() {
    if (_countdown > 0) {
      return;
    }
    setState(() {
      _countdown = 3;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 1) {
        timer.cancel();
        setState(() {
          _countdown = 0;
          _hasStarted = true;
        });
      } else {
        setState(() {
          _countdown -= 1;
        });
      }
    });
  }

  Color _speedColor() {
    final minSpeed = widget.preset.minSpeedMph;
    if (_currentSpeed <= minSpeed) {
      return const Color(0xFFD94141);
    }
    if (_currentSpeed <= minSpeed + 0.4) {
      return const Color(0xFFE68A2E);
    }
    return const Color(0xFFEEE6DC);
  }

  String _formatDistance(double miles) {
    return miles.toStringAsFixed(1);
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return minutes > 0
        ? '${minutes}:${remainder.toString().padLeft(2, '0')}'
        : remainder.toString();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _confirmExit();
        return shouldExit;
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/solo.png',
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.45),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Text(
                            'Walk',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final shouldExit = await _confirmExit();
                            if (shouldExit && mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          icon: const Icon(Icons.chevron_left_rounded),
                          label: const Text('Give up'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _OutlinedText(
                            text: _currentSpeed.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 88,
                              fontWeight: FontWeight.w700,
                              color: _speedColor(),
                              letterSpacing: -1.5,
                            ),
                            outlineColor: Colors.black.withOpacity(0.35),
                            outlineWidth: 1,
                          ),
                          Transform.translate(
                            offset: const Offset(0, -6),
                            child: _OutlinedText(
                              text: 'mph',
                              style: TextStyle(
                                fontSize: 22,
                                color: _speedColor(),
                                letterSpacing: 2,
                                height: 0.9,
                              ),
                              outlineColor: Colors.black.withOpacity(0.35),
                              outlineWidth: 0.9,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            '${_formatDistance(_currentMiles)} miles',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Column(
                            children: [
                              Text(
                                'Warnings left',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$_warningsLeft',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (_graceSecondsRemaining != null)
                                Text(
                                  'Grace: ${_formatSeconds(_graceSecondsRemaining!)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.orange.shade200,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (_eraseSecondsRemaining != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'Erase in: ${_formatSeconds(_eraseSecondsRemaining!)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Visibility(
                        visible: !_hasStarted && _countdown == 0,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: FilledButton(
                          onPressed: _startCountdown,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Start Walk',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_countdown > 0)
              Container(
                color: Colors.black.withOpacity(0.35),
                alignment: Alignment.center,
                child: Text(
                  '$_countdown',
                  style: const TextStyle(
                    fontSize: 140,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 6),
                        blurRadius: 16,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OutlinedText extends StatelessWidget {
  const _OutlinedText({
    required this.text,
    required this.style,
    required this.outlineColor,
    required this.outlineWidth,
  });

  final String text;
  final TextStyle style;
  final Color outlineColor;
  final double outlineWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..color = outlineColor,
          ),
        ),
        Text(text, style: style),
      ],
    );
  }
}
