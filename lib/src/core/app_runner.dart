import 'dart:async';
import 'dart:developer';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:l/l.dart';
import 'package:owlistic/owlistic.dart';

/// An abstraction for running an application with common initialization.
///
/// The [app] function contains the unique logic for a specific application
/// (e.g., a periodic task or a Telegram bot).
/// It will be called after the common components have been initialized.
Future<void> runApplication(
  /// The command-line arguments.
  List<String> args,
  Future<void> Function(Dependencies dependencies) app,
) async {
  final arguments = Arguments.parse(args);
  await initializeDateFormatting('ru');
  l.capture<void>(
    // Run the application within a zoned guard to catch top-level errors.
    () => runZonedGuarded<void>(
      () async {
        final db = Database.lazy(path: arguments.database);
        await db.refresh();
        l.i('Database is ready');

        // Retrieve the last update ID for the Telegram bot.
        final lastUpdateId = db.getKey<int>(updateIdKey);
        final bot = TelegramBot(token: arguments.token, offset: lastUpdateId);
        final ln = Localization(db: db);
        await ln.initializeAllMessages();

        // Execute the application-specific logic.
        await app(Dependencies(db: db, bot: bot, arguments: arguments, ln: ln));
      },
      (error, stackTrace) {
        l.e('An top level error occurred. $error', stackTrace);
        debugger(); // Set a breakpoint here
      },
    ),
    LogOptions(
      handlePrint: true,
      outputInRelease: true,
      printColors: true, // Keep colors for console output, can be false if not needed.
      overrideOutput: (event) {
        // Filter logs based on verbosity level.
        if (event.level.level > arguments.verbose.level) return null;
        var message = switch (event.message) {
          // Convert message to string.
          String text => text,
          Object obj => obj.toString(),
        };
        if (kReleaseMode) {
          // Hide sensitive data in release mode
          if (arguments.token case String key when key.isNotEmpty) {
            message = message.replaceAll(key, '******');
          }
        }
        return '[${event.level.prefix}] '
            '${DateFormat('dd.MM.yyyy HH:mm:ss').format(event.timestamp)} '
            '| $message';
      },
    ),
  );
}
