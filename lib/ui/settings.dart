import 'dart:convert';
import 'package:universal_io/io.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../appinfo.dart';
import '../constants.dart';
import '../dsbapi.dart' as dsb;
import '../langs/language.dart';
import '../logging.dart' as log;
import '../main.dart';
import '../touch_bar.dart';
import '../uilib.dart';
import 'first_login.dart';

import 'home_page.dart';

class Settings extends StatefulWidget {
  final AmpHomePageState parent;

  Settings(this.parent);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late AmpFormField _usernameFormField;
  late AmpFormField _passwordFormField;
  var _hide = true;
  late AmpFormField _wpeFormField;

  _SettingsState() {
    _usernameFormField = AmpFormField.username(
      onChange: () => widget.parent.rebuildDragDown(useCtx: false),
      onFieldSubmitted: (_) => widget.parent.rebuildDragDown(),
    );
    _passwordFormField = AmpFormField.password(
      onChange: () => widget.parent.rebuildDragDown(useCtx: false),
      onFieldSubmitted: (_) => widget.parent.rebuildDragDown(),
    );
    _wpeFormField = AmpFormField(
      initialValue: prefs.wpeDomain,
      label: () => Language.current.wpemailDomain,
      keyboardType: TextInputType.url,
      onChanged: (field) {
        prefs.wpeDomain = field.text.trim();
        widget.parent.rebuildDragDown(useCtx: false);
      },
      onFieldSubmitted: (_) => widget.parent.rebuildDragDown(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      TextSwitch(
        text: Language.current.useSystemTheme,
        value: prefs.useSystemTheme,
        onChanged: (v) {
          setState(() => prefs.useSystemTheme = v);
          widget.parent.checkBrightness();
        },
      ),
      TextSwitch(
        text: Language.current.darkMode,
        value: prefs.isDarkMode,
        onChanged: prefs.useSystemTheme
            ? null
            : (v) async {
                prefs.toggleDarkModePressed();
                setState(() => prefs.isDarkMode = v);
                await dsb.updateWidget(useJsonCache: true, context: context);
                widget.parent.rebuild();
                rebuildWholeApp();
              },
      ),
      TextSwitch(
        text: Language.current.highContrastMode,
        value: prefs.highContrast,
        onChanged: (v) async {
          log.info('Settings', 'switching design mode');
          setState(() => prefs.highContrast = v);
          await dsb.updateWidget(useJsonCache: true, context: context);
          widget.parent.rebuild();
        },
      ),
      TextSwitch(
        text: Language.current.hapticFeedback,
        value: prefs.hapticFeedback,
        onChanged: (value) => setState(() => prefs.hapticFeedback = value),
      ),
      ListTile(
        title: Text(Language.current.selectAccentColor),
        onTap: _showColorPickerDialog,
        trailing: Padding(
          padding: EdgeInsets.only(right: 6),
          child: Icon(Icons.circle, color: prefs.accentColor, size: 28),
        ),
      ),
      Divider(),
      TextWidget(
        text: Language.current.filterPlans,
        widget: Row(mainAxisSize: MainAxisSize.min, children: [
          DropdownMenu<String>(
            value: prefs.classGrade,
            items: dsb.grades,
            onChanged: (v) {
              setState(prefs.setClassGrade(v));
              dsb.updateWidget(useJsonCache: true, context: context);
              widget.parent.rebuild();
            },
            enabled: prefs.oneClassOnly,
          ),
          ampPadding(8),
          DropdownMenu<String>(
            value: prefs.classLetter,
            items: dsb.letters,
            onChanged: (v) {
              if (v == null) return;
              setState(() => prefs.classLetter = v);
              dsb.updateWidget(useJsonCache: true, context: context);
              widget.parent.rebuild();
            },
            enabled: prefs.oneClassOnly,
          ),
          ampPadding(4),
          Switch(
            value: prefs.oneClassOnly,
            onChanged: (value) {
              setState(() => prefs.oneClassOnly = value);
              dsb.updateWidget(useJsonCache: true, context: context);
              widget.parent.rebuild();
            },
          ),
        ]),
      ),
      TextSwitch(
        text: Language.current.groupByClass,
        value: prefs.groupByClass,
        onChanged: (v) {
          setState(() => prefs.groupByClass = v);
          widget.parent.rebuildDragDown(useCtx: false);
        },
      ),
      TextSwitch(
        text: Language.current.parseSubjects,
        value: prefs.parseSubjects,
        onChanged: (v) {
          setState(() => prefs.parseSubjects = v);
          widget.parent.rebuildDragDown(useCtx: false);
        },
      ),
      Divider(),
      TextWidget(
        text: Language.current.changeLanguage,
        widget: DropdownMenu<Language>(
          value: isAprilFools
              ? Language.fromCode(prefs.savedLangCode)
              : Language.current,
          items: Language.all,
          onChanged: (v) async {
            if (v == null) return;
            setState(() => Language.current = v);
            await dsb.updateWidget(useJsonCache: true, context: context);
            widget.parent.rebuild();
            rebuildWholeApp();
            // initTouchBar(widget.parent.tabController);
          },
        ),
      ),
      Divider(),
      Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: AutofillGroup(
          child: Column(children: [
            _usernameFormField.flutter(),
            _passwordFormField.flutter(
              suffixIcon:
                  ampHidePwdBtn(_hide, () => setState(() => _hide = !_hide)),
              obscureText: _hide,
            )
          ]),
        ),
      ),
      Divider(),
      Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: _wpeFormField.flutter(),
      ),
      Divider(),
      Container(
        width: double.infinity,
        child: Center(
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async => showAboutDialog(
              context: context,
              applicationName: AMP_APP,
              applicationVersion: '$appVersion ($buildNumber)',
              applicationIcon: SvgPicture.asset('assets/logo.svg', height: 40),
              children: [Text(Language.current.appInfo)],
            ),
            child: Column(children: [
              ampIcon(Icons.info, Icons.info_outlined, 50),
              ampPadding(4),
              Text(Language.current.settingsAppInfo,
                  textAlign: TextAlign.center),
            ]),
          ),
        ),
      ),
      devOptions(),
    ]);
  }

  Widget devOptions() {
    if (!prefs.devOptionsEnabled) return emptyWidget;
    return Column(children: [
      Divider(),
      TextSwitch(
        text: 'Entwickleroptionen aktiviert',
        value: prefs.devOptionsEnabled,
        onChanged: (v) => setState(() => prefs.devOptionsEnabled = v),
      ),
      TextSwitch(
        text: 'JSON Cache erzwingen',
        value: prefs.forceJsonCache,
        onChanged: (v) => setState(() => prefs.forceJsonCache = v),
      ),
      TextSwitch(
        text: 'Update Notifier',
        value: prefs.updatePopup,
        onChanged: (v) => setState(() => prefs.updatePopup = v),
      ),
      Divider(),
      ampPadding(5),
      ampRaisedButton('Print HTTP Cache', prefs.listCache),
      ampRaisedButton(
        'Clear HTTP Cache',
        () => prefs.deleteCache((hash, val, ttl) => true),
      ),
      ampRaisedButton(
        'Set JSON Cache to Demo',
        () => prefs.dsbJsonCache = _demoCache,
      ),
      ampRaisedButton('Clear Log', () => setState(log.clear)),
      ampRaisedButton('Den Firsten einsperren',
          () => ampChangeScreen(FirstLogin(), context)),
      ampRaisedButton(
        'App-Daten löschen',
        () => showConfirmDialog(
          context,
          title: Text('App-Daten löschen'),
          content: (context) => Text('Sicher?'),
          onConfirm: () {
            prefs.clear();
            SystemNavigator.pop();
          },
        ),
      ),
      log.widget,
    ]);
  }

  void _showColorPickerDialog() {
    hapticFeedback();
    const materialColors = Colors.primaries;
    showSimpleDialog(
      context,
      content: (context) => Wrap(
        children: materialColors
            .map(
              (c) => IconButton(
                icon: Icon(Icons.circle, color: c, size: 36),
                onPressed: () {
                  hapticFeedback();
                  prefs.accentColor = c;
                  adjustStatusBarForeground();
                  widget.parent.rebuildDragDown();
                  rebuildWholeApp();
                  Navigator.pop(context);
                },
              ),
            )
            .toList(),
      ),
      actions: (_) => [],
    );
  }

  String get _demoCache => jsonEncode([
        {
          'url': 'https://example.com',
          'preview_url': 'https://example.com',
          'preview': [],
          'day': 4,
          'date': '2.4.2021 Freitag',
          'subs': [
            {
              'class': '5c',
              'lesson': 3,
              'sub_teacher': 'Häußler',
              'subject': 'D',
              'notes': '',
              'free': false,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '9b',
              'lesson': 6,
              'sub_teacher': '---',
              'subject': 'Bio',
              'notes': '',
              'free': true,
              'org_teacher': null,
              'room': null,
            }
          ]
        },
        {
          'url': 'https://example.com',
          'preview_url': 'https://example.com',
          'preview': [],
          'day': 0,
          'date': '5.4.2021 Montag',
          'subs': [
            {
              'class': '5cd',
              'lesson': 2,
              'sub_teacher': 'Wolf',
              'subject': 'Kath',
              'notes': '',
              'free': false,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '6b',
              'lesson': 5,
              'sub_teacher': 'Gnan',
              'subject': 'Kath',
              'notes': '',
              'free': false,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '6c',
              'lesson': 3,
              'sub_teacher': 'Albl',
              'subject': 'E',
              'notes': '',
              'free': false,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '6c',
              'lesson': 4,
              'sub_teacher': 'Fikrle',
              'subject': 'E',
              'notes': '',
              'free': false,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '6c',
              'lesson': 6,
              'sub_teacher': '---',
              'subject': 'Frz',
              'notes': '',
              'free': true,
              'org_teacher': null,
              'room': null,
            },
            {
              'class': '9c',
              'lesson': 6,
              'sub_teacher': '---',
              'subject': 'E',
              'notes': '',
              'free': true,
              'org_teacher': null,
              'room': null,
            }
          ]
        }
      ]);
}
