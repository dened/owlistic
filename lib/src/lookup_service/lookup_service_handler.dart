import 'package:l/l.dart';
import 'package:owlistic/src/database.dart' show Database;
import 'package:owlistic/src/dto/certificate_entity.dart';
import 'package:owlistic/src/dto/search_info.dart';
import 'package:owlistic/src/localization/localization.dart';
import 'package:owlistic/src/telegram_bot/telegram_bot.dart';

abstract interface class LookupServiceHandler {
  Future<void> certFound(
      {required SearchInfo searchInfo, required String link, required CertificateEntity certificate});

  Future<void> certNotFound(int daysCount, SearchInfo searchInfo);
}

final class TelegramNotificationHandler implements LookupServiceHandler {
  TelegramNotificationHandler({
    required TelegramBot bot,
    required Database db,
    required Localization ln,
  })  : _bot = bot,
        _db = db,
        _ln = ln;

  final TelegramBot _bot;
  final Database _db;
  final Localization _ln;

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
      final certNotFoundMessage = await _ln.withChatId(
        searchInfo.chatId,
        () => _ln.certNotFoundMessage(daysCount, searchInfo.nummer),
      );
      final messageId = await _bot.sendMessage(
        searchInfo.chatId,
        certNotFoundMessage,
      );
      _db.setKey(searchInfo.key, messageId);
      l.i('Saved message ID $messageId for ${searchInfo.nummer}');
    } on ForbiddenTelegramException catch (error) {
      await _db.removeUserById(error.chatId);
      l.e('Bot is blocked: $error');
    } on Object catch (error, stackTrace) {
      l.e('Failed to send message: $error', stackTrace);
    }
  }

  @override
  Future<void> certFound(
      {required SearchInfo searchInfo, required String link, required CertificateEntity certificate}) async {
    try {
      final formattedMessage = await _formatCertificate(certificate, link, searchInfo.chatId);
      await _bot.sendMessage(
        searchInfo.chatId,
        formattedMessage,
        autoEscapeMarkdown: false,
        parseMode: ParseMode.html,
      );
      await _db.saveCertificate(
        searchInfoId: searchInfo.id,
        link: link,
        entity: certificate,
      );
    } on ForbiddenTelegramException catch (error) {
      await _db.removeUserById(error.chatId);
      l.e('Bot is blocked: $error');
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
  Future<String> _formatCertificate(CertificateEntity certificate, String link, int chatId) async {
    final title = await _ln.withChatId(chatId, () => _ln.certFoundTitle);
    final fullNameLabel = await _ln.withChatId(chatId, () => _ln.certFoundFullNameLabel);
    final linkText = await _ln.withChatId(chatId, () => _ln.certFoundLinkText);

    final buffer = StringBuffer()
      ..writeln('<b>$title</b>')
      ..writeln('');

    final personalData = certificate.personalData.content;
    if ({for (final c in personalData) c.type: c}
        case {
          'lastname': LastnameContent lastname,
          'firstname': FirstnameContent firstname,
        }) {
      buffer.writeln('<b>$fullNameLabel</b> ${firstname.content} ${lastname.content}');
    }

    final content =
        certificate.grades.content.whereType<PointsAndTextContent>().map((c) => (c.title, '${c.points}/${c.content}'));

    buffer.writeln();
    for (final (title, points) in content) {
      buffer.writeln('<b>- $title:</b> $points');
    }

    final resultText = certificate.grades.content.whereType<ResultTextContent>().map((c) => c.content).firstOrNull;
    if (resultText != null) {
      buffer.writeln(resultText);
    }

    buffer
      ..writeln('\n')
      ..writeln('<b><a href="$link">$linkText</a></b>');

    return buffer.toString();
  }
}

extension on SearchInfo {
  String get key => 'key_$id';
}
