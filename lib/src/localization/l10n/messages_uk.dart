// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a uk locale. All the
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

typedef String? MessageIfAbsent(String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'uk';

  static m0(dateFormatPattern) =>
      "Неправильний формат дати іспиту!\nБудь ласка, введіть дату у форматі ${dateFormatPattern}.";

  static m1(daysCount, attendeeNumber) =>
      "Результатів не знайдено за останні ${daysCount} днів для користувача ${attendeeNumber}";

  static m2(displayName) => "Мову вибрано: ${displayName}";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
        'addInvalidAttendeeNumber': MessageLookupByLibrary.simpleMessage(
            'Неправильний номер учасника. Він повинен складатися з 7 цифр (наприклад, 0312345).\nЯкщо ви впевнені, що номер правильний, введіть його ще раз.\nЯкщо ви не знаєте свій номер, введіть 000, щоб пропустити цей крок.'),
        'addInvalidBirthDate': MessageLookupByLibrary.simpleMessage(
            'Неправильний формат дати народження!\nБудь ласка, введіть дату у форматі ДД.ММ.РРРР.'),
        'addInvalidExamDate': m0,
        'addPromptAttendeeNumber':
            MessageLookupByLibrary.simpleMessage('Введіть ваш 7-значний номер учасника іспиту (наприклад, 0312345).'),
        'addPromptBirthDate':
            MessageLookupByLibrary.simpleMessage('Введіть вашу дату народження у форматі ДД.ММ.РРРР.'),
        'addPromptExamDate': MessageLookupByLibrary.simpleMessage('Введіть дату вашого іспиту у форматі ДД.ММ.РРРР.'),
        'addSuccess': MessageLookupByLibrary.simpleMessage(
            'Інформацію успішно додано!\nВи можете переглянути список доданих записів за допомогою /show або додати новий за допомогою /add.\nДля видалення даних використовуйте команду /delete.'),
        'agreeButtonText': MessageLookupByLibrary.simpleMessage('✅ Прийняти'),
        'certFoundFullNameLabel': MessageLookupByLibrary.simpleMessage('Повне ім\'я:'),
        'certFoundLinkText': MessageLookupByLibrary.simpleMessage('Посилання на сертифікат'),
        'certFoundTitle': MessageLookupByLibrary.simpleMessage('Сертифікат знайдено!'),
        'certNotFoundMessage': m1,
        'checkNowStart': MessageLookupByLibrary.simpleMessage('Запуск перевірки результатів...'),
        'consentDeclinedMessage': MessageLookupByLibrary.simpleMessage(
            'Ви відхилили умови. Щоб користуватися ботом, вам потрібно погодитися з Політикою конфіденційності. Ви можете перезапустити бота за допомогою команди /start, щоб знову переглянути умови.'),
        'consentGivenMessage': MessageLookupByLibrary.simpleMessage(
            'Дякуємо за вашу згоду! Тепер ви можете використовувати всі функції бота.\nЩоб додати дані вашого іспиту, скористайтеся командою /add.'),
        'declineButtonText': MessageLookupByLibrary.simpleMessage('❌ Відхилити'),
        'deleteAllSuccessCallback': MessageLookupByLibrary.simpleMessage('Всі записи успішно видалено.'),
        'deleteButtonDeleteAll': MessageLookupByLibrary.simpleMessage('Видалити все'),
        'deleteMeButtonNo': MessageLookupByLibrary.simpleMessage('❌ Ні'),
        'deleteMeButtonYes': MessageLookupByLibrary.simpleMessage('✅ Так, видалити все'),
        'deleteMeCancelledMessage':
            MessageLookupByLibrary.simpleMessage('Дію скасовано. Ваші дані залишаються в системі.'),
        'deleteMeConfirmationMessage': MessageLookupByLibrary.simpleMessage(
            'Ви дійсно бажаєте відкликати згоду та видалити всі ваші дані з системи?'),
        'deleteMeSuccessMessage': MessageLookupByLibrary.simpleMessage(
            'Вашу згоду відкликано, а всі ваші дані успішно видалено з системи. Якщо ви захочете знову скористатися ботом, вам потрібно буде пройти процедуру згоди заново, ввівши команду /start.'),
        'deleteNoData': MessageLookupByLibrary.simpleMessage('Дані ще не додано. Немає чого видаляти.'),
        'deleteOneSuccessCallback': MessageLookupByLibrary.simpleMessage('Запис успішно видалено.'),
        'deleteSelectPrompt': MessageLookupByLibrary.simpleMessage(
            'Виберіть запис для видалення або натисніть \"Видалити все\", щоб видалити всі записи.'),
        'langEnglish': MessageLookupByLibrary.simpleMessage('Англійська'),
        'langGerman': MessageLookupByLibrary.simpleMessage('Німецька'),
        'langRussian': MessageLookupByLibrary.simpleMessage('Російська'),
        'langUkrainian': MessageLookupByLibrary.simpleMessage('Українська'),
        'langUkrainian1': MessageLookupByLibrary.simpleMessage('Ukrainian'),
        'langUkrainian2': MessageLookupByLibrary.simpleMessage('Ukrainian'),
        'langUkrainian3': MessageLookupByLibrary.simpleMessage('Ukrainian'),
        'languageSelectPompt':
            MessageLookupByLibrary.simpleMessage('Виберіть бажану мову (Англійська, Німецька, Російська, Українська):'),
        'languageSelectedCallback': m2,
        'mustAcceptConsentMessage': MessageLookupByLibrary.simpleMessage(
            'Вам потрібно погодитися з Політикою конфіденційності перед використанням цієї функції. Будь ласка, скористайтеся командою /start, щоб знову переглянути умови.'),
        'privacyPolicyButtonText': MessageLookupByLibrary.simpleMessage('📄 Політика конфіденційності'),
        'showExamDatePrefix': MessageLookupByLibrary.simpleMessage('Іспит:'),
        'showListHeader': MessageLookupByLibrary.simpleMessage('Список доданих записів:\n'),
        'showNoData':
            MessageLookupByLibrary.simpleMessage('Дані ще не додано. Використовуйте /add для додавання нових записів.'),
        'startBotWith': MessageLookupByLibrary.simpleMessage(
            '👋 Ласкаво просимо до бота для перевірки сертифікатів telc!\n\nДля моєї роботи я збиратиму та оброблятиму деякі дані:\n*   Ваші дані Telegram: ID, мовний код – для ідентифікації та комунікації.\n*   Дані для пошуку сертифіката: номер учасника іспиту, дата народження та дата іспиту. Ці дані ви вводите самостійно.\n\n📄 Знайдена інформація про сертифікат (наприклад, \"B2 Beruf\") буде збережена в системі. Термін зберігання таких даних не перевищує 12 місяців.\n\n⚠️ Важливо!\nВи можете вводити дані для пошуку сертифіката іншої особи. Надаючи такі дані, ви підтверджуєте, що маєте всі необхідні дозволи (наприклад, згоду цієї особи) на їх обробку через бота у зазначених цілях.\n\nНатискаючи кнопку \"Прийняти\", ви підтверджуєте свою згоду з нашою Політикою конфіденційності\n'),
        'startWelcomeMessage': MessageLookupByLibrary.simpleMessage(
            '👋 Ласкаво просимо до бота для перевірки сертифікатів telc!\n\nЦей бот допоможе вам швидко та легко перевірити результати ваших іспитів telc.\n\nЩоб додати дані вашого іспиту, скористайтеся командою /add.\nВи також можете переглянути збережені дані за допомогою /show, видалити їх за допомогою /delete або відкликати згоду та видалити всі ваші дані за допомогою /delete_me.\n\n')
      };
}
