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

typedef String? MessageIfAbsent(
    String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'uk';

  static m0(dateFormatPattern) => "Неправильний формат дати іспиту!\nБудь ласка, введіть дату у форматі ${dateFormatPattern}.";

  static m1(daysCount, attendeeNumber) => "Результатів не знайдено за останні ${daysCount} днів для користувача ${attendeeNumber}";

  static m2(displayName) => "Мову вибрано: ${displayName}";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
      'addInvalidAttendeeNumber': MessageLookupByLibrary.simpleMessage('Неправильний номер учасника. Він повинен складатися з 7 цифр (наприклад, 0312345).\nЯкщо ви впевнені, що номер правильний, введіть його ще раз.\nЯкщо ви не знаєте свій номер, введіть 000, щоб пропустити цей крок.'),
    'addInvalidBirthDate': MessageLookupByLibrary.simpleMessage('Неправильний формат дати народження!\nБудь ласка, введіть дату у форматі ДД.ММ.РРРР.'),
    'addInvalidExamDate': m0,
    'addPromptAttendeeNumber': MessageLookupByLibrary.simpleMessage('Введіть ваш 7-значний номер учасника іспиту (наприклад, 0312345).'),
    'addPromptBirthDate': MessageLookupByLibrary.simpleMessage('Введіть вашу дату народження у форматі ДД.ММ.РРРР.'),
    'addPromptExamDate': MessageLookupByLibrary.simpleMessage('Введіть дату вашого іспиту у форматі ДД.ММ.РРРР.'),
    'addSuccess': MessageLookupByLibrary.simpleMessage('Інформацію успішно додано!\nВи можете переглянути список доданих записів за допомогою /show або додати новий за допомогою /add.\nДля видалення даних використовуйте команду /delete.'),
    'certFoundFullNameLabel': MessageLookupByLibrary.simpleMessage('Повне ім\'я:'),
    'certFoundLinkText': MessageLookupByLibrary.simpleMessage('Посилання на сертифікат'),
    'certFoundTitle': MessageLookupByLibrary.simpleMessage('Сертифікат знайдено!'),
    'certNotFoundMessage': m1,
    'checkNowStart': MessageLookupByLibrary.simpleMessage('Запуск перевірки результатів...'),
    'deleteAllSuccessCallback': MessageLookupByLibrary.simpleMessage('Всі записи успішно видалено.'),
    'deleteButtonDeleteAll': MessageLookupByLibrary.simpleMessage('Видалити все'),
    'deleteNoData': MessageLookupByLibrary.simpleMessage('Дані ще не додано. Немає чого видаляти.'),
    'deleteOneSuccessCallback': MessageLookupByLibrary.simpleMessage('Запис успішно видалено.'),
    'deleteSelectPrompt': MessageLookupByLibrary.simpleMessage('Виберіть запис для видалення або натисніть \"Видалити все\", щоб видалити всі записи.'),
    'helpText': MessageLookupByLibrary.simpleMessage('Доступні команди:\n/help - Показати це повідомлення допомоги\n/start - Запустити бота\n/check_now - Перевірити результат зараз\n/language - Встановити мову\n/add - Додати нові дані\n/delete - Видалити дані\n/show - Показати всі дані\n'),
    'langEnglish': MessageLookupByLibrary.simpleMessage('Англійська'),
    'langGerman': MessageLookupByLibrary.simpleMessage('Німецька'),
    'langRussian': MessageLookupByLibrary.simpleMessage('Російська'),
    'langUkrainian': MessageLookupByLibrary.simpleMessage('Українська'),
    'languageSelectPompt': MessageLookupByLibrary.simpleMessage('Виберіть бажану мову (Англійська, Німецька, Російська, Українська):'),
    'languageSelectedCallback': m2,
    'showExamDatePrefix': MessageLookupByLibrary.simpleMessage('Іспит:'),
    'showListHeader': MessageLookupByLibrary.simpleMessage('Список доданих записів:\n'),
    'showNoData': MessageLookupByLibrary.simpleMessage('Дані ще не додано. Використовуйте /add для додавання нових записів.'),
    'startBotGreeting': MessageLookupByLibrary.simpleMessage('Бот запущено. Ласкаво просимо!\nВикористовуйте /help для перегляду доступних команд.')
  };
}
