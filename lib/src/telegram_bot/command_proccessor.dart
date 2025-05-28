import 'package:telc_result_checker/src/database.dart';
import 'package:telc_result_checker/src/telegram_bot/base_handler.dart';
import 'package:telc_result_checker/src/telegram_bot/context.dart';
import 'package:telc_result_checker/src/telegram_bot/conversation_handler.dart';
import 'package:telc_result_checker/src/telegram_bot/telegram_bot.dart';

/// Обработчик сообщений, имплементирующий OnUpdateHandler.
class CommandProcessor {
  CommandProcessor({
    required TelegramBot bot,
    required Database db,
  })  : _bot = bot,
        _db = db;

  /// The Telegram bot instance.

  final TelegramBot _bot;
  final Database _db;
  final List<BaseHandler> _handlers = [];
  final Map<int, ConversationHandler> _sessions = {};

  void call(Map<String, Object?> update) {
    // Обработка обновления

    final context = Context(update: update, bot: _bot, db: _db);
    final chatId = context.chatId;
    if (chatId == null) return;
    final session = _sessions[chatId];
    // Есть ли сессия для этого чата
    if (session != null) {
      if (context.isCommand) {
        // если пришла новая команда, то мы удаляем сессию
        _sessions.remove(chatId)?.reset(chatId);
      } else {
        // если пришло сообщение, то мы обрабатываем его в сессии
        // и выходим
        session.handle(context);
        return;
      }
    }
    for (final handler in _handlers) {
      if (handler.canHandle(context)) {
        if (handler is ConversationHandler) {
          _sessions[chatId] = handler;
        }
        handler.handle(context);
        return;
      }
    }
  }

  void addHandler(BaseHandler handler) {
    _handlers.add(handler);
  }
}



