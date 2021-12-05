import 'dart:collection';

import 'package:dsbuntis/dsbuntis.dart';

import '../constants.dart';
import 'language.dart';

class Dutch extends Language {
  @override
  String get appInfo => '$AMP_APP is een app '
      'om eenvoudig vervangingsplannen van Untis te bekijken via DSBMobile.';

  @override
  String get code => 'nl';

  @override
  String get settings => 'Instellingen';

  @override
  String get start => 'Start';

  @override
  String get name => 'Nederlands';

  @override
  String get settingsAppInfo => 'App-informatie';

  @override
  String get highContrastMode => 'Modus met hoog contrast';

  @override
  String get changeLogin => 'Login gegevens';

  @override
  String get useSystemTheme => 'Gebruik systeemontwerp';

  @override
  String get edit => 'Aanpassen';

  @override
  String get substitution => 'Stand-in';

  @override
  String dsbSubToSubtitleNotFree(String t, String n) =>
      'Vertegenwoordigd door $t$n';

  @override
  String dsbSubToSubtitleFree(String notesaddon) => 'Vrije periode$notesaddon';

  @override
  String dsbError(Object e) => 'Controleer uw internetverbinding en '
      'zorg ervoor dat de inloggegevens correct zijn. (dsbuntis: $e)';

  @override
  String get empty => 'Leeg';

  @override
  String get password => 'Wachtwoord';

  @override
  String get username => 'DSBMobile-ID';

  @override
  String get save => 'Opslaan';

  @override
  String get cancel => 'Afbreken';

  @override
  String get allClasses => 'Alle klassen';

  @override
  String get changeLanguage => 'Taal wijzigen';

  @override
  String get done => 'Afgewerkt';

  @override
  String get subject => 'Onderwerpen';

  @override
  String get notes => 'Opmerkingen';

  @override
  String get teacher => 'Leraar';

  @override
  final LinkedHashMap<String, String> subjectLut = LinkedHashMap.from({
    'spo': 'Sport',
    'e': 'Engels',
    'ev': 'Evangelische religie',
    'et': 'Ethiek',
    'd': 'Duitse',
    'i': 'Informatica',
    'g': 'Geschiedenis',
    'geo': 'Aardrijkskunde',
    'l': 'Latijns',
    'it': 'Italiaans',
    'f': 'Frans',
    'frz': 'Frans',
    'so': 'Sociale Studies',
    'sk': 'Sociale Studies',
    'm': 'Wiskunde',
    'mu': 'Muziek',
    'b': 'Biologie',
    'bwl': 'Bedrijfskunde',
    'c': 'Scheikunde',
    'k': 'Kunst',
    'ka': 'Katholieke religie',
    'p': 'Fysica',
    'ps': 'Psychologie',
    'w': 'Economie/Recht',
    'w/r': 'Economie/Recht',
    'w&r': 'Economie/Recht',
    'nut': 'Natuur en technologie',
    'spr': 'Spreekuur',
  });

  @override
  String get darkMode => 'Donkere modus';

  @override
  String dayToString(Day? day) {
    switch (day) {
      case null:
        return '';
      case Day.monday:
        return 'Maandag';
      case Day.tuesday:
        return 'Dinsdag';
      case Day.wednesday:
        return 'Woensdag';
      case Day.thursday:
        return 'Donderdag';
      case Day.friday:
        return 'Vrijdag';
      default:
        throw UnimplementedError('Onbekende dag!');
    }
  }

  @override
  String get noSubs => 'Geen voorstellingen';

  @override
  String get changedAppearance => 'Uiterlijk vervangingsplan gewijzigd!';

  @override
  String get show => 'Tonen';

  @override
  String get dismiss => 'Afsluiten';

  @override
  String get open => 'Openen';

  @override
  String get update => 'Bijwerken';

  @override
  String plsUpdate(String oldVersion, String newVersion) =>
      'Een update is beschikbaar: $oldVersion → $newVersion';

  @override
  String get wpemailDomain => 'Webadres van uw school (voorbeeld.nl)';

  @override
  String get openPlanInBrowser => 'Open plan in browser';

  @override
  String get parseSubjects => 'Vertaal onderwerpen';

  @override
  String warnWrongDate(String date) =>
      'Het lijkt erop dat dit vervangingsplan achterhaald is. (Datum: "$date")';

  @override
  String get groupByClass => 'Groepeer per klas';

  @override
  String get changeStudentGroup => 'Verander van klas';

  @override
  String get filterPlans => 'Filter vervangingsplannen';

  @override
  String get teachers => 'Leraren';

  @override
  String get selectAccentColor => 'Kies een accentkleur';

  @override
  String get search => 'Zoeken';

  @override
  String get hapticFeedback => 'Haptische feedback';

  @override
  String get internetConnectionFail => 'Internetverbinding mislukt.';

  @override
  String get error => 'Fout';
}
