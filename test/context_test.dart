import 'package:mockito/annotations.dart';
import 'package:owlistic/src/database.dart';
import 'package:owlistic/src/localization/localization.dart';
import 'package:owlistic/src/telegram_bot/context.dart';
import 'package:owlistic/src/telegram_bot/telegram_bot.dart';
import 'package:test/test.dart';

import 'context_test.mocks.dart';

// Annotation to generate mocks for TelegramBot and Database.
@GenerateMocks([TelegramBot, Database, Localization])
void main() {
  // Declare mock instances to be used in tests.
  late MockTelegramBot mockTelegramBot;
  late MockDatabase mockDatabase;
  late MockLocalization mockLn;

  group('Context', () {
    setUp(() {
      // Initialize mocks before each test in this group.
      mockTelegramBot = MockTelegramBot();
      mockDatabase = MockDatabase();
      mockLn = MockLocalization();
    });

    test('getCommands returns a list of commands when entities are present', () {
      final update = {
        'message': {
          'message_id': 1,
          'chat': {'id': 123},
          'text': '/start /help',
          'entities': [
            {'type': 'bot_command', 'offset': 0, 'length': 6},
            {'type': 'bot_command', 'offset': 7, 'length': 5},
          ],
        },
      };
      final context = Context(update: update, bot: mockTelegramBot, db: mockDatabase, ln: mockLn);

      expect(context.commands, ['/start', '/help']);
    });

    test('getArgs returns arguments for commands when text follows commands', () {
      final update = {
        'message': {
          'message_id': 1,
          'chat': {'id': 123},
          'text': '/che 2342 /rest aassd asd as /h',
          'entities': [
            {'offset': 0, 'length': 4, 'type': 'bot_command'},
            {'offset': 10, 'length': 5, 'type': 'bot_command'},
            {'offset': 29, 'length': 2, 'type': 'bot_command'},
          ],
        },
      };
      final context = Context(update: update, bot: mockTelegramBot, db: mockDatabase, ln: mockLn);

      expect(context.getArgs(), {'/che': '2342', '/rest': 'aassd asd as'});
    });

    test('getArgs returns an empty map if commands have no arguments', () {
      final update = {
        'message': {
          'message_id': 1,
          'chat': {'id': 123},
          'text': '/start',
          'entities': [
            {'type': 'bot_command', 'offset': 0, 'length': 6},
          ],
        },
      };
      final context = Context(update: update, bot: mockTelegramBot, db: mockDatabase, ln: mockLn);

      expect(context.getArgs(), isEmpty);
    });
  });
}
