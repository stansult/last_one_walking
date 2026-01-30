import 'dart:async';
import 'dart:io';

import 'package:vm_service/vm_service_io.dart';

void _usage() {
  stderr.writeln('Usage: dart run tool/call_extension.dart <vm_service_ws_uri> <extension> [value]');
  stderr.writeln('Example: dart run tool/call_extension.dart ws://127.0.0.1:12345/abcd=/ws ext.last_one_walking.setSpeed 2.0');
}

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    _usage();
    exit(64);
  }

  final uri = args[0];
  final extension = args[1];
  final value = args.length > 2 ? args[2] : null;

  final service = await vmServiceConnectUri(uri);
  try {
    final vm = await service.getVM();
    final isolate = vm.isolates?.isNotEmpty == true ? vm.isolates!.first : null;
    if (isolate == null) {
      stderr.writeln('No isolate found.');
      exit(1);
    }

    final argsMap = <String, String>{};
    if (value != null) {
      argsMap['value'] = value;
    }

    final result = await service.callServiceExtension(
      extension,
      isolateId: isolate.id,
      args: argsMap.isEmpty ? null : argsMap,
    );

    stdout.writeln(result.json);
  } finally {
    await service.dispose();
  }
}
