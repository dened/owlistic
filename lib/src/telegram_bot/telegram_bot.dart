import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:l/l.dart';
import 'package:owlistic/src/retry.dart';

final Converter<List<int>, Map<String, Object?>> _jsonDecoder =
    utf8.decoder.fuse(json.decoder).cast<List<int>, Map<String, Object?>>();

final Converter<Object?, List<int>> _jsonEncoder = json.encoder.fuse(utf8.encoder);

typedef OnUpdateHandler = void Function(int id, Map<String, Object?> update);

/// Represents a button in an inline keyboard.
class InlineKeyboardButton {
  InlineKeyboardButton({required this.text, this.callbackData, this.url});

  final String text;
  final String? callbackData;
  final String? url;

  Map<String, Object?> toJson() => {
    'text': text,
    if (callbackData != null) 'callback_data': callbackData,
    if (url != null) 'url': url,
  };
}

/// Represents the parse mode for Telegram messages.
enum ParseMode {
  markdownV2('MarkdownV2'),
  html('HTML'),
  markdown('Markdown');

  const ParseMode(this.type);
  final String type;
}

/// A simple Telegram bot client.
class TelegramBot {
  TelegramBot({
    required String token,
    http.Client? client,
    Duration poolingTimeout = const Duration(seconds: 30),
    int? offset,
  }) : _client = client ?? http.Client(),
       _baseUri = Uri.parse('https://api.telegram.org/bot$token'),
       _poolingTimeout = poolingTimeout,
       _offset = offset ?? 0;

  final Uri _baseUri;
  final http.Client _client;
  final Duration _poolingTimeout;

  int _offset;
  Completer<void>? _poller;

  final List<OnUpdateHandler> _updateHandlers = <OnUpdateHandler>[];

  /// Escape special characters in a MarkdownV2 string.
  static String escapeMarkdownV2(String text) {
    if (text.isEmpty) return text;
    const specialChars = r'_*\[\]()~`>#+\-=|{}.!';
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (specialChars.contains(char)) buffer.write(r'\');
      buffer.write(char);
    }

    return buffer.toString();
  }

  /// Add a handler to be called when an update is received.
  void addHandler(OnUpdateHandler handler) {
    _updateHandlers.add(handler);
  }

  /// Remove a handler from the list of handlers.
  void removeHandler(OnUpdateHandler handler) {
    _updateHandlers.remove(handler);
  }

  /// Send a message to a chat.
  Future<int> sendMessage(
    int chatId,
    String text, {
    bool disableNotification = true,
    bool protectContent = false,
    bool autoEscapeMarkdown = true,
    ParseMode parseMode = ParseMode.markdownV2,
    Map<String, Object?>? replyMarkup,
  }) async {
    final url = _buildMethodUri('sendMessage');
    final response = await retry(
      () => _client
          .post(
            url,
            body: _jsonEncoder.convert(<String, Object?>{
              'chat_id': chatId,
              'text': (autoEscapeMarkdown && parseMode == ParseMode.markdownV2) ? escapeMarkdownV2(text) : text,
              'parse_mode': parseMode.type,
              'disable_notification': disableNotification,
              'protect_content': protectContent,
              if (replyMarkup != null) 'reply_markup': replyMarkup,
            }),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 12)),
    );
    if (response.statusCode != 200)
      switch (response.statusCode) {
        case 403:
          throw ForbiddenTelegramException(chatId: chatId);
        default:
          throw Exception('Failed to send message: status code ${response.statusCode},  body: ${response.body}');
      }
    final result = _jsonDecoder.convert(response.bodyBytes);
    if (result case <String, Object?>{'ok': true, 'result': <String, Object?>{'message_id': int messageId}}) {
      l.d(result);
      return messageId;
    } else if (result case <String, Object?>{'ok': false, 'description': String description}) {
      l.w('Failed to send message: $description', StackTrace.current, result);
      throw Exception('Failed to send message: $description');
    } else {
      l.w('Failed to send message', StackTrace.current, result);
      throw Exception('Failed to send message');
    }
  }

  /// Edit the message
  Future<int> editMessageText(
    int chatId,
    int messageId,
    String text, {
    bool disableNotification = true,
    bool protectContent = false,
    bool autoEscapeMarkdown = true,
    ParseMode parseMode = ParseMode.markdownV2,
    Map<String, Object?>? replyMarkup,
  }) async {
    final url = _buildMethodUri('editMessageText');
    final response = await retry(
      () => _client
          .post(
            url,
            body: _jsonEncoder.convert(<String, Object?>{
              'chat_id': chatId,
              'message_id': messageId,
              'text': autoEscapeMarkdown ? escapeMarkdownV2(text) : text,
              'parse_mode': parseMode.type,
              'disable_notification': disableNotification,
              'protect_content': protectContent,
              if (replyMarkup != null) 'reply_markup': replyMarkup,
            }),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 12)),
    );
    if (response.statusCode != 200)
      switch (response.statusCode) {
        case 403:
          throw ForbiddenTelegramException(chatId: chatId);
        default:
          throw Exception('Failed to send message: status code ${response.statusCode},  body: ${response.body}');
      }
    final result = _jsonDecoder.convert(response.bodyBytes);
    if (result case <String, Object?>{'ok': true, 'result': <String, Object?>{'message_id': int messageId}}) {
      l.d(result);
      return messageId;
    } else if (result case <String, Object?>{'ok': false, 'description': String description}) {
      l.w('Failed to send message: $description', StackTrace.current, result);
      throw Exception('Failed to send message: $description');
    } else {
      l.w('Failed to send message', StackTrace.current, result);
      throw Exception('Failed to send message');
    }
  }

  /// Delete a message from a chat.
  Future<void> deleteMessage(int chatId, int messageId) async {
    final url = _buildMethodUri('deleteMessage');
    final response = await retry(
      () => _client
          .post(
            url,
            body: _jsonEncoder.convert({'chat_id': chatId, 'message_id': messageId}),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 12)),
    );
    if (response.statusCode == 200 || response.statusCode == 400) return;
    l.w('Failed to delete message: status code ${response.statusCode}', StackTrace.current);
    throw Exception('Failed to delete message: status code ${response.statusCode}');
  }

  /// Delete messages from a chat.
  Future<void> deleteMessages(int chatId, Set<int> messageIds) async {
    if (messageIds.isEmpty) return;
    if (messageIds.length == 1) return deleteMessage(chatId, messageIds.single);
    final url = _buildMethodUri('deleteMessages');
    final toDelete = messageIds.toList(growable: false);
    final length = toDelete.length;
    for (var i = 0; i < length; i += 100) {
      final response = await retry(
        () => _client
            .post(
              url,
              body: _jsonEncoder.convert({
                'chat_id': chatId,
                'message_ids': toDelete.sublist(i, math.min(i + 100, length)),
              }),
              headers: {'Content-Type': 'application/json'},
            )
            .timeout(const Duration(seconds: 12)),
      );
      if (response.statusCode == 200 || response.statusCode == 400) continue;
      l.w('Failed to delete messages: status code ${response.statusCode}', StackTrace.current);
      throw Exception('Failed to delete messages: status code ${response.statusCode}');
    }
  }

  Future<int> sendInlineKeyboard(
    int chatId,
    String text,
    List<List<InlineKeyboardButton>> buttons, {
    bool disableNotification = true,
    bool protectContent = true,
  }) async {
    final replyMarkup = <String, Object?>{
      'inline_keyboard': buttons
          .map((row) => row.map((button) => button.toJson()).toList(growable: false))
          .toList(growable: false),
    };
    return sendMessage(
      chatId,
      text,
      disableNotification: disableNotification,
      protectContent: protectContent,
      replyMarkup: replyMarkup,
    );
  }

  Future<int> sendReplyKeyboard(
    int chatId,
    String text,
    List<List<InlineKeyboardButton>> buttons, {
    bool resizeKeyboard = true,
    bool oneTimeKeyboard = true,
  }) async {
    final replyMarkup = <String, Object?>{
      'keyboard': buttons
          .map((row) => row.map((button) => button.toJson()).toList(growable: false))
          .toList(growable: false),
      'resize_keyboard': resizeKeyboard,
      'one_time_keyboard': oneTimeKeyboard,
    };
    return sendMessage(chatId, text, disableNotification: true, protectContent: true, replyMarkup: replyMarkup);
  }

  Future<int> sendReplyKeyboardRemove(int chatId, String text, {bool selective = true}) async {
    final replyMarkup = <String, Object?>{'remove_keyboard': true, 'selective': selective};
    return sendMessage(chatId, text, disableNotification: true, protectContent: true, replyMarkup: replyMarkup);
  }

  /// Answer a callback query.
  Future<void> answerCallbackQuery(String callbackQueryId, String text, {bool arlert = false}) async {
    final url = _buildMethodUri('answerCallbackQuery');
    final response = await retry(
      () => _client
          .post(
            url,
            body: _jsonEncoder.convert({
              'callback_query_id': callbackQueryId,
              if (text.isNotEmpty) 'text': text,
              if (arlert) 'show_alert': arlert,
            }),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 12)),
    );
    if (response.statusCode == 200 || response.statusCode == 400) return;
    l.w('Failed to answer callback query: status code ${response.statusCode}', StackTrace.current);
    throw Exception('Failed to answer callback query: status code ${response.statusCode}');
  }

  @pragma('vm:prefer-inline')
  Uri _buildMethodUri(String method) => _baseUri.replace(path: '${_baseUri.path}/$method');

  /// Start polling for updates.
  void start({Set<String> types = const <String>{'message', 'callback_query'}}) => runZonedGuarded(
    () {
      stop();
      final allowedTypes = jsonEncode(types.toList(growable: false));
      final url = _buildMethodUri('getUpdates');
      final poller = _poller = Completer<void>()..future.ignore();
      Future<void>(() async {
        while (true) {
          try {
            if (poller.isCompleted) return;
            final updates = await _getUpdates(
              url.replace(
                queryParameters: {
                  'allowed_updates': allowedTypes,
                  'timeout': _poolingTimeout.inSeconds.toString(),
                  'offset': _offset.toString(),
                },
              ),
            ).timeout(_poolingTimeout * 2);
            if (poller.isCompleted) return;
            _handleUpdates(updates);
          } on TimeoutException catch (e, stackTrace) {
            l.e('Timeout while polling for updates: $e', stackTrace);
          } on Object catch (e, stackTrace) {
            l.e('Error while polling for updates: $e', stackTrace);
            await Future<void>.delayed(const Duration(seconds: 5));
          }
        }
      });
    },
    (error, stackTrace) {
      l.e('Error while polling for updates: $error', stackTrace);
    },
  );

  void stop() {
    _poller?.complete();
  }

  /// Handle updates received from polling.
  void _handleUpdates(List<({int id, Map<String, Object?> update})> updates) {
    for (final update in updates) {
      assert(update.id >= 0 && update.id + 1 > _offset, 'Invalid update id: ${update.id}');
      _offset = math.max(_offset, update.id + 1);
      for (final handler in _updateHandlers) {
        try {
          handler(update.id, update.update);
          l.d('_handleUpdates {id: ${update.id}, update: ${update.update}');
        } on Object catch (error, stackTrace) {
          l.e('Error while handling update #${update.id}: $error', stackTrace, {
            'id': update.id,
            'update': update.update,
          });
          continue;
        }
      }
    }
  }

  Future<List<({int id, Map<String, Object?> update})>> _getUpdates(Uri url) async {
    final response = await _client.get(url).timeout(_poolingTimeout * 2);
    if (response.statusCode != 200) {
      l.w(
        'Failed to get updates: status code ${response.statusCode}',
        StackTrace.current,
        _jsonDecoder.convert(response.bodyBytes),
      );
      return const [];
    }
    final update = _jsonDecoder.convert(response.bodyBytes);
    if (update['ok'] != true) {
      l.w('Failed to get updates: not ok', StackTrace.current, update);
      return const [];
    }

    final result = update['result'];
    if (result is! List) {
      l.w('Failed to get updates: result is not a list', StackTrace.current, update);
      return const [];
    }

    return result
      .whereType<Map<String, Object?>>()
      .map<({int id, Map<String, Object?> update})>(
        (u) => (
          id: switch (u['update_id']) {
            int id => id,
            _ => -1,
          },
          update: u,
        ),
      )
      .where((u) => u.id > 0)
      .toList(growable: false)..sort((a, b) => a.id.compareTo(b.id));
  }
}

/// Indicates that the bot was blocked by the user.
/// This should be handled by removing the user from the database.
class ForbiddenTelegramException implements Exception {
  const ForbiddenTelegramException({required int chatId}) : _chatId = chatId;

  final int _chatId;
  int get chatId => _chatId;

  @override
  String toString() => 'Forbidden: bot was blocked by the user: $chatId';
}
