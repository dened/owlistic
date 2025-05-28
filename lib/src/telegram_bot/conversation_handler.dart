import 'dart:async';

import 'package:l/l.dart';
import 'package:owlistic/src/telegram_bot/base_handler.dart';
import 'package:owlistic/src/telegram_bot/context.dart';

typedef ConversationStep = FutureOr<int> Function(Context ctx, Map<String, Object?> storage);

class ConversationFirstStep {
  ConversationFirstStep(
    String command,
    FutureOr<int> Function(Context ctx, Map<String, Object?> storage) entry,
  )   : _command = command,
        _callback = entry;

  final String _command;
  final FutureOr<int> Function(Context ctx, Map<String, Object?> storage) _callback;

  bool canHandle(Context ctx) {
    final commands = ctx.getCommands();
    if (commands == null) return false;
    // only one command is allowed
    if (commands.length != 1) return false;

    return _command == commands.first;
  }

  FutureOr<int> handle(Context ctx, Map<String, Object?> storage) => _callback(ctx, storage);
}

class ConversationHandler extends BaseHandler {
  ConversationHandler(
    String command,
    FutureOr<int> Function(Context ctx, Map<String, Object?> storage) entry, {
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
        final state = ConversationState();

        state.nextStep = await _callback.handle(ctx, state.storage);
        _conversationStates[ctx.chatId!] = state;
        assert(_steps.containsKey(state.nextStep), 'Conversation step ${state.nextStep} not found in $_steps');
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
