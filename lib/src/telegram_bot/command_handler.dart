import 'dart:async';

import 'package:owlistic/src/telegram_bot/base_handler.dart';
import 'package:owlistic/src/telegram_bot/context.dart';

typedef Handler = FutureOr<void> Function(Context ctx);

class CommandHandler extends BaseHandler {
  CommandHandler(String command, Handler callback, {super.guards})
      : _command = command,
        _callback = callback;

  final String _command;
  final Handler _callback;

  @override
  bool canHandle(Context ctx) {
    final commands = ctx.commands;
    if (commands == null) return false;
    // only one command is allowed
    if (commands.length != 1) return false;

    return _command == commands.first;
  }

  @override
  FutureOr<void> handle(Context ctx) => _callback(ctx);
}
