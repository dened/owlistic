/// Represents the state of a single conversation session for a specific chat.
///
/// Each active conversation in a chat has an instance of [ConversationState]
/// associated with it. This class holds the custom state data ([State])
/// that persists throughout the conversation and tracks the [nextStep]
/// to be executed.
///
/// - [T] is an [Enum] defining the possible steps of the conversation.
/// - [State] is the type of the custom state object for this conversation.
class ConversationState<T extends Enum, State> {
  /// Creates a new [ConversationState] with the initial [state].
  ConversationState(State state) : _state = state;

  final State _state;

  /// Stores the actual enum value of the next step to be processed.
  T? nextStep;

  /// Gets the custom state object for this conversation.
  State get state => _state;
}

// Defines the possible outcomes of a conversation step.
sealed class Step<T extends Enum> {
  const Step();
}

// Indicates the conversation should proceed to the specified next step.
class NextStep<T extends Enum> extends Step<T> {
  const NextStep(this.step);
  final T step; // The enum value of the next step.
}

// Indicates the conversation has finished.
class Done<T extends Enum> extends Step<T> {
  const Done();
}

/// A simple example enum for conversation steps.
///
/// Replace this with your own enum specific to each conversation handler.
enum OneStep { go }

/// A function type for creating an initial state object for a conversation.
///
/// - [State] is the type of the state object to be created.
typedef StateBuilder<State> = State Function();

/// A predefined [StateBuilder] that creates an [EmptyState].
///
/// Useful for conversations that do not require custom state data.
StateBuilder<EmptyState> emptyStateBuilder = () => const EmptyState();

/// A simple empty class to be used as a state for conversations
/// that do not require custom state data.
final class EmptyState {
  const EmptyState();
}
