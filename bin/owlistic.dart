import 'dart:async';
import 'dart:io' as io;

import 'package:l/l.dart';
import 'package:owlistic/owlistic.dart';

/// Runs the Telegram bot.
///
Future<void> main(List<String> args) async {
  // Handle the shutdown event
  l.i('Press [Ctrl+C] to exit');
  shutdownHandler(() async {
    l.i('Shutting down');
    io.exit(0);
  }).ignore();

  await runApplication(args, (dependencies) async {
    await dependencies.db.customStatement('VACUUM;');

    Timer.periodic(const Duration(days: 5), (_) async {
      await dependencies.db.customStatement('VACUUM;'); // Compact the database every five days
      l.i('Database "${dependencies.arguments.database}" is compacted');
    });
// Initialize the Telegram bot and register the main update handler.
    dependencies.bot
      ..addHandler(handler(dp: dependencies))
      ..start();
  });
}

/// Handles the command line arguments.
Future<T?> shutdownHandler<T extends Object?>([final Future<T> Function()? onShutdown]) {
  //StreamSubscription<String>? userKeySub;
  StreamSubscription<io.ProcessSignal>? sigIntSub;
  StreamSubscription<io.ProcessSignal>? sigTermSub;
  final shutdownCompleter = Completer<T>.sync();
  var catchShutdownEvent = false;
  {
    Future<void> signalHandler(io.ProcessSignal signal) async {
      if (catchShutdownEvent) return;
      catchShutdownEvent = true;
      l.i('Received signal "$signal" - closing');
      T? result;
      try {
        //userKeySub?.cancel();
        sigIntSub?.cancel().ignore();
        sigTermSub?.cancel().ignore();
        result = await onShutdown?.call().catchError((Object error, StackTrace stackTrace) {
          l.e('Error during shutdown | $error', stackTrace);
          io.exit(2);
        });
      } finally {
        if (!shutdownCompleter.isCompleted) shutdownCompleter.complete(result);
      }
    }

    sigIntSub = io.ProcessSignal.sigint.watch().listen(signalHandler, cancelOnError: false);

    // SIGTERM is not supported on Windows.
    // Attempting to register a SIGTERM handler raises an exception.
    if (!io.Platform.isWindows)
      sigTermSub = io.ProcessSignal.sigterm.watch().listen(signalHandler, cancelOnError: false);
  }
  return shutdownCompleter.future;
}

/// Creates the main update handler for the Telegram bot.
/// This function sets up the command processor and all command/conversation handlers.
/// It also ensures that each update is processed within the correct localization context.
///
/// Returns a function that will be called by the Telegram bot library for each incoming update.
void Function(int updateId, Map<String, Object?> update) handler({
  required Dependencies dp,
}) {
  final bot = dp.bot;
  final db = dp.db;
  final ln = dp.ln;

  final commandProcessor = CommandProcessor(
    bot: bot,
    db: db,
    ln: ln,
  );
  // Handler for the /help command.
  // ignore: avoid_single_cascade_in_expression_statements
  commandProcessor
    ..addHandler(CommandHandler('/help', (ln) => ln.helpCommandDescription, (ctx) async {
      final helpMessage = StringBuffer()..writeln(ctx.ln.helpListHeader);
      for (final handler in commandProcessor.handlers) {
        if (handler is CommandHandlerMixin) {
          helpMessage.writeln('${handler.command} - ${handler.description(ctx.ln)}');
        }
      }
      await ctx.bot.sendMessage(ctx.chatId, helpMessage.toString());
    }))
    // Handler for the /start command.
    ..addHandler(
        ConversationHandler.emptyState<OneStep>('/start', (ln) => ln.startCommandDescription, (ctx, state) async {
      // Send the language selection prompt with an inline keyboard.
      await ctx.bot
          .sendInlineKeyboard(ctx.chatId, ln.startBotWith, ln.privacyPolicyKeyboard(dp.arguments.privacyPolicyUrl));
      return const NextStep(OneStep.go);
    }, steps: {
      // Process the user's language selection from the callback query.
      OneStep.go: (ctx, state) async {
        final callbackData = ctx.callbackData;

        if (callbackData == 'consent_agree') {
          // Initialize the Telegram bot and register the main update handler.
          ctx.db.saveUser(
            id: ctx.chatId,
            languageCode: ctx.languageCode,
          );
          ctx.db.saveUserConsent(
            userId: ctx.chatId,
            consentText: ln.startBotWith,
          );
          await ctx.bot.answerCallbackQuery(ctx.callbackId, '');
          await ctx.bot.editMessageText(ctx.chatId, ctx.messageId, ln.consentGivenMessage);
        } else if (callbackData == 'consent_decline') {
          await ctx.bot.answerCallbackQuery(ctx.callbackId, '');
          await ctx.bot.editMessageText(ctx.chatId, ctx.messageId, ln.consentDeclinedMessage);
        }

        return const Done();
      },
    }))
    // Handler for the /check_now command.
    ..addHandler(
      CommandHandler('/check_now', (ln) => ln.checkNowCommandDescription, (ctx) async {
        final messageId = await ctx.bot.sendMessage(ctx.chatId, ln.checkNowStart);
        // Attempt to parse 'checkDays' argument, if provided.
        final checkDays = int.tryParse(ctx.getArgs()?['/check_now'] ?? '');
        await ExternalLookupService.run(ctx.chatId, checkDays: checkDays);
        // Delete the "Starting results check..." message after a delay.
        Future.delayed(const Duration(seconds: 5), () => ctx.bot.deleteMessage(ctx.chatId, messageId));
      }, guards: [
        ConsentGuard(),
      ]),
    )
    // Conversation handler for the /language command.
    ..addHandler(
        ConversationHandler.emptyState<OneStep>('/language', (ln) => ln.languageCommandDescription, (ctx, state) async {
      // Send the language selection prompt with an inline keyboard.
      await ctx.bot.sendInlineKeyboard(ctx.chatId, ln.languageSelectPompt, ln.languageSelectionKeyboard);
      return const NextStep(OneStep.go);
    }, steps: {
      // Step 0: Process the user's language selection from the callback query.
      OneStep.go: (ctx, state) async {
        final languageCode = ctx.callbackData;
        if (languageCode == null || languageCode.isEmpty) {
          l.w('Callback data for language selection is empty or null.');
          return const Done();
        }

        ctx.db.saveUserLanguageCode(ctx.chatId, languageCode);

        /// Since the user's language code has just been saved,
        /// we use `ln.withChatId` to ensure the callback message is localized correctly in the user's selected language.
        final languageSelectedCallback = await ln.withChatId(ctx.chatId, () {
          final displayName = ln.getDisplayNameForLanguageCode(languageCode);
          return ln.languageSelectedCallback(displayName);
        });
        await ctx.bot.answerCallbackQuery(ctx.callbackId, languageSelectedCallback);
        await ctx.bot.deleteMessage(ctx.chatId, ctx.messageId);
        return const Done();
      },
    }, guards: [
      ConsentGuard(),
    ]))
    // Conversation handler for the /add command (to add exam search info).
    ..addHandler(ConversationHandler<AddConversationStep, AddState>('/add', (ln) => ln.addCommandDescription,
        (ctx, state) async {
      await ctx.bot.sendMessage(ctx.chatId, ln.addPromptAttendeeNumber);
      return const NextStep(AddConversationStep.number);
    },
        stateBuilder: AddState.new,
        steps: <AddConversationStep, ConversationStepCallback<AddConversationStep, AddState>>{
          AddConversationStep.number: (ctx, state) async {
            // Validate the entered attendee number.
            final number = ctx.text ?? '';
            if ([
              RegExp(r'^\d{7}$').hasMatch(number),
              number == '000',
              number == state.number,
            ].any((element) => element)) {
              state.number = number;
              // If valid, prompt for the birth date.
              await ctx.bot.sendMessage(ctx.chatId, ln.addPromptBirthDate);
              return const NextStep(AddConversationStep.birthDate);
            }
            // If invalid, send an error message and ask again.
            await ctx.bot.sendMessage(ctx.chatId, ln.addInvalidAttendeeNumber);
            state.number = number;
            return const NextStep(AddConversationStep.number);
          },
          AddConversationStep.birthDate: (ctx, state) async {
            final birthDate = ctx.text ?? '';
            // Validate the entered birth date format.
            if (dateFormat.tryParse(birthDate) == null) {
              await ctx.bot.sendMessage(ctx.chatId, ln.addInvalidBirthDate);
              return const NextStep(AddConversationStep.birthDate);
            }
            state.birthDate = birthDate;
            await ctx.bot.sendMessage(ctx.chatId, ln.addPromptExamDate);
            return const NextStep(AddConversationStep.examDate);
          },
          AddConversationStep.examDate: (ctx, state) async {
            final number = state.number;
            final birthDate = state.birthDate;
            final examDate = ctx.text ?? '';
            // Validate the entered exam date format.
            if (dateFormat.tryParse(examDate) == null) {
              await ctx.bot.sendMessage(ctx.chatId, ln.addInvalidExamDate(dateFormat.pattern!));
              return const NextStep(AddConversationStep.examDate);
            }

            // Save the collected information to the database.
            ctx.db.saveSearchInfo(
              chatId: ctx.chatId,
              attendeeNumber: number!,
              birthDate: dateFormat.parse(birthDate!),
              examDate: dateFormat.parse(examDate),
            );

            // Send a success message.
            await ctx.bot.sendMessage(ctx.chatId, ln.addSuccess);
            return const Done();
          },
        },
        guards: [
          ConsentGuard(),
        ]))
    // Handler for the /show command.
    ..addHandler(CommandHandler('/show', (ln) => ln.showCommandDescription, (ctx) async {
      final searchInfoList = await ctx.db.getSearchInfo(ctx.chatId);
      if (searchInfoList.isEmpty) {
        // If no data, send a corresponding message.
        await ctx.bot.sendMessage(ctx.chatId, ln.showNoData);
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
        ctx.chatId,
        message.toString(),
      );
    }, guards: [
      ConsentGuard(),
    ]))
    // Conversation handler for the /delete command.
    ..addHandler(
        ConversationHandler.emptyState<OneStep>('/delete', (ln) => ln.deleteCommandDescription, (ctx, state) async {
      final searchInfoList = await ctx.db.getSearchInfo(ctx.chatId);
      if (searchInfoList.isEmpty) {
        // If no data, send a message and finish.
        await ctx.bot.sendMessage(ctx.chatId, ln.deleteNoData);
        return const Done();
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

      await ctx.bot.sendInlineKeyboard(ctx.chatId, ln.deleteSelectPrompt, inlineKeyboard);

      return const NextStep(OneStep.go);
    }, steps: {
      // Step for processing the deletion choice.
      OneStep.go: (ctx, state) async {
        final value = ctx.callbackData ?? '';

        if (value == 'all') {
          // If "Delete All" is selected.
          await ctx.db.deleteAllSearchInfo(ctx.chatId);
          await ctx.bot.answerCallbackQuery(ctx.callbackId, ln.deleteAllSuccessCallback);
          await ctx.bot.deleteMessage(ctx.chatId, ctx.messageId);
          return const Done();
        }
        // If a specific entry is selected for deletion.
        final index = int.parse(value);
        await ctx.db.deleteSearchInfo(index);
        await ctx.bot.answerCallbackQuery(ctx.callbackId, ln.deleteOneSuccessCallback);
        await ctx.bot.deleteMessage(ctx.chatId, ctx.messageId);
        return const Done();
      },
    }, guards: [
      ConsentGuard(),
    ]))
    ..addHandler(ConversationHandler.emptyState<OneStep>('/delete_me', (ln) => ln.deleteMeCommandDescription,
        (ctx, state) async {
      final keyboard = <List<InlineKeyboardButton>>[
        [InlineKeyboardButton(text: ln.deleteMeButtonYes, callbackData: 'delete_me_confirm_yes')],
        [InlineKeyboardButton(text: ln.deleteMeButtonNo, callbackData: 'delete_me_confirm_no')]
      ];

      await ctx.bot.sendInlineKeyboard(ctx.chatId, ln.deleteMeConfirmationMessage, keyboard);

      return const NextStep(OneStep.go);
    }, steps: {
      // Step for processing the deletion choice.
      OneStep.go: (ctx, state) async {
        final value = ctx.callbackData ?? '';
        await ctx.bot.answerCallbackQuery(ctx.callbackId, '');
        if (value == 'delete_me_confirm_yes') {
          ctx.db.removeUserById(ctx.chatId);
          await ctx.bot.editMessageText(ctx.chatId, ctx.messageId, ln.deleteMeSuccessMessage);
          return const Done();
        }

        await ctx.bot.editMessageText(ctx.chatId, ctx.messageId, ln.deleteMeCancelledMessage);
        return const Done();
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

    // Extract locale code from the update using pattern matching.
    // Since we cannot save the user's locale information before the user accepts the privacy policy,
    // we must take it from the information in Telegram and pass it as fallbackLocale
    final localeCode = switch (update) {
      {'message': {'chat': {'language_code': final String languageCode}}} => languageCode,
      {'message': {'from': {'language_code': final String languageCode}}} => languageCode,
      _ => null,
    };

    if (chatId != null) {
      // Process the incoming update (e.g., a command or callback query)
      // within the locale context of the user associated with the chatId.
      // This ensures that any localized strings are retrieved in the user's language.
      ln.withChatId(chatId, () => commandProcessor(update), fallbackLocale: localeCode);
    }
  };
}

// Defines the steps for the '/add' command conversation.
enum AddConversationStep {
  number,
  birthDate,
  examDate,
}

/// State storage for the /add command conversation.
class AddState {
  String? number;
  String? birthDate;
}
