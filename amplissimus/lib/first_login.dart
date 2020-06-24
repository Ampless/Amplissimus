import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/langs/language.dart';
import 'package:Amplissimus/main.dart';
import 'package:Amplissimus/values.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/widgets.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class FirstLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        builder: (context, child) {
          return ScrollConfiguration(behavior: MyBehavior(), child: child);
        },
        title: AmpStrings.appTitle,
        theme: ThemeData(
          canvasColor: Prefs.designMode ? AmpColors.primaryBlack : AmpColors.primaryWhite,
          primarySwatch: AmpColors.primaryBlack,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FirstLoginScreenPage(title: AmpStrings.appTitle, textStyle: TextStyle(
          color: AmpColors.colorForeground,
        ),),
      ), 
      onWillPop: () async {
        if(FirstLoginValues.tabController.index <= 0) return false;
        else FirstLoginValues.tabController.animateTo(FirstLoginValues.tabController.index-1);
        return false;
      }
    );
  }
}
class FirstLoginScreenPage extends StatefulWidget {
  FirstLoginScreenPage({this.title, this.textStyle});
  final String title;
  final TextStyle textStyle;
  @override
  State<StatefulWidget> createState() {return FirstLoginScreenPageState();}
}
class FirstLoginScreenPageState extends State<FirstLoginScreenPage> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool credentialsAreLoading = false;
  bool dsbWidgetIsLoading = false;
  bool isError = false;
  String textString = '';
  String animString = 'intro';
  String gradeDropDownValue = Prefs.grade.trim().toLowerCase();
  String letterDropDownValue = Prefs.char.trim().toLowerCase();

  @override
  void initState() {
    if(Prefs.char.trim().toLowerCase().isEmpty)
      letterDropDownValue = CustomValues.lang.classSelectorEmpty;
    if(Prefs.grade.trim().toLowerCase().isEmpty)
      gradeDropDownValue = CustomValues.lang.classSelectorEmpty;
    FirstLoginValues.tabController = TabController(length: 2, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: FirstLoginValues.tabController,
        children: <Widget> [
          AnimatedContainer(duration: Duration(seconds: 1), color: AmpColors.colorBackground,
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: Text(CustomValues.lang.settingsChangeLoginPopup, style: TextStyle(color: AmpColors.colorForeground, fontSize: 25),),
                centerTitle: true,
              ),
              body: Center(
                heightFactor: 1,
                child: Container(margin: EdgeInsets.all(20), child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(CustomValues.lang.settingsSelectClass, style: TextStyle(color: AmpColors.colorForeground, fontSize: 20),),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      DropdownButton(
                        underline: Container(
                          height: 2,
                          color: AmpColors.colorForeground,
                        ),
                        style: TextStyle(color: AmpColors.colorForeground),
                        value: gradeDropDownValue,
                        items: FirstLoginValues.grades.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            gradeDropDownValue = value;
                            if(gradeDropDownValue == CustomValues.lang.classSelectorEmpty)
                              Prefs.grade = '';
                            else
                              Prefs.grade = value;
                          });
                        },
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                      DropdownButton(
                        underline: Container(
                          height: 2,
                          color: AmpColors.colorForeground,
                        ),
                        style: TextStyle(color: AmpColors.colorForeground),
                        value: letterDropDownValue,
                        items: FirstLoginValues.letters.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            letterDropDownValue = value;
                            if(letterDropDownValue == CustomValues.lang.classSelectorEmpty)
                              Prefs.char = '';
                            else Prefs.char = value;
                          });
                        },
                      ),
                    ]),
                    Divider(color: AmpColors.colorForeground, height: 20,),
                    
                    Padding(padding: EdgeInsets.all(4)),
                    TextFormField(
                      style: TextStyle(color: AmpColors.colorForeground),
                      controller: FirstLoginValues.usernameInputFormController,
                      key: FirstLoginValues.usernameInputFormKey,
                      validator: Widgets.textFieldValidator,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AmpColors.colorForeground, width: 1.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AmpColors.colorForeground, width: 2.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(color: AmpColors.colorForeground),
                        labelText: CustomValues.lang.settingsChangeLoginPopupUsername,
                        fillColor: AmpColors.colorForeground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                          BorderSide(color: AmpColors.colorForeground)
                        )
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(6)),
                    TextFormField(
                      style: TextStyle(color: AmpColors.colorForeground),
                      controller: FirstLoginValues.passwordInputFormController,
                      key: FirstLoginValues.passwordInputFormKey,
                      validator: Widgets.textFieldValidator,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: AmpColors.colorForeground),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AmpColors.colorForeground, width: 1.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AmpColors.colorForeground, width: 2.0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelText: CustomValues.lang.settingsChangeLoginPopupPassword,
                        fillColor: AmpColors.colorForeground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AmpColors.colorForeground),
                        )
                      ),
                    ),
                    Divider(color: AmpColors.colorForeground, height: 20),

                    Padding(padding: EdgeInsets.all(4)),
                    Text(CustomValues.lang.settingsChangeLanguage, style: TextStyle(color: AmpColors.colorForeground, fontSize: 20)),
                    DropdownButton(
                      underline: Container(
                        height: 2,
                        color: Colors.white,
                      ),
                      style: TextStyle(color: AmpColors.colorForeground),
                      value: CustomValues.lang,
                      items: Language.all.map<DropdownMenuItem<Language>>((value) {
                        return DropdownMenuItem<Language>(value: value, child: Text(value.name));
                      }).toList(),
                      onChanged: (value) => setState(() {
                        CustomValues.lang = value;
                      }),
                    ),
                    Divider(color: AmpColors.colorForeground, height: 20,),
                    Padding(padding: EdgeInsets.all(10)),
                    Divider(color: Colors.transparent, height: 30),
                    AnimatedDefaultTextStyle(
                      child: Text(textString), 
                      style: TextStyle(color: Colors.redAccent, fontSize: isError ? 20 : 0),
                      duration: Duration(milliseconds: 350)
                    ),
                  ],
                ),),
              ),
              bottomSheet: credentialsAreLoading 
                ? LinearProgressIndicator(
                  backgroundColor: AmpColors.colorBackground, 
                  valueColor: AlwaysStoppedAnimation<Color>(AmpColors.colorForeground),
                ) : Container(height: 0,),
              floatingActionButton: FloatingActionButton.extended(
                elevation: 0,
                onPressed: () async {
                  bool condA = FirstLoginValues.passwordInputFormKey.currentState.validate();
                  bool condB = FirstLoginValues.usernameInputFormKey.currentState.validate();
                  if(!condA || !condB) return;
                  setState(() => credentialsAreLoading = true);
                  try {
                    Prefs.username = FirstLoginValues.usernameInputFormController.text.trim();
                    Prefs.password = FirstLoginValues.passwordInputFormController.text.trim();
                    await dsbUpdateWidget(() {});
                    isError = true;
                    setState(() => {credentialsAreLoading = false, textString = ''});
                    FocusScope.of(context).unfocus();
                    FirstLoginValues.tabController.animateTo(1);
                  } catch(e) {
                    setState(() {
                      credentialsAreLoading = false;
                      textString = errorString(e);
                      isError = true;
                    });
                  }
                }, 
                backgroundColor: AmpColors.colorBackground,
                splashColor: AmpColors.colorForeground,
                label: Text(CustomValues.lang.settingsChangeLoginPopupSave, style: widget.textStyle),
                icon: Icon(Icons.save, color: AmpColors.colorForeground,),
              ),
            ),
          ),
          Stack(children: [
            Container(child: FlareActor(
              'assets/anims/get_ready.flr',
              animation: animString,
              callback: (name) {
                if(name.trim().toLowerCase() == 'idle') setState(() => animString = 'idle2');
                else setState(() => animString = 'idle');
              },
            ), color: Colors.black,),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: Text(AmpStrings.appTitle, style: TextStyle(fontSize: 24, color: Colors.white),),
                centerTitle: true,
              ),
              floatingActionButton: FloatingActionButton.extended(
                elevation: 0,
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  Prefs.firstLogin = false;
                  setState(() => dsbWidgetIsLoading = false);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp(initialIndex: 0)));
                },
                backgroundColor: AmpColors.colorBackground,
                splashColor: AmpColors.colorForeground,
                label: Text(CustomValues.lang.firstStartupDone, style: widget.textStyle),
                icon: Icon(MdiIcons.arrowRight, color: AmpColors.colorForeground,),
              ),
              bottomSheet: dsbWidgetIsLoading 
                ? LinearProgressIndicator(
                  backgroundColor: AmpColors.colorBackground, 
                  valueColor: AlwaysStoppedAnimation<Color>(AmpColors.colorForeground),
                ) : Container(height: 0),
            ),
          ]),
        ]
      )
    );
  }

}

class FirstLoginValues {
  static final usernameInputFormKey = GlobalKey<FormFieldState>();
  static final passwordInputFormKey = GlobalKey<FormFieldState>();
  static final usernameInputFormController = TextEditingController(text: Prefs.username);
  static final passwordInputFormController = TextEditingController(text: Prefs.password);
  static TabController tabController;

  static final List<String> grades = [CustomValues.lang.classSelectorEmpty,'5','6','7','8','9','10','11','12','13'];
  static final List<String> letters = [CustomValues.lang.classSelectorEmpty,'a','b','c','d','e','f','g','q'];
}
