// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static m0(dateFormatPattern) => "Ungültiges Prüfungsdatumsformat!\nBitte geben Sie das Datum im Format ${dateFormatPattern} ein.";

  static m1(daysCount, attendeeNumber) => "Für Benutzer ${attendeeNumber} wurden in den letzten ${daysCount} Tagen keine Ergebnisse gefunden";

  static m2(displayName) => "Sprache ausgewählt: ${displayName}";

  @override
  final Map<String, dynamic> messages = _notInlinedMessages(_notInlinedMessages);

  static Map<String, dynamic> _notInlinedMessages(_) => {
      'addInvalidAttendeeNumber': MessageLookupByLibrary.simpleMessage('Ungültige Teilnehmernummer. Sie muss 7-stellig sein (z.B. 0312345).\nWenn Sie sicher sind, dass die Nummer korrekt ist, geben Sie sie bitte erneut ein.\nWenn Sie Ihre Nummer nicht kennen, geben Sie 000 ein, um diesen Schritt zu überspringen.'),
    'addInvalidBirthDate': MessageLookupByLibrary.simpleMessage('Ungültiges Geburtsdatumsformat!\nBitte geben Sie das Datum im Format TT.MM.JJJJ ein.'),
    'addInvalidExamDate': m0,
    'addPromptAttendeeNumber': MessageLookupByLibrary.simpleMessage('Geben Sie Ihre 7-stellige Prüfungsteilnehmernummer ein (z.B. 0312345).'),
    'addPromptBirthDate': MessageLookupByLibrary.simpleMessage('Geben Sie Ihr Geburtsdatum im Format TT.MM.JJJJ ein.'),
    'addPromptExamDate': MessageLookupByLibrary.simpleMessage('Geben Sie Ihr Prüfungsdatum im Format TT.MM.JJJJ ein.'),
    'addSuccess': MessageLookupByLibrary.simpleMessage('Informationen erfolgreich hinzugefügt!\nSie können die Liste der hinzugefügten Einträge mit /show anzeigen oder mit /add einen neuen hinzufügen.\nUm Daten zu löschen, verwenden Sie den Befehl /delete.'),
    'certFoundFullNameLabel': MessageLookupByLibrary.simpleMessage('Vollständiger Name:'),
    'certFoundLinkText': MessageLookupByLibrary.simpleMessage('Zertifikat-Link'),
    'certFoundTitle': MessageLookupByLibrary.simpleMessage('Zertifikat gefunden!'),
    'certNotFoundMessage': m1,
    'checkNowStart': MessageLookupByLibrary.simpleMessage('Ergebnisprüfung wird gestartet...'),
    'deleteAllSuccessCallback': MessageLookupByLibrary.simpleMessage('Alle Einträge erfolgreich gelöscht.'),
    'deleteButtonDeleteAll': MessageLookupByLibrary.simpleMessage('Alles löschen'),
    'deleteNoData': MessageLookupByLibrary.simpleMessage('Noch keine Daten hinzugefügt. Nichts zu löschen.'),
    'deleteOneSuccessCallback': MessageLookupByLibrary.simpleMessage('Eintrag erfolgreich gelöscht.'),
    'deleteSelectPrompt': MessageLookupByLibrary.simpleMessage('Wählen Sie einen Eintrag zum Löschen aus oder klicken Sie auf \"Alles löschen\", um alle Einträge zu entfernen.'),
    'helpText': MessageLookupByLibrary.simpleMessage('Verfügbare Befehle:\n/help - Diese Hilfenachricht anzeigen\n/start - Den Bot starten\n/check_now - Ergebnis jetzt prüfen\n/language - Sprache einstellen\n/add - Neue Daten hinzufügen\n/delete - Daten löschen\n/show - Alle Daten anzeigen\n'),
    'langEnglish': MessageLookupByLibrary.simpleMessage('Englisch'),
    'langGerman': MessageLookupByLibrary.simpleMessage('Deutsch'),
    'langRussian': MessageLookupByLibrary.simpleMessage('Russisch'),
    'langUkrainian': MessageLookupByLibrary.simpleMessage('Ukrainisch'),
    'languageSelectPompt': MessageLookupByLibrary.simpleMessage('Wählen Sie Ihre bevorzugte Sprache (Englisch, Deutsch, Russisch, Ukrainisch):'),
    'languageSelectedCallback': m2,
    'showExamDatePrefix': MessageLookupByLibrary.simpleMessage('Prüfung:'),
    'showListHeader': MessageLookupByLibrary.simpleMessage('Liste der hinzugefügten Einträge:\n'),
    'showNoData': MessageLookupByLibrary.simpleMessage('Noch keine Daten hinzugefügt. Verwenden Sie /add, um neue Einträge hinzuzufügen.'),
    'startBotGreeting': MessageLookupByLibrary.simpleMessage('Bot gestartet. Willkommen!\nNutze /help, um verfügbare Befehle zu sehen.')
  };
}
