import 'dart:async';

import 'package:owlistic/src/localization/localization.dart';
import 'package:owlistic/src/telegram_bot/context.dart';
import 'package:owlistic/src/telegram_bot/guard.dart';

/// A callback function that handles an incoming Telegram update.
///
/// This function is executed by the [CommandProcessor] when a handler
/// is found that can process a specific update. It receives the [Context]
/// which contains all relevant information about the update.
typedef Handler = FutureOr<void> Function(Context ctx);

/// An abstract base class for all Telegram bot handlers.
///
/// Handlers are responsible for processing incoming updates from Telegram.
/// Each handler must implement [canHandle] to determine if it is capable
/// of processing a given [Context], and [handle] to perform the actual
/// processing logic.
///
/// Handlers can optionally have [guards] that provide additional checks
/// before the handler's [handle] method is executed.
abstract class BaseHandler {
  /// Creates a new [BaseHandler] with optional [guards].
  BaseHandler({
    List<Guard>? guards,
  }) : _guards = guards ?? const <Guard>[];

  final List<Guard> _guards;

  bool canHandle(Context ctx);

  FutureOr<void> handle(Context ctx);

  /// Checks if the handler can be activated for the given [Context].
  ///
  /// This method iterates through all registered [guards] and returns `false`
  /// if any guard's [Guard.canActivate] method returns `false`.
  /// If there are no guards, or if all guards return `true`, this method
  /// returns `true`.
  ///
  /// This check is performed *after* [canHandle] returns `true`.
  FutureOr<bool> canActivate(Context ctx) async {
    for (final guard in _guards) {
      if (!await guard.canActivate(ctx)) return false;
    }
    return true;
  }
}

/// A callback function that provides a localized description for a command.
///
/// This function takes a [Localization] instance and returns a string
/// description of the command, suitable for use in help messages.
typedef DescriptionCallback = String Function(Localization ln);

/// A mixin for handlers that are triggered by a specific bot command.
///
/// Handlers that use this mixin must provide a [command] string and a
/// [description] callback. The mixin provides a default implementation
/// of [canHandle] that checks if the incoming [Context] contains
/// exactly one command and if that command matches the handler's [command].
mixin CommandHandlerMixin on BaseHandler {
  /// The command string that triggers this handler (e.g., "/start", "/help").
  String get command;

  /// A callback that returns a localized description of this command.
  ///
  /// This is used, for example, to generate the list of commands
  /// in the /help message.
  DescriptionCallback get description;

  /// Determines if this handler can process the given [Context].
  ///
  /// This implementation checks if the context contains exactly one command
  /// and if that command matches the handler's [command].
  @override
  bool canHandle(Context ctx) {
    final commands = ctx.commands;
    if (commands == null) return false;
    // only one command is allowed
    if (commands.length != 1) return false;

    return command == commands.first;
  }
}
