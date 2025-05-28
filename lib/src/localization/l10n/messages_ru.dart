// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ru locale. All the
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
  String get localeName => 'ru';

  static m0(dateFormatPattern) => "Неверный формат даты экзамена!\nПожалуйста, введите дату в формате ${dateFormatPattern}.";

  static m1(daysCount, attendeeNumber) => "Результаты не найдены за последние ${daysCount} дней для пользователя ${attendeeNumber}";

  static m2(displayName) => "Язык выбран: ${displayName}";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
      'addInvalidAttendeeNumber': MessageLookupByLibrary.simpleMessage('Неверный номер участника. Он должен состоять из 7 цифр (например, 0312345).\nЕсли вы уверены, что номер правильный, введите его еще раз.\nЕсли вы не знаете свой номер, введите 000, чтобы пропустить этот шаг.'),
    'addInvalidBirthDate': MessageLookupByLibrary.simpleMessage('Неверный формат даты рождения!\nПожалуйста, введите дату в формате ДД.ММ.ГГГГ.'),
    'addInvalidExamDate': m0,
    'addPromptAttendeeNumber': MessageLookupByLibrary.simpleMessage('Введите ваш 7-значный номер участника экзамена (например, 0312345).'),
    'addPromptBirthDate': MessageLookupByLibrary.simpleMessage('Введите вашу дату рождения в формате ДД.ММ.ГГГГ.'),
    'addPromptExamDate': MessageLookupByLibrary.simpleMessage('Введите дату вашего экзамена в формате ДД.ММ.ГГГГ.'),
    'addSuccess': MessageLookupByLibrary.simpleMessage('Информация успешно добавлена!\nВы можете просмотреть список добавленных записей с помощью /show или добавить новую с помощью /add.\nДля удаления данных используйте команду /delete.'),
    'certFoundFullNameLabel': MessageLookupByLibrary.simpleMessage('ФИО:'),
    'certFoundLinkText': MessageLookupByLibrary.simpleMessage('Ссылка на сертификат'),
    'certFoundTitle': MessageLookupByLibrary.simpleMessage('Сертификат найден!'),
    'certNotFoundMessage': m1,
    'checkNowStart': MessageLookupByLibrary.simpleMessage('Запуск проверки результатов...'),
    'deleteAllSuccessCallback': MessageLookupByLibrary.simpleMessage('Все записи успешно удалены.'),
    'deleteButtonDeleteAll': MessageLookupByLibrary.simpleMessage('Удалить все'),
    'deleteNoData': MessageLookupByLibrary.simpleMessage('Данные еще не добавлены. Нечего удалять.'),
    'deleteOneSuccessCallback': MessageLookupByLibrary.simpleMessage('Запись успешно удалена.'),
    'deleteSelectPrompt': MessageLookupByLibrary.simpleMessage('Выберите запись для удаления или нажмите \"Удалить все\", чтобы удалить все записи.'),
    'helpText': MessageLookupByLibrary.simpleMessage('Доступные команды:\n/help - Показать это сообщение помощи\n/start - Запустить бота\n/check_now - Проверить результат сейчас\n/language - Установить язык\n/add - Добавить новые данные\n/delete - Удалить данные\n/show - Показать все данные\n'),
    'langEnglish': MessageLookupByLibrary.simpleMessage('Английский'),
    'langGerman': MessageLookupByLibrary.simpleMessage('Немецкий'),
    'langRussian': MessageLookupByLibrary.simpleMessage('Русский'),
    'langUkrainian': MessageLookupByLibrary.simpleMessage('Украинский'),
    'languageSelectPompt': MessageLookupByLibrary.simpleMessage('Выберите предпочитаемый язык (Английский, Немецкий, Русский, Украинский):'),
    'languageSelectedCallback': m2,
    'showExamDatePrefix': MessageLookupByLibrary.simpleMessage('Экзамен:'),
    'showListHeader': MessageLookupByLibrary.simpleMessage('Список добавленных записей:\n'),
    'showNoData': MessageLookupByLibrary.simpleMessage('Данные еще не добавлены. Используйте /add для добавления новых записей.'),
    'startBotGreeting': MessageLookupByLibrary.simpleMessage('Бот запущен. Добро пожаловать!\nИспользуйте /help для просмотра доступных команд.')
  };
}
