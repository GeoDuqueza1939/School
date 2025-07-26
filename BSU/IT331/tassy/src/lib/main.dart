//==============================================================
// Program Name:  TASSY: The Task Assistant System
// Description:   A simple task list application
// Author:        Geovani P. Duqueza
//==============================================================

import 'package:flutter/material.dart';

void main() {
  runApp(TassyApp());
}

class TassyApp extends StatelessWidget {
  const TassyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return TassyMain();
  }
}

// ignore: must_be_immutable
class TassyMain extends StatefulWidget {
  final String title = "TASSY"; // Appbar title
  final Map<String, Object> themes = {
      "theme": ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light,),
      ),
      "darkTheme": ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey, brightness: Brightness.dark,),
      ),
      "themeMode": ThemeMode.light,
  };

  TassyMain({super.key});

  @override
  State<TassyMain> createState() => _TassyMainState();
}

class _TassyMainState extends State<TassyMain> {
  int _counter = 0; // FROM DEMO! PLEASE REMOVE/EDIT!

  _TassyMainState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TASSY: The Task Assistant System', // application title bar/browser title
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('You have pushed the button this many times:'), // FROM DEMO! PLEASE REMOVE/EDIT!
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium, // FROM DEMO! PLEASE REMOVE/EDIT!
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ),
      ),
      theme: widget.themes["theme"] as ThemeData,
      darkTheme: widget.themes["darkTheme"] as ThemeData,
      themeMode: widget.themes["themeMode"] as ThemeMode,
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++; // FROM DEMO! PLEASE REMOVE/EDIT!

      // widget.themes["themeMode"] = (widget.themes["themeMode"] as ThemeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
    });
  }
}

enum TimeUnit {
  second, minute, hour, day, week, month, year, decade, century, millenium
}

class TassyTask {
  String? taskName;
  DateTime? schedule;
  double duration;
  TimeUnit durationUnit;
  List<DateTime>? reminders;

  TassyTask({required this.taskName, this.schedule, this.duration = 0, this.durationUnit = TimeUnit.hour, this.reminders});
}

class TassyReminder {
  DateTime? reminderSchedule;
  double _snoozeDuration = 0; // zero means disabled snooze
  TimeUnit _snoozeUnit = TimeUnit.minute;

  TassyReminder({required this.reminderSchedule, double snoozeDuration = 0, TimeUnit snoozeUnit = TimeUnit.minute}) {
    setSnooze(snoozeDuration, unit: snoozeUnit);
  }

  void setSnooze(double duration, {TimeUnit unit = TimeUnit.minute}) {
    _snoozeDuration = duration;
    _snoozeUnit = unit;
  }

  double get snoozeDuration {
    return _snoozeDuration;
  }

  TimeUnit get snoozeUnit {
    return _snoozeUnit;
  }
}