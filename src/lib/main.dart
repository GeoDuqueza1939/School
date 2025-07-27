//==============================================================
// Program Name:  TASSY: The Task Assistant System
// Description:   A simple task list application
// Author:        Geovani P. Duqueza
//==============================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:string_to_color/string_to_color.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

void main() {
  final String appTitle = "TASSY: The Task Assistant System";
  final String title = "TASSY";

  runApp(TassyApp(title: title, appTitle: appTitle));

  WidgetsFlutterBinding.ensureInitialized();
  setWindowTitle(appTitle);
}

// #region Widgets
class TassyApp extends StatefulWidget {
  final String title;
  final String appTitle;

  const TassyApp({super.key, required this.title, required this.appTitle});

  @override
  State<TassyApp> createState() => _TassyAppState();
}

class TassyMain extends StatefulWidget {
  const TassyMain({super.key});

  @override
  State<TassyMain> createState() => _TassyMainState();
}

class TassySettings extends StatefulWidget {
  const TassySettings({super.key});

  @override
  State<TassySettings> createState() => _TassySettingsState();
}

class TassyTaskEditor extends StatefulWidget {
  final EditorMode mode;

  const TassyTaskEditor(this.mode, {super.key});

  @override
  State<TassyTaskEditor> createState() => _TassyTaskEditorState();
}
// #endregion

// #region States
class _TassyAppState extends State<TassyApp> {
  Map<String, ThemeData> themes = {}, darkThemes = {};
  ThemeMode themeMode = ThemeMode.dark;
  String selectedThemeName = "MEADOW";
  Map<String, String> seedColors = {
    "MEADOW": "silver",
    "SKY": "bluegreen",
    "BROWN": "red[400]",
    "PURPLE": "black",
    "MOSS": "green",
    "TEAL": "blueAccent",
    "WARM": "orange",
  };

  @override
  Widget build(BuildContext context) {
    retrieveThemes();

    return MaterialApp(
      title: widget.appTitle,
      home: const TassyMain(),
      theme: themes[(selectedThemeName == "dark" ? "bright" : selectedThemeName)],
      darkTheme: darkThemes[(selectedThemeName == "bright" ? "dark" : selectedThemeName)],
      themeMode: themeMode,
    );
  }

  void retrieveThemes() { // autogenerate themes according to the provided color seeds; other custom themes may be added after the loop
    List<String> colors = seedColors.keys.toList();

    for (String color in colors) {
      themes[color] = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorUtils.stringToColor(seedColors[color] as String), brightness: Brightness.light),
      );
      darkThemes[color] = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorUtils.stringToColor(seedColors[color] as String), brightness: Brightness.dark),
      );
    }
  }

  void selectTheme(String themeName) {
    setState(() {
      selectedThemeName = themeName;
    });
  }
}

class _TassyMainState extends State<TassyMain> with TickerProviderStateMixin, MsgBoxMixin {
  late List<Widget> _tabbedPages = [];
  late List<Tab> _tabs = [];
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabs = _generateTabs();
  }

  @override
  Widget build(BuildContext context) {
    _tabbedPages = _generateTabbedPages();
    _tabController = TabController(
      length: min(_tabs.length, _tabbedPages.length),
      vsync: this,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.findAncestorWidgetOfExactType<TassyApp>()!.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      drawer: _generateDrawer(context),
      body: TabBarView(
        controller: _tabController,
        children: _tabbedPages,
      ),
      floatingActionButton: _tempFAB(),
    );
  }

  Widget _generateDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary
            ),
            child: Center(
              child: Text("TASSY Menu"),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home_rounded),
            title: Text("Home"),
            onTap: () {
              viewTabbedPage(0);
            },
          ),
          ListTile(
            leading: Icon(Icons.add_task_rounded),
            title: Text("New Task"),
            onTap: () {
              viewRoute((context) => TassyTaskEditor(EditorMode.add));
            },
          ),
          ListTile(
            leading: Icon(Icons.task_rounded),
            title: Text("View Tasks"),
            onTap: () {
              viewTabbedPage(1);
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text("User Profile"),
            onTap: () {
              viewTabbedPage(2);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_rounded),
            title: Text("Settings"),
            onTap: () {
              viewRoute((context) => TassySettings());
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app_rounded),
            title: Text("Exit"),
            onTap: exitApp,
          ),
        ],
      ),
    );
  }

  List<Tab> _generateTabs() {
    return <Tab>[
      Tab(icon: Icon(Icons.home_rounded), text: "Home",),
      Tab(icon: Icon(Icons.task_rounded), text: "Tasks",),
      Tab(icon: Icon(Icons.account_circle), text: "User",),
    ];
  }

  List<Widget> _generateTabbedPages() {
    return <Widget>[
      Container(
        child: Text("Home"),
      ),
      Container(
        child: Text("View Tasks"),
      ),
      Container(
        child: Text("User Profile"),
      ),
    ];
  }

  void viewTabbedPage(int num) 
  {
    Navigator.pop(context);
    _tabController!.index = num;
  }

  void viewRoute(WidgetBuilder f) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: f));
  }

  void exitApp() async {
    final dev = DeviceInfoPlugin();
    final devInfo = await dev.deviceInfo;
    final allInfo = devInfo.data;

    setState(() {
      String devType = (allInfo.containsKey('servicePackMajor') ? 'Windows'
        : (allInfo.containsKey('prettyName') ? 'Linux'
        : (allInfo.containsKey('osRelease') ? 'MacOS'
        : (allInfo.containsKey('utsname') ? 'IOS'
        : (allInfo.containsKey('systemFeatures') ? 'Android'
        : (allInfo.containsKey('browserName') ? 'Web'
        : 'unknown'))))));
          
      switch (devType) {
        case 'Windows': case 'Linux': case 'MacOS':
          exit(0); // REPLACE WITH A SAFER EXIT OPTION ONCE AVAILABLE!!!!
          // ignore: dead_code
          break;
        case 'IOS': case 'Android':
          SystemNavigator.pop();
          break;
        case 'Web': case 'unknown':
          Navigator.pop(context);
          _simpleMsg(context, 'To close this app, please close the browser tab or window manually.', title: (context.findAncestorWidgetOfExactType<TassyApp>() as TassyApp).title);
          break;
      }
    });
  }
  
  FloatingActionButton _tempFAB() { // FOR TESTING ONLY
    _TassyAppState appState = context.findAncestorStateOfType<_TassyAppState>() as _TassyAppState;

    return FloatingActionButton.extended(
      label: Text("Theme: ${(appState).selectedThemeName}"),
      onPressed: () {
        Iterator<String> it = appState.seedColors.keys.iterator;
        while (it.moveNext()) {
          if (appState.selectedThemeName == it.current) {
            setState(() {
              appState.selectTheme(it.moveNext() ? it.current : appState.seedColors.keys.first);
            });
            break;
          }
        }
      },
    )
  }
}

class _TassySettingsState extends State<TassySettings> {
  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
    );
  }
}

class _TassyTaskEditorState extends State<TassyTaskEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.mode == EditorMode.add ? "New" : "Edit"} Task"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings_rounded),
            tooltip: "App Settings",
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TassySettings()));
            },
          ),
        ],
      ),
    );
  }
}

// #endregion

// #region Dialog boxes
mixin MsgBoxMixin {
  Future _simpleMsg(BuildContext context, String msg, {String title = ""}) {
    return showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
// #endregion

// #region Data structures
enum EditorMode {
  add, edit
}

enum TimeUnit {
  second, minute, hour, day, week, month, year, decade, century, millenium
}

class TassyTask {
  String? taskName;
  String? description;
  DateTime? schedule;
  double duration;
  TimeUnit durationUnit;
  List<TassyReminder>? reminders;

  TassyTask(this.taskName, {this.description, this.schedule, this.duration = 0, this.durationUnit = TimeUnit.hour, this.reminders});
}

class TassyReminder {
  DateTime? alarm;
  double _snoozeDuration = 0; // zero means disabled snooze
  TimeUnit _snoozeUnit = TimeUnit.minute;

  TassyReminder(this.alarm, {double snoozeDuration = 0, TimeUnit snoozeUnit = TimeUnit.minute}) {
    setSnooze(snoozeDuration, unit: snoozeUnit);
  }

  void setSnooze(double duration, {TimeUnit unit = TimeUnit.minute}) {
    _snoozeDuration = duration;
    _snoozeUnit = unit;
  }

  void disableSnooze() {
    setSnooze(0);
  }

  String get snoozeDetails {
    return "$snoozeDurationString $snoozeUnitString";
  }

  double get snoozeDuration {
    return _snoozeDuration;
  }

  String get snoozeDurationString {
    return (_snoozeDuration.toInt() == _snoozeDuration ? _snoozeDuration.toInt() : _snoozeDuration).toString();
  }

  TimeUnit get snoozeUnit {
    return _snoozeUnit;
  }

  String get snoozeUnitString {
    return _snoozeUnit.name.toString() + (snoozeDuration == 1 ? "" : "s");
  }
}
// #endregion