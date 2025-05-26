import 'dart:async';
import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:l/l.dart';
import 'package:telc_result_checker/owlistic.dart';
import 'package:telc_result_checker/src/database.dart';
import 'package:telc_result_checker/src/date_utils.dart';
import 'package:telc_result_checker/src/telegram_bot/command_handler.dart';
import 'package:telc_result_checker/src/telegram_bot/command_proccessor.dart';
import 'package:telc_result_checker/src/telegram_bot/conversation_handler.dart';
import 'package:telc_result_checker/src/telegram_bot/telegram_bot.dart';

Future<void> main(List<String> args) async {
  final arguments = Arguments.parse(args);

  l.capture(
    () => runZonedGuarded<void>(() async {
      final db = Database.lazy();
      await db.refresh();
      l.i('Database is ready');
      final lastUpdateId = db.getKey<int>(updateIdKey);
      final bot = TelegramBot(
        token: arguments.token,
        offset: lastUpdateId,
      );

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
          '/add - Add new data\n'
          '/delete - Delete data\n'
          '/show - Show all data\n',
        );
      }),
    )
    ..addHandler(
      CommandHandler('/start', (ctx) async {
        await ctx.db.saveUser(
          id: ctx.chatId!,
          firstName: ctx.chat?['first_name'] as String?,
          lastName: ctx.chat?['last_name'] as String?,
          username: ctx.chat?['username'] as String?,
          languageCode: ctx.chat?['language_code'] as String? ?? 'ru',
        );
        await ctx.bot.sendMessage(
          ctx.chatId!,
          'Start the bot\n',
        );
      }),
    )
    ..addHandler(ConversationHandler('/language', (ctx, state) async {
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

        await ctx.bot.answerCallbackQuery(ctx.callbackId, 'Выбран язык: $language');
        await ctx.bot.deleteMessage(ctx.chatId!, ctx.messageId!);
        await (ctx.db.update(ctx.db.user)..where((tbl) => tbl.id.equals(ctx.chatId!))).write(UserCompanion(
          languageCode: Value<String?>(language),
        ));
        return ConversationHandler.finish;
      },
    }))
    ..addHandler(ConversationHandler('/add', (ctx, state) async {
      // Define the entry logic here
      await ctx.bot.sendMessage(
        ctx.chatId!,
        'Введите номер участника экзамена. \nНомер должен состоять из 7 цифр(например: 0312345).',
      );
      return AddConversationStep.number.index;
    }, steps: <int, ConversationStep>{
      AddConversationStep.number.index: (ctx, state) async {
        final number = ctx.text ?? '';
        if ([
          RegExp(r'^\d{7}$').hasMatch(number),
          number == '000',
          number == state['number'],
        ].any((element) => element)) {
          state['number'] = number;
          await ctx.bot.sendMessage(ctx.chatId!, 'Введите дату рождения в формате ДД.ММ.ГГГГ');
          return AddConversationStep.birthDate.index;
        }

        await ctx.bot.sendMessage(
            ctx.chatId!,
            'Номер участника неверный. Номер должен состоять из 7 цифр(например: 0312345).\n'
            'Если вы уверены, что этот номер правильный, то введите его еще раз.\n'
            'Если вы не знаете свой номер, то введите 000 для пропуска этого шага.');
        state['number'] = number;
        return AddConversationStep.number.index;
      },
      AddConversationStep.birthDate.index: (ctx, state) async {
        final birthDate = ctx.text ?? '';
        if (dateFormat.tryParse(birthDate) == null) {
          await ctx.bot.sendMessage(
              ctx.chatId!, 'Дата рождения введена неверно!\nПожалуйста, введите дату в формате ДД.ММ.ГГГГ');
          return AddConversationStep.birthDate.index;
        }
        state['birthDate'] = birthDate;
        await ctx.bot.sendMessage(ctx.chatId!, 'Введите дату экзамена в формате ДД.ММ.ГГГГ');
        return AddConversationStep.examDate.index;
      },
      AddConversationStep.examDate.index: (ctx, state) async {
        final number = state['number'] as String?;
        final birthDate = state['birthDate'] as String?;
        final examDate = ctx.text ?? '';

        if (dateFormat.tryParse(examDate) == null) {
          await ctx.bot.sendMessage(
              ctx.chatId!,
              'Дата экзамена введена неверно!\n'
              'Пожалуйста, введите дату в формате ${dateFormat.pattern}');
          return AddConversationStep.birthDate.index;
        }

        await ctx.db.into(ctx.db.searchInfo).insertOnConflictUpdate(
              SearchInfoCompanion.insert(
                userId: ctx.chatId!,
                attendeeNumber: number!,
                birthDate: dateFormat.parse(birthDate!).secondsSinceEpoch,
                examDate: dateFormat.parse(examDate).secondsSinceEpoch,
              ),
            );

        await ctx.bot.sendMessage(
            ctx.chatId!,
            'Информация успешно добавлена!\n'
            'Вы можете посмотреть список добавленных номеров '
            'с помощью команды /show или добавить новый номер с помощью команды /add.\n'
            'Для удаления данных используйте команду /delete.');

        return ConversationHandler.finish;
      },
    }))
    ..addHandler(CommandHandler('/show', (ctx) async {
      final searchInfoList = await ctx.db.getSearchInfo(ctx.chatId!);
      if (searchInfoList.isEmpty) {
        await ctx.bot.sendMessage(ctx.chatId!, 'Нет добавленных номеров. Используйте /add для добавления.');
        return;
      }
      final message = StringBuffer('Список добавленных номеров:\n');
      for (final searchInfo in searchInfoList) {
        message.writeln(
          '${searchInfo.nummer} - ${dateFormat.format(searchInfo.birthDate)}. '
          'Экзамен: ${dateFormat.format(searchInfo.examDate)}',
        );
      }
      await ctx.bot.sendMessage(
        ctx.chatId!,
        message.toString(),
      );
    }))
    ..addHandler(ConversationHandler('/delete', (ctx, state) async {
      final searchInfoList = await ctx.db.getSearchInfo(ctx.chatId!);
      if (searchInfoList.isEmpty) {
        await ctx.bot.sendMessage(ctx.chatId!, 'Нет добавленных номеров. Используйте /add для добавления.');
        return ConversationHandler.finish;
      }

      // Преобразовать список searchInfoList в массив списков по 5 элементов
      const rowLength = 5;
      final inlineKeyboard = <List<InlineKeyboardButton>>[];
      for (var i = 0; i < searchInfoList.length; i += rowLength) {
        final row = searchInfoList
            .skip(i)
            .take(rowLength)
            .map((searchInfo) => InlineKeyboardButton(
                  text: '[${searchInfo.nummer}]',
                  callbackData: '${searchInfo.id}',
                ))
            .toList();
        inlineKeyboard.add(row);
      }

      inlineKeyboard.add([
        InlineKeyboardButton(
          text: 'Удалить все',
          callbackData: 'all',
        )
      ]);

      await ctx.bot.sendInlineKeyboard(ctx.chatId!,
          'Выберите номер для удаления или нажмите "Удалить все" для удаления всех записей.', inlineKeyboard);

      return DeleteStep.select.index;
    }, steps: {
      DeleteStep.select.index: (ctx, state) async {
        final value = ctx.callbackData ?? '';

        if (value == 'all') {
          await ctx.db.deleteAllSearchInfo(ctx.chatId!);
          await ctx.bot.answerCallbackQuery(ctx.callbackId, 'Все записи успешно удалены.');
          await ctx.bot.deleteMessage(ctx.chatId!, ctx.messageId!);
          return ConversationHandler.finish;
        }

        final index = int.parse(value);

        await ctx.db.deleteSearchInfo(index);

        await ctx.bot.answerCallbackQuery(ctx.callbackId, 'Запись успешно удалена.');
        await ctx.bot.deleteMessage(ctx.chatId!, ctx.messageId!);
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

enum DeleteStep {
  select,
}
