import 'dart:async';

import 'package:l/l.dart';
import 'package:owlistic/src/telegram_bot/base_handler.dart';
import 'package:owlistic/src/telegram_bot/context.dart';
import 'package:owlistic/src/telegram_bot/conversation_state.dart';
import 'package:owlistic/src/telegram_bot/guard.dart';

/// A callback function that defines a step in a conversation.
///
/// It takes the current [Context] and the conversation's [State] as input.
/// It should return a [FutureOr] of [Step<T>], indicating the next step
/// in the conversation or that the conversation is [Done].
///
/// - [T] is an [Enum] representing the possible steps in the conversation.
/// - [State] is the type of the state object associated with this conversation.
typedef ConversationStepCallback<T extends Enum, State> = FutureOr<Step<T>> Function(
  Context ctx,
  State state,
);

/// A type alias for chat ID, typically an integer.
typedef ChatId = int;

/// Handles multi-step conversations with users in a Telegram bot.
///
/// A `ConversationHandler` is initiated by a specific command and then proceeds
/// through a series of defined steps. Each step is represented by a callback
/// function that processes the user's input and determines the next step.
///
/// It maintains a [State] object for each active conversation, allowing data
/// to be persisted across multiple steps.
///
/// - [T] is an [Enum] that defines the possible steps of the conversation.
/// - [State] is the type of the custom state object used to store data
///   throughout the conversation.
class ConversationHandler<T extends Enum, State> extends BaseHandler with CommandHandlerMixin {
  /// Creates a new [ConversationHandler].
  ///
  /// This factory constructor delegates to the private `_internal` constructor.
  ///
  /// - [command]: The command string (e.g., "/add") that triggers this conversation.
  /// - [description]: A callback that returns a localized description of this command,
  ///   used for help messages.
  /// - [entryCallback]: The callback function for the first step of the conversation,
  ///   executed when the [command] is received.
  /// - [steps]: A map where keys are enum values of type [T] representing
  ///   conversation steps, and values are [ConversationStepCallback] functions
  ///   for those steps.
  /// - [stateBuilder]: A function that creates an initial instance of the [State]
  ///   object for a new conversation.
  /// - [guards]: An optional list of [Guard]s that can prevent the handler
  ///   from activating.
  factory ConversationHandler(
    String command,
    DescriptionCallback description,
    ConversationStepCallback<T, State> entryCallback, {
    required Map<T, ConversationStepCallback<T, State>> steps,
    required StateBuilder<State> stateBuilder,
    List<Guard>? guards,
  }) =>
      ConversationHandler<T, State>._internal(
        command,
        description,
        entryCallback,
        steps: steps,
        stateBuilder: stateBuilder,
        guards: guards,
      );

  /// Private constructor for [ConversationHandler].
  ///
  /// Initializes the handler with all necessary properties.
  ConversationHandler._internal(
    String command,
    DescriptionCallback description,
    ConversationStepCallback<T, State> entryCallback, {
    required Map<T, ConversationStepCallback<T, State>> steps,
    required StateBuilder<State> stateBuilder,
    super.guards,
  })  : _command = command,
        _description = description,
        _entryCallback = entryCallback,
        _steps = steps,
        _stateBuilder = stateBuilder,
        super();

  /// Creates a [ConversationHandler] that uses an [EmptyState].
  ///
  /// This is a convenience factory method for conversations that do not require
  /// a custom state object.
  ///
  /// - [command]: The command string that triggers this conversation.
  /// - [description]: A callback that returns a localized description of this command.
  /// - [entryCallback]: The callback for the first step, typed with [EmptyState].
  /// - [steps]: A map of conversation steps, with callbacks typed with [EmptyState].
  /// - [guards]: An optional list of [Guard]s.
  static ConversationHandler<T, EmptyState> emptyState<T extends Enum>(
    String command,
    DescriptionCallback description,
    ConversationStepCallback<T, EmptyState> entryCallback, {
    required Map<T, ConversationStepCallback<T, EmptyState>> steps,
    List<Guard>? guards,
  }) =>
      ConversationHandler<T, EmptyState>._internal(
        command,
        description,
        entryCallback,
        steps: steps,
        stateBuilder: emptyStateBuilder, // Uses a predefined builder for EmptyState
        guards: guards,
      );

  final String _command;
  final DescriptionCallback _description;
  final ConversationStepCallback<T, State> _entryCallback;
  final Map<T, ConversationStepCallback<T, State>> _steps;
  final StateBuilder<State> _stateBuilder;

  /// Stores active conversation sessions, mapping chat IDs to their [ConversationState].
  final Map<ChatId, ConversationState<T, State>> _session = {};

  @override
  String get command => _command;

  @override
  DescriptionCallback get description => _description;

  /// Handles an incoming [Context] (Telegram update).
  ///
  /// If no active session exists for the chat and the context's command matches
  /// this handler's command, a new conversation is started by calling the
  /// [_entryCallback].
  ///
  /// If an active session exists, the appropriate step callback from [_steps]
  /// is executed based on the session's current step.
  ///
  /// Errors during step execution lead to the session being reset.
  @override
  FutureOr<void> handle(Context ctx) async {
    final chatId = ctx.chatId;
    var state = _session[chatId];

    // If no state or conversation was reset (nextStep is null)
    if (state == null || state.nextStep == null) {
      // Check if the current context can start THIS conversation
      if (super.canHandle(ctx)) { // Uses canHandle from CommandHandlerMixin
        try {
          // Create a new state for the conversation
          state = ConversationState<T, State>(_stateBuilder());
          _session[chatId] = state;
          // Execute the entry callback for the new conversation
          final nextStepResult = await _entryCallback(ctx, state.state);
          _updateStateWithStepResult(chatId, state, nextStepResult);
        } on Object catch (error, stackTrace) {
          l.e('Error in conversation entry point for command $command: $error', stackTrace);
          reset(chatId); // Reset session on error
        }
      } else if (state != null) {
        // This case handles if state exists but nextStep is null (e.g., after an external reset)
        // and the current update is not the starting command.
        // Effectively, the conversation is over or wasn't meant to be handled by this non-command update.
      }
      // If not a command that can start this conversation, and no active state, do nothing.
      return;
    }

    // Existing conversation, process current step
    final currentStepEnum = state.nextStep; // This is of type T (the enum value for the step)

    final stepCallback = _steps[currentStepEnum];
    if (stepCallback == null) {
      l.e('Conversation step callback not found for step $currentStepEnum in command $command. Available steps: ${_steps.keys}');
      reset(chatId); // Reset session if step definition is missing
      return;
    }

    try {
      // Execute the callback for the current step
      final nextStepResult = await stepCallback(ctx, state.state);
      _updateStateWithStepResult(chatId, state, nextStepResult);
    } on Object catch (error, stackTrace) {
      l.e('Error in conversation step $currentStepEnum for command $command: $error', stackTrace);
      reset(chatId); // Reset session on error
    }
  }

  /// Updates the conversation state based on the result of a step callback.
  ///
  /// If [stepResult] is a [NextStep], the session's `nextStep` is updated.
  /// If the new step is not defined in [_steps], an error is logged and the session is reset.
  /// If [stepResult] is [Done], the session is reset.
  void _updateStateWithStepResult(int chatId, ConversationState<T, State> state, Step<T> stepResult) {
    switch (stepResult) {
      case NextStep<T> nextStep:
        state.nextStep = nextStep.step;
        // Ensure the next step is actually defined in the conversation's steps
        if (!_steps.containsKey(state.nextStep)) {
          l.e('Error: Next step ${state.nextStep} returned by callback is not present in the configured steps for command $command. Available: ${_steps.keys}');
          reset(chatId);
        }
        break;
      case Done<T>():
        reset(chatId); // Conversation finished, reset session
        break;
    }
  }

  /// Resets the conversation session for the given [chatId] by removing it
  /// from the active sessions map.
  void reset(int chatId) => _session.remove(chatId);
}
