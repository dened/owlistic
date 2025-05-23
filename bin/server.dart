import 'dart:async';
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:l/l.dart';
import 'package:telc_result_checker/owlistic.dart';
import 'package:telc_result_checker/src/database.dart';
import 'package:telc_result_checker/src/lookup_service_handler.dart';
import 'package:telc_result_checker/src/telegram/command_proccessor.dart';
import 'package:telc_result_checker/src/telegram_bot.dart';

Future<void> main(List<String> args) async {
  final arguments = Arguments.parse(args);

  l.capture(
    () => runZonedGuarded<void>(() async {
      final storage = FileStorage(arguments.file);
      await storage.refresh();

      final db = Database.lazy();
      await db.refresh();
      l.i('Database is ready');
      final lastUpdateId = db.getKey<int>(updateIdKey);
      final bot = TelegramBot(
        token: arguments.token,
        offset: lastUpdateId,
      );

      final service = TelcCertificateLookupService(
        apiClient: TelcApiClient(),
        storage: storage,
        handler: TelegramNotificationHandler(bot, db),
      );
      await service.start();

      bot
        ..addHandler(handler(
          bot: bot,
          db: db,
        ))
        ..start();
    }, (error, stackTrace) {
      l.e('An top level error occurred. $error', stackTrace);
      debugger(); // Set a breakpoint here
    }),
    LogOptions(
      handlePrint: true,
      outputInRelease: true,
      printColors: false,
      overrideOutput: (event) {
        //logsBuffer.add(event);
        if (event.level.level > arguments.verbose.level) return null;
        var message = switch (event.message) {
          String text => text,
          Object obj => obj.toString(),
        };
        if (kReleaseMode) {
          // Hide sensitive data in release mode
          if (arguments.token case String key when key.isNotEmpty) message = message.replaceAll(key, '******');
        }
        return '[${event.level.prefix}] '
            '${DateFormat('dd.MM.yyyy HH:mm:ss').format(event.timestamp)} '
            '| $message';
      },
    ),
  );
}

void Function(int updateId, Map<String, Object?> update) handler({
  required TelegramBot bot,
  required Database db,
}) {
  final messageHandler = CommandProcessor(
    bot: bot,
    db: db,
  )
    ..addHandler(
      CommandHandler('/help', (ctx) async {
        await ctx.bot.sendMessage(
          ctx.chatId!,
          'Available commands:\n'
          '/help - Show this help message\n'
          '/start - Start the bot\n'
          '/language - Set language\n'
          '/stop - Stop the bot\n',
        );
      }),
    )
    ..addHandler(
      CommandHandler('/start', (ctx) async {
        await ctx.bot.sendMessage(
          ctx.chatId!,
          'Start the bot\n',
        );
      }),
    )
    ..addHandler(
      CommandHandler('/stop', (ctx) async {
        await ctx.bot.sendMessage(
          ctx.chatId!,
          'Stop the bot',
        );
      }),
    )
    ..addHandler(ConversationHandler('/language', (ctx) async {
      await ctx.bot.sendInlineKeyboard(
          ctx.chatId!, 'Выберите язык из поддерживаемых(Английский, Немецкий, Русский, Украинский):', [
        [
          InlineKeyboardButton(text: 'Английский', callbackData: 'en'),
          InlineKeyboardButton(text: 'Немецкий', callbackData: 'de'),
        ],
        [
          InlineKeyboardButton(text: 'Русский', callbackData: 'ru'),
          InlineKeyboardButton(text: 'Украинский', callbackData: 'uk'),
        ],
      ]);
      return 0;
    }, steps: {
      0: (ctx, state) async {
        final language = ctx.callbackData;
        if (language == null || language.isEmpty) {
          await ctx.bot.sendMessage(ctx.chatId!, 'Please provide a valid language.');
          return 0;
        }
        await ctx.bot.deleteMessage(ctx.chatId!, ctx.messageId!);
        await ctx.bot.answerCallbackQuery(ctx.callbackId, '');
        return ConversationHandler.finish;
      },
    }))
    ..addHandler(ConversationHandler('/add', (ctx) async {
      // Define the entry logic here
      await ctx.bot.sendMessage(
        ctx.chatId!,
        'Введите номер',
      );
      return AddConversationStep.number.index;
    }, steps: <int, ConversationStep>{
      AddConversationStep.number.index: (ctx, state) async {
        final number = ctx.text;
        if (number == null || number.isEmpty) {
          await ctx.bot.sendMessage(ctx.chatId!, 'Please provide a valid number.');
          return AddConversationStep.number.index;
        }
        state['number'] = number;
        await ctx.bot.sendMessage(ctx.chatId!, 'Please provide your birth date:');
        return AddConversationStep.birthDate.index;
      },
      AddConversationStep.birthDate.index: (ctx, state) async {
        final birthDate = ctx.text;
        if (birthDate == null || birthDate.length < 8) {
          await ctx.bot.sendMessage(ctx.chatId!, 'Please provide a valid birth date.');
          return AddConversationStep.birthDate.index;
        }
        state['birthDate'] = birthDate;
        await ctx.bot.sendMessage(ctx.chatId!, 'Please provide your exam date:');
        return AddConversationStep.examDate.index;
      },
      AddConversationStep.examDate.index: (ctx, state) async {
        final number = state['number'] as String?;
        final birthDate = state['birthDate'] as String?;
        final examDate = ctx.text;

        await ctx.bot.sendMessage(
            ctx.chatId!, 'We are saved your data: number: $number, birthDate: $birthDate, examDate: $examDate');
        return ConversationHandler.finish;
      },
    }));

  return (int updateId, Map<String, Object?> update) {
    messageHandler(update);
  };
}

enum AddConversationStep {
  number,
  birthDate,
  examDate,
}
