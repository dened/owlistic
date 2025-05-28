import 'dart:async';

import 'package:l/l.dart';
import 'package:owlistic/owlistic.dart';
import 'package:owlistic/src/core/app_runner.dart';
import 'package:owlistic/src/date_utils.dart';
import 'package:owlistic/src/localization/localization.dart';
import 'package:owlistic/src/telegram_bot/command_handler.dart';
import 'package:owlistic/src/telegram_bot/command_proccessor.dart';
import 'package:owlistic/src/telegram_bot/conversation_handler.dart';
import 'package:owlistic/src/telegram_bot/external_lookup_service.dart';

/// Runs the Telegram bot.
///
Future<void> main(List<String> args) async {
  await runApplication(args, (dependencies) async {
    // Initialize and start the Telegram bot.
    // The main handler function is registered here.
    dependencies.bot
      ..addHandler(handler(bot: dependencies.bot, db: dependencies.db, ln: dependencies.ln))
      ..start();
  });
}

/// Creates the main update handler for the Telegram bot.
/// This function sets up the command processor and all command/conversation handlers.
/// It also ensures that each update is processed within the correct localization context.
///
/// Returns a function that will be called by the Telegram bot library for each incoming update.
void Function(int updateId, Map<String, Object?> update) handler({
  required TelegramBot bot,
  required Database db,
  required Localization ln,
}) {
  final commandProcessor = CommandProcessor(
    bot: bot,
    db: db,
  )
    // Handler for the /help command.
    ..addHandler(
      CommandHandler('/help', (ctx) async {
        await ctx.bot.sendMessage(ctx.chatId!, ln.helpText);
      }),
    )
    // Handler for the /start command.
    ..addHandler(
      CommandHandler('/start', (ctx) async {
        ctx.db.saveUser(
          id: ctx.chatId!,
          // Extract user information from the context.
          firstName: ctx.chat?['first_name'] as String?,
          lastName: ctx.chat?['last_name'] as String?,
          username: ctx.chat?['username'] as String?,
          languageCode: ctx.chat?['language_code'] as String?,
        );

        await ctx.bot.sendMessage(ctx.chatId!, ln.startBotGreeting);
      }),
    )
    // Handler for the /check_now command.
    ..addHandler(
      CommandHandler('/check_now', (ctx) async {
        final messageId = await ctx.bot.sendMessage(ctx.chatId!, ln.checkNowStart);
        // Attempt to parse 'checkDays' argument, if provided.
        final checkDays = int.tryParse(ctx.getArgs()?['/check_now'] ?? '');
        await ExternalLookupService.run(ctx.chatId!, checkDays: checkDays);
        // Delete the "Starting results check..." message after a delay.
        Future.delayed(const Duration(seconds: 5), () => ctx.bot.deleteMessage(ctx.chatId!, messageId));
      }),
    )
    // Conversation handler for the /language command.
    ..addHandler(ConversationHandler('/language', (ctx, state) async {
      // Send the language selection prompt with an inline keyboard.
      await ctx.bot.sendInlineKeyboard(ctx.chatId!, ln.languageSelectPompt, ln.languageSelectionKeyboard);
      return 0;
    }, steps: {
      // Step 0: Process the user's language selection from the callback query.
      0: (ctx, state) async {
        final languageCode = ctx.callbackData;
        if (languageCode == null || languageCode.isEmpty) {
          l.w('Callback data for language selection is empty or null.');
          return 0;
        }

        ctx.db.saveUserLanguageCode(ctx.chatId!, languageCode);

        /// Since the user's language code has just been saved,
        /// we use `ln.withChatId` to ensure the callback message is localized correctly in the user's selected language.
        final languageSelectedCallback = await ln.withChatId(ctx.chatId!, () {
          final displayName = ln.getDisplayNameForLanguageCode(languageCode);
          return ln.languageSelectedCallback(displayName);
        });
        await ctx.bot.answerCallbackQuery(ctx.callbackId, languageSelectedCallback);
        await ctx.bot.deleteMessage(ctx.chatId!, ctx.messageId!);
        return ConversationHandler.finish;
      },
    }))
    // Conversation handler for the /add command (to add exam search info).
    ..addHandler(ConversationHandler('/add', (ctx, state) async {
      // Prompt for the attendee number.
      final addPromptAttendeeNumber = await ln.withChatId(ctx.chatId!, () => ln.addPromptAttendeeNumber);
      await ctx.bot.sendMessage(ctx.chatId!, addPromptAttendeeNumber);
      return AddConversationStep.number.index;
    }, steps: <int, ConversationStep>{
      AddConversationStep.number.index: (ctx, state) async {
        // Validate the entered attendee number.
        final number = ctx.text ?? '';
        if ([
          RegExp(r'^\d{7}$').hasMatch(number),
          number == '000',
          number == state['number'],
        ].any((element) => element)) {
          state['number'] = number;
          final addPromptBirthDate = await ln.withChatId(ctx.chatId!, () => ln.addPromptBirthDate);
          // If valid, prompt for the birth date.
          await ctx.bot.sendMessage(ctx.chatId!, addPromptBirthDate);
          return AddConversationStep.birthDate.index;
        }
        final addInvalidAttendeeNumber = await ln.withChatId(ctx.chatId!, () => ln.addInvalidAttendeeNumber);
        // If invalid, send an error message and ask again.
        await ctx.bot.sendMessage(ctx.chatId!, addInvalidAttendeeNumber);
        state['number'] = number;
        return AddConversationStep.number.index;
      },
      AddConversationStep.birthDate.index: (ctx, state) async {
        final addInvalidBirthDate = await ln.withChatId(ctx.chatId!, () => ln.addInvalidBirthDate);
        final birthDate = ctx.text ?? '';
        // Validate the entered birth date format.
        if (dateFormat.tryParse(birthDate) == null) {
          await ctx.bot.sendMessage(ctx.chatId!, addInvalidBirthDate);
          return AddConversationStep.birthDate.index;
        }
        final addPromptExamDate = await ln.withChatId(ctx.chatId!, () => ln.addPromptExamDate);
        // If valid, prompt for the exam date.
        state['birthDate'] = birthDate;
        await ctx.bot.sendMessage(ctx.chatId!, addPromptExamDate);
        return AddConversationStep.examDate.index;
      },
      AddConversationStep.examDate.index: (ctx, state) async {
        final number = state['number'] as String?;
        final birthDate = state['birthDate'] as String?;
        final examDate = ctx.text ?? '';
        // Validate the entered exam date format.
        if (dateFormat.tryParse(examDate) == null) {
          final addInvalidExamDate = await ln.withChatId(ctx.chatId!, () => ln.addInvalidExamDate(dateFormat.pattern!));
          await ctx.bot.sendMessage(ctx.chatId!, addInvalidExamDate);
          return AddConversationStep.examDate.index;
        }

        // Save the collected information to the database.
        await ctx.db.into(ctx.db.searchInfo).insertOnConflictUpdate(
              SearchInfoCompanion.insert(
                userId: ctx.chatId!,
                attendeeNumber: number!,
                birthDate: dateFormat.parse(birthDate!).secondsSinceEpoch,
                examDate: dateFormat.parse(examDate).secondsSinceEpoch,
              ),
            );
        final addSuccess = await ln.withChatId(ctx.chatId!, () => ln.addSuccess);
        // Send a success message.
        await ctx.bot.sendMessage(ctx.chatId!, addSuccess);
        return ConversationHandler.finish;
      },
    }))
    // Handler for the /show command.
    ..addHandler(CommandHandler('/show', (ctx) async {
      final searchInfoList = await ctx.db.getSearchInfo(ctx.chatId!);
      if (searchInfoList.isEmpty) {
        // If no data, send a corresponding message.
        await ctx.bot.sendMessage(ctx.chatId!, ln.showNoData);
        return;
      }
      // Format and send the list of search entries.
      final message = StringBuffer(ln.showListHeader);
      for (final searchInfo in searchInfoList) {
        message.writeln(
          '${searchInfo.nummer} - ${dateFormat.format(searchInfo.birthDate)}. '
          '${ln.showExamDatePrefix} ${dateFormat.format(searchInfo.examDate)}',
        );
      }
      await ctx.bot.sendMessage(
        ctx.chatId!,
        message.toString(),
      );
    }))
    // Conversation handler for the /delete command.
    ..addHandler(ConversationHandler('/delete', (ctx, state) async {
      final searchInfoList = await ctx.db.getSearchInfo(ctx.chatId!);
      if (searchInfoList.isEmpty) {
        // If no data, send a message and finish.
        await ctx.bot.sendMessage(ctx.chatId!, ln.deleteNoData);
        return ConversationHandler.finish;
      }

      const rowLength = 5;
      // Create an inline keyboard with buttons for each entry and a "Delete All" button.
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
          text: ln.deleteButtonDeleteAll,
          callbackData: 'all',
        )
      ]);

      await ctx.bot.sendInlineKeyboard(ctx.chatId!, ln.deleteSelectPrompt, inlineKeyboard);

      return DeleteStep.select.index;
    }, steps: {
      // Step for processing the deletion choice.
      DeleteStep.select.index: (ctx, state) async {
        final value = ctx.callbackData ?? '';

        if (value == 'all') {
          // If "Delete All" is selected.
          await ctx.db.deleteAllSearchInfo(ctx.chatId!);
          await ctx.bot.answerCallbackQuery(ctx.callbackId, ln.deleteAllSuccessCallback);
          await ctx.bot.deleteMessage(ctx.chatId!, ctx.messageId!);
          return ConversationHandler.finish;
        }
        // If a specific entry is selected for deletion.
        final index = int.parse(value);
        await ctx.db.deleteSearchInfo(index);
        await ctx.bot.answerCallbackQuery(ctx.callbackId, ln.deleteOneSuccessCallback);
        await ctx.bot.deleteMessage(ctx.chatId!, ctx.messageId!);
        return ConversationHandler.finish;
      },
    }));

  // This is the function that will be called for each incoming update.
  return (int updateId, Map<String, Object?> update) {
    // Extract chatId from the update using pattern matching.
    // This handles both regular messages and callback queries.
    final chatId = switch (update) {
      {'message': {'chat': {'id': final int id}}} => id,
      {'callback_query': {'message': {'chat': {'id': final int id}}}} => id,
      _ => null,
    };

    if (chatId != null) {
      // Process the incoming update (e.g., a command or callback query)
      // within the locale context of the user associated with the chatId.
      // This ensures that any localized strings are retrieved in the user's language.
      ln.withChatId(chatId, () => commandProcessor(update));
    }
  };
}

// Defines the steps for the '/add' command conversation.
enum AddConversationStep {
  number,
  birthDate,
  examDate,
}

// Defines the steps for the '/delete' command conversation.
enum DeleteStep {
  select,
}
