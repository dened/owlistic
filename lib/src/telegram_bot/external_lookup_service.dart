
import 'dart:convert';
import 'dart:io';

import 'package:l/l.dart';
// ignore: avoid_classes_with_only_static_members
class ExternalLookupService {
  static Future<void> run(int chatId, {int? checkDays, bool enableDebugging = false,
  })  async {
    final exucutable = Platform.executable;
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

    final process = await Process.start(exucutable, args);

    process.stdout.transform(utf8.decoder).listen((data) {
      // Print to console, so you can see the Observatory URI
      // ignore: avoid_print
      l.d('[LookupService STDOUT]: $data');
      // l.i('[LookupService STDOUT]: $data'); // Also log it
    });
    process.stderr.transform(utf8.decoder).listen((data) {
      // ignore: avoid_print
      l.e('[LookupService STDERR]: $data');
      // l.e('[LookupService STDERR]: $data'); // Also log it
    });
  }
}
