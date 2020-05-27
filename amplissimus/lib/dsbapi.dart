import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:amplissimus/logging.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

const String DSB_BUNDLE_ID = "de.heinekingmedia.dsbmobile";
const String DSB_DEVICE = "SM-G935F";
const String DSB_VERSION = "2.5.9";
const String DSB_OS_VERSION = "28 8.0";
const String DSB_LANGUAGE = "de";
const String DSB_WEBSERVICE = 'https://app.dsbcontrol.de/JsonHandler.ashx/GetData';

String removeLastChars(String s, int n) {
  return s.substring(0, s.length - n);
}

Future<http.Response> httpPost(String url, dynamic body, {Map<String, String> headers}) {
  ampLog(ctx: 'DSBHTTP', message: 'Posting to "$url" with headers "$headers": $body');
  return http.post(url, body: body, headers: headers);
}

Future<http.Response> httpGet(String url) {
  ampLog(ctx: 'DSBHTTP', message: 'Getting from "$url"...');
  return http.get(url);
}

class DsbAccount {
  String username;
  String password;

  DsbAccount(this.username, this.password);

  Future<String> getData() async {
    String datetime = removeLastChars(DateTime.now().toIso8601String(), 3) + 'Z';
    String uuid = new Uuid().v4();
    String json = '{"UserId":"$username","UserPw":"$password","AppVersion":"$DSB_VERSION","Language":"$DSB_LANGUAGE","OsVersion":"$DSB_OS_VERSION","AppId":"$uuid","Device":"$DSB_DEVICE","BundleId":"$DSB_BUNDLE_ID","Date":"$datetime","LastUpdate":"$datetime"}';
    http.Response res = await httpPost(DSB_WEBSERVICE, '{"req": {"Data": "${base64.encode(gzip.encode(utf8.encode(json)))}", "DataType": 1}}', headers: HashMap.fromEntries([MapEntry<String, String>("content-type", "application/json")]));
    var jsonResponse = jsonDecode(res.body);
    assert(jsonResponse is Map);
    assert(jsonResponse.containsKey('d'));
    return utf8.decode(gzip.decode(base64.decode(jsonResponse['d'])));
  }
}

class DsbSubstitution {
  String affectedClass;
  String hour;
  String teacher;
  String subject;
  String notes;

  DsbSubstitution(this.affectedClass, this.hour, this.teacher, this.subject, this.notes);

  static DsbSubstitution fromElements(dom.Element affectedClass, dom.Element hour, dom.Element teacher, dom.Element subject, dom.Element notes) {
    return DsbSubstitution(ihu(affectedClass), ihu(hour), ihu(teacher), ihu(subject), ihu(notes));
  }
  static DsbSubstitution fromElementArray(List<dom.Element> elements) {
    return fromElements(elements[0], elements[1], elements[2], elements[3], elements[4]);
  }

  static String ihu(dom.Element e) {
    return HtmlUnescape().convert(e.innerHtml).replaceAll(RegExp(r'</?.+?>', caseSensitive: false), '');
  }

  String toString() {
    return "['$affectedClass', '$hour', '$teacher', '$subject', '$notes']";
  }
}

Future<Map<String, String>> dsbGetHtml(String json) async {
  Map<String, String> map = HashMap<String, String>();
  for (var plan in jsonDecode(json)['ResultMenuItems'][0]['Childs'][0]['Root']['Childs'])
    map[plan['Title']] = (await httpGet(plan['Childs'][0]['Detail'])).body;
  return map;
}

List<DsbSubstitution> dsbGetSubs(String body) {
  List<dom.Element> html = HtmlParser(body).parse()
                       .children[0].children[1].children[1]
                       .children[2].children[0].children[0].children;
  List<DsbSubstitution> subs = [];
  for(int i = 1; i < html.length; i++) {
    subs.add(DsbSubstitution.fromElementArray(html[i].children));
  }
  return subs;
}

Future<Map<String, List<DsbSubstitution>>> dsbGetAllSubs(String username, String password) async {
  Map<String, List<DsbSubstitution>> map = new HashMap<String, List<DsbSubstitution>>();
  String json = await DsbAccount(username, password).getData();
  Map<String, String> htmls = await dsbGetHtml(json);
  htmls.forEach((title, url) {
    map[title] = dsbGetSubs(url);
  });
  return map;
}

Map<String, List<DsbSubstitution>> dsbSearchClass(Map<String, List<DsbSubstitution>> allSubs, String stage, String letter) {
  stage = stage.toLowerCase();
  letter = letter.toLowerCase();
  Map<String, List<DsbSubstitution>> map = {};
  allSubs.forEach((key, value) {
    List<DsbSubstitution> subs = [];
    for(DsbSubstitution sub in value) {
      String affClass = sub.affectedClass.toLowerCase();
      if(affClass.contains(stage) && affClass.contains(letter)) {
        subs.add(sub);
      }
    }
    map[key] = subs;
  });
  return map;
}

Table dsbGetTable(String title, List<DsbSubstitution> subs) {
  ampLog(ctx: 'DSBAcc', message: 'creating dsbtable');
  List<TableRow> rows = [
    TableRow(children: [ Text(' '), Container(), Container(), Container(), Container() ]),
    TableRow(children: [ Text(' '), Container(), Container(), Container(), Container() ]),
    TableRow(children: [ Text(title), Container(), Container(), Container(), Container() ]),
    TableRow(children: [ Text('Klasse'), Text('Stunde'), Text('Lehrer*in'), Text('Fach'), Container() ])
  ];
  for(DsbSubstitution sub in subs) {
    rows.add(TableRow(children: [
      Text(sub.affectedClass),
      Text(sub.hour),
      Text(sub.teacher),
      Text(sub.subject),
      Text(sub.notes)
    ]));
  }
  return Table(
    //border: TableBorder(
    //  bottom: BorderSide(width: 2),
    //  left: BorderSide(width: 2),
    //  right: BorderSide(width: 2),
    //  top: BorderSide(width: 2),
    //  horizontalInside: BorderSide(width: 2),
    //  verticalInside: BorderSide(width: 2)
    //),
    children: rows
  );
}

List<Table> dsbGetTables(Map<String, List<DsbSubstitution>> allSubs) {
  List<Table> tables = [];
  allSubs.forEach((title, subs) {
    tables.add(dsbGetTable(title, subs));
  });
  return tables;
}

Table joinTables(List<Table> tables) {
  if(tables.length == 0) return Table();
  List<TableRow> rows = [];
  for(Table t in tables) {
    rows.addAll(t.children);
  }
  return Table(border: tables[0].border, children: rows);
}

Future<Widget> dsbGetWidget() async {
  return joinTables(dsbGetTables(dsbSearchClass(await dsbGetAllSubs('158681', '***'), '06', 'c')));
}

