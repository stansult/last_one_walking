import 'dart:async';
import 'dart:io';

import 'package:vm_service/vm_service_io.dart';

void _usage() {
  stderr.writeln('Usage: dart run tool/call_extension.dart <vm_service_ws_uri> <extension> [value]');
  stderr.writeln('       dart run tool/call_extension.dart <extension> [value]  (reads tool/vmservice/last)');
  stderr.writeln('Example: dart run tool/call_extension.dart ws://127.0.0.1:12345/abcd=/ws ext.last_one_walking.setSpeed 2.0');
}

Future<void> main(List<String> args) async {
  if (args.length < 1) {
    _usage();
    exit(64);
  }

  String? uri;
  String extension;
  String? value;

  if (args[0].startsWith('ws://')) {
    if (args.length < 2) {
      _usage();
      exit(64);
    }
    uri = args[0];
    extension = args[1];
    value = args.length > 2 ? args[2] : null;
  } else {
    extension = args[0];
    value = args.length > 1 ? args[1] : null;
    final file = File('tool/vmservice/last');
    if (!file.existsSync()) {
      stderr.writeln('Missing tool/vmservice/last. Run tool/run_with_vmservice.sh or pass the ws:// URI.');
      exit(64);
    }
    uri = file.readAsStringSync().trim();
  }

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
