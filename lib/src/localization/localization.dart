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

  Future<T> withChatId<T>(int chatId, T Function() callback, {String? fallbackLocale}) async {
    final languageCode = await _db.getUserLanguageCode(chatId) ?? fallbackLocale ?? defaultLocale;

    return Intl.withLocale<T>(languageCode, callback) as T;
  }

  // --- General ---
  String get helpListHeader => Intl.message(
        'Available commands:',
        name: 'helpListHeader',
        desc: 'Header for the list of available commands in the help message.',
      );

  String get helpCommandDescription => Intl.message(
        'Show this help message',
        name: 'helpCommandDescription',
        desc: 'Description for the /help command.',
      );

  String get startCommandDescription => Intl.message(
        'Start the bot and accept the privacy policy',
        name: 'startCommandDescription',
        desc: 'Description for the /start command.',
      );

  String get checkNowCommandDescription => Intl.message(
        'Check for results now',
        name: 'checkNowCommandDescription',
        desc: 'Description for the /check_now command.',
      );

  String get languageCommandDescription => Intl.message(
        'Set your preferred language',
        name: 'languageCommandDescription',
        desc: 'Description for the /language command.',
      );

  // Note: Descriptions for /add, /show, /delete, /delete_me are already present
  // as part of the addSuccess, showNoData, deleteNoData, deleteMeSuccessMessage, etc.
  // We might need dedicated, shorter descriptions for the help list.
  // Let's add them now.

  String get addCommandDescription => Intl.message('Add new exam search data', name: 'addCommandDescription');
  String get showCommandDescription => Intl.message('Show all your saved search data', name: 'showCommandDescription');
  String get deleteCommandDescription => Intl.message('Delete saved search data', name: 'deleteCommandDescription');
  String get deleteMeCommandDescription => Intl.message('Delete all your data and revoke consent', name: 'deleteMeCommandDescription');

  // --- Privacy Policy and Consent ---
  String get startBotWith => Intl.message(
        '''
👋 Welcome to the telc certificate checker bot!

For my operation, I will collect and process some data:
*   Your Telegram data: ID, language code – for identification and communication.
*   Data for certificate lookup: exam attendee number, birth date, and exam date. You will enter this data yourself.

📄 Found certificate information (e.g., "B2 Beruf") will be stored in the system. The retention period for such data is no more than 12 months.

⚠️ Important!
You may enter data to search for another person's certificate. By providing such data, you confirm that you have all necessary permissions (e.g., consent from this person) for its processing via the bot for the specified purposes.

By clicking the "Agree" button, you confirm your acceptance of our Privacy Policy
''',
        name: 'startBotWith',
        desc: 'Greeting message when the bot starts.',
      );

  // --- Privacy Policy and Consent ---
  String get privacyPolicyButtonText => Intl.message(
        '📄 Privacy Policy',
        name: 'privacyPolicyButtonText',
        desc: 'Text for the privacy policy button.',
      );

  String get agreeButtonText => Intl.message(
        '✅ Agree',
        name: 'agreeButtonText',
        desc: 'Text for the agree button.',
      );

  String get declineButtonText => Intl.message(
        '❌ Decline',
        name: 'declineButtonText',
        desc: 'Text for the decline button.',
      );

  /// Keyboard for privacy policy consent.
  /// The URL for the privacy policy should be replaced with the actual URL.
  List<List<InlineKeyboardButton>> privacyPolicyKeyboard(String url) => [
        [
          InlineKeyboardButton(text: agreeButtonText, callbackData: 'consent_agree'),
          InlineKeyboardButton(text: declineButtonText, callbackData: 'consent_decline'),
        ],
        [
          InlineKeyboardButton(text: privacyPolicyButtonText, url: url),
        ],
      ];

  String get consentGivenMessage => Intl.message(
        'Thank you for your consent! You can now use all bot features.',
        name: 'consentGivenMessage',
        desc: 'Message shown when user agrees to privacy policy.',
      );

  String get consentDeclinedMessage => Intl.message(
        'You have declined the terms. To use the bot, you need to agree to the Privacy Policy. You can restart the bot with /start to see the terms again.',
        name: 'consentDeclinedMessage',
        desc: 'Message shown when user declines privacy policy.',
      );

  String get mustAcceptConsentMessage => Intl.message(
        'You need to agree to the Privacy Policy before using this feature. Please use the /start command to see the terms again.',
        name: 'mustAcceptConsentMessage',
        desc: 'Message shown when a feature requires user consent but consent has not been given.',
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
        // This is a success message, not a command description.
        name: 'addSuccess',
      );
  // --- Show Command ---
  String get showNoData => Intl.message(
        'No data added yet. Use /add to add new entries.',
        name: 'showNoData',
      );
  // This is a message when no data is found, not a command description.

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
        // This is a message when no data is found, not a command description.
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

  // --- Delete Me Command ---

  String get deleteMeConfirmationMessage => Intl.message(
        'Are you sure you want to revoke consent and delete all your data from the system?',
        name: 'deleteMeConfirmationMessage',
        desc: 'Confirmation message for deleting all user data and revoking consent.',
      );

  String get deleteMeButtonYes => Intl.message(
        '✅ Yes, delete all',
        name: 'deleteMeButtonYes',
        desc: 'Button text for confirming deletion of all user data.',
      );

  String get deleteMeButtonNo => Intl.message(
        '❌ No',
        name: 'deleteMeButtonNo',
        desc: 'Button text for cancelling deletion of all user data.',
      );

  String get deleteMeSuccessMessage => Intl.message(
        'Your consent has been revoked, and all your data has been successfully deleted from the system. If you wish to use the bot again, you will need to go through the consent procedure again by entering the /start command.',
        name: 'deleteMeSuccessMessage',
        // This is a success message, not a command description.
        desc: 'Message shown after user confirms data deletion and consent revocation.',
      );

  String get deleteMeCancelledMessage => Intl.message(
        'Action cancelled. Your data remains in the system.',
        name: 'deleteMeCancelledMessage',
        desc: 'Message shown after user cancels data deletion.',
      );
}
