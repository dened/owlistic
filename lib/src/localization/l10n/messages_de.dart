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
    'agreeButtonText': MessageLookupByLibrary.simpleMessage('✅ Zustimmen'),
    'certFoundFullNameLabel': MessageLookupByLibrary.simpleMessage('Vollständiger Name:'),
    'certFoundLinkText': MessageLookupByLibrary.simpleMessage('Zertifikat-Link'),
    'certFoundTitle': MessageLookupByLibrary.simpleMessage('Zertifikat gefunden!'),
    'certNotFoundMessage': m1,
    'checkNowStart': MessageLookupByLibrary.simpleMessage('Ergebnisprüfung wird gestartet...'),
    'consentDeclinedMessage': MessageLookupByLibrary.simpleMessage('Sie haben die Bedingungen abgelehnt. Um den Bot nutzen zu können, müssen Sie der Datenschutzrichtlinie zustimmen. Sie können den Bot mit /start neu starten, um die Bedingungen erneut anzuzeigen.'),
    'consentGivenMessage': MessageLookupByLibrary.simpleMessage('Vielen Dank für Ihre Zustimmung! Sie können jetzt alle Bot-Funktionen nutzen.'),
    'declineButtonText': MessageLookupByLibrary.simpleMessage('❌ Ablehnen'),
    'deleteAllSuccessCallback': MessageLookupByLibrary.simpleMessage('Alle Einträge erfolgreich gelöscht.'),
    'deleteButtonDeleteAll': MessageLookupByLibrary.simpleMessage('Alles löschen'),
    'deleteMeButtonNo': MessageLookupByLibrary.simpleMessage('❌ Nein'),
    'deleteMeButtonYes': MessageLookupByLibrary.simpleMessage('✅ Ja, alles löschen'),
    'deleteMeCancelledMessage': MessageLookupByLibrary.simpleMessage('Aktion abgebrochen. Ihre Daten bleiben im System.'),
    'deleteMeConfirmationMessage': MessageLookupByLibrary.simpleMessage('Sind Sie sicher, dass Sie die Einwilligung widerrufen und alle Ihre Daten aus dem System löschen möchten?'),
    'deleteMeSuccessMessage': MessageLookupByLibrary.simpleMessage('Ihre Einwilligung wurde widerrufen und alle Ihre Daten wurden erfolgreich aus dem System gelöscht. Wenn Sie den Bot erneut verwenden möchten, müssen Sie den Zustimmungsvorgang erneut durchlaufen, indem Sie den Befehl /start eingeben.'),
    'deleteNoData': MessageLookupByLibrary.simpleMessage('Noch keine Daten hinzugefügt. Nichts zu löschen.'),
    'deleteOneSuccessCallback': MessageLookupByLibrary.simpleMessage('Eintrag erfolgreich gelöscht.'),
    'deleteSelectPrompt': MessageLookupByLibrary.simpleMessage('Wählen Sie einen Eintrag zum Löschen aus oder klicken Sie auf \"Alles löschen\", um alle Einträge zu entfernen.'),
    'helpText': MessageLookupByLibrary.simpleMessage('Verfügbare Befehle:\n/help - Diese Hilfenachricht anzeigen\n/start - Den Bot starten\n/check_now - Ergebnis jetzt prüfen\n/language - Sprache einstellen\n/add - Neue Daten hinzufügen\n/delete - Daten löschen\n/show - Alle Daten anzeigen\n/delete_me - Einwilligung widerrufen und Daten löschen\n'),
    'langEnglish': MessageLookupByLibrary.simpleMessage('Englisch'),
    'langGerman': MessageLookupByLibrary.simpleMessage('Deutsch'),
    'langRussian': MessageLookupByLibrary.simpleMessage('Russisch'),
    'langUkrainian': MessageLookupByLibrary.simpleMessage('Ukrainisch'),
    'languageSelectPompt': MessageLookupByLibrary.simpleMessage('Wählen Sie Ihre bevorzugte Sprache (Englisch, Deutsch, Russisch, Ukrainisch):'),
    'languageSelectedCallback': m2,
    'mustAcceptConsentMessage': MessageLookupByLibrary.simpleMessage('Sie müssen der Datenschutzrichtlinie zustimmen, bevor Sie diese Funktion nutzen können. Bitte verwenden Sie den Befehl /start, um die Bedingungen erneut anzuzeigen.'),
    'privacyPolicyButtonText': MessageLookupByLibrary.simpleMessage('📄 Datenschutzrichtlinie'),
    'showExamDatePrefix': MessageLookupByLibrary.simpleMessage('Prüfung:'),
    'showListHeader': MessageLookupByLibrary.simpleMessage('Liste der hinzugefügten Einträge:\n'),
    'showNoData': MessageLookupByLibrary.simpleMessage('Noch keine Daten hinzugefügt. Verwenden Sie /add, um neue Einträge hinzuzufügen.'),
    'startBotWith': MessageLookupByLibrary.simpleMessage('👋 Willkommen beim telc Zertifikat-Checker-Bot!\n\nFür meinen Betrieb werde ich einige Daten sammeln und verarbeiten:\n*   Ihre Telegram-Daten: ID, Sprachcode – zur Identifizierung und Kommunikation.\n*   Daten für die Zertifikatssuche: Prüfungsteilnehmernummer, Geburtsdatum und Prüfungsdatum. Diese Daten geben Sie selbst ein.\n\n📄 Gefundene Zertifikatsinformationen (z.B. \"B2 Beruf\") werden im System gespeichert. Die Aufbewahrungsfrist für solche Daten beträgt nicht mehr als 12 Monate.\n\n⚠️ Wichtig!\nSie können Daten eingeben, um das Zertifikat einer anderen Person zu suchen. Indem Sie solche Daten bereitstellen, bestätigen Sie, dass Sie alle erforderlichen Berechtigungen (z.B. Zustimmung dieser Person) für deren Verarbeitung über den Bot für die angegebenen Zwecke haben.\n\nIndem Sie auf die Schaltfläche \"Zustimmen\" klicken, bestätigen Sie Ihre Annahme unserer Datenschutzrichtlinie\n')
  };
}
