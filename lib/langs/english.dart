import 'dart:collection';

import 'package:dsbuntis/dsbuntis.dart';

import '../constants.dart';
import 'language.dart';

class English extends Language {
  @override
  String get appInfo => '$AMP_APP is an app '
      'for easily viewing Untis substitution plans using DSBMobile.';

  @override
  String get code => 'en';

  @override
  String get settings => 'Settings';

  @override
  String get start => 'Start';

  @override
  String get name => 'English';

  @override
  String get settingsAppInfo => 'App Information';

  @override
  String get highContrastMode => 'High contrast mode';

  @override
  String get changeLogin => 'Login data';

  @override
  String get useSystemTheme => 'Use system design';

  @override
  String dsbSubToSubtitleNotFree(String t, String n) => 'Substituted by $t$n';

  @override
  String dsbSubToSubtitleFree(String notesaddon) => 'Free lesson$notesaddon';

  @override
  String dsbError(Object e) => 'Please check your internet connection and '
      'make sure that your credentials are correct. (dsbuntis: $e)';

  @override
  String get empty => 'empty';

  @override
  String get password => 'Password';

  @override
  String get username => 'DSBMobile-ID';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get allClasses => 'All classes';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get done => 'Done';

  @override
  String get subject => 'Subject';

  @override
  String get notes => 'Notes';

  @override
  String get teacher => 'Teacher';

  @override
  String get edit => 'Edit';

  @override
  String get substitution => 'Substitution';

  @override
  final LinkedHashMap<String, String> subjectLut = LinkedHashMap.from({
    'spo': 'Physical Education / Sports',
    'e': 'English',
    'ev': 'Protestant Religion',
    'et': 'Ethics',
    'd': 'German',
    'i': 'Computer Science',
    'g': 'History',
    'geo': 'Geography',
    'l': 'Latin',
    'it': 'Italian',
    'f': 'French',
    'frz': 'French',
    'so': 'Social Studies / Politics',
    'sk': 'Social Studies / Politics',
    'm': 'Maths',
    'mu': 'Music',
    'b': 'Biology',
    'bwl': 'Business Administration',
    'c': 'Chemistry',
    'k': 'Art',
    'ka': 'Catholic Religion',
    'p': 'Physics',
    'ps': 'Psychology',
    'w': 'Economics/Law',
    'w/r': 'Economics/Law',
    'w&r': 'Economics/Law',
    'nut': '"Nature and Technology"',
    'spr': 'Consultation Hour',
  });

  @override
  String get darkMode => 'Dark mode';

  @override
  String dayToString(Day? day) {
    switch (day) {
      case null:
        return '';
      case Day.monday:
        return 'Monday';
      case Day.tuesday:
        return 'Tuesday';
      case Day.wednesday:
        return 'Wednesday';
      case Day.thursday:
        return 'Thursday';
      case Day.friday:
        return 'Friday';
      default:
        throw UnimplementedError('Unknown Day!');
    }
  }

  @override
  String get noSubs => 'No substitutions';

  @override
  String get changedAppearance =>
      'Changed the appearance of the substitution plan!';

  @override
  String get show => 'Show';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get open => 'Open';

  @override
  String get update => 'Update';

  @override
  String plsUpdate(String oldVersion, String newVersion) =>
      'An update is available: $oldVersion → $newVersion';

  @override
  String get wpemailDomain => 'Your school\'s web address (example.com)';

  @override
  String get openPlanInBrowser => 'Open plan in browser';

  @override
  String get parseSubjects => 'Parse subjects';

  @override
  String warnWrongDate(String date) =>
      'It seems that this substitution plan is outdated. (date: "$date")';

  @override
  String get groupByClass => 'Group by class';

  @override
  String get changeStudentGroup => 'Change class';

  @override
  String get filterPlans => 'Filter substitution plans';

  @override
  String get teachers => 'Teachers';

  @override
  String get selectAccentColor => 'Select accent color';

  @override
  String get search => 'Search';

  @override
  String get hapticFeedback => 'Haptic feedback';

  @override
  String get internetConnectionFail => 'Internet connection failed.';

  @override
  String get error => 'Error';
}
