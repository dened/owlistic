import 'dart:async';

import 'package:l/l.dart';
import 'package:telc_result_checker/src/database.dart';
import 'package:telc_result_checker/src/telegram/context.dart';
import 'package:telc_result_checker/src/telegram_bot.dart';

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

typedef Handler = FutureOr<void> Function(Context ctx);

abstract class BaseHandler {
  bool canHandle(Context ctx);

  FutureOr<void> handle(Context ctx);
}

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

typedef ConversationStep = FutureOr<int> Function(Context ctx, Map<String, Object?> storage);

class ConversationFirstStep {
  ConversationFirstStep(
    String command,
    FutureOr<int> Function(Context ctx) entry,
  )   : _command = command,
        _callback = entry;

  final String _command;
  final FutureOr<int> Function(Context ctx) _callback;

  bool canHandle(Context ctx) {
    final commands = ctx.getCommands();
    if (commands == null) return false;
    // only one command is allowed
    if (commands.length != 1) return false;

    return _command == commands.first;
  }

  FutureOr<int> handle(Context ctx) => _callback(ctx);
}

class ConversationHandler extends BaseHandler {
  ConversationHandler(
    String command,
    FutureOr<int> Function(Context ctx) entry, {
    required Map<int, ConversationStep> steps,
  })  : _steps = steps,
        _callback = ConversationFirstStep(command, entry);

  static const int finish = -1;

  final ConversationFirstStep _callback;
  final Map<int, ConversationStep> _steps;

  final Map<int, ConversationState> _conversationStates = {};

  @override
  bool canHandle(Context ctx) => _callback.canHandle(ctx);

  @override
  FutureOr<void> handle(Context ctx) async {
    // вход в беседу
    if (_callback.canHandle(ctx)) {
      try {
        final nextStep = await _callback.handle(ctx);
        _conversationStates[ctx.chatId!] = ConversationState(nextStep);
        assert(_steps.containsKey(nextStep), 'Conversation step $nextStep not found in $_steps');
      } on Object catch (error, stackTrace) {
        l.e('Error in conversation handler: $error', stackTrace);
      }
    } else {
      final chatId = ctx.chatId;
      if (chatId == null) return;
      final state = _conversationStates[chatId];
      if (state == null) {
        l.e('Conversation state not found for chat ${ctx.chatId}');
        reset(chatId);
        return;
      }
      final step = _steps[state.nextStep];
      if (step == null) {
        l.e('Conversation step ${state.nextStep} not found in $_steps');
        reset(ctx.chatId!);
        return;
      }
      // обработка сообщения в беседе
      try {
        state.nextStep = await step(ctx, state.storage);
        if (state.nextStep == finish) {
          reset(chatId);
        } else {
          assert(_steps.containsKey(state.nextStep), 'Conversation step $state.nextStep not found in $_steps');
        }
      } on Object catch (error, stackTrace) {
        l.e('Error in conversation handler: $error', stackTrace);
      }
    }
  }

  void reset(int chatId) {
    _conversationStates.remove(chatId);
  }
}

class ConversationState {
  ConversationState(int nextStep) : _nextStep = nextStep;

  final Map<String, Object?> _storage = {};
  Map<String, Object?> get storage => _storage;

  int? _nextStep;
  int get nextStep => _nextStep!;
  set nextStep(int value) {
    _nextStep = value;
  }

  void reset() {
    _nextStep = null;
    _storage.clear();
  }
}
