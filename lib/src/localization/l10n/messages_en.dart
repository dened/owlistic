// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.
// @dart=2.12
// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = MessageLookup();

typedef String? MessageIfAbsent(
    String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'en';

  static m0(dateFormatPattern) => "Invalid exam date format!\nPlease enter the date in ${dateFormatPattern} format.";

  static m1(daysCount, attendeeNumber) => "No results found for the last ${daysCount} days for user ${attendeeNumber}";

  static m2(displayName) => "Language selected: ${displayName}";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
      'addInvalidAttendeeNumber': MessageLookupByLibrary.simpleMessage('Invalid attendee number. It must be 7 digits (e.g., 0312345).\nIf you are sure the number is correct, please enter it again.\nIf you do not know your number, enter 000 to skip this step.'),
    'addInvalidBirthDate': MessageLookupByLibrary.simpleMessage('Invalid birth date format!\nPlease enter the date in DD.MM.YYYY format.'),
    'addInvalidExamDate': m0,
    'addPromptAttendeeNumber': MessageLookupByLibrary.simpleMessage('Enter your 7-digit exam attendee number (e.g., 0312345).'),
    'addPromptBirthDate': MessageLookupByLibrary.simpleMessage('Enter your birth date in DD.MM.YYYY format.'),
    'addPromptExamDate': MessageLookupByLibrary.simpleMessage('Enter your exam date in DD.MM.YYYY format.'),
    'addSuccess': MessageLookupByLibrary.simpleMessage('Information added successfully!\nYou can view the list of added entries with /show or add a new one with /add.\nTo delete data, use the /delete command.'),
    'agreeButtonText': MessageLookupByLibrary.simpleMessage('✅ Agree'),
    'certFoundFullNameLabel': MessageLookupByLibrary.simpleMessage('Full Name:'),
    'certFoundLinkText': MessageLookupByLibrary.simpleMessage('Certificate Link'),
    'certFoundTitle': MessageLookupByLibrary.simpleMessage('Certificate found!'),
    'certNotFoundMessage': m1,
    'checkNowStart': MessageLookupByLibrary.simpleMessage('Starting results check...'),
    'consentDeclinedMessage': MessageLookupByLibrary.simpleMessage('You have declined the terms. To use the bot, you need to agree to the Privacy Policy. You can restart the bot with /start to see the terms again.'),
    'consentGivenMessage': MessageLookupByLibrary.simpleMessage('Thank you for your consent! You can now use all bot features.'),
    'declineButtonText': MessageLookupByLibrary.simpleMessage('❌ Decline'),
    'deleteAllSuccessCallback': MessageLookupByLibrary.simpleMessage('All entries successfully deleted.'),
    'deleteButtonDeleteAll': MessageLookupByLibrary.simpleMessage('Delete All'),
    'deleteMeButtonNo': MessageLookupByLibrary.simpleMessage('❌ No'),
    'deleteMeButtonYes': MessageLookupByLibrary.simpleMessage('✅ Yes, delete all'),
    'deleteMeCancelledMessage': MessageLookupByLibrary.simpleMessage('Action cancelled. Your data remains in the system.'),
    'deleteMeConfirmationMessage': MessageLookupByLibrary.simpleMessage('Are you sure you want to revoke consent and delete all your data from the system?'),
    'deleteMeSuccessMessage': MessageLookupByLibrary.simpleMessage('Your consent has been revoked, and all your data has been successfully deleted from the system. If you wish to use the bot again, you will need to go through the consent procedure again by entering the /start command.'),
    'deleteNoData': MessageLookupByLibrary.simpleMessage('No data added yet. Nothing to delete.'),
    'deleteOneSuccessCallback': MessageLookupByLibrary.simpleMessage('Entry successfully deleted.'),
    'deleteSelectPrompt': MessageLookupByLibrary.simpleMessage('Select an entry to delete, or click \"Delete All\" to remove all entries.'),
    'helpText': MessageLookupByLibrary.simpleMessage('Available commands:\n/help - Show this help message\n/start - Start the bot\n/check_now - Check result now\n/language - Set language\n/add - Add new data\n/delete - Delete data\n/show - Show all data\n/delete_me - Revoke consent and delete data\n'),
    'langEnglish': MessageLookupByLibrary.simpleMessage('English'),
    'langGerman': MessageLookupByLibrary.simpleMessage('German'),
    'langRussian': MessageLookupByLibrary.simpleMessage('Russian'),
    'langUkrainian': MessageLookupByLibrary.simpleMessage('Ukrainian'),
    'languageSelectPompt': MessageLookupByLibrary.simpleMessage('Select your preferred language (English, German, Russian, Ukrainian):'),
    'languageSelectedCallback': m2,
    'mustAcceptConsentMessage': MessageLookupByLibrary.simpleMessage('You need to agree to the Privacy Policy before using this feature. Please use the /start command to see the terms again.'),
    'privacyPolicyButtonText': MessageLookupByLibrary.simpleMessage('📄 Privacy Policy'),
    'showExamDatePrefix': MessageLookupByLibrary.simpleMessage('Exam:'),
    'showListHeader': MessageLookupByLibrary.simpleMessage('List of added entries:\n'),
    'showNoData': MessageLookupByLibrary.simpleMessage('No data added yet. Use /add to add new entries.'),
    'startBotWith': MessageLookupByLibrary.simpleMessage('👋 Welcome to the telc certificate checker bot!\n\nFor my operation, I will collect and process some data:\n*   Your Telegram data: ID, language code – for identification and communication.\n*   Data for certificate lookup: exam attendee number, birth date, and exam date. You will enter this data yourself.\n\n📄 Found certificate information (e.g., \"B2 Beruf\") will be stored in the system. The retention period for such data is no more than 12 months.\n\n⚠️ Important!\nYou may enter data to search for another person\'s certificate. By providing such data, you confirm that you have all necessary permissions (e.g., consent from this person) for its processing via the bot for the specified purposes.\n\nBy clicking the \"Agree\" button, you confirm your acceptance of our Privacy Policy\n')
  };
}
