//==============================================================
// Program Name:  TASSY: The Task Assistant System
// Description:   A simple task list application
// Author:        Geovani P. Duqueza
//==============================================================

import 'dart:io';
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
  final GlobalKey<_TassyAppState> appKey = GlobalKey<_TassyAppState>();
  
  runApp(TassyApp(key: appKey));
}

// #region Widgets
class TassyApp extends StatefulWidget {
  final String title = "TASSY";
  final String appTitle = "TASSY: The Task Assistant System";
  static final DateFormat df = DateFormat("M/d/yyyy h:mm a");
  static String selectedThemeName = "SKY";
  static ThemeMode themeMode = ThemeMode.light;
  static final List<String> themeNames = [];
  static Map<String, ThemeData> themes = {}, darkThemes = {};

  const TassyApp({super.key});

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
    _TassyAppState appState = getAppState(context);

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
                TassyApp.themeNames.clear();
                TassyApp.themeNames.addAll((appState.darkModeSwitchValue ? TassyApp.darkThemes.keys : TassyApp.themes.keys));
              },
            ),
            ListTile(
              title: Text("Select theme:"),
              tileColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
              trailing: DropdownButton<String>(
                dropdownColor: Theme.of(context).colorScheme.primary,
                value: TassyApp.selectedThemeName,
                items: TassyApp.themeNames.map((themeName)=>DropdownMenuItem<String>(
                  value: themeName,
                  child: Text(
                    themeName,
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                  ),
                )).toList(),
                onChanged: (String? value) {
                  TassyApp.selectedThemeName = value!;
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
  final TassyTask task;
  // ignore: prefer_typing_uninitialized_variables
  final taskTileState;
  // ignore: prefer_typing_uninitialized_variables
  final mainState;
 
  const TassyTaskEditor(this.task, {super.key, this.taskTileState, this.mainState});

  @override
  State<TassyTaskEditor> createState() => _TassyTaskEditorState();
}

class TaskList extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final mainState;

  const TaskList({super.key, required this.mainState});
  
  @override
  State<TaskList> createState() => _TaskListState();
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
class _TassyAppState extends State<TassyApp> with MsgBoxMixin {
  late DBController db;
  bool dbRetrieved = false;
  TassyUser? user;
  List<TassyTask> tasks = [];
  bool darkModeSwitchValue = false;

  @override
  void initState() {
    super.initState();
    setWindowTitle(widget.appTitle);

    db = DBController(this);
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
      theme: TassyApp.themes[(TassyApp.selectedThemeName == "dark" ? "bright" : TassyApp.selectedThemeName)],
      darkTheme: TassyApp.darkThemes[(TassyApp.selectedThemeName == "bright" ? "dark" : TassyApp.selectedThemeName)],
      themeMode: TassyApp.themeMode,
    );
  }

  void databaseSynced() {
    setState(() {
      dbRetrieved = true;
    });
  }
  
  void retrieveThemes() { // autogenerate themes according to the provided color seeds; other custom themes may be added after the loop
    Map<String, String> seedColors = {
      "MEADOW": "silver",
      "SKY": "bluegreen",
      "BROWN": "red[400]",
      "PURPLE": "black",
      "MOSS": "green",
      "TEAL": "blueAccent",
      "WARM": "orange",
    };
    List<String> colors = seedColors.keys.toList();

    for (String color in colors) {
      TassyApp.themes[color] = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorUtils.stringToColor(seedColors[color] as String), brightness: Brightness.light),
      );
      TassyApp.darkThemes[color] = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorUtils.stringToColor(seedColors[color] as String), brightness: Brightness.dark),
      );
    }
    TassyApp.themeNames.clear();
    TassyApp.themeNames.addAll((darkModeSwitchValue ? TassyApp.darkThemes.keys : TassyApp.themes.keys));
    darkModeSwitchValue = (TassyApp.themeMode == ThemeMode.dark);
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

  void saveUser() {
    db.update("user", "name = '${user!.name}', nickname = '${user!.nickname}', position = '${user!.position}', officeUnit = '${user!.officeUnit}', company = '${user!.company}'", criteriaStr: "WHERE userId = ${user!.userId}");
    db.delete("phoneNumber", criteriaStr: "WHERE userId = ${user!.userId}");
    db.delete("emailAddress", criteriaStr: "WHERE userId = ${user!.userId}");

    for (String phoneNumber in user!.phoneNumbers) {
      db.insert("phoneNumber", "phoneNumber, userId", [[phoneNumber, user!.userId]]);
    }

    for (String emailAddress in user!.emailAddresses) {
      db.insert("emailAddress", "emailAddress, userId", [[emailAddress, user!.userId]]);
    }
  }

  List<TassyTask> retrieveTasks() { // TEMPORARY DATA ONLY
    sql.ResultSet results;
    List<TassyTask> tasks = <TassyTask>[];

    TimeUnit getTimeUnit(int i)=>TimeUnit.values[i < TimeUnit.values.length || i >= 0 ? i : 2];

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
          db: db,
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
            db: db,
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
      TassyApp.selectedThemeName = themeName;
    });
  }

  void turnOnDarkTheme(bool value) {
    setState(() {
      TassyApp.themeMode = (value ? ThemeMode.dark : ThemeMode.light);
    });
  }

  @override
  dispose() {
    super.dispose();
    db.db!.dispose();
  }
}

class _TassyMainState extends State<TassyMain> with TickerProviderStateMixin, MsgBoxMixin, _AppStateMixin, _MainStateMixin {
  final GlobalKey<FormState> userFormKey = GlobalKey<FormState>();
  late List<Widget> _tabbedPages = [];
  late List<Tab> _tabs = [];
  late List<FloatingActionButton?> _fabs = [];
  FloatingActionButton? _fab;
  TabController? _tabController;
  int _lastPage = 0;
  Widget taskList = Center(
    child: CircularProgressIndicator.adaptive(),
  );
  bool userEditMode = false;

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
      length: (_tabs.length < _tabbedPages.length ? _tabs.length : _tabbedPages.length),
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
    List<Widget> drawerChildren = <Widget>[
      DrawerHeader(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary
        ),
        child: Center(
          child: Text("TASSY Menu"),
        ),
      ),
    ];
    drawerChildren.addAll(
      [
        ["Home", Icons.home_rounded, () {viewTabbedPage(0, fromDrawer: true);}],
        ["New Task", Icons.add_task_rounded, () {
          _tabController!.index = 1;
          viewRoute((context) => TassyTaskEditor(TassyTask("", taskId: -1, db: getAppState(context).db), mainState: this,), fromDrawer: true);
        }],
        ["View Tasks", Icons.task_rounded, () {viewTabbedPage(1, fromDrawer: true);}],
        ["User Profile", Icons.account_circle, () {viewTabbedPage(2, fromDrawer: true);}],
        ["Settings", Icons.settings_rounded, () {viewRoute((context) => TassySettings(), fromDrawer: true);}],
        ["Exit", Icons.exit_to_app_rounded, exitApp],
      ].map((record)=>ListTile(
        leading: Icon(record[1] as IconData),
        title: Text(record[0] as String),
        onTap: record[2] as Function(),
      )).toList()
    );

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: drawerChildren,
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
    _TassyAppState appState = getAppState(context);
    taskList = (appState.dbRetrieved ? TaskList(mainState: this)
    : 
      Center(
        child: CircularProgressIndicator.adaptive(),
      )
    );

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
                  _tabController!.index = 1;
                  viewRoute((context) => TassyTaskEditor(TassyTask("", taskId: -1, db: getAppState(context).db), mainState: this,));
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
        child: taskList,
      ),
      Container(
        padding: const EdgeInsets.all(25),
        child: (appState.dbRetrieved
          ? 
            (userEditMode
            ?
              Form(
                key: userFormKey,
                child: Column(
                  spacing: 0,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Full Name"),
                      initialValue: appState.user!.name,
                      onSaved: (String? value) {
                        appState.user!.name = value!;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Nickname"),
                      initialValue: appState.user!.nickname,
                      onSaved: (String? value) {
                        appState.user!.nickname = value!;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Position"),
                      initialValue: appState.user!.position,
                      onSaved: (String? value) {
                        appState.user!.position = value!;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: "Office Unit"),
                      initialValue: appState.user!.officeUnit,
                      onSaved: (String? value) {
                        appState.user!.officeUnit = value!;
                      },
                    ),
                    TextFormField(
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Company"),
                      initialValue: appState.user!.company,
                      onSaved: (String? value) {
                        appState.user!.company = value!;
                      },
                    ),
                  ],
                ),
              )
            : 
              SingleChildScrollView(
                child: Column(
                  spacing: 0,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 75,
                    ),
                    SizedBox(height: 10),
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
                    SizedBox(height: 10),
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
        tooltip: "New Task",
        child: Icon(Icons.add_rounded),
        onPressed: () {
          _tabController!.index = 1;
          viewRoute((context)=>TassyTaskEditor(TassyTask("", taskId: -1, db: getAppState(context).db), mainState: this,));
        },
      ),
      FloatingActionButton(
        tooltip: "Edit User",
        child: Icon((userEditMode ? Icons.save_rounded : Icons.edit_rounded)),
        onPressed: () {
          setState(() {
            userFormKey.currentState?.save();
            getAppState(context).saveUser();
            userEditMode = !userEditMode;
            _fabs = _generateFABs();
            _fab = _fabs[_tabController!.index];
          });
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
      getAppState(context).tasks.removeWhere((checkTask)=>(checkTask.taskId == task.taskId));
      task.dbDelete();
      if (currentViewIsMain) _lastPage = index;
    });
  }
}

class _TassyTaskEditorState extends State<TassyTaskEditor> with _AppStateMixin, MsgBoxMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController scheduleTextController;
  late TassyTask tempTask;
  
  @override
  initState() {
    super.initState();

    tempTask = TassyTask.copy(widget.task); // create a duplicate of the task to hold temporary values

    scheduleTextController = TextEditingController.fromValue(
      TextEditingValue(text: (tempTask.schedule == null ? "" : TassyApp.df.format(tempTask.schedule!))),
    );
  }
 
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("${tempTask.taskId < 0 ? "New" : "Edit"} Task"),
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
              initialValue: tempTask.taskName,
              onSaved: (String? value) {
                if (_formKey.currentState?.validate() ?? false) {
                  tempTask.taskName = value!;
                }
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
              initialValue: tempTask.description,
              onSaved: (String? value) {
                tempTask.description = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: "Date/Time"),
              controller: scheduleTextController,
              onSaved: (String? value) {
                setState(() {
                  scheduleTextController.value = TextEditingValue(text: value!);
                  tempTask.schedule = TassyApp.df.tryParse(value);
                });
              },
              validator: (value) => (value!.trim() != "" && TassyApp.df.tryParse(value) == null ? "Invalid date" : null),
              onTap: () {
                dt.DatePicker.showDateTimePicker(context,
                  showTitleActions: true,
                  currentTime: DateTime.now(),
                  minTime: DateTime(2000, 1, 1),
                  maxTime: DateTime(2100, 12, 31, 23, 59),
                  onConfirm: (date) {
                    setState(() {
                      scheduleTextController.value = TextEditingValue(text: TassyApp.df.format(date));
                      tempTask.schedule = date;
                    });
                  },
                  locale: dt.LocaleType.en,
                );
              },
            ),
            ListTile(
              // leading: Text("Duration", style: TextStyle(inherit: true)),
              isThreeLine: false,
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 0,
              title: TextFormField(
                decoration: const InputDecoration(labelText: "Duration"),
                initialValue: (tempTask.duration % 1 == tempTask.duration ? tempTask.duration.toInt() : tempTask.duration).toString(),
                onFieldSubmitted: (String? value) {
                  _formKey.currentState?.validate();
                },
                validator: (String? value) => (num.tryParse(value!) == null ? "Numeric value required!" : null),
              ),
              trailing: DropdownButton<String>(
                value: tempTask.durationUnit.name,
                items: TimeUnit.values.map((u)=>DropdownMenuItem<String>(
                  value: u.name,
                  child: Text(u.name),
                )).toList(),
                onChanged: (String? value) {
                  setState(() {
                    tempTask.durationUnit = TimeUnit.values.byName(value!);
                  });
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
    
    if (isValid) {
      _formKey.currentState?.save();

      if (tempTask.taskId == -1) {
        widget.mainState.setState(() {
          tempTask.dbAdd();
          getAppState(context).tasks.add(tempTask);
          Navigator.of(context).pop();
        });
      }
      else {
        widget.taskTileState.setState(() {
          widget.task.duplicateData(tempTask);
          widget.task.dbUpdate();
          Navigator.of(context).pop();
        });
      }

    }
    else {
      _simpleMsg(context, "Saving task failed. Please edit the invalid data to continue saving this task.", title: getAppState(context).widget.title);
    }
    return;
  }

  @override
  void dispose() {
    scheduleTextController.dispose();
    super.dispose();
  }
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) => TaskTile(widget.mainState.getAppState(context).tasks[index], widget),
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemCount: widget.mainState.getAppState(context).tasks.length,
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

    taskSubtitle += (taskSubtitle == "" ? "" : "\n") + (widget.task.schedule == null ? "" : "\u{1f4c5}: ${DateFormat("MM/dd/yyyy${(widget.task.schedule!.hour == 0 && widget.task.schedule!.minute == 0 && widget.task.schedule!.second == 0 ? "" : " hh:mm aaa")}").format(widget.task.schedule!)}");

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
            widget.task.dbUpdate();
            Navigator.pop(context);
          });
        },
        () {
          setState(() {
            widget.task.done = !isDone;
            widget.task.dbUpdate();
            Navigator.pop(context);
          });
        },
        title: getAppState(context).widget.title
      );
    }
    else {
      widget.task.done = false;
      widget.task.dbUpdate();
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
          getMainState(context).viewRoute((context) => TassyTaskEditor(widget.task, taskTileState: this));
        },
        icon: Icon(Icons.edit_rounded),
      ),
      IconButton(
        tooltip: "Delete",
        onPressed: () {
          _dialogYesNo(
            context,
            "Delete this task?",
            () {
              getMainState(context).removeTask(widget.task);
              Navigator.of(context).pop();
            },
            () { Navigator.of(context).pop(); },
            title: getAppState(context).widget.title,
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
  _TassyAppState getAppState(BuildContext context) {
    return context.findAncestorStateOfType<_TassyAppState>() as _TassyAppState;
  }
}

mixin _MainStateMixin {
  _TassyMainState getMainState(BuildContext context) {
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
  int taskId = -1; // negative id for new tasks
  String taskName = "";
  String description = "";
  DateTime? schedule;
  double duration = 0;
  TimeUnit durationUnit = TimeUnit.hour;
  List<TassyReminder> reminders = [];
  bool done = false;
  DBController? db;

  TassyTask(this.taskName, {this.description = "", this.schedule, this.duration = 0, this.durationUnit = TimeUnit.hour, List<TassyReminder>? reminders, this.done = false, required this.db, this.taskId = -1 /*TEMP PARAM*/,});

  TassyTask.db({required this.taskId, required this.db}) {
    // retrieve from database
  }

  /// Deep copy
  TassyTask.copy(TassyTask toCopy) {
    duplicateData(toCopy);
  }

  void duplicateData(TassyTask toCopy) {
    taskId = toCopy.taskId;
    taskName = toCopy.taskName;
    description = toCopy.description;
    schedule = toCopy.schedule;
    duration = toCopy.duration;
    durationUnit = toCopy.durationUnit;
    reminders = toCopy.reminders.map((reminder)=>TassyReminder.copy(reminder)).toList();
    done = toCopy.done;
    db = toCopy.db;
  }

  @override
  String toString() {
    return "${super.toString()}\n  taskId: $taskId\n  taskName: $taskName\n  description: $description\n  schedule: $schedule\n  duration: $duration\n  durationUnit: $durationUnit\n  reminders: ${reminders.map((reminder)=>"\n$reminder")}\n  taskId: $taskId\n";
  }

  void dbAdd() {
    if (taskId == -1) { // new tasks only
      taskId = db!.insert("task", "taskName, description, schedule, duration, durationUnit, done", [[taskName, description, schedule.toString(), duration, durationUnit.index, done]]);
      for (TassyReminder reminder in reminders) {
        reminder.taskId = taskId;
        reminder.dbAdd();
      }
    }
  }

  void dbUpdate() {
    if (taskId != -1) { // existing tasks only
      db!.update("task", "taskName = '$taskName', description = '$description', schedule = '$schedule', duration = '$duration', durationUnit = '${durationUnit.index}', done = $done", criteriaStr: "WHERE taskId = $taskId");
    }
  }

  void dbDelete() {
    if (taskId != -1) {
      db!.delete("task", criteriaStr: "WHERE taskId = $taskId");
    }
  }
}

class TassyReminder {
  int reminderId = -1; // negative id for new reminders
  DateTime? alarm;
  double _snoozeDuration = 0; // zero means disabled snooze
  TimeUnit _snoozeUnit = TimeUnit.minute;
  int taskId = -1; // negative id for new reminders
  DBController? db;

  TassyReminder(this.alarm, {double snoozeDuration = 0, TimeUnit snoozeUnit = TimeUnit.minute, required this.db, this.reminderId = -1, this.taskId = -1 /*TEMP PARAM*/}) {
    setSnooze(snoozeDuration, unit: snoozeUnit);
  }

  TassyReminder.db({required this.reminderId, required this.db}) {
    // retrieve from database
  }

  /// Deep copy
  TassyReminder.copy(TassyReminder toCopy) {
    duplicateData(toCopy);
  }

  void duplicateData(TassyReminder toCopy) {
    reminderId = toCopy.reminderId;
    alarm = toCopy.alarm;
    _snoozeDuration = toCopy.snoozeDuration;
    _snoozeUnit = toCopy.snoozeUnit;
    db = toCopy.db;
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

  @override
  String toString() {
    return "${super.toString()}\n  reminderId: $reminderId\n  alarm: $alarm\n  snoozeDuration: $snoozeDuration\n  snoozeUnit: $snoozeUnit";
  }

  void dbAdd() {
    if (reminderId == -1) { // new tasks only
      reminderId = db!.insert("reminder", "alarm, snoozeDuration, snoozeUnit, taskId", [[alarm.toString(), snoozeDuration, snoozeUnit.index, taskId]]);
    }
  }

  void dbUpdate() {
    if (reminderId != -1) { // existing tasks only
      db!.update("reminder", "alarm = '$alarm', snoozeDuration = '$snoozeDuration', snoozeUnit = '$snoozeUnit', taskId = '$taskId'", criteriaStr: "WHERE reminderId = $reminderId");
    }
  }

  void dbDelete() {
    if (reminderId != -1) { // existing tasks only
      db!.delete("reminder", criteriaStr: "WHERE reminderId = $reminderId");
    }
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

  List<String> get phoneNumbers {
    return _phoneNumbers;
  }

  List<String> get emailAddresses {
    return _emailAddresses;
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
    int lastInsertRowId = -1;

    try {
      open();
      
      stmt = _db!.prepare("INSERT INTO $table ($fieldStr) VALUES (${fieldStr.split(",").map((str)=>"?").reduce((a, b)=>"$a, $b")})");
      
      for (var valueSet in valueSetArr) {
        stmt.execute(valueSet);
      }

      stmt.dispose();
      lastInsertRowId = (_db!.updatedRows == 0 ? -1 : _db!.lastInsertRowId);
    }
    catch (ex) {
      debugPrint("$ex");
    }
    finally {
      close();
    }

    return lastInsertRowId;
  }

  /// DBController.update
  ///   table - table name;
  ///   fieldValueStr - a comma-delimited string of colName = formattedvalue;
  ///   criteriaStr - a WHERE clause;
  ///
  /// RETURNS: number of rows updated
  int update(String table, String fieldValueStr, {String criteriaStr = ""}) {
    int updatedRows = 0;

    try {
      open();

      _db!.execute("UPDATE $table SET $fieldValueStr ${criteriaStr == "" ? ";" : " $criteriaStr;"}");

      updatedRows = _db!.updatedRows;
    }
    catch (ex) {
      debugPrint("$ex");
    }
    finally {
      close();
    }

    return updatedRows;
  }

  /// DBController.delete
  ///   table - table name;
  ///   criteriaStr - a WHERE clause;
  /// 
  /// RETURNS: number of rows updated
  int delete(String table, {String criteriaStr = ""}) {
    int updatedRows = 0;

    try {
      open();

      _db!.execute("DELETE FROM $table ${criteriaStr == "" ? ";" : " $criteriaStr;"}");

      updatedRows = _db!.updatedRows;
    }
    catch (ex) {
      debugPrint("$ex");
    }
    finally {
      close();
    }

    return updatedRows;
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