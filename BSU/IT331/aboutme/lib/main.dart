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
  runApp(MaterialApp(home: AboutMe_Duqueza()));
}

// ignore: camel_case_types
class AboutMe_Duqueza extends StatefulWidget {
  const AboutMe_Duqueza({super.key});
  
  @override
  State<StatefulWidget> createState() => _AboutMeState();
}

class _AboutMeState extends State<AboutMe_Duqueza> with RouteMixin {
  final Map<String, Object> user = {
    'fullName': 'Geovani P. Duqueza',
    'initials': 'GD',
    'bio': 'An IT enthusiast with a background in other fields.',
    'classSection': 'BSIT-ETEEAP/IT 3301',
    'course': 'Bachelor of Science in Information Technology (ETEEAP)',
    'age': 41,
    'hobbies': 'Reading, watching animé, playing video games, coding',
    'email': '24-00901@g.batstate-u.edu.ph',
    'profilePic': 'assets/images/profile-photo000.jpg',
  };
  bool fabVisible = false;
  bool profileDetailsVisible = false;
  List<Widget> visibleButtonLabel = <Widget>[
    Text('Show details', style: TextStyle(height: 1),),
    Icon(Icons.arrow_drop_down, semanticLabel: 'Show details',),
  ];
  int _currentPageIndex = 0;
  List<Widget> _pages = [];
  IconData darkModeIcon = Icons.dark_mode;
  ThemeMode themeMode = ThemeMode.light;
  ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
      brightness: Brightness.light,
    ),
    fontFamily: 'Lora',
  );
  ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.black54,
      primary: Colors.grey,
      brightness: Brightness.dark,
    ),
    fontFamily: 'Lora',
  );
  
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ContactMe contactMe = ContactMe();

    return MaterialApp(
      title: '${user['fullName']} (Profile Page)',
      routes: {
        "home": (context) {
            _setDefaultPages();
            return Scaffold(
              appBar: AppBar(
                title: Text('${_getInfo('fullName')} (Profile Page)'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
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
                          // backgroundColor: Colors.grey,
                          foregroundImage: AssetImage(_getInfo('profilePic')),
                          child: Text(_getInfo('initials')),
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Home'),
                      leading: const Icon(
                        Icons.home,
                        // color: Colors.black,
                      ),
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
                      leading: const Icon(
                        Icons.account_circle,
                        // color: Colors.black,
                      ),
                      onTap: () {
                        setState(() {
                          Navigator.pop(context);
                          _currentPageIndex = 1;
                          fabVisible = true;
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('My Hobbies'),
                      leading: const Icon(
                        Icons.toys_rounded,
                      ),
                      onTap: () {
                        setState(() {
                          viewRoute((context)=>HobbiesMoreInfo(), context, fromDrawer: true);
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('My Skills'),
                      leading: const Icon(
                        Icons.contact_page,
                      ),
                      onTap: () {
                        setState(() {
                          viewRoute((context)=>SkillsInfo(), context, fromDrawer: true);
                        });
                      },

                    ),
                    ListTile(
                      title: const Text('Contact Information'),
                      leading: const Icon(
                        Icons.contact_page,
                      ),
                      onTap: () {
                        setState(() {
                          // viewRoute((context)=>ContactMe(), context, fromDrawer: true);
                          Navigator.pop(context);
                          Navigator.pushNamed(context, "contact");
                        });
                      },

                    ),
                    ListTile(
                      title: const Text('Toggle Dark Mode'),
                      leading: Icon(
                        darkModeIcon,
                        // color: Colors.black,
                      ),
                      onTap: () {
                        setState(() {
                          Navigator.pop(context);
                          if (darkModeIcon == Icons.dark_mode) {
                            darkModeIcon = Icons.sunny;
                            themeMode = ThemeMode.dark;
                          }
                          else {
                            darkModeIcon = Icons.dark_mode;
                            themeMode = ThemeMode.light;
                          }
                        });
                      },
                    ),
                    ListTile(
                      title: const Text('Exit'),
                      leading: const Icon(
                        Icons.exit_to_app,
                        // color: Colors.black,
                      ),
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
          },
        // "hobbies": (context) {},
        // "skills": (context) {},
        "contact": contactMe.builder,
      },
      initialRoute: "home",
      // home: 
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
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
    return Center(child: Text('Welcome to My Profile!', style: Theme.of(context).textTheme.headlineMedium));
  }
  
  Widget _generateProfilePage() {
    return Center(
      child: Card(
        elevation: 5,
        // color: Colors.grey[400],
        child: Container(            
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:(context)=>SimpleDialog(
                          title: Text("About Me"),
                          contentPadding: EdgeInsets.all(25),
                          children: [
                            Text("Please don't obsess on my gorgeous photo too much."),
                            SizedBox(height: 25),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("OK"),
                            ),
                          ],
                        )
                      );
                    },
                    child: CircleAvatar(
                      minRadius: 25,
                      maxRadius: 75,
                      // backgroundColor: Colors.grey,
                      foregroundImage: AssetImage(_getInfo('profilePic')),
                      child: Text('GD'),
                    ),
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
                        Text(_getInfo('bio'), style: TextStyle(fontFamily: 'Dancing Script', fontSize: 18),),
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
                      null, ['', 'hobbies'],
                    ].map(
                      (i)=>(i == null ? TableRow(children: List<SizedBox>.generate(3, (i)=>SizedBox(height: 10,)),) 
                        : TableRow(
                          children: [
                            Text(i[0], style: TextStyle(fontWeight: FontWeight.bold),),
                            SizedBox(width: 10),
                            (i[0] == "" ? TextButton(onPressed: () {viewRoute((context)=>HobbiesMoreInfo(), context);}, child: Text("View Detailed Hobbies"))
                              : GestureDetector(
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder:(context) {
                                      return AlertDialog(
                                        title: Text("About Me"),
                                        contentPadding: EdgeInsets.all(25),
                                        content: Text("You have long pressed on my hobbies. Please click the button [View Detailed Hobbies] for more details."),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text("OK"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Text(_getInfo(i[1])),
                              )
                            ),
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

class HobbiesMoreInfo extends StatelessWidget with RouteMixin {
  const HobbiesMoreInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Hobbies"),
            automaticallyImplyLeading: false,
            leading: IconButton (
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // viewRoute((context)=>AboutMe_Duqueza(), context);
                Navigator.pop(context);
              },
            ),
          ),
          body: ListView(
            children: <Widget>[
              ListTile(
                leading: Text("Favorite Books"),
                title: Text("Harry Potter, Lord of the Rings, any Stephen King novel"),
              ),
              ListTile(
                leading: Text("Favorite Anime"),
                title: Text("Pokemon, Arifureta, Re:ZERO, any animé of the isekai genre"),
              ),
              ListTile(
                leading: Text("Favorite Video Games"),
                title: Text("Starcraft/Starcraft II, Dungeon and Dragons Online, Warcraft (any installment)"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SkillsInfo extends StatelessWidget with RouteMixin {
  const SkillsInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Skills"),
            automaticallyImplyLeading: false,
            leading: IconButton (
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                // viewRoute((context)=>AboutMe_Duqueza(), context);
                Navigator.pop(context);
              },
            ),
          ),
          body: ListView(
            children: <Widget>[
              ListTile(
                leading: Text("IT Skills"),
                title: Text("Programming; IT Management; Computer Systems Servicing"),
              ),
              ListTile(
                leading: Text("Programming Languages"),
                title: Text("VB6; VB.Net; VBScript; JavaScript; C++; C#; PHP; Python; Dart;"),
              ),
              ListTile(
                leading: Text("Other Skills"),
                title: Text("Clerical; Cookery"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ContactMe extends StatelessWidget with RouteMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactMe({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: builder,
    );
  }

  Widget builder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Me"),
        automaticallyImplyLeading: false,
        leading: IconButton (
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // viewRoute((context)=>AboutMe_Duqueza(), context);
            Navigator.pop(context);
          },
        ),
      ),
      body: Form(
        key: _formKey,
        // autovalidateMode: AutovalidateMode.always,
        child: ListView(
          children: <Widget>[
            ListTile(
              leading: Text("Email Address"),
              title: Text("24-00901@g.batstate-u.edu.ph"),
            ),
            ListTile(
              leading: Text("Phone Number"),
              title: Text("09153032914"),
            ),
            SizedBox(height: 25),
            ListTile(
              leading: Text("Send Feedback"),
              title: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Sender Name"),
                    initialValue: "",
                    validator: (String? value) {
                      return (value!.isEmpty ? "Should not be empty" : null);
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Email"),
                    initialValue: "",
                    validator: (String? value) {
                      final regex = RegExp(r"^\w[\w\.-]*@\w[\w\.-]*\.[a-zA-Z]{2,}$");

                      return (!regex.hasMatch(value!) ? 'Invalid email address' : null);
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: "Message/Comment"),
                    minLines: 5,
                    maxLines: 10,
                    validator: (String? value) {
                      return (value!.isEmpty ? "Should not be empty" : (value.length < 10 ? "Message is too short" : null));
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Successfully submitted data!")
                    ),
                  );
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please check the fields for invalid inputs.")
                    ),
                  );
                }
              },
              child: Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

mixin RouteMixin {
  void viewRoute(WidgetBuilder f, BuildContext context, {bool fromDrawer = false}) {
    if (fromDrawer) Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: f));
  }
}