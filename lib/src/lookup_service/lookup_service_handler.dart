import 'package:l/l.dart';
import 'package:telc_result_checker/src/database.dart' show Database;
import 'package:telc_result_checker/src/dto/cetrificate_entity.dart';
import 'package:telc_result_checker/src/dto/search_info.dart';
import 'package:telc_result_checker/src/telegram_bot/telegram_bot.dart';

abstract interface class LookupServiceHandler {
  Future<void> certFound(
      {required SearchInfo searchInfo, required String link, required CertificateEntity certificate});

  Future<void> certNotFound(int daysCount, SearchInfo searchInfo);
}

final class TelegramNotificationHandler implements LookupServiceHandler {
  TelegramNotificationHandler({
    required TelegramBot bot,
    required Database db,
  })  : _bot = bot,
        _db = db;

  final TelegramBot _bot;
  final Database _db;

  @override
  Future<void> certNotFound(int daysCount, SearchInfo searchInfo) async {
    final messageId = _db.getKey<int>(searchInfo.key);

    // If a message ID exists, delete the previous message
    // to avoid cluttering the chat with multiple messages.
    if (messageId != null) {
      _bot.deleteMessage(searchInfo.chatId, messageId).ignore();
      _db.removeKey(searchInfo.key);
      l.i('Deleted message ID $messageId for ${searchInfo.nummer}');
    }

    try {
      final messageId = await _bot.sendMessage(
        searchInfo.chatId,
        'Результатов не найдено за последние $daysCount дней для пользователя ${searchInfo.nummer}',
      );
      _db.setKey(searchInfo.key, messageId);
      l.i('Saved message ID $messageId for ${searchInfo.nummer}');
    } on Object catch (error, stackTrace) {
      l.e('Failed to send message: $error', stackTrace);
    }
  }

  @override
  Future<void> certFound(
      {required SearchInfo searchInfo, required String link, required CertificateEntity certificate}) async {
    try {
      await _bot.sendMessage(
        searchInfo.chatId,
        _formatCertificate(certificate, link),
        autoEscapeMarkdown: false,
        parseMode: ParseMode.html,
      );
      await _db.saveCertificate(
        searchInfoId: searchInfo.id,
        link: link,
        entity: certificate,
      );
    } on Object catch (error, stackTrace) {
      l.e('Failed to send message: $error', stackTrace);
    }
  }

  /// Formats the certificate information into a string for sending as a message.
  ///
  /// Example output:
  /// <b>Сертификат найден!</b>
  ///
  /// <b>ФИО:</b> User Name
  /// <b>- Lesen:</b> 57/60
  /// <b>- Hören:</b> 48/60
  /// <b>- Schreiben:</b> 32.5/60
  /// <b>- Sprechen:</b> 46/60
  /// <b>- Gesamtergebnis B2:</b> 183.5/240
  /// Das angestrebte Prüfungsziel B2 nach dem GER wurde gut erfüllt.
  ///
  /// <b><a href="https://example.com/certificate/12345">Ссылка на сертификат</a></b>
  String _formatCertificate(CertificateEntity certrificate, String link) {
    final buffer = StringBuffer()
      ..writeln('<b>Сертификат найден!</b>')
      ..writeln('');

    final personalData = certrificate.personalData.content;
    if ({for (final c in personalData) c.type: c}
        case {
          'lastname': LastnameContent lastname,
          'firstname': FirstnameContent firstname,
        }) {
      buffer.writeln('<b>ФИО:</b> ${firstname.content} ${lastname.content}');
    }

    final content =
        certrificate.grades.content.whereType<PointsAndTextContent>().map((c) => (c.title, '${c.points}/${c.content}'));

    buffer.writeln();
    for (final (title, points) in content) {
      buffer.writeln('<b>- $title:</b> $points');
    }

    final resultText = certrificate.grades.content.whereType<ResultTextContent>().map((c) => c.content).firstOrNull;
    if (resultText != null) {
      buffer.writeln(resultText);
    }

    buffer
      ..writeln('\n')
      ..writeln('<b><a href="$link">Ссылка на сертификат</a></b>');

    return buffer.toString();
  }
}

extension on SearchInfo {
  String get key => 'key_$id';
}