import 'dart:convert';
import 'dart:io' as io;

import 'package:l/l.dart';

/// Runs the external `lookup_service` process.
///
/// Parameters:
///  - `chatId`: The Telegram chat ID for which the check is performed.
///    This parameter is passed to the `lookup_service`.
///  - `checkDays`: An optional number of days for which to check results.
///    Passed to the `lookup_service`.
///  - `enableDebugging`: A flag indicating whether to run the Dart script
///    in debug mode (with VM service enabled and pause on start).
///    This flag is ignored if a compiled executable is launched.
///
/// Launch Logic:
/// 1. The `LOOKUP_SERVICE_PATH` environment variable is checked.
/// 2. If it is set and not empty, it is assumed to be the path to the
///    compiled `lookup_service.run`. The process is started with this path.
/// 3. Otherwise, the `bin/lookup_service.dart` Dart script is launched
///    using `dart run`. Debugging can be enabled in this mode.
///
/// The output (stdout and stderr) of the launched process is logged.
Future<void> runExternalLookupService(int chatId, {int? checkDays, bool enableDebugging = false}) async {
  String executablePath;
  List<String> processArgs;

  // Check if we need to run the compiled executable or the Dart script.
  // The LOOKUP_SERVICE_PATH environment variable will be set in the Docker container.
  final compiledExecutablePath = io.Platform.environment['LOOKUP_SERVICE_PATH'];

  if (compiledExecutablePath != null && compiledExecutablePath.isNotEmpty) {
    // Launching the compiled executable (e.g., in Docker)
    executablePath = compiledExecutablePath;
    processArgs = <String>[
      '--chat-id',
      chatId.toString(),
      if (checkDays != null) ...{'--check-days', checkDays.toString()},
    ];
    l.i('Using compiled lookup_service: $executablePath');
  } else {
    // Launching the Dart script (e.g., for local development)
    executablePath = io.Platform.executable; // This is 'dart'
    const scriptPath = 'bin/lookup_service.dart';
    processArgs = <String>[
      'run', // Dart CLI command to run the script
      if (enableDebugging) ...[
        '--enable-vm-service=0', // 0 means an available port will be chosen
        '--pause-isolates-on-start', // Pause to allow debugger to attach
      ],
      scriptPath,
      '--chat-id',
      chatId.toString(),
      if (checkDays != null) ...{'--check-days', checkDays.toString()},
    ];
    l.i('Using Dart script for lookup_service: $executablePath $scriptPath');
  }

  l.i('Starting lookup_service process with executable: $executablePath and args: ${processArgs.join(' ')}');

  try {
    final process = await io.Process.start(executablePath, processArgs, runInShell: false);

    // Log stdout
    process.stdout
        .transform(const Utf8Decoder(allowMalformed: true))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .listen((line) => l.d('LookupService stdout: $line'));

    // Log stderr
    process.stderr
        .transform(const Utf8Decoder(allowMalformed: true))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .listen((line) => l.w('LookupService stderr: $line'));

    final exitCode = await process.exitCode;
    l.i('Lookup_service process finished with exit code: $exitCode');
    if (exitCode != 0) {
      throw Exception('Lookup_service process failed with exit code: $exitCode');
    }
  } on Object catch (e, s) {
    l.e('Failed to run lookup_service process: $e', s);
    rethrow; // Rethrow the exception so the caller can handle it
  }
}
