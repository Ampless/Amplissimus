import 'dart:collection';

import 'package:dsbuntis/dsbuntis.dart';
import '../main.dart';
import 'dutch.dart';
import 'english.dart';
import 'german.dart';

abstract class Language {
  String get code;
  String get name;

  String get darkMode;
  String get useSystemTheme;
  String get highContrastMode;
  String get changeLanguage;
  String get parseSubjects;
  String get changeLogin;
  String get username;
  String get password;
  String get save;
  String get cancel;
  String get settingsAppInfo;
  String get appInfo;
  String get start;
  String get settings;
  String get allClasses;
  String get empty;
  String get done;
  String get noSubs;
  String get subject;
  String get notes;
  String get teacher;
  String get edit;
  String get substitution;
  String get changedAppearance;
  String get show;
  String get dismiss;
  String get open;
  String get update;
  String get wpemailDomain;
  String get openPlanInBrowser;
  String get groupByClass;
  String get changeStudentGroup;
  String get filterPlans;
  String get teachers;
  String get selectAccentColor;
  String get search;
  String get hapticFeedback;
  String get internetConnectionFail;
  String get error;
  String plsUpdate(String oldVersion, String newVersion);
  String warnWrongDate(String date);
  String dayToString(Day? day);
  String dsbError(Object e);
  LinkedHashMap<String, String> get subjectLut;
  String dsbSubToSubtitleNotFree(String subTeacher, String notesaddon);
  String dsbSubToSubtitleFree(String notesaddon);
  String _notesAddon(Substitution sub) =>
      sub.notes.isNotEmpty ? ' (${sub.notes})' : '';
  String dsbSubToSubtitle(Substitution sub) => sub.isFree
      ? dsbSubToSubtitleFree(_notesAddon(sub))
      : dsbSubToSubtitleNotFree(sub.subTeacher, _notesAddon(sub));

  //why tf doesn't this break?!
  static Language _current = fromCode(prefs.savedLangCode);
  static Language get current => isAprilFools ? Dutch() : _current;
  static set current(Language l) {
    prefs.savedLangCode = l.code;
    _current = l;
  }

  static final List<Language> _langs = [English(), German()];
  static List<Language> get all => _langs;

  static bool _strContain(String s1, String s2) =>
      s1.contains(s2) || s2.contains(s1);

  static Language fromCode(String code) => _langs.firstWhere(
      (l) => _strContain(code.toLowerCase(), l.code.toLowerCase()),
      orElse: () => _langs[0]);

  @override
  String toString() => name;
}

bool get isAprilFools {
  final now = DateTime.now();
  return now.day == 1 && now.month == 4;
}
