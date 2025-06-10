import 'dart:async';

import 'package:owlistic/src/telegram_bot/base_handler.dart';
import 'package:owlistic/src/telegram_bot/context.dart';

/// A handler specifically designed for processing single bot commands.
///
/// This class extends [BaseHandler] and uses the [CommandHandlerMixin]
/// to automatically handle the `canHandle` logic based on the provided
/// command string.
///
/// It executes a single [Handler] callback when the matching command
/// is received and the guards ([BaseHandler.canActivate]) pass.
class CommandHandler extends BaseHandler with CommandHandlerMixin {
  /// Creates a new [CommandHandler].
  ///
  /// - [command]: The command string (e.g., "/help") that this handler
  ///   will respond to.
  /// - [description]: A callback that returns a localized description of this command.
  /// - [callback]: The [Handler] function to execute when the command is received
  ///   and guards pass.
  /// - [guards]: An optional list of [Guard]s that can prevent the handler
  ///   from activating.
  CommandHandler(
    String command,
    DescriptionCallback description,
    Handler callback, {
    super.guards,
  })  : _command = command,
        _description = description,
        _callback = callback;

  final String _command;
  final DescriptionCallback _description;
  final Handler _callback;

  /// The command string that triggers this handler.
  @override
  String get command => _command;

  /// A callback that returns a localized description of this command.
  @override
  DescriptionCallback get description => _description;

  @override
  FutureOr<void> handle(Context ctx) => _callback(ctx);
}
