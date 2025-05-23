import 'package:telc_result_checker/src/database.dart';
import 'package:telc_result_checker/src/telegram_bot.dart';

class Context {
  Context({
    required Map<String, Object?> update,
    required TelegramBot bot,
    required Database db,
  })  : _update = update,
        _bot = bot,
        _db = db;

  final Map<String, Object?> _update;
  final TelegramBot _bot;
  final Database _db;

  TelegramBot get bot => _bot;
  Database get db => _db;

  Map<String, Object?>? get msg =>
      isCallback ? (callbackQuery?['message'] as Map<String, Object?>?) : _update['message'] as Map<String, Object?>?;
  Map<String, Object?>? get callbackQuery => _update['callback_query'] as Map<String, Object?>?;
  Map<String, Object?>? get chat => msg?['chat'] as Map<String, Object?>?;

  bool get isCallback => _update['callback_query'] != null;
  int? get messageId => msg?['message_id'] as int?;
  String get callbackId => callbackQuery?['id'] as String? ?? '';
  String? get callbackData => callbackQuery?['data'] as String?;
  int? get chatId => chat?['id'] as int?;
  String? get text => msg?['text'] as String?;
  bool get isCommand => getCommands()?.isNotEmpty ?? false;

  List<String>? getCommands() {
    final entities = (msg?['entities'] as List<dynamic>?)?.map((e) => e as Map<String, Object?>).toList();
    if (entities == null) return null;

    final txt = text;
    if (txt == null) return null;
    final commands = <String>[];

    for (final entity in entities) {
      if (entity
          case <String, Object?>{
            'type': String type,
            'offset': int offset,
            'length': int length,
          }) {
        if (type == 'bot_command') {
          commands.add(txt.substring(offset, offset + length));
        }
      }
    }

    return commands;
  }
}
