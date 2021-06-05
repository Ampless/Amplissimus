import 'dart:async';
import 'dart:convert';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'logging.dart' as log;
import 'uilib.dart';

class Prefs {
  final SharedPreferences? _prefs;

  Prefs(this._prefs);

  T _get<T>(String key, T dflt, T? Function(String)? f) {
    return (_prefs != null) ? (f!(key) ?? dflt) : dflt;
  }

  int _getInt(String k, int d) => _get(k, d, _prefs?.getInt);

  String _getString(String k, String d) => _get(k, d, _prefs?.getString);

  bool _getBool(String k, bool d) => _get(k, d, _prefs?.getBool);

  List<String> _getStringList(String k, List<String> d) =>
      _get(k, d, _prefs?.getStringList);

  void _set<T>(String key, T value, Function(String, T)? f) {
    if (_prefs != null) f!(key, value);
  }

  void _setInt(String k, int v) => _set(k, v, _prefs?.setInt);

  void _setString(String k, String v) => _set(k, v, _prefs?.setString);

  void _setBool(String k, bool v) => _set(k, v, _prefs?.setBool);

  //NOTE: collisions would break everything.
  String _hashCache(String s) => sha256.convert(utf8.encode(s)).toString();

  String? getCache(String url) {
    log.info(['prefs', 'getCache'], url);
    if (_prefs == null) return null;
    final hash = _hashCache(url);
    if (!_getStringList('CACHE_URLS', []).contains(hash)) {
      log.info(['prefs', 'getCache'], 'Miss: $url');
      return null;
    }
    final ttl = _getInt('CACHE_TTL_$hash', 0);
    if (ttl == 0 || ttl > DateTime.now().millisecondsSinceEpoch) {
      if (!_prefs!.containsKey('CACHE_VAL_$hash')) return null;
      return _prefs!.getString('CACHE_VAL_$hash');
    }
    _prefs!.remove('CACHE_VAL_$hash');
    log.info(['prefs', 'getCache'], 'TTL reached: $url');
    return null;
  }

  void setCache(String url, String html, Duration ttl) {
    if (_prefs == null) return;
    final hash = _hashCache(url);
    final cachedHashes = _getStringList('CACHE_URLS', []);
    if (!cachedHashes.contains(hash)) cachedHashes.add(hash);
    _prefs!.setStringList('CACHE_URLS', cachedHashes);
    _prefs!.setString('CACHE_VAL_$hash', html);
    _prefs!.setInt(
        'CACHE_TTL_$hash', DateTime.now().add(ttl).millisecondsSinceEpoch);
  }

  void deleteCache(bool Function(String, String, int) isToBeDeleted) {
    if (_prefs == null) return;
    final cachedHashes = _getStringList('CACHE_URLS', []);
    final toRemove = cachedHashes.where((hash) =>
        _prefs!.getString('CACHE_VAL_$hash') == null ||
        _prefs!.getInt('CACHE_TTL_$hash') == null ||
        isToBeDeleted(hash, _prefs!.getString('CACHE_VAL_$hash')!,
            _prefs!.getInt('CACHE_TTL_$hash')!));
    for (final hash in toRemove) {
      _prefs!.remove('CACHE_VAL_$hash');
      _prefs!.remove('CACHE_TTL_$hash');
      log.info('Cache', 'Removed $hash');
    }
    _prefs!.setStringList('CACHE_URLS',
        cachedHashes.where((h) => !toRemove.contains(h)).toList());
  }

  void listCache() {
    log.raw('{');
    for (final hash in _getStringList('CACHE_URLS', [])) {
      log.raw(jsonEncode({
        'hash': hash,
        'len': _getString('CACHE_VAL_$hash', '').length,
        'ttl': _getInt('CACHE_TTL_$hash', -1),
      }));
    }
    log.raw('}');
  }

  int _toggleDarkModePressed = 0;
  int _lastToggleDarkModePress = 0;

  void toggleDarkModePressed() {
    if (DateTime.now().millisecondsSinceEpoch >
        _lastToggleDarkModePress + 10000) {
      _toggleDarkModePressed = 0;
    }

    _toggleDarkModePressed++;
    _lastToggleDarkModePress = DateTime.now().millisecondsSinceEpoch;

    if (_toggleDarkModePressed > 9 &&
        highContrast &&
        parseSubjects &&
        oneClassOnly) {
      devOptionsEnabled = !devOptionsEnabled;
      _toggleDarkModePressed = 0;
    }
  }

  bool get highContrast => _getBool('alttheme', false);

  set highContrast(bool i) => _setBool('alttheme', i);

  String get username => _getString('dsbuser', '');

  set username(String s) => _setString('dsbuser', s);

  String get password => _getString('dsbpass', '');

  set password(String s) => _setString('dsbpass', s);

  String get classGrade => _getString('grade', '5').trim().toLowerCase();

  set classGrade(String s) => _setString('grade', s.trim().toLowerCase());

  void Function() setClassGrade(String? v) => () {
        if (v == null) return;
        classGrade = v;
        if ((int.tryParse(v) ?? -1) > 10) {
          classLetter = '';
        }
      };

  String get classLetter => _getString('char', 'a').trim().toLowerCase();

  set classLetter(String s) => _setString('char', s.trim().toLowerCase());

  bool get oneClassOnly => _getBool('oneclass', false);

  set oneClassOnly(bool b) => _setBool('oneclass', b);

  bool get devOptionsEnabled => _getBool('devoptions', false);

  set devOptionsEnabled(bool b) => _setBool('devoptions', b);

  bool get hapticFeedback => _getBool('hapticfeedback', true);

  set hapticFeedback(bool b) => _setBool('hapticfeedback', b);

  bool get firstLogin => _getBool('firstlogin', true);

  set firstLogin(bool b) => _setBool('firstlogin', b);

  bool get forceJsonCache => _getBool('alwaysjsoncache', false);

  set forceJsonCache(bool b) => _setBool('alwaysjsoncache', b);

  bool get useSystemTheme => _getBool('systheme', false);

  set useSystemTheme(bool b) => _setBool('systheme', b);

  String get dsbJsonCache => _getString('jsoncache', '');

  set dsbJsonCache(String s) => _setString('jsoncache', s);

  String get wpeDomain => _getString('wpedomain', '');

  set wpeDomain(String s) => _setString('wpedomain', s);

  String get savedLangCode => _getString('lang', Platform.localeName);

  set savedLangCode(String s) => _setString('lang', s);

  bool get updatePopup => _getBool('update', true);

  set updatePopup(bool b) => _setBool('update', b);

  bool get parseSubjects => _getBool('parsesubs', true);

  set parseSubjects(bool b) => _setBool('parsesubs', b);

  bool get groupByClass => _getBool('groupbyclass', true);

  set groupByClass(bool b) => _setBool('groupbyclass', b);

  int get accentIndex =>
      _getInt('accentcolor', Colors.primaries.indexOf(Colors.blue));

  set accentIndex(int c) => _setInt('accentcolor', c);

  MaterialColor get accentColor => Colors.primaries[accentIndex];

  set accentColor(MaterialColor c) => accentIndex = Colors.primaries.indexOf(c);

  Timer? _updateTimer;
  Function()? _timerFunction;

  void timerInit(Function() f) {
    _timerFunction = f;
    _updateUpdateTimer(timer);
  }

  int get timer => _getInt('timer', 15);

  set timer(int i) {
    _setInt('timer', i);
    _updateUpdateTimer(i);
  }

  void _updateUpdateTimer(int i) {
    _updateTimer?.cancel();
    _updateTimer =
        Timer.periodic(Duration(minutes: i), (_) => _timerFunction!());
  }

  Future<bool> clear() async {
    if (_prefs == null) return false;
    final success = await _prefs!.clear();
    if (success) log.info('prefs', 'Cleared SharedPreferences.');
    return success;
  }

  Brightness get brightness => isDarkMode ? Brightness.dark : Brightness.light;

  set brightness(Brightness b) {
    if (Brightness.values.length > 2) {
      log.err('AmpColors.brightness', 'more than 2 Brightness states exist.');
    }
    isDarkMode = b != Brightness.light;
    log.info('AmpColors', 'set brightness = $b');
  }

  bool get isDarkMode => _getBool('darkmode', true);

  set isDarkMode(bool b) {
    _setBool('darkmode', b);
    log.info('AmpColors', 'set isDarkMode = $isDarkMode');
  }

  ThemeData get themeData {
    var b = useSystemTheme
        ? SchedulerBinding.instance!.window.platformBrightness ==
            Brightness.dark
        : isDarkMode;
    return b
        ? ThemeData.dark().copyWith(
            dialogBackgroundColor: Color.fromARGB(0xe0, 0x10, 0x10, 0x10),
            scaffoldBackgroundColor: Colors.black,
            primaryColor: accentColor,
            accentColor: accentColor,
            toggleableActiveColor: accentColor,
            cardColor: Colors.transparent,
            colorScheme:
                ThemeData.dark().colorScheme.copyWith(primary: accentColor),
            cardTheme: CardTheme(elevation: 0),
            iconTheme: IconThemeData(color: Colors.white),
            appBarTheme: AppBarTheme(
              iconTheme: IconThemeData(color: Colors.white),
              actionsIconTheme: IconThemeData(color: Colors.white),
              elevation: 0,
              centerTitle: true,
            ),
            inputDecorationTheme:
                ThemeData.dark().inputDecorationTheme.copyWith(
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      isDense: true,
                      alignLabelWithHint: true,
                    ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
            ),
            dividerTheme: DividerThemeData(color: Colors.white38),
            snackBarTheme: SnackBarThemeData(actionTextColor: accentColor),
          )
        : ThemeData.light().copyWith(
            dialogBackgroundColor: brightAccentColor
                ? Color.fromARGB(0xe0, 0xd0, 0xd0, 0xd0)
                : Color.fromARGB(0xe0, 0xff, 0xff, 0xff),
            primaryColor: accentColor,
            accentColor: accentColor,
            toggleableActiveColor: accentColor,
            cardColor: Colors.transparent,
            colorScheme:
                ThemeData.light().colorScheme.copyWith(primary: accentColor),
            cardTheme: CardTheme(elevation: 0),
            buttonTheme: ButtonThemeData(
              buttonColor: accentColor,
              textTheme: ButtonTextTheme.primary, // <- auto-selects right color
            ),
            iconTheme: IconThemeData(color: Colors.black),
            appBarTheme: ThemeData.light().appBarTheme.copyWith(
                  iconTheme: IconThemeData(color: Colors.black),
                  actionsIconTheme: IconThemeData(color: Colors.black),
                  elevation: 0,
                  centerTitle: true,
                ),
            inputDecorationTheme:
                ThemeData.light().inputDecorationTheme.copyWith(
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      isDense: true,
                      alignLabelWithHint: true,
                    ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
            ),
            dividerTheme: DividerThemeData(color: Colors.black38),
            snackBarTheme: SnackBarThemeData(actionTextColor: accentColor),
          );
  }
}
