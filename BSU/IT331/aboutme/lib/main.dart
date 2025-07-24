//==============================================================
// Program Name:  AboutMe_Duqueza ()
// Description:   A personalized mobile application that 
//                features an "About Me" page.
// Author:        Geovani P. Duqueza
//==============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

void main() {
  Map<String, Object> user = {
    'fullName': 'Geovani P. Duqueza',
    'initials': 'GD',
    'bio': 'An IT enthusiast with a background in several fields.',
    'classSection': 'BSIT-ETEEAP/IT 3301',
    'course': 'Bachelor of Science in Information Technology (ETEEAP)',
    'age': 41,
    'hobbies': 'Reading, watching animé, playing video games, coding',
    'email': '24-00901@g.batstate-u.edu.ph',
    'profilePic': 'assets/images/profile-photo000.jpg',
  };

  runApp(MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: '${user['fullName']} (Profile Page)',
      home: AboutMe_Duqueza(user),
    ));
}

// ignore: camel_case_types, must_be_immutable
class AboutMe_Duqueza extends StatefulWidget {
  Map<String, Object> user = {};

  AboutMe_Duqueza(this.user, {super.key});
  
  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _AboutMeState(user);
  }
}

class _AboutMeState extends State<AboutMe_Duqueza> {
  Map<String, Object> user = {};
  bool fabVisible = true;
  bool profileDetailsVisible = false;
  List<Widget> visibleButtonLabel = <Widget>[
    Text('Show details', style: TextStyle(height: 1),),
    Icon(Icons.arrow_drop_down, semanticLabel: 'Show details',),
  ];
  int _currentPageIndex = 1;
  List<Widget> _pages = [];
  
  _AboutMeState(this.user) {
    _setDefaultPages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${_getInfo('fullName')} (Profile Page)'), backgroundColor: Colors.blueAccent,),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: UserAccountsDrawerHeader(
                accountName: Text(_getInfo('fullName')),
                accountEmail: Text(_getInfo('email')),
                currentAccountPictureSize: Size.square(50),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.grey,
                  foregroundImage: AssetImage(_getInfo('profilePic')),
                  child: Text(_getInfo('initials')),
                ),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              leading: const Icon(Icons.home, color: Colors.black,),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  _currentPageIndex = 0;
                  fabVisible = false;
                });
              },
            ),
            ListTile(
              title: const Text('My Profile'),
              leading: const Icon(Icons.account_circle, color: Colors.black,),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  _currentPageIndex = 1;
                  fabVisible = true;
                });
              },
            ),
            ListTile(
              title: const Text('My Contact Information'),
              leading: const Icon(Icons.contact_page, color: Colors.black,),
              onTap: () {
                setState(() {
                  Navigator.pop(context);
                  _currentPageIndex = 2;
                  fabVisible = false;
                });
              },

            ),
            ListTile(
              title: const Text('Exit'),
              leading: const Icon(Icons.exit_to_app, color: Colors.black,),
              enabled: true,
              onTap: () async {
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
                      exit(0);
                      // ignore: dead_code
                      break;
                    case 'IOS': case 'Android':
                      SystemNavigator.pop();
                      break;
                    case 'Web': case 'unknown':
                      Navigator.pop(context);
                      _simpleMsg('To close this app, please close the browser tab or window manually.', title: 'About Me');
                      break;
                  }
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: fabVisible,
        child: FloatingActionButton(
          tooltip: 'Toggle view details',
          onPressed: _showDetails,
          child: Icon(Icons.remove_red_eye_outlined),
        ),
      ),
      body: Container(
        // scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(15),
        child: _pages[_currentPageIndex],
      ),
    );
  }

  String _getInfo(String key) {
    return user[key].toString();
  }

  Future _simpleMsg(String msg, {String title = 'About Me'}) {
    return showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDetails() {

    setState(() {
      profileDetailsVisible = !profileDetailsVisible;

      visibleButtonLabel = <Widget>[
        Text('${profileDetailsVisible ? 'Hide' : 'Show'} details', style: TextStyle(height: 1),),
        Icon((profileDetailsVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down), semanticLabel: '${profileDetailsVisible ? 'Hide' : 'Show'} details',),
      ];

      _pages[1] = _generateProfilePage();
    });
  }
  
  Widget _generateHomePage() {
    return Center(child: Text('Home'));
  }
  
  Widget _generateProfilePage() {
    return Center(
      child: Card(
        elevation: 5,
        color: Colors.grey[400],
        child: Container(            
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    minRadius: 25,
                    maxRadius: 75,
                    backgroundColor: Colors.grey,
                    foregroundImage: AssetImage(_getInfo('profilePic')),
                    child: Text('GD'),
                  ),
                  SizedBox(width: 25),
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_getInfo('fullName').toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),),
                        Text('${_getInfo('age')} years old',),
                        SizedBox(height: 12),
                        Text(_getInfo('bio'), style: TextStyle(fontStyle: FontStyle.italic),),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _showDetails,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: visibleButtonLabel,
                ),
              ),
              Visibility(
                visible: profileDetailsVisible,
                child: Table(
                  defaultColumnWidth: IntrinsicColumnWidth(),
                  textBaseline: TextBaseline.alphabetic,
                  defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                  children: List<TableRow>.of(
                    [
                      null, ['Course', 'course'],
                      null, ['Class/Section', 'classSection'],
                      null, ['Hobbies', 'hobbies'],
                    ].map(
                      (i)=>(i == null ? TableRow(children: List<SizedBox>.generate(3, (i)=>SizedBox(height: 10,)),) 
                        : TableRow(
                          children: [
                            Text(i[0], style: TextStyle(fontWeight: FontWeight.bold),),
                            SizedBox(width: 10),
                            Text(_getInfo(i[1])),
                          ],
                        )
                      )
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _generateContactInfoPage() {
    return Center(child: Text('Contact Info'));
  }
  
  void _setDefaultPages() {
    _pages = [
      _generateHomePage(),
      _generateProfilePage(),
      _generateContactInfoPage(),
    ];
  }
}
