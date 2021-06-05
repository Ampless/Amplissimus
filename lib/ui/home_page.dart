import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pedantic/pedantic.dart';
import 'package:update/update.dart';
import '../appinfo.dart';
import '../constants.dart';
import '../dsbapi.dart' as dsb;
import '../langs/language.dart';
import '../logging.dart' as log;
import '../main.dart';
import '../touch_bar.dart';
import '../uilib.dart';
import '../wpemails.dart';
import 'settings.dart';

class AmpHomePage extends StatefulWidget {
  AmpHomePage(this.initialIndex, {Key? key}) : super(key: key);
  final int initialIndex;

  @override
  AmpHomePageState createState() => AmpHomePageState();
}

var _checkForUpdates = !Platform.isAndroid;

class AmpHomePageState extends State<AmpHomePage>
    with SingleTickerProviderStateMixin {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  late TabController tabController;

  Future<void> checkBrightness() async {
    if (!prefs.useSystemTheme) return;
    prefs.brightness = SchedulerBinding.instance!.window.platformBrightness;
    await dsb.updateWidget(useJsonCache: true);
    rebuild();
    rebuildWholeApp();
  }

  @override
  void initState() {
    log.info('AmpHomePageState', 'initState()');

    if (SchedulerBinding.instance != null) checkBrightness();
    SchedulerBinding.instance?.window.onPlatformBrightnessChanged =
        checkBrightness;

    super.initState();

    tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialIndex);
    prefs.timerInit(rebuildDragDown);

    // initTouchBar(tabController);

    (() async {
      if (Platform.isAndroid || !prefs.updatePopup) return;
      log.info('UN', 'Searching for updates...');
      _checkForUpdates = false;
      final update = await UpdateInfo.getFromGitHub(
        '$AMP_GH_ORG/$AMP_APP',
        appVersion,
        http.get,
      );
      if (update != null) {
        log.info('UN', 'Found an update, displaying the dialog.');
        await showSimpleDialog(
          context,
          title: AmpText(Language.current.update),
          content: (context) =>
              Text(Language.current.plsUpdate(appVersion, update.version)),
          actions: (context) => [
            DialogButton(context, Language.current.dismiss),
            DialogButton(context, Language.current.update,
                onPressed: () => ampOpenUrl(update.url))
          ],
        );
      }
    })();
  }

  void rebuild() {
    try {
      setState(() {});
      log.info('AmpApp', 'rebuilt!');
    } catch (e) {
      log.err(['AmpHomePageState', 'rebuild'], e);
    }
  }

  Future<Null> rebuildDragDown({bool useCtx = true}) async {
    unawaited(_refreshKey.currentState?.show());
    final d = dsb.updateWidget(context: useCtx ? context : null);
    await wpemailUpdate();
    await d;
    rebuild();
  }

  int _lastUpdate = 0;

  @override
  Widget build(BuildContext context) {
    try {
      log.info('AmpHomePageState', 'Building HomePage...');
      if (_lastUpdate <
          DateTime.now()
              .subtract(Duration(minutes: prefs.timer))
              .millisecondsSinceEpoch) {
        rebuildDragDown();
        _lastUpdate = DateTime.now().millisecondsSinceEpoch;
      }
      final tabs = [
        RefreshIndicator(
          key: _refreshKey,
          onRefresh: rebuildDragDown,
          child: ListView(
            children: [
              dsb.widget(context),
              wpemailsave.isNotEmpty ? Divider(height: 20) : emptyWidget,
              wpemailsave.isNotEmpty ? WPEmails() : emptyWidget,
            ],
          ),
        ),
        Settings(this),
      ];

      return Scaffold(
        appBar: EmptyAmpAppBar(),
        body: WillPopScope(
          onWillPop: () async {
            FocusScope.of(context).unfocus();
            return false;
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AmpTabBar(
                [
                  Tab(text: Language.current.start),
                  Tab(text: Language.current.settings),
                ],
                tabController,
              ),
              Flexible(
                child: TabBarView(
                  controller: tabController,
                  physics: ClampingScrollPhysics(),
                  children: tabs,
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      log.err('AmpHomePageState', e);
      return AmpText(log.errorString(e));
    }
  }
}
