import 'dart:async';
import 'package:universal_io/io.dart';

import 'package:url_launcher/link.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

import 'langs/language.dart';
import 'logging.dart' as log;
import 'main.dart';
import 'subject.dart';
import 'uilib.dart';

Widget _classWidget(List<Substitution> subs) {
  final mappedSubs = <String, List<Substitution>>{};
  for (final s in subs) {
    if (!mappedSubs.containsKey(s.affectedClass)) {
      mappedSubs[s.affectedClass] = [];
    }
    mappedSubs[s.affectedClass]!.add(s);
  }
  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: mappedSubs.entries.map((entry) {
      var firstEntry = true;
      return [
        ampList(entry.value.map((s) {
          final lol = _renderSub(s, firstEntry);
          firstEntry = false;
          return lol;
        }).toList()),
        Container(height: 12),
      ];
    }).reduce((v, e) => [...v, ...e]),
  );
}

Widget _renderPlans(List<Plan> plans, BuildContext context) {
  log.info('DSB', 'Rendering plans');
  final widgets = <Widget>[];
  for (final plan in plans) {
    final dayWidget = plan.subs.isEmpty
        ? ampList([ListTile(title: AmpText(Language.current.noSubs))])
        : prefs.groupByClass
            ? _classWidget(plan.subs)
            : ampList(plan.subs.map((s) => _renderSub(s, true)).toList());
    final warn = outdated(plan.date, DateTime.now());
    widgets.add(
      ListTile(
        title: Row(children: [
          AmpText(' ${Language.current.dayToString(plan.day)}', size: 24),
          IconButton(
            icon: warn
                ? ampIcon(Icons.warning, Icons.warning_amber_outlined)
                : ampIcon(Icons.info, Icons.info_outline),
            tooltip: warn
                ? Language.current.warnWrongDate(plan.date)
                : plan.date.split(' ').first,
            onPressed: () {
              hapticFeedback();
              showSnackBar(
                context,
                AmpText(warn
                    ? Language.current.warnWrongDate(plan.date)
                    : plan.date),
              );
            },
            padding: EdgeInsets.fromLTRB(4, 4, 2, 4),
          ),
          Link(
            uri: Uri.parse(plan.url),
            builder: (_, followLink) => IconButton(
              icon: ampIcon(Icons.open_in_new, Icons.open_in_new_outlined),
              tooltip: Language.current.openPlanInBrowser,
              onPressed: followLink != null
                  ? () => {hapticFeedback(), followLink()}
                  : null,
              padding: EdgeInsets.fromLTRB(4, 4, 2, 4),
            ),
          ),
        ]),
      ),
    );
    widgets.add(dayWidget);
  }
  log.info('DSB', 'Done rendering plans.');
  return Column(children: widgets);
}

List<Plan> _plans = [];
Widget widget(BuildContext context) => _renderPlans(_plans, context);

void snackBarErrorHandle(BuildContext context, Object e) {
  if (e is DsbException) {
    showSnackBar(context, AmpText(Language.current.dsbError(e)));
  } else if (e is SocketException) {
    showSnackBar(context, AmpText(Language.current.internetConnectionFail));
  } else {
    showSnackBar(
        context, AmpText('${Language.current.error}: (${e.toString()})'));
  }
}

Future<List<Plan>> _getPlans(bool useJsonCache, {BuildContext? context}) async {
  try {
    if (useJsonCache) return Plan.plansFromJsonString(prefs.dsbJsonCache);
  } catch (e) {
    log.err(['DSB', '_getPlans'], e);
    if (context != null) snackBarErrorHandle(context, e);
  }
  try {
    final plans = await getAllSubs(
      prefs.username,
      prefs.password,
      http: http,
      endpoint: Platform.operatingSystem.toLowerCase().contains('web')
          ? 'https://proxy.amplissimus.chrissx.de/'
          : 'https://mobileapi.dsbcontrol.de',
    );
    prefs.dsbJsonCache = Plan.plansToJsonString(plans);
    return plans;
  } catch (e) {
    log.err(['DSB', '_getPlans'], e);
    if (context != null) snackBarErrorHandle(context, e);
    return Plan.plansFromJsonString(prefs.dsbJsonCache);
  }
}

Future<Null> updateWidget(
    {BuildContext? context, bool useJsonCache = false}) async {
  try {
    final fjc = prefs.forceJsonCache;
    final ujc = useJsonCache;
    final unc = fjc || ujc;
    log.info(
        ['DSB', 'updateWidget'], 'Getting plans with $fjc || $ujc => $unc');
    var plans = await _getPlans(unc, context: context);

    if (prefs.oneClassOnly) {
      plans = Plan.searchInPlans(
          plans,
          (sub) =>
              sub.affectedClass.contains(prefs.classGrade) &&
              sub.affectedClass.contains(prefs.classLetter));
    }
    for (final plan in plans) {
      plan.subs.sort();
    }
    _plans = plans;
  } catch (e) {
    log.err(['DSB', 'updateWidget'], e);
    if (context != null) snackBarErrorHandle(context, e);
  }
}

bool outdated(String date, DateTime now, {BuildContext? context}) {
  try {
    final raw = date.split(' ').first.split('.');
    return now.isAfter(DateTime(
      int.parse(raw[2]),
      int.parse(raw[1]),
      int.parse(raw[0]),
    ).add(Duration(days: 3)));
  } catch (e) {
    log.err(['DSB', 'outdated'], e);
    if (context != null) snackBarErrorHandle(context, e);
    return false;
  }
}

Widget _renderSub(Substitution sub, bool displayClass) {
  final subject = parseSubject(sub.subject);
  final title = sub.orgTeacher == null || sub.orgTeacher!.isEmpty
      ? subject
      : '$subject – ${sub.orgTeacher}';

  return ListTile(
    horizontalTitleGap: 4,
    title: AmpText(title, size: 18),
    leading: Padding(
      padding: EdgeInsets.only(left: sub.lesson > 9 ? 1 : 6, top: 5),
      child: AmpText(sub.lesson, size: 28, weight: FontWeight.bold),
    ),
    subtitle: AmpText(Language.current.dsbSubToSubtitle(sub), size: 16),
    trailing: displayClass
        ? AmpText(sub.affectedClass, weight: FontWeight.bold, size: 18)
        : null,
  );
}

//this is a really bad place to put this, but we can fix that later
List<String> get grades => ['5', '6', '7', '8', '9', '10', '11', '12', '13'];
List<String> get letters => ['', 'a', 'b', 'c', 'd', 'e', 'f', 'g'];
