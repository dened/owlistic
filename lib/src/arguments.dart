import 'dart:io' as io;
import 'package:args/args.dart';
import 'package:l/l.dart' as logger;

final class Arguments {
  Arguments._({
    required this.token,
    required this.file,
    required this.verbose,
    required this.checkDays,
    required this.chatId,
  });

  factory Arguments.parse(List<String> arguments) {
    final parser = ArgParser()
      ..addOption(
        'token',
        abbr: 't',
        mandatory: true,
        help: 'Telegram bot token',
        valueHelp: '123:ABC-DEF',
      )
      ..addOption(
        'file',
        abbr: 'f',
        mandatory: true,
        help: 'Path to the file for FileStorage',
        valueHelp: '/path/to/file',
      )
      ..addOption(
        'verbose',
        abbr: 'v',
        defaultsTo: 'all',
        help: 'Verbose mode for output: all | debug | info | warn | error',
        valueHelp: 'info',
      )
      ..addOption(
        'chat-id',
        abbr: 'c',
        help: 'Chat ID for manually checking results',
        valueHelp: '12345678',
      )
      ..addOption(
        'check-days',
        abbr: 'd',
        help: 'How many days to check for search certificate',
        valueHelp: '15',
      );

    const options = <String>{
      'token',
      'verbose',
      'file',
      'chat-id',
      'check-days',
    };

    try {
      final results = parser.parse(arguments);
      final table = <String, String>{
        // --- From .env file --- //
        if (io.File('.env') case io.File env when env.existsSync())
          for (final line in env.readAsLinesSync().map((e) => e.trim()))
            if (line.length >= 3 && !line.startsWith('#'))
              if (line.split('=') case List<String> parts when parts.length == 2)
                parts[0].trimRight().toLowerCase(): parts[1].trimLeft(),
      };

      table.addAll({
        // --- Options --- //
        for (final option in options)
          if (results.wasParsed(option))
            option.toLowerCase(): results.option(option)?.toString() ?? ''
          else if (parser.options[option]?.defaultsTo case String byDefault
              when !table.containsKey(option) && byDefault.isNotEmpty)
            option.toLowerCase(): byDefault,
      });

      return Arguments._(
        token: table['token'] ?? '',
        file: table['file'] ?? 'data/data.json',
        verbose: switch (table['verbose']?.trim().toLowerCase()) {
          'v' || 'all' || 'verbose' => const logger.LogLevel.vvvvvv(),
          'd' || 'debug' => const logger.LogLevel.debug(),
          'i' || 'info' || 'conf' || 'config' => const logger.LogLevel.info(),
          'w' || 'warn' || 'warning' => const logger.LogLevel.warning(),
          'e' || 'err' || 'error' || 'severe' || 'fatal' => const logger.LogLevel.error(),
          _ => const logger.LogLevel.warning(),
        },
        chatId: int.tryParse(table['chat-id'] ?? ''),
        checkDays: int.tryParse(table['check-days'] ?? ''),
      );
    } on FormatException catch (e) {
      io.stderr.writeln('Error: ${e.message}');
      io.stderr.writeln(parser.usage);
      io.exit(64); // Exit code 64 indicates a usage error.
    }
  }
  final String token;
  final String file;

  final logger.LogLevel verbose;

  final int? chatId;
  final int? checkDays;
}
