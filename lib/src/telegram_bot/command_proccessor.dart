import 'package:owlistic/src/database.dart';
import 'package:owlistic/src/localization/localization.dart';
import 'package:owlistic/src/telegram_bot/base_handler.dart';
import 'package:owlistic/src/telegram_bot/context.dart';
import 'package:owlistic/src/telegram_bot/conversation_handler.dart';
import 'package:owlistic/src/telegram_bot/telegram_bot.dart';

/// Processes incoming Telegram updates and routes them to appropriate handlers.
///
/// The `CommandProcessor` is responsible for:
/// - Creating a [Context] for each update.
/// - Managing conversation sessions ([ConversationHandler]).
/// - Iterating through registered [BaseHandler]s to find one that can handle the update.
/// - Invoking guards ([Guard]) before activating a handler.
/// - Storing active [ConversationHandler] sessions.
class CommandProcessor {
  /// Creates a new [CommandProcessor].
  ///
  /// - [bot]: The [TelegramBot] instance for interacting with the Telegram API.
  /// - [db]: The [Database] instance for data persistence.
  /// - [ln]: The [Localization] instance for handling internationalization.
  CommandProcessor({required TelegramBot bot, required Database db, required Localization ln})
    : _bot = bot,
      _db = db,
      _ln = ln;

  final TelegramBot _bot;
  final Database _db;
  final Localization _ln;
  final List<BaseHandler> _handlers = [];

  /// Returns an unmodifiable list of registered handlers.
  ///
  /// This can be used, for example, to dynamically generate help messages
  /// based on the available commands and their descriptions.
  List<BaseHandler> get handlers => List.unmodifiable(_handlers);

  /// Stores active conversation sessions, mapping chat IDs to their [ConversationHandler].
  // The `strict_raw_type` lint is ignored here because ConversationHandler itself is generic,
  // but we store various specializations of it. Type checking is handled at the point of use.
  // ignore: strict_raw_type
  final Map<int, ConversationHandler> _sessions = {};

  /// Processes a raw Telegram update.
  ///
  /// This method is the main entry point for incoming updates.
  /// It creates a [Context], checks for active sessions, and then
  /// attempts to find a suitable handler for the update.
  void call(Map<String, Object?> update) {
    final context = Context(update: update, bot: _bot, db: _db, ln: _ln);
    final chatId = context.chatId;
    final session = _sessions[chatId];

    // Check if a session exists for this chat
    if (session != null) {
      if (context.isCommand) {
        // If a new command arrives, reset and remove the existing session
        // to allow the new command to be processed by any handler.
        _sessions.remove(chatId)?.reset(chatId);
      } else {
        // If a non-command message arrives and a session exists,
        // delegate handling to the active session and return.
        session.handle(context);
        return;
      }
    }

    // Asynchronously process handlers to avoid blocking the main isolate.
    // This is important because `handler.canActivate` can be async (e.g., DB lookups).
    Future<void>(() async {
      for (final handler in _handlers) {
        if (handler.canHandle(context)) {
          // Check guards before activating the handler.
          final canActivate = await handler.canActivate(context);
          if (!canActivate) {
            // If guards prevent activation, stop processing for this update
            // to prevent other handlers from being checked unnecessarily for this specific update.
            return;
          }
          // If the handler is a ConversationHandler, store it as an active session.
          if (handler is ConversationHandler) {
            _sessions[chatId] = handler;
          }
          // Execute the handler.
          handler.handle(context);
          // Once a handler is found and executed, stop iterating.
          return;
        }
      }
    });
  }

  /// Registers a [BaseHandler] with the processor.
  ///
  /// Handlers are checked in the order they are added.
  void addHandler(BaseHandler handler) {
    _handlers.add(handler);
  }
}
