import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:l/l.dart';
import 'package:telc_result_checker/src/retry.dart';

final Converter<List<int>, Map<String, Object?>> _jsonDecoder =
    utf8.decoder.fuse(json.decoder).cast<List<int>, Map<String, Object?>>();

final Converter<Object?, List<int>> _jsonEncoder = json.encoder.fuse(utf8.encoder);

class TelegramBot {
  TelegramBot({
    required String token,
    http.Client? client,
  })  : _client = client ?? http.Client(),
        _baseUri = Uri.parse('https://api.telegram.org/bot$token');

  final Uri _baseUri;
  final http.Client _client;

  /// Send a message to a chat.
  Future<int> sendMessage(
    int chatId,
    String text, {
    bool disableNotification = true,
    bool protectContent = true,
  }) async {
    final url = _buildMethodUri('sendMessage');
    final response = await retry(
      () => _client
          .post(
            url,
            body: _jsonEncoder.convert(<String, Object?>{
              'chat_id': chatId,
              'text': text,
              'parse_mode': 'MarkdownV2',
              'disable_notification': disableNotification,
              'protect_content': protectContent,
            }),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 12)),
    );
    if (response.statusCode != 200) throw Exception('Failed to send message: status code ${response.statusCode}');
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

  @pragma('vm:prefer-inline')
  Uri _buildMethodUri(String method) => _baseUri.replace(path: '${_baseUri.path}/$method');
}
