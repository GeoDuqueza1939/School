//==============================================================
// Program Name:  DeviceInfoApp (Device Info App using 
//                Library APIs)
// Description:   A Stateful Widget app that uses a software
//                library API to retrieve and display mobile 
//                device information using the Flutter plugin 
//                device_info_plus
// Author:        Geovani P. Duqueza
//==============================================================

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  runApp(const DeviceInfoApp());
}

class DeviceInfoApp extends StatefulWidget {
  const DeviceInfoApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AppState createState() => _AppState();
}

class _AppState extends State<DeviceInfoApp> {
  String model = '';
  String oem = '';
  String os = '';
  String dateTime = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Device Information'), backgroundColor: Colors.blue),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Card(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(15),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                columnWidths: {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(child: Text('Device model: ', style: TextStyle(fontWeight: FontWeight.bold),),),
                      TableCell(child: Text(model)),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(child: Text('Manufacturer: ', style: TextStyle(fontWeight: FontWeight.bold),),),
                      TableCell(child: Text(oem)),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(child: Text('OS Version: ', style: TextStyle(fontWeight: FontWeight.bold),),),
                      TableCell(child: Text(os)),
                    ],
                  ),
                  TableRow(
                    children: [
                      TableCell(child: Text('Date/Time Retrieved: ', style: TextStyle(fontWeight: FontWeight.bold),),),
                      TableCell(child: Text(dateTime)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          tooltip: 'Refresh Info',
          label: Text('Refresh Info'),
          icon: Icon(Icons.refresh, color: Colors.blueGrey),
          onPressed: () async {
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
              dateTime = DateTime.now().toString();

              if (allInfo.containsKey('browserName')) {
                switch (allInfo['browserName']) {
                  case BrowserName.firefox:
                    model = 'Mozilla Firefox';
                    break;
                  case BrowserName.samsungInternet:
                    model = 'Samsung Internet Browser';
                    break;
                  case BrowserName.opera:
                    model = 'Opera Web Browser';
                    break;
                  case BrowserName.msie:
                    model = 'Microsoft Internet Explorer';
                    break;
                  case BrowserName.edge:
                    model = 'Microsoft Edge';
                    break;
                  case BrowserName.chrome:
                    model = 'Google Chrome';
                    break;
                  case BrowserName.safari:
                    model = 'Apple Safari';
                    break;
                  default:
                    model = 'Unknown web browser';
                    break;
                }
              }
              else {
                model = (allInfo.containsKey('model') ? allInfo['model'].toString() 
                  : (devType == 'Windows' || devType == 'Linux' ? '$devType PC' 
                  : 'unknown'));
              }

              oem = (allInfo.containsKey('manufacturer') ? allInfo['manufacturer'].toString()
                : (devType == 'Web' ? allInfo['vendor'].toString()
                : (devType == 'Windows' || devType == 'Linux' ? '$devType PC'
                : devType == 'IOS' || devType == 'MacOS' ? 'Apple'
                : 'unknown')));
              os = (devType == 'Windows' ? allInfo['productName'].toString()
                : (devType == 'Linux' ? allInfo['prettyName'].toString()
                : (devType == 'MacOS' ? 'MacOS ${allInfo['osRelease']}'
                : (devType == 'IOS' ? '${allInfo['systemName']} ${allInfo['systemVersion']}'
                : (devType == 'Android' ? 'Android ${allInfo['version']}'
                : (devType == 'Web' ? 'Web browser'
                : 'unknown'))))));
            });
          },
        ),
      ),
    );
  }
}
