import 'dart:async';
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:l/l.dart';
import 'package:telc_result_checker/owlistic.dart';
import 'package:telc_result_checker/src/telegram_bot.dart';

Future<void> main(List<String> args) async {
  final arguments = Arguments.parse(args);

  l.capture(
    () => runZonedGuarded<void>(() async {
      final storage = FileStorage(arguments.file);
      await storage.refresh();

      final service = TelcCertificateLookupService(
        apiClient: TelcApiClient(),
        storage: storage,
        bot: TelegramBot(token: arguments.token),
      );
      await service.start();
    }, (error, stackTrace) {
      l.e('An top level error occurred. $error', stackTrace);
      debugger(); // Set a breakpoint here
    }),
    LogOptions(
      handlePrint: true,
      outputInRelease: true,
      printColors: false,
      overrideOutput: (event) {
        //logsBuffer.add(event);
        if (event.level.level > arguments.verbose.level) return null;
        var message = switch (event.message) {
          String text => text,
          Object obj => obj.toString(),
        };
        if (kReleaseMode) {
          // Hide sensitive data in release mode
          if (arguments.token case String key when key.isNotEmpty) message = message.replaceAll(key, '******');
        }
        return '[${event.level.prefix}] '
            '${DateFormat('dd.MM.yyyy HH:mm:ss').format(event.timestamp)} '
            '| $message';
      },
    ),
  );
}
