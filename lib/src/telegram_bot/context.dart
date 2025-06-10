import 'package:owlistic/src/database.dart';
import 'package:owlistic/src/localization/localization.dart';
import 'package:owlistic/src/telegram_bot/telegram_bot.dart';

/// Represents the context of an incoming Telegram update.
///
/// This class parses the raw update data and provides convenient access
/// to common fields like `chatId`, `messageId`, `text`, `callbackData`, etc.
/// It also handles parsing of bot commands from the message text.
class Context {
  /// Creates a new [Context] instance from a raw Telegram update.
  ///
  /// Parses the `update` map to extract relevant information for messages
  /// and callback queries.
  Context({
    required Map<String, Object?> update,
    required TelegramBot bot,
    required Database db,
    required Localization ln,
  })  : _rawUpdate = update,
        _bot = bot,
        _db = db,
        _ln = ln {
    // Store the raw update, bot, and database instances.
    if (update case {'message': final Map<String, Object?> msg}) {
      _msg = msg;
    } else if (update
        case {
          'callback_query': {
            'message': final Map<String, Object?> msg,
            'data': final String data,
            'id': final String id,
          }
        }) {
      _msg = msg;
      _callbackId = id;
      _callbackData = data;
    } else {
      // If the update structure is unrecognized, throw an exception.
      throw Exception('Error during parse of update: $update');
    }

    if (_msg
        // Further parse the extracted message (_msg) for common fields.
        case {
          'message_id': final int id,
          'chat': final Map<String, Object?> chat,
          'text': final String? text,
        }) {
      _messageId = id;
      _chat = chat;
      _text = text;
    } else {
      // If the message structure is invalid, throw an exception.
      throw Exception('Error during parse of message: $_msg');
    }

    // Extract the chat ID from the chat object.
    _chatId = switch (_chat) {
      {'id': final int id} => id,
      _ => throw Exception('Error during parse of chat: $_chat'),
    };

    _languageCode = switch (_msg) {
      {'from': {'language_code': final String languageCode}} => languageCode,
      _ => null,
    };


    // Parse bot commands from the message text.
    _commands = _parseCommands();
  }

  /// The raw Telegram update data.
  final Map<String, Object?> _rawUpdate;

  /// The Telegram bot instance for sending replies or performing actions.
  final TelegramBot _bot;

  /// The database instance for data persistence.
  final Database _db;

  /// The localization instance for handling internationalization.
  final Localization _ln;

  /// The 'message' part of the update.
  late Map<String, Object?> _msg;

  /// The ID of the message.
  late int _messageId;

  /// The text content of the message, if any.
  String? _text;

  /// The 'chat' object from the message.
  late Map<String, Object?> _chat;

  /// The ID of the chat.
  late int _chatId;

  /// The language code of the chat.
  String? _languageCode;


  /// The ID of the callback query, if the update is a callback query.
  late String _callbackId;

  /// The data associated with the callback query, if any.
  String? _callbackData;

  /// A list of bot commands found in the message text.
  List<String>? _commands;

  /// Gets the [TelegramBot] instance.
  TelegramBot get bot => _bot;

  /// Gets the data associated with the callback query.
  String? get callbackData => _callbackData;

  /// Gets the ID of the callback query.
  String get callbackId => _callbackId;
  
  /// Gets the 'chat' object from the message.
  Map<String, Object?> get chat => _chat;

  /// Gets the ID of the chat.
  int get chatId => _chatId;

  /// Gets the language code of the chat. 
  String? get languageCode => _languageCode;


  /// Gets the list of bot commands found in the message.
  List<String>? get commands => _commands;

  /// Gets the [Database] instance.
  Database get db => _db;

  /// Returns `true` if the message contains any bot commands.
  bool get isCommand => _commands?.isNotEmpty ?? false;

  /// Gets the [Localization] instance.
  Localization get ln => _ln;

  /// Gets the ID of the message.
  int get messageId => _messageId;

  /// Gets the raw Telegram update data.
  Map<String, Object?> get rawUpdate => _rawUpdate;

  /// Gets the text content of the message.
  String? get text => _text;


  Map<String, String?>? getArgs() {
    final txt = text;
    if (txt == null) return null;

    final commands = _parseCommands();
    if (commands == null) return null;

    // A map to store commands and their corresponding arguments.
    final args = <String, String?>{};
    for (final command in commands) {
      // Find the start of the argument (right after the command).
      final argStart = txt.indexOf(command) + command.length;
      // Find the end of the argument (before the next command or end of text).
      final argEnd = txt.indexOf('/', argStart);

      final arg = txt.substring(argStart, argEnd > -1 ? argEnd : txt.length).trim();
      if (arg.isNotEmpty) {
        args[command] = arg;
      }
    }

    return args;
  }

  /// Parses bot commands from the message text and its entities.
  ///
  /// A command is identified by an entity of type 'bot_command'.
  /// Returns a list of command strings (e.g., ["/start", "/help"]) or `null`
  /// if no commands are found or if the text is null.
  List<String>? _parseCommands() {
    final text = _text;
    if (text == null) return null;

    // Use pattern matching on the 'entities' field of the message.
    return switch (_msg['entities']) {
      List<dynamic> list => list
            // Filter for elements that are maps (representing entities).
            .whereType<Map<String, Object?>>()
            // Further filter for maps that represent a 'bot_command'.
            .where((map) => switch (map) {
                  {'type': 'bot_command', 'offset': int _, 'length': int _} => true,
                  _ => false,
                })
            // For each valid 'bot_command' entity, extract the command text.
            .map((map) {
          final offset = map['offset'] as int;
          final length = map['length'] as int;
          return text.substring(offset, offset + length);
        }).toList(),
      // If 'entities' is not a list or is null, return null.
      _ => null,
    };
  }
}
