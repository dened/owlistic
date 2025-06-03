import 'dart:convert';
import 'dart:io' as io;

import 'package:l/l.dart';

// ignore: avoid_classes_with_only_static_members
class ExternalLookupService {
  static Future<void> run(
    int chatId, {
    int? checkDays,
    bool enableDebugging = false,
  }) async {
    final exucutable = io.Platform.executable;
    const scriptPath = 'bin/lookup_service.dart';
    final args = <String>[
      'run',
      if (enableDebugging) ...[
        '--enable-vm-service=0', // 0 means an available port will be chosen
        '--pause-isolates-on-start', // Pause to allow debugger to attach
      ],
      scriptPath,
      '--chat-id',
      chatId.toString(),
      if (checkDays != null) ...{
        '--check-days',
        checkDays.toString(),
      }
    ];

    l.i('Starting lookup_service process with args: ${args.join(' ')}');

    await io.Process.start(
      exucutable,
      args,
      runInShell: true,
    )
      ..stdout
          .transform(const Utf8Decoder(allowMalformed: true))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .listen(l.d)
      ..stderr
          .transform(const Utf8Decoder(allowMalformed: true))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .listen(l.d);
  }
}
