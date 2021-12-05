import 'dart:collection';

import 'package:dsbuntis/dsbuntis.dart';

import '../constants.dart';
import 'language.dart';

class German extends Language {
  @override
  String get appInfo => '$AMP_APP ist eine App '
      'zum einfachen Ansehen von Untis Vertretungsplänen durch DSBMobile.';

  @override
  String get code => 'de';

  @override
  String get settings => 'Einstellungen';

  @override
  String get start => 'Start';

  @override
  String get name => 'Deutsch';

  @override
  String get settingsAppInfo => 'App-Informationen';

  @override
  String get highContrastMode => 'Hochkontrastmodus';

  @override
  String get changeLogin => 'Login-Daten';

  @override
  String get useSystemTheme => 'System-Design verwenden';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get substitution => 'Vertretung';

  @override
  String dsbSubToSubtitleNotFree(String t, String n) => 'Vertreten durch $t$n';

  @override
  String dsbSubToSubtitleFree(String notesaddon) => 'Freistunde$notesaddon';

  @override
  String dsbError(Object e) =>
      'Bitte überprüfen Sie Ihre Internetverbindung und '
      'stellen Sie sicher, dass die Logindaten richtig sind. (dsbuntis: $e)';

  @override
  String get empty => 'leer';

  @override
  String get password => 'Passwort';

  @override
  String get username => 'DSBMobile-ID';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get allClasses => 'Alle Klassen';

  @override
  String get changeLanguage => 'Sprache ändern';

  @override
  String get done => 'Fertig';

  @override
  String get subject => 'Fach';

  @override
  String get notes => 'Notizen';

  @override
  String get teacher => 'Lehrkraft';

  @override
  final LinkedHashMap<String, String> subjectLut = LinkedHashMap.from({
    'spo': 'Sport',
    'e': 'Englisch',
    'ev': 'Evangelische Religion',
    'et': 'Ethik',
    'd': 'Deutsch',
    'i': 'Informatik',
    'g': 'Geschichte',
    'geo': 'Geografie',
    'l': 'Latein',
    'it': 'Italienisch',
    'f': 'Französisch',
    'frz': 'Französisch',
    'so': 'Sozialkunde',
    'sk': 'Sozialkunde',
    'm': 'Mathematik',
    'mu': 'Musik',
    'b': 'Biologie',
    'bwl': 'Betriebswirtschaftslehre',
    'c': 'Chemie',
    'k': 'Kunst',
    'ka': 'Katholische Religion',
    'p': 'Physik',
    'ps': 'Psychologie',
    'w': 'Wirtschaft/Recht',
    'w/r': 'Wirtschaft/Recht',
    'w&r': 'Wirtschaft/Recht',
    'nut': 'Natur und Technik',
    'spr': 'Sprechstunde',
  });

  @override
  String get darkMode => 'Dark Mode';

  @override
  String dayToString(Day? day) {
    switch (day) {
      case null:
        return '';
      case Day.monday:
        return 'Montag';
      case Day.tuesday:
        return 'Dienstag';
      case Day.wednesday:
        return 'Mittwoch';
      case Day.thursday:
        return 'Donnerstag';
      case Day.friday:
        return 'Freitag';
      default:
        throw UnimplementedError('Unbekannter Tag!');
    }
  }

  @override
  String get noSubs => 'Keine Vertretungen';

  @override
  String get changedAppearance => 'Aussehen des Vertretungsplans geändert!';

  @override
  String get show => 'Anzeigen';

  @override
  String get dismiss => 'Schließen';

  @override
  String get open => 'Öffnen';

  @override
  String get update => 'Update';

  @override
  String plsUpdate(String oldVersion, String newVersion) =>
      'Ein Update ist verfügbar: $oldVersion → $newVersion';

  @override
  String get wpemailDomain => 'Webaddresse deiner Schule (beispiel.de)';

  @override
  String get openPlanInBrowser => 'Plan im Browser öffnen';

  @override
  String get parseSubjects => 'Fächer übersetzen';

  @override
  String warnWrongDate(String date) =>
      'Es scheint, als wäre dieser Vertretungsplan veraltet. (Datum: "$date")';

  @override
  String get groupByClass => 'Nach Klasse gruppieren';

  @override
  String get changeStudentGroup => 'Klasse ändern';

  @override
  String get filterPlans => 'Vertretungspläne filtern';

  @override
  String get teachers => 'Lehrkräfte';

  @override
  String get selectAccentColor => 'Akzentfarbe wählen';

  @override
  String get search => 'Suchen';

  @override
  String get hapticFeedback => 'Haptisches Feedback';

  @override
  String get internetConnectionFail => 'Internetverbindung fehlgeschlagen.';

  @override
  String get error => 'Fehler';
}
