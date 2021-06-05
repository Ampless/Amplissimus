import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:universal_io/io.dart';

import '../constants.dart';
import '../dsbapi.dart' as dsb;
import '../langs/language.dart';
import '../logging.dart' as log;
import '../main.dart';
import '../uilib.dart';
import 'home_page.dart';

class FirstLogin extends StatefulWidget {
  @override
  _FirstLoginState createState() => _FirstLoginState();
}

class _FirstLoginState extends State<FirstLogin> {
  bool _loading = false;
  Object _error = '';
  bool _hide = true;
  final _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final _usernameFormField = AmpFormField.username(
        onFieldSubmitted: (_) => _passwordFocusNode.requestFocus());
    final _passwordFormField = AmpFormField.password(
      focusNode: _passwordFocusNode,
      onFieldSubmitted: (_) => _submitLogin(),
    );
    if (prefs.classLetter.isEmpty) prefs.classLetter = dsb.letters.first;
    if (prefs.classGrade.isEmpty) prefs.classGrade = dsb.grades.first;
    return Scaffold(
      appBar: ampTitle(AMP_APP),
      body: Container(
        child: ListView(children: [
          ampPadding(
            10,
            Column(children: [
              AutofillGroup(
                child: Column(children: [
                  _usernameFormField.flutter(),
                  _passwordFormField.flutter(
                    suffixIcon: ampHidePwdBtn(
                        _hide, () => setState(() => _hide = !_hide)),
                    obscureText: _hide,
                  ),
                ]),
              ),
              Divider(),
              TextWidget(
                text: Language.current.changeLanguage,
                widget: DropdownMenu<Language>(
                  value: Language.current,
                  items: Language.all,
                  onChanged: (v) => setState(() {
                    if (v == null) return;
                    Language.current = v;
                  }),
                ),
              ),
              Divider(),
              ampErrorText(_error is DsbException
                  ? Language.current.dsbError(_error)
                  : _error.toString()),
            ]),
          )
        ]),
      ),
      bottomSheet: _loading
          ? LinearProgressIndicator(semanticsLabel: 'Loading')
          : emptyWidget,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 0,
        onPressed: () => {hapticFeedback(), _submitLogin()},
        highlightElevation: 0,
        label: Text(Language.current.save),
        icon: ampIcon(Icons.save, Icons.save_outlined),
      ),
    );
  }

  Future<void> _submitLogin() async {
    setState(() => _loading = true);
    try {
      await getAllSubs(
        prefs.username,
        prefs.password,
        http: http,
        endpoint: Platform.operatingSystem.toLowerCase().contains('web')
            ? 'https://proxy.amplissimus.chrissx.de/'
            : 'https://mobileapi.dsbcontrol.de',
      );

      await dsb.updateWidget();

      setState(() {
        _loading = false;
        _error = '';
      });

      prefs.firstLogin = false;
      return ampChangeScreen(AmpHomePage(0), context);
    } catch (e) {
      log.err('FLP', e);
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }
}
