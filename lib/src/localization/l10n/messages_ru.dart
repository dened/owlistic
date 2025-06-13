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

typedef String? MessageIfAbsent(String? messageStr, List<Object>? args);

class MessageLookup extends MessageLookupByLibrary {
  @override
  String get localeName => 'ru';

  static m0(dateFormatPattern) =>
      "Неверный формат даты экзамена!\nПожалуйста, введите дату в формате ${dateFormatPattern}.";

  static m1(daysCount, attendeeNumber) =>
      "Результаты не найдены за последние ${daysCount} дней для пользователя ${attendeeNumber}";

  static m2(displayName) => "Язык выбран: ${displayName}";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
        'addCommandDescription': MessageLookupByLibrary.simpleMessage('Добавить новые данные для поиска экзамена'),
        'addInvalidAttendeeNumber': MessageLookupByLibrary.simpleMessage(
            'Неверный номер участника. Он должен состоять из 7 цифр (например, 0312345).\nЕсли вы уверены, что номер правильный, введите его еще раз.\nЕсли вы не знаете свой номер, введите 000, чтобы пропустить этот шаг.'),
        'addInvalidBirthDate': MessageLookupByLibrary.simpleMessage(
            'Неверный формат даты рождения!\nПожалуйста, введите дату в формате ДД.ММ.ГГГГ.'),
        'addInvalidExamDate': m0,
        'addPromptAttendeeNumber':
            MessageLookupByLibrary.simpleMessage('Введите ваш 7-значный номер участника экзамена (например, 0312345).'),
        'addPromptBirthDate': MessageLookupByLibrary.simpleMessage('Введите вашу дату рождения в формате ДД.ММ.ГГГГ.'),
        'addPromptExamDate': MessageLookupByLibrary.simpleMessage('Введите дату вашего экзамена в формате ДД.ММ.ГГГГ.'),
        'addSuccess': MessageLookupByLibrary.simpleMessage(
            'Информация успешно добавлена!\nВы можете просмотреть список добавленных записей с помощью /show или добавить новую с помощью /add.\nДля удаления данных используйте команду /delete.'),
        'agreeButtonText': MessageLookupByLibrary.simpleMessage('✅ Принять'),
        'certFoundFullNameLabel': MessageLookupByLibrary.simpleMessage('ФИО:'),
        'certFoundLinkText': MessageLookupByLibrary.simpleMessage('Ссылка на сертификат'),
        'certFoundTitle': MessageLookupByLibrary.simpleMessage('Сертификат найден!'),
        'certNotFoundMessage': m1,
        'checkNowCommandDescription': MessageLookupByLibrary.simpleMessage('Проверить результаты сейчас'),
        'checkNowStart': MessageLookupByLibrary.simpleMessage('Запуск проверки результатов...'),
        'consentDeclinedMessage': MessageLookupByLibrary.simpleMessage(
            'Вы отклонили условия. Чтобы использовать бота, вам необходимо согласиться с Политикой конфиденциальности. Вы можете перезапустить бота с помощью команды /start, чтобы снова ознакомиться с условиями.'),
        'consentGivenMessage': MessageLookupByLibrary.simpleMessage(
            'Спасибо за ваше согласие! Теперь вы можете использовать все функции бота.\nЧтобы добавить данные вашего экзамена, используйте команду /add.'),
        'declineButtonText': MessageLookupByLibrary.simpleMessage('❌ Отклонить'),
        'deleteAllSuccessCallback': MessageLookupByLibrary.simpleMessage('Все записи успешно удалены.'),
        'deleteButtonDeleteAll': MessageLookupByLibrary.simpleMessage('Удалить все'),
        'deleteCommandDescription': MessageLookupByLibrary.simpleMessage('Удалить сохраненные данные поиска'),
        'deleteMeButtonNo': MessageLookupByLibrary.simpleMessage('❌ Нет'),
        'deleteMeButtonYes': MessageLookupByLibrary.simpleMessage('✅ Да, удалить всё'),
        'deleteMeCancelledMessage':
            MessageLookupByLibrary.simpleMessage('Действие отменено. Ваши данные остаются в системе.'),
        'deleteMeCommandDescription':
            MessageLookupByLibrary.simpleMessage('Удалить все ваши данные и отозвать согласие'),
        'deleteMeConfirmationMessage': MessageLookupByLibrary.simpleMessage(
            'Вы действительно хотите отозвать согласие и удалить все свои данные из системы?'),
        'deleteMeSuccessMessage': MessageLookupByLibrary.simpleMessage(
            'Ваше согласие отозвано, и все ваши данные были успешно удалены из системы. Если вы захотите снова воспользоваться ботом, вам потребуется пройти процедуру согласия заново, введя команду /start.'),
        'deleteNoData': MessageLookupByLibrary.simpleMessage('Данные еще не добавлены. Нечего удалять.'),
        'deleteOneSuccessCallback': MessageLookupByLibrary.simpleMessage('Запись успешно удалена.'),
        'deleteSelectPrompt': MessageLookupByLibrary.simpleMessage(
            'Выберите запись для удаления или нажмите \"Удалить все\", чтобы удалить все записи.'),
        'helpCommandDescription': MessageLookupByLibrary.simpleMessage('Показать это справочное сообщение'),
        'helpListHeader': MessageLookupByLibrary.simpleMessage('Доступные команды:'),
        'langEnglish': MessageLookupByLibrary.simpleMessage('Английский'),
        'langGerman': MessageLookupByLibrary.simpleMessage('Немецкий'),
        'langRussian': MessageLookupByLibrary.simpleMessage('Русский'),
        'langUkrainian': MessageLookupByLibrary.simpleMessage('Украинский'),
        'langUkrainian1': MessageLookupByLibrary.simpleMessage('Ukrainian'),
        'langUkrainian2': MessageLookupByLibrary.simpleMessage('Ukrainian'),
        'langUkrainian3': MessageLookupByLibrary.simpleMessage('Ukrainian'),
        'languageCommandDescription': MessageLookupByLibrary.simpleMessage('Установить предпочитаемый язык'),
        'languageSelectPompt': MessageLookupByLibrary.simpleMessage(
            'Выберите предпочитаемый язык (Английский, Немецкий, Русский, Украинский):'),
        'languageSelectedCallback': m2,
        'mustAcceptConsentMessage': MessageLookupByLibrary.simpleMessage(
            'Вам необходимо согласиться с Политикой конфиденциальности перед использованием этой функции. Пожалуйста, используйте команду /start, чтобы снова ознакомиться с условиями.'),
        'privacyPolicyButtonText': MessageLookupByLibrary.simpleMessage('📄 Политика конфиденциальности'),
        'showCommandDescription': MessageLookupByLibrary.simpleMessage('Показать все сохраненные данные поиска'),
        'showExamDatePrefix': MessageLookupByLibrary.simpleMessage('Экзамен:'),
        'showListHeader': MessageLookupByLibrary.simpleMessage('Список добавленных записей:\n'),
        'showNoData': MessageLookupByLibrary.simpleMessage(
            'Данные еще не добавлены. Используйте /add для добавления новых записей.'),
        'startBotWith': MessageLookupByLibrary.simpleMessage(
            '👋 Добро пожаловать в бот для проверки сертификатов telc!\n\nДля моей работы я буду собирать и обрабатывать некоторые данные:\n*   Ваши данные Telegram: ID, языковой код – для идентификации и коммуникации.\n*   Данные для поиска сертификата: номер участника экзамена, дата рождения и дата экзамена. Эти данные вы вводите самостоятельно.\n\n📄 Найденная информация о сертификате (например, \"B2 Beruf\") будет сохранена в системе. Срок хранения таких данных не превышает 12 месяцев.\n\n⚠️ Важно!\nВы можете вводить данные для поиска сертификата другого человека. Предоставляя такие данные, вы подтверждаете, что у вас есть все необходимые разрешения (например, согласие этого человека) на их обработку через бота в указанных целях.\n\nНажимая кнопку \"Принять\", вы подтверждаете свое согласие с нашей Политикой конфиденциальности\n'),
        'startCommandDescription':
            MessageLookupByLibrary.simpleMessage('Запустить бота и принять политику конфиденциальности'),
        'startWelcomeMessage': MessageLookupByLibrary.simpleMessage(
            '👋 Добро пожаловать в бот для проверки сертификатов telc!\n\nЭтот бот поможет вам быстро и легко проверить результаты ваших экзаменов telc.\n\nЧтобы добавить данные вашего экзамена, используйте команду /add.\nВы также можете просмотреть сохраненные данные с помощью /show, удалить их с помощью /delete или отозвать согласие и удалить все ваши данные с помощью /delete_me.\n\n')
      };
}
