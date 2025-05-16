import 'package:l/l.dart';
import 'package:telc_result_checker/src/database.dart';
import 'package:telc_result_checker/src/dto/cetrificate_entity.dart';
import 'package:telc_result_checker/src/dto/search_info.dart';
import 'package:telc_result_checker/src/telegram_bot.dart';

abstract interface class LookupServiceHandler {
  Future<void> certFound(String id, CertificateEntity certificate);
  Future<void> certNotFound(String id, SearchInfo info);
}

final class TelegramNotificationHandler implements LookupServiceHandler {
  TelegramNotificationHandler(this.bot, this.storage);

  final TelegramBot bot;
  final IKeyValueStorage storage;

  @override
  Future<void> certFound(String id, CertificateEntity certificate) async {
    try {
      await bot.sendMessage(int.parse(id), 'Certificate found');
    } on Object catch (error, stackTrace) {
      l.e('Failed to send message: $error', stackTrace);
    }
  }

  @override
  Future<void> certNotFound(String id, SearchInfo info) async {
    final chatId = int.parse(id);
    final key = _createKey(id, info);
    final messageId = storage.getKey<int>(key);
    if (messageId != null) {
      bot.deleteMessage(chatId, messageId).ignore();
      storage.removeKey(key);
      l.i('Deleted message ID $messageId for ${info.nummer}');
    }

    try {
      final messageId = await bot.sendMessage(
        chatId,
        'Результатов не найдено за последние 15 дней для пользователя ${info.nummer}',
      );
      storage.setKey(key, messageId);
      l.i('Saved message ID $messageId for ${info.nummer}');
    } on Object catch (error, stackTrace) {
      l.e('Failed to send message: $error', stackTrace);
    }
  }

  String _createKey(String id, SearchInfo info) =>
      '$id${info.nummer}${info.examDate.hashCode}${info.birthDate.hashCode}';
}
