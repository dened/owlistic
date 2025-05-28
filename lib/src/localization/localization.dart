import 'dart:async';

import 'package:intl/intl.dart';
import 'package:owlistic/owlistic.dart';
import 'package:owlistic/src/localization/l10n/messages_all.dart';



class Localization {
  Localization({required Database db}) : _db = db;

  final Database _db;

  Future<void> initializeAllMessages() async {
    for (final locale in supportedLocales) {
      await initializeMessages(locale);
    }
  }
  

  Future<T> withChatId<T>(int chatId, T Function() callback) async {
    final languageCode = await _db.getUserLanguageCode(chatId);

    return Intl.withLocale<T>(languageCode, callback) as T;
  }

  // --- General ---
  String get helpText => Intl.message(
        'Available commands:\n'
        '/help - Show this help message\n'
        '/start - Start the bot\n'
        '/check_now - Check result now\n'
        '/language - Set language\n'
        '/add - Add new data\n'
        '/delete - Delete data\n'
        '/show - Show all data\n',
        name: 'helpText',
        desc: 'The help message listing all commands.',
      );

  String get startBotGreeting => Intl.message(
        'Bot started. Welcome!\nUse /help to see available commands.',
        name: 'startBotGreeting',
        desc: 'Greeting message when the bot starts.',
      );

  String get checkNowStart => Intl.message(
        'Starting results check...',
        name: 'checkNowStart',
        desc: 'Message shown when result check is initiated.',
      );

  // --- Language Selection ---
  String get languageSelectPompt => Intl.message(
        'Select your preferred language (English, German, Russian, Ukrainian):',
        name: 'languageSelectPompt',
        desc: 'Prompt to select a language.',
      );

  String get langEnglish => Intl.message('English', name: 'langEnglish');
  String get langGerman => Intl.message('German', name: 'langGerman');
  String get langRussian => Intl.message('Russian', name: 'langRussian');
  String get langUkrainian => Intl.message('Ukrainian', name: 'langUkrainian');

  /// Returns the localized display name for a given language code.
  /// This method should be called within a locale context (e.g., via `withChatId`),
  /// so that `langEnglish`, `langGerman`, etc., are resolved correctly.
  String getDisplayNameForLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        return langEnglish;
      case 'de':
        return langGerman;
      case 'ru':
        return langRussian;
      case 'uk':
        return langUkrainian;
      default:
        // Fallback to the language code itself if no localized name is found.
        return languageCode;
    }
  }

  String languageSelectedCallback(String displayName) => Intl.message(
      'Language selected: $displayName',
      name: 'languageSelectedCallback',
      args: [displayName],
      desc: 'Confirmation message after language selection.',
      examples: const {'displayName': 'English'},
    );

  List<List<InlineKeyboardButton>> get languageSelectionKeyboard => [
        [
          InlineKeyboardButton(text: langEnglish, callbackData: 'en'),
          InlineKeyboardButton(text: langGerman, callbackData: 'de'),
        ],
        [
          InlineKeyboardButton(text: langRussian, callbackData: 'ru'),
          InlineKeyboardButton(text: langUkrainian, callbackData: 'uk'),
        ],
      ];

  // --- Add Command ---
  String get addPromptAttendeeNumber => Intl.message(
        'Enter your 7-digit exam attendee number (e.g., 0312345).',
        name: 'addPromptAttendeeNumber',
      );

  String get addPromptBirthDate => Intl.message(
        'Enter your birth date in DD.MM.YYYY format.',
        name: 'addPromptBirthDate',
      );

  String get addInvalidAttendeeNumber => Intl.message(
        'Invalid attendee number. It must be 7 digits (e.g., 0312345).\n'
        'If you are sure the number is correct, please enter it again.\n'
        'If you do not know your number, enter 000 to skip this step.',
        name: 'addInvalidAttendeeNumber',
      );

  String get addInvalidBirthDate => Intl.message(
        'Invalid birth date format!\nPlease enter the date in DD.MM.YYYY format.',
        name: 'addInvalidBirthDate',
      );

  String get addPromptExamDate => Intl.message(
        'Enter your exam date in DD.MM.YYYY format.',
        name: 'addPromptExamDate',
      );

  String addInvalidExamDate(String dateFormatPattern) => Intl.message(
        'Invalid exam date format!\nPlease enter the date in $dateFormatPattern format.',
        name: 'addInvalidExamDate',
        args: [dateFormatPattern],
        examples: const {'dateFormatPattern': 'DD.MM.YYYY'},
      );

  String get addSuccess => Intl.message(
        'Information added successfully!\n'
        'You can view the list of added entries with /show or add a new one with /add.\n'
        'To delete data, use the /delete command.',
        name: 'addSuccess',
      );
  // --- Show Command ---
  String get showNoData => Intl.message(
        'No data added yet. Use /add to add new entries.',
        name: 'showNoData',
      );

  String get showListHeader => Intl.message(
        'List of added entries:\n',
        name: 'showListHeader',
      );

  String get showExamDatePrefix => Intl.message(
        'Exam:',
        name: 'showExamDatePrefix',
      );

  // --- Delete Command ---
  String get deleteNoData => Intl.message(
        'No data added yet. Nothing to delete.',
        name: 'deleteNoData',
      );

  String get deleteButtonDeleteAll => Intl.message(
        'Delete All',
        name: 'deleteButtonDeleteAll',
      );
  String get deleteSelectPrompt => Intl.message(
        'Select an entry to delete, or click "Delete All" to remove all entries.',
        name: 'deleteSelectPrompt',
      );
  String get deleteAllSuccessCallback => Intl.message(
        'All entries successfully deleted.',
        name: 'deleteAllSuccessCallback',
      );
  String get deleteOneSuccessCallback => Intl.message(
        'Entry successfully deleted.',
        name: 'deleteOneSuccessCallback',
      );

  // --- Lookup Service Notifications ---
  String certNotFoundMessage(int daysCount, String attendeeNumber) => Intl.message(
        'No results found for the last $daysCount days for user $attendeeNumber',
        name: 'certNotFoundMessage',
        args: [daysCount, attendeeNumber],
        desc: 'Message when no certificate is found for a user after a certain number of days.',
        examples: const {'daysCount': 7, 'attendeeNumber': '1234567'},
      );

  String get certFoundTitle => Intl.message(
        'Certificate found!',
        name: 'certFoundTitle',
        desc: 'Title indicating a certificate was found.',
      );

  String get certFoundFullNameLabel => Intl.message(
        'Full Name:',
        name: 'certFoundFullNameLabel',
        desc: 'Label for the full name of the certificate holder.',
      );

  String get certFoundLinkText => Intl.message(
        'Certificate Link',
        name: 'certFoundLinkText',
        desc: 'Text for the hyperlink to the certificate.',
      );
}
