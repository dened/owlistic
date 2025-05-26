import 'dart:async';

import 'package:telc_result_checker/src/telegram_bot/base_handler.dart';
import 'package:telc_result_checker/src/telegram_bot/context.dart';

typedef Handler = FutureOr<void> Function(Context ctx);

class CommandHandler extends BaseHandler {
  CommandHandler(
    String command,
    Handler entry,
  )   : _command = command,
        _callback = entry;

  final String _command;
  final Handler _callback;

  @override
  bool canHandle(Context ctx) {
    final commands = ctx.getCommands();
    if (commands == null) return false;
    // only one command is allowed
    if (commands.length != 1) return false;

    return _command == commands.first;
  }

  @override
  FutureOr<void> handle(Context ctx) => _callback(ctx);
}
