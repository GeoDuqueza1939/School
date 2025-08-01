//==============================================================
// Program Name:  TASSY: The Task Assistant System
// Description:   A simple task list application
// Author:        Geovani P. Duqueza
//==============================================================

import 'dart:core';
import 'dart:io';
import 'dart:math';
// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as pth;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sql;
// ignore: unused_import
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:string_to_color/string_to_color.dart';
import 'package:window_size/window_size.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as dt;

void main() {
  final String appTitle = "TASSY: The Task Assistant System";
  final String title = "TASSY";

  WidgetsFlutterBinding.ensureInitialized();
  setWindowTitle(appTitle);

  runApp(TassyApp(title: title, appTitle: appTitle));
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

class TassySettings extends StatelessWidget with _AppStateMixin {
  TassySettings({super.key});
  
  @override
  Widget build(BuildContext context) {
    _TassyAppState appState = _getAppState(context);

    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: appState.darkModeSwitchValue,
              onChanged: (bool value) {
                appState.darkModeSwitchValue = value;
                appState.turnOnDarkTheme(value);
                appState.themeNames = (appState.darkModeSwitchValue ? appState.darkThemes.keys : appState.themes.keys).toList();
              },
            ),
            ListTile(
              title: Text("Select theme:"),
              tileColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              trailing: DropdownButton<String>(
                dropdownColor: Theme.of(context).colorScheme.primary,
                value: appState.selectedThemeName,
                items: appState.themeNames.map((themeName)=>DropdownMenuItem<String>(
                  value: themeName,
                  child: Text(
                    themeName,
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                )).toList(),
                onChanged: (String? value) {
                  appState.selectedThemeName = value!;
                  appState.selectTheme(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}

class TassyTaskEditor extends StatefulWidget {
  final EditorMode mode;
  final TassyTask task;

  const TassyTaskEditor(this.mode, {super.key, required this.task});

  @override
  State<TassyTaskEditor> createState() => _TassyTaskEditorState();
}

class TaskList extends StatelessWidget with _AppStateMixin {
  const TaskList({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) => TaskTile(_getAppState(context).tasks[index], this),
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemCount: _getAppState(context).tasks.length,
      // children: _getAppState(context).tasks.map((task)=>TaskTile(task, this)).toList(),
    );
  }
}

class TaskTile extends StatefulWidget {
  final TassyTask task;
  final TaskList taskList;

  const TaskTile(this.task, this.taskList, {super.key});

  @override
  State<StatefulWidget> createState()=>_TaskTileState();
}
// #endregion

// #region States
class _TassyAppState extends State<TassyApp> with _AppStateMixin, MsgBoxMixin {
  late DBController db;
  // ignore: avoid_init_to_null
  TassyUser? user = null;
  Map<String, ThemeData> themes = {}, darkThemes = {};
  ThemeMode themeMode = ThemeMode.light;
  String selectedThemeName = "SKY";
  Map<String, String> seedColors = {
    "MEADOW": "silver",
    "SKY": "bluegreen",
    "BROWN": "red[400]",
    "PURPLE": "black",
    "MOSS": "green",
    "TEAL": "blueAccent",
    "WARM": "orange",
  };
  List<TassyTask> tasks = [];
  bool dbRetrieved = false;
  late List<String> themeNames;
  bool darkModeSwitchValue = false;

  @override
  void initState() {
    super.initState();

    retrieveDatabase();
  }

  @override
  Widget build(BuildContext context) {
    retrieveThemes();
    if (dbRetrieved) {
      user = retrieveUser();
      tasks = retrieveTasks();
    }

    return MaterialApp(
      title: widget.appTitle,
      home: const TassyMain(),
      theme: themes[(selectedThemeName == "dark" ? "bright" : selectedThemeName)],
      darkTheme: darkThemes[(selectedThemeName == "bright" ? "dark" : selectedThemeName)],
      themeMode: themeMode,
    );
  }

  void retrieveDatabase() {
    db = DBController(this);
  }

  void databaseSynced() {
    setState(() {
      dbRetrieved = true;
    });
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
    themeNames = (darkModeSwitchValue ? darkThemes.keys : themes.keys).toList();
    darkModeSwitchValue = (themeMode == ThemeMode.dark);
  }

  TassyUser? retrieveUser() {
    TassyUser? user;
    sql.ResultSet results;
    int userId = -1;
    String name = "", nickname = "", position = "", officeUnit = "", company = "";

    try {
      results = db.select("user", "*");

      if (results.isNotEmpty) {
        userId = results[0]["userId"];
        name = results[0]["name"];
        nickname = results[0]["nickname"];
        position = results[0]["position"];
        officeUnit = results[0]["officeUnit"];
        company = results[0]["company"];
      }

      user = TassyUser(
        userId: userId,
        name: name,
        nickname: nickname,
        position: position,
        officeUnit: officeUnit,
        company: company,
        phoneNumbers: ["09153032914", "09295015297"],
        emailAddresses: ["geovani.duqueza@deped.gov.ph", "24-00901@g.batstate-u.edu.ph"],
      );
    }
    catch (ex) {
      debugPrint("$ex");
    }

    return user;
  }

  List<TassyTask> retrieveTasks() { // TEMPORARY DATA ONLY
    sql.ResultSet results;
    List<TassyTask> tasks = <TassyTask>[];

    TimeUnit getTimeUnit(int i)=>(i == 9 ? TimeUnit.millenium
    : (i == 8 ? TimeUnit.century
      : (i == 7 ? TimeUnit.decade
        : (i == 6 ? TimeUnit.year
          : (i == 5 ? TimeUnit.month
            : (i == 4 ? TimeUnit.week
              : (i == 3 ? TimeUnit.day
                : (i == 1 ? TimeUnit.minute
                  : (i == 0 ? TimeUnit.second
                    : TimeUnit.hour)))))))));

    try {
      results = db.select("task", "*");
      
      tasks = results.map((result) {
        TassyTask task = TassyTask(
          result["taskName"],
          taskId: result["taskId"],
          description: result["description"],
          schedule: DateTime.tryParse(result["schedule"]),
          duration: double.tryParse(result["duration"].toString()) ?? 0,
          durationUnit: getTimeUnit(int.tryParse(result["durationUnit"].toString()) ?? 2),
          reminders: [],
          done: (result["done"] != 0),
        );

        db.select(
          "reminder", "*",
          criteriaStr: "WHERE reminder.taskId = ${task.taskId}"
        ).map((reminder) {
          task.reminders.add(TassyReminder(
            DateTime.tryParse(reminder["alarm"]),
            reminderId: reminder["reminderId"],
            snoozeDuration: double.tryParse(reminder["snoozeDuration"].toString()) ?? 0,
            snoozeUnit: getTimeUnit(int.tryParse(reminder["snoozeUnit"]) ?? 2),
          ));
        });

        return task;
      }).toList();
    }
    catch (ex) {
      debugPrint("$ex");
    }
    return tasks;
  }

  void selectTheme(String themeName) {
    setState(() {
      selectedThemeName = themeName;
    });
  }

  void turnOnDarkTheme(bool value) {
    setState(() {
      themeMode = (value ? ThemeMode.dark : ThemeMode.light);
    });
  }

  @override
  dispose() {
    super.dispose();
    db.db!.dispose();
  }
}

class _TassyMainState extends State<TassyMain> with TickerProviderStateMixin, MsgBoxMixin, _AppStateMixin {
  late List<Widget> _tabbedPages = [];
  late List<Tab> _tabs = [];
  late List<FloatingActionButton?> _fabs = [];
  FloatingActionButton? _fab;
  TabController? _tabController;
  int _lastPage = 0;

  @override
  void initState() {
    super.initState();
    _tabs = _generateTabs();
    _fabs = _generateFABs();
  }

  @override
  Widget build(BuildContext context) {
    _tabbedPages = _generateTabbedPages();
    _tabController = TabController(
      initialIndex: _lastPage,
      length: min(_tabs.length, _tabbedPages.length),
      vsync: this,
    );
    _tabController!.addListener(() {
      setState(() {
        _fab = _fabs[_tabController!.index];
        _lastPage = _tabController!.index;
      });
    });

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
      floatingActionButton: _fab,
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
              viewTabbedPage(0, fromDrawer: true);
            },
          ),
          ListTile(
            leading: Icon(Icons.add_task_rounded),
            title: Text("New Task"),
            onTap: () {
              viewRoute((context) => TassyTaskEditor(EditorMode.add, task: TassyTask("", taskId: -1)), fromDrawer: true);
            },
          ),
          ListTile(
            leading: Icon(Icons.task_rounded),
            title: Text("View Tasks"),
            onTap: () {
              viewTabbedPage(1, fromDrawer: true);
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text("User Profile"),
            onTap: () {
              viewTabbedPage(2, fromDrawer: true);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings_rounded),
            title: Text("Settings"),
            onTap: () {
              viewRoute((context) => TassySettings(), fromDrawer: true);
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
    _TassyAppState appState = _getAppState(context);

    return <Widget>[
      Container(
        padding: const EdgeInsets.fromLTRB(25, 35, 25, 25),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            children: <Widget>[
              Text(
                "Welcome to TASSY, the Task Assistant System!",
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              Text(
                "Please choose an action below.",
                textAlign: TextAlign.center,
              ),
              ElevatedButton.icon(
                label: Text("New Task"),
                onPressed: () {
                  viewRoute((context) => TassyTaskEditor(EditorMode.add, task: TassyTask("", taskId: -1)));
                },
              ),
              ElevatedButton.icon(
                label: Text("View Tasks"),
                onPressed: () {
                  viewTabbedPage(1);
                },
              ),
              ElevatedButton.icon(
                label: Text("View User Profile"),
                onPressed: () {
                  viewTabbedPage(2);
                },
              ),
            ],
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(25),
        child: (appState.dbRetrieved ? TaskList() 
        : 
          Center(
            child: CircularProgressIndicator.adaptive(),
          )
        ),
      ),
      Container(
        padding: const EdgeInsets.all(25),
        child: (appState.dbRetrieved
        ?
          SingleChildScrollView(
            child: Column(
              spacing: 0,
              children: <Widget>[
                CircleAvatar(
                  radius: 75,
                ),
                Text(
                  appState.user!.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "\"${appState.user!.nickname}\"",
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  appState.user!.position,
                  textAlign: TextAlign.center,
                ),
                Text(
                  appState.user!.officeUnit,
                  textAlign: TextAlign.center,
                ),
                Text(
                  appState.user!.company,
                  textAlign: TextAlign.center,
                ),
              ]
            ),
          )
        :
          Container(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: CircularProgressIndicator.adaptive(),
            )
          )
        ),
      ),
    ];
  }

  List<FloatingActionButton?> _generateFABs() {
    return <FloatingActionButton?>[
      null,
      FloatingActionButton(
        child: Icon(Icons.add_rounded),
        onPressed: () {
          viewRoute((context)=>TassyTaskEditor(EditorMode.add, task: TassyTask("", taskId: -1)));
        },
      ),
      FloatingActionButton(
        child: Icon(Icons.edit_rounded),
        onPressed: () {
          
        },
      ),
    ];
  }

  void viewTabbedPage(int num, {bool fromDrawer = false})
  {
    if (_lastPage != 0) _lastPage = 0; // set to default;
    if (fromDrawer) Navigator.pop(context);
    _tabController!.index = num;
  }

  void viewRoute(WidgetBuilder f, {bool fromDrawer = false}) {
    if (fromDrawer) Navigator.pop(context);
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
  
  void removeTask(TassyTask task, {bool currentViewIsMain = true, int index = 1}) {
    setState(() {
      _getAppState(context).tasks.removeWhere((checkTask)=>(checkTask.taskId == task.taskId));
      if (currentViewIsMain) _lastPage = index;
    });
  }
}

class _TassyTaskEditorState extends State<TassyTaskEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? schedule = DateTime.now();
  String? taskName;
  String? description;
  late TextEditingController scheduleTextController;
  
  @override
  initState() {
    super.initState();

    scheduleTextController = TextEditingController.fromValue(
      TextEditingValue(text: (schedule ?? "").toString()),
    );
  }
 
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(25),
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: "Task Name"),
              onChanged: (String? value) {
                _formKey.currentState?.validate();
              },
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Text field is required!";
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Date/Time"),
              controller: scheduleTextController,
              onTap: () {
                dt.DatePicker.showDateTimePicker(context,
                  showTitleActions: true,
                  currentTime: DateTime.now(),
                  minTime: DateTime(2000, 1, 1),
                  maxTime: DateTime(2100, 12, 31, 23, 59),
                  /* pickerModel: dt.DateTimePickerModel(
                    locale: dt.LocaleType.en,
                  ), */
                  onChanged: (date) {
                    // setState(() {
                    //   scheduleTextController.value = TextEditingValue(text: date.toString());
                    //   description = date.toString();
                    // });
                  },
                  onConfirm: (date) {
                    setState(() {
                      scheduleTextController.value = TextEditingValue(text: date.toString());
                      description = date.toString();
                    });
                  },
                  locale: dt.LocaleType.en,
                );
              },
            ),
            ListTile(
              // leading: Text("Duration", style: TextStyle(inherit: true)),
              title: TextFormField(
                decoration: const InputDecoration(labelText: "Duration"),
                onChanged: (String? value) {
                  _formKey.currentState?.validate();
                },
                validator: (String? value) {
                  if (num.tryParse(value!) == null) {
                    return "Numeric value required!";
                  }
                  return null;
                },
              ),
              trailing: DropdownButton<String>(
                value: TimeUnit.hour.name,
                items: TimeUnit.values.map((u)=>DropdownMenuItem<String>(
                  value: u.name,
                  child: Text(u.name),
                )).toList(),
                onChanged: (String? value) {

                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Save",
        child: Icon(Icons.save_rounded),
        onPressed: () => _submit(),
      ),
    );
  }

  void _submit() {
    final isValid = (_formKey.currentState?.validate() ?? false);
    if (!isValid) {
      return;
    }
    _formKey.currentState?.save();
  }

}

class _TaskTileState extends State<TaskTile> with _AppStateMixin, _MainStateMixin, MsgBoxMixin {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String taskTitle = widget.task.taskName.trim();
    String taskSubtitle = (widget.task.description.trim() == "" ? "" : widget.task.description.trim());

    taskSubtitle += (taskSubtitle == "" ? "" : "\n") + (widget.task.schedule == null ? "" : "Schedule: ${DateFormat("MM/dd/yyyy${(widget.task.schedule!.hour == 0 && widget.task.schedule!.minute == 0 && widget.task.schedule!.second == 0 ? "" : " hh:mm aaa")}").format(widget.task.schedule!)}");

    return ListTile(
      leading: Visibility(
        visible: true,
        child: _generateCheckbox(),
      ),
      title: Text(taskTitle, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(taskSubtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: _generateIconButtonList(),
      ),
      onTap: () {
        setState(() {
          markAsDone(!widget.task.done);
        });
      },
    );
  }

  void markAsDone(bool isDone) {
    if (isDone) {
      _dialogYesNo(
        context,
        "Do you want to mark this task as done?",
        () {
          setState(() {
            widget.task.done = isDone;
            Navigator.pop(context);
          });
        },
        () {
          setState(() {
            widget.task.done = !isDone;
            Navigator.pop(context);
          });
        },
        title: _getAppState(context).widget.title
      );
    }
    else {
      widget.task.done = false;
    }
  }

  Checkbox _generateCheckbox() {
    return Checkbox(
      value: widget.task.done,
      onChanged: (bool? value) {
        setState(() {
          markAsDone(value!);
        },);
      },
    );
  }
  
  List<Widget> _generateIconButtonList() {
    return <Widget>[
      IconButton(
        tooltip: "Edit",
        onPressed: () {
          _getMainState(context).viewRoute((context) => TassyTaskEditor(EditorMode.edit, task: widget.task));
        },
        icon: Icon(Icons.edit_rounded),
      ),
      IconButton(
        tooltip: "Delete",
        onPressed: () {
          _dialogYesNo(
            context,
            "Delete this task?",
            () { _getMainState(context).removeTask(widget.task); Navigator.of(context).pop(); },
            () { Navigator.of(context).pop(); },
            title: _getAppState(context).widget.title,
          );
        },
        icon: Icon(Icons.delete_rounded),
      ),
    ];
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future _dialogYesNo(BuildContext context, String msg, void Function() fyes, void Function() fno, {String title = ""}) {
    return showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: fyes,
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: fno,
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }
}

mixin _AppStateMixin {
  _TassyAppState _getAppState(BuildContext context) {
    return context.findAncestorStateOfType<_TassyAppState>() as _TassyAppState;
  }
}

mixin _MainStateMixin {
  _TassyMainState _getMainState(BuildContext context) {
    return context.findAncestorStateOfType<_TassyMainState>() as _TassyMainState;
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
  int taskId; // negative id for new tasks
  String taskName = "";
  String description = "";
  DateTime? schedule;
  double duration = 0;
  TimeUnit durationUnit = TimeUnit.hour;
  List<TassyReminder> reminders = [];
  bool done = false;

  TassyTask(this.taskName, {this.description = "", this.schedule, this.duration = 0, this.durationUnit = TimeUnit.hour, List<TassyReminder>? reminders, this.done = false, this.taskId = -1 /*TEMP PARAM*/});

  TassyTask.db({required this.taskId}) {
    // retrieve from database
  }
}

class TassyReminder {
  int reminderId; // negative id for new reminders
  DateTime? alarm;
  double _snoozeDuration = 0; // zero means disabled snooze
  TimeUnit _snoozeUnit = TimeUnit.minute;

  TassyReminder(this.alarm, {double snoozeDuration = 0, TimeUnit snoozeUnit = TimeUnit.minute, this.reminderId = -1 /*TEMP PARAM*/}) {
    setSnooze(snoozeDuration, unit: snoozeUnit); 
  }

  TassyReminder.db({required this.reminderId}) {
    // retrieve from database
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
    return snoozeUnit.name.toString() + (snoozeDuration == 1 ? "" : "s");
  }
}

class TassyUser {
  int userId; // negative id for new user
  String name = "New User";
  String nickname = "";
  String position = "";
  String officeUnit = "";
  String company = "";
  late List<String> _phoneNumbers;
  late List<String> _emailAddresses;

  TassyUser({this.name = "New User", this.nickname = "", this.position = "", this.officeUnit = "", this.company = "", List<String>? phoneNumbers, List<String>? emailAddresses, this.userId = -1}) {
    _phoneNumbers = [];
    _emailAddresses = [];

    if (phoneNumbers != null && phoneNumbers.isNotEmpty) {
      for (String phoneNumber in phoneNumbers) {
        addPhoneNumber(phoneNumber);
      }
    }

    if (emailAddresses != null && emailAddresses.isNotEmpty) {
      for (String phoneNumber in emailAddresses) {
        addPhoneNumber(phoneNumber);
      }
    }
  }

  void addPhoneNumber(String phoneNumber) {
    phoneNumber = phoneNumber.trim();
    if (phoneNumber != "" && !_phoneNumbers.contains(phoneNumber)) {
      _phoneNumbers.add(phoneNumber);
    }
  }

  void addEmailAddress(String emailAddress) {
    emailAddress = emailAddress.trim();
    if (emailAddress != "" && !_emailAddresses.contains(emailAddress)) {
      _emailAddresses.add(emailAddress);
    }
  }
}
// #endregion

// #region Database
class DBController {
  sql.Database? _db;
  String filepath = "";
  // ignore: library_private_types_in_public_api
  final _TassyAppState appState;

  // ignore: library_private_types_in_public_api
  DBController(this.appState) {
    setupPath();

    test();
  }

  Future<bool> setupPath() async {
    String path = "";

    try {
      final Directory directory = (Platform.isIOS ? await getLibraryDirectory() : await getApplicationDocumentsDirectory());
      String path = pth.join(directory.path, 'tassy.sqlite3');

      final exists = await File(path).exists();

      if (!exists) {
        ByteData data = await rootBundle.load('assets/db/tassy.sqlite3');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        
        await File(path).writeAsBytes(bytes, flush: true);
      }

      filepath = path;
      debugPrint("DB path initialized: $filepath");

      appState.databaseSynced();
    }
    catch (ex) {
      debugPrint("$ex");
      filepath = path;
    }

    return (filepath != "");
  }

  sql.Database? get db {
    return _db;
  }

  bool test() {
    bool ok = true;
    try {
      open();
    }
    catch (ex) {
      debugPrint("$ex");
      ok = false;
    }
    finally {
      close();
    }

    return ok;
  }

  void open() { // SHOULD DISPOSE/CLOSE CONNECTION AFTERWARDS!!! AVOID USING DIRECTLY
    if (filepath == "") throw "Uninitialized DB path.";

    try {
      _db = sql.sqlite3.open(filepath);
    }
    catch (ex) {
      debugPrint("$ex");
      if (db != null) {
        _db!.dispose();
        _db = null;
      }
    }
  }

  /// DBController.select:
  ///   table - table name;
  ///   fieldStr - a comma-delimited strig consisting of table column names;
  ///   criteriaStr - a WHERE clause;
  /// 
  /// RETURNS: ResultSet
  sql.ResultSet select(String table, String fieldStr, {String criteriaStr = ""}) {
    sql.ResultSet results;

    try {
      open();

      results = _db!.select("SELECT $fieldStr FROM $table${criteriaStr == "" ? ";" : " $criteriaStr;"}");
    }
    catch (ex) {
      debugPrint("$ex");
      results = sql.ResultSet([], [], []);
    }
    finally {
      close();
    }

    return results;
  }

  /// DBController.insert:
  ///   table - table name;
  ///   fieldStr - a comma-delimited string consisting of table column names;
  ///   valueSetArr - a array of value arrays, each of which is sorted 
  ///     according to the order of the table column names in fieldStr;
  /// 
  /// RETURNS: lastInsertRowId or -1
  int insert(String table, String fieldStr, List<List<Object?>> valueSetArr) {
    final sql.PreparedStatement stmt;

    try {
      open();
      
      stmt = _db!.prepare("INSERT INTO $table ($fieldStr) VALUES (${fieldStr.split(",").map((str)=>"?").reduce((a, b)=>"$a, $b")})");
      
      for (var valueSet in valueSetArr) {
        stmt.execute(valueSet);
      }

      stmt.dispose();
    }
    catch (ex) {
      debugPrint("$ex");
    }
    finally {
      close();
    }

    return (_db!.updatedRows == 0 ? -1 : _db!.lastInsertRowId);
  }

  /// DBController.update
  ///   table - table name;
  ///   fieldValueStr - a comma-delimited string of colName = formattedvalue;
  ///   criteriaStr - a WHERE clause;
  ///
  /// RETURNS: number of rows updated
  int update(String table, String fieldValueStr, {String criteriaStr = ""}) {
    try {
      open();

      _db!.execute("UPDATE $table SET $fieldValueStr ${criteriaStr == "" ? ";" : " $criteriaStr;"}");
    }
    catch (ex) {
      debugPrint("$ex");
    }
    finally {
      close();
    }

    return _db!.updatedRows;
  }

  /// DBController.delete
  ///   table - table name;
  ///   criteriaStr - a WHERE clause;
  /// 
  /// RETURNS: number of rows updated
  int delete(String table, {String criteriaStr = ""}) {
    try {
      open();

      _db!.execute("DELETE FROM $table ${criteriaStr == "" ? ";" : " $criteriaStr;"}");
    }
    catch (ex) {
      debugPrint("$ex");
    }
    finally {
      close();
    }

    return _db!.updatedRows;
  }

  void close() { // ALWAYS USE THIS TO CLOSE CONNECTION
    if (_db != null) {
      try {
        _db!.dispose();
      }
      catch (ex) {
        debugPrint("$ex");
      }
      finally {
        _db = null;
      }
    }
  }
}
// #endregion