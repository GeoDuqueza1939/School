//==============================================================
// Program Name:  TASSY: The Task Assistant System
// Description:   A simple task list application
// Author:        Geovani P. Duqueza
//==============================================================

import 'package:flutter/material.dart';
import 'package:string_to_color/string_to_color.dart';
import 'package:window_size/window_size.dart';

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
  TassyAppState createState() => TassyAppState();
}

class TassyMain extends StatefulWidget {
  const TassyMain({super.key});

  @override
  TassyMainState createState() => TassyMainState();
}

class TassySettings extends StatefulWidget {
  const TassySettings({super.key});

  @override
  TassySettingsState createState() => TassySettingsState();
}

class TassyTaskEditor extends StatefulWidget {
  final EditorMode mode;

  const TassyTaskEditor(this.mode, {super.key});

  @override
  TassyTaskEditorState createState() => TassyTaskEditorState();
}
// #endregion

// #region States
class TassyAppState extends State<TassyApp> {
  Map<String, ThemeData> themes = {}, darkThemes = {};
  ThemeMode themeMode = ThemeMode.light;
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

class TassyMainState extends State<TassyMain> {
  List<Widget> pages = [];
  // ignore: prefer_final_fields
  int _currentPage = 0;

  TassyMainState() {
    generatePages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.findAncestorWidgetOfExactType<TassyApp>()!.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: Drawer(
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
                viewPage(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.add_task_rounded),
              title: Text("New Task"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TassyTaskEditor(EditorMode.add)));
              },
            ),
            ListTile(
              leading: Icon(Icons.task_rounded),
              title: Text("View Tasks"),
              onTap: () {
                viewPage(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("User Profile"),
              onTap: () {
                viewPage(2);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings_rounded),
              title: Text("Settings"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TassySettings()));
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app_rounded),
              title: Text("Exit"),
            ),
          ],
        ),
      ),
      body: Container(
        // decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer),
        // margin: EdgeInsets.all(0),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.all(10),
            child: pages[_currentPage],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Theme: ${(context.findAncestorStateOfType<TassyAppState>() as TassyAppState).selectedThemeName}"),
        onPressed: () {
          TassyAppState appState = context.findAncestorStateOfType<TassyAppState>() as TassyAppState;
          Iterator<String> it = appState.seedColors.keys.iterator;
          while (it.moveNext()) {
            if (appState.selectedThemeName == it.current) {
              setState(() {
                if (it.moveNext()) {
                  appState.selectTheme(it.current);
                }
                else {
                  appState.selectTheme(appState.seedColors.keys.first);
                }
              });
              break;
            }
          }
        },
      ),
    );
  }

  void generatePages() {
    pages = [
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

  void viewPage(int num) 
  {
    setState(() {
      Navigator.pop(context);
      _currentPage = num;
    });
  }
}

class TassySettingsState extends State<TassySettings> {
  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
    );
  }
}

class TassyTaskEditorState extends State<TassyTaskEditor> {
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