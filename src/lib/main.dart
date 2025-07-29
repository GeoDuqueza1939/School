//==============================================================
// Program Name:  TASSY: The Task Assistant System
// Description:   A simple task list application
// Author:        Geovani P. Duqueza
//==============================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
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

class TaskList extends StatelessWidget {
  // ignore: library_private_types_in_public_api
  final _TassyAppState appState;

  // ignore: library_private_types_in_public_api
  const TaskList(this.appState, {super.key});
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: appState.tasks.map((task)=>TaskTile(task, this)).toList(),
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
class _TassyAppState extends State<TassyApp> with _AppStateMixin {
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
  late TassyUser user;
  List<TassyTask> tasks = [];

  @override
  void initState() {
    super.initState();

    user = retrieveUser();

    tasks = retrieveTasks();
  }

  @override
  Widget build(BuildContext context) {
    retrieveThemes();
    user = retrieveUser();
    tasks = retrieveTasks();

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

  TassyUser retrieveUser() { // TEMPORARY DATA ONLY
    return TassyUser(
      userId: 0,
      name: "Geovani Duqueza",
      nickname: "Geo",
      position: "Administrative Assistant III",
      officeUnit: "OSDS-Personnel Unit",
      company: "Department of Education \u2013 Sto. Tomas City",
      phoneNumbers: ["09153032914", "09295015297"],
      emailAddresses: ["geovani.duqueza@deped.gov.ph", "24-00901@g.batstate-u.edu.ph"],
    );
  }

  List<TassyTask> retrieveTasks() { // TEMPORARY DATA ONLY
    return <TassyTask>[
      TassyTask(
        taskId: 0,
        "Work",
      ),
      TassyTask(
        taskId: 1,
        "Go to the market",
        description: "Buy tomatoes, potatoes, and onions",
        schedule: DateTime(2025, 8, 1, 8),
      ),
      TassyTask(
        taskId: 2,
        "School",
        description: "Submit project",
        schedule: DateTime(2025, 7, 30),
      ),
      TassyTask(
        taskId: 3,
        "Meeting",
        description: "Office unit",
        schedule: DateTime(2025, 7, 31, 9),
        duration: 1.5,
        durationUnit: TimeUnit.hour,
        reminders: <TassyReminder>[
          TassyReminder(
            DateTime(2025, 7, 31, 8,55),
            snoozeDuration: 5,
            snoozeUnit: TimeUnit.minute,
          )
        ],
      ),
    ];
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
}

class _TassyMainState extends State<TassyMain> with TickerProviderStateMixin, MsgBoxMixin, _AppStateMixin {
  late List<Widget> _tabbedPages = [];
  late List<Tab> _tabs = [];
  TabController? _tabController;
  int _lastPage = 0;

  @override
  void initState() {
    super.initState();
    _tabs = _generateTabs();
  }

  @override
  Widget build(BuildContext context) {
    _tabbedPages = _generateTabbedPages();
    _tabController = TabController(
      initialIndex: _lastPage,
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
              viewTabbedPage(0, fromDrawer: true);
            },
          ),
          ListTile(
            leading: Icon(Icons.add_task_rounded),
            title: Text("New Task"),
            onTap: () {
              viewRoute((context) => TassyTaskEditor(EditorMode.add), fromDrawer: true);
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
        padding: EdgeInsets.fromLTRB(25, 35, 25, 25),
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
                  viewRoute((context) => TassyTaskEditor(EditorMode.add));
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
        padding: EdgeInsets.fromLTRB(25, 25, 25, 25),
        child: TaskList(appState),
      ),
      Container(
        padding: EdgeInsets.fromLTRB(25, 25, 25, 25),
        child: SingleChildScrollView(
          child: Column(
            spacing: 0,
            children: <Widget>[
              CircleAvatar(
                radius: 75,
              ),
              Text(
                appState.user.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                "\"${appState.user.nickname}\"",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                appState.user.position,
              ),
              Text(
                appState.user.officeUnit,
              ),
              Text(
                appState.user.company,
              ),
            ],
          ),
        ),
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
  
  FloatingActionButton _tempFAB() { // FOR TESTING ONLY
    _TassyAppState appState = _getAppState(context);

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
    );
  }
}

// THIS WIDGET OF THIS STATE MIGHT BE BETTER OFF AS A STATELESS WIDGET
class _TassySettingsState extends State<TassySettings> with _AppStateMixin {
  bool darkModeSwitchValue = false;
  late _TassyAppState appState;
  String selectedThemeName = "";
  List<String> themeNames = [];

  @override
  void initState() {
    super.initState();
    appState = _getAppState(context);
    darkModeSwitchValue = (appState.themeMode == ThemeMode.dark);
    selectedThemeName = appState.selectedThemeName;
    themeNames = (darkModeSwitchValue ? appState.darkThemes.keys : appState.themes.keys).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25),
        child: Column(
          children: <Widget>[
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: darkModeSwitchValue,
              onChanged: (bool value) {
                darkModeSwitchValue = value;
                appState.turnOnDarkTheme(value);
                themeNames = (darkModeSwitchValue ? appState.darkThemes.keys : appState.themes.keys).toList();
              },
            ),
            ListTile(
              title: Text("Select theme:"),
              tileColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              trailing: DropdownButton<String>(
                dropdownColor: Theme.of(context).colorScheme.primary,
                value: selectedThemeName,
                items: themeNames.map((themeName)=>DropdownMenuItem<String>(
                  value: themeName,
                  child: Text(
                    themeName,
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                )).toList(),
                onChanged: (String? value) {
                  selectedThemeName = value!;
                  appState.selectTheme(selectedThemeName);
                },
              ),
            ),
          ],
        ),
      ),
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
      body: ListView(
        padding: EdgeInsets.all(25),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Save",
        child: Icon(Icons.save_rounded),
        onPressed: () {

        },
      ),
    );
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
          widget.task.done = !widget.task.done;
        });
      },
    );
  }

  Checkbox _generateCheckbox() {
    return Checkbox(
      value: widget.task.done,
      onChanged: (bool? value) {  },
      
    );
  }
  
  List<Widget> _generateIconButtonList() {
    return <Widget>[
      IconButton(
        tooltip: "Edit",
        onPressed: () {
          
        },
        icon: Icon(Icons.edit_rounded),
      ),
      IconButton(
        tooltip: "Delete",
        onPressed: () {
          _dialogYesNo(context, "Delete this task?", (() { _getMainState(context).removeTask(widget.task); Navigator.of(context).pop(); }), (() { Navigator.of(context).pop(); }), title: _getAppState(context).widget.title);
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
    return _snoozeUnit.name.toString() + (snoozeDuration == 1 ? "" : "s");
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
  Database? _db;
  String filepath;

  DBController() {
    setupPath();
  }

  void setupPath() async { // adapted from https://stackoverflow.com/questions/78015865/location-to-place-sqlite-db-in-flutter
    final directory = await getTemporaryDirectory();
    final String path = join(directory.path, 'tassy.sqlite3');

    final exists = await File(path).exists();

    if (!exists) {
      ByteData data = await rootBundle.load('assets/db/tassy.sqlite3');
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      
      await File(path).writeAsBytes(bytes, flush: true);
    }

    filepath = path;
  }

  get getDB async { // SHOULD DISPOSE/CLOSE CONNECTION AFTERWARDS!!!
    _db = sqlite3.open(filepath);

    return _db;
  }

  void close() {
    _db!.dispose();
  } 
}
// #endregion