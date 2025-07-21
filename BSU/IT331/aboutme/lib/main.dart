//==============================================================
// Program Name:  AboutMe_Duqueza ()
// Description:   A personalized mobile application that 
//                features an "About Me" page.
// Author:        Geovani P. Duqueza
//==============================================================

import 'package:flutter/material.dart';

void main() {
  runApp(const AboutMe_Duqueza());
}

// ignore: camel_case_types
class AboutMe_Duqueza extends StatefulWidget {
  const AboutMe_Duqueza({super.key});
  
  @override
  State<StatefulWidget> createState() => AboutMeState();
}

// ignore: camel_case_types
class AboutMeState extends State<AboutMe_Duqueza> {
  String fullName = 'Geovani P. Duqueza';
  String bio = 'An IT enthusiast with a background in several fields.';
  String classSection = 'BSIT-ETEEAP/IT 3301';
  String course = 'Bachelor of Science in Information Technology (ETEEAP)';
  String age = '41';
  String hobbies = 'Reading, watching animé, playing video games, coding';
  String accountEmail = '24-00901@g.batstate-u.edu.ph';
  bool visible = false;
  List<Widget> visibleButtonLabel = <Widget>[
    Text('Show details', style: TextStyle(height: 1),),
    Icon(Icons.arrow_drop_down, semanticLabel: 'Show details',),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$fullName (Profile Page)',
      home: Scaffold(
        appBar: AppBar(title: Text('$fullName (Profile Page)'), backgroundColor: Colors.blueAccent,),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: UserAccountsDrawerHeader(
                  accountName: Text(fullName),
                  accountEmail: Text(accountEmail),
                  currentAccountPictureSize: Size.square(50),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.grey,
                    foregroundImage: AssetImage('assets/images/profile-photo000.jpg'),
                    child: Text('GD'),
                  ),
                ),
              ),
              const ListTile(
                title: Text('Home'),
                leading: Icon(Icons.home, color: Colors.black,)
              ),
              const ListTile(
                title: Text('My Profile'),
                leading: Icon(Icons.account_circle, color: Colors.black,)
              ),
              const ListTile(
                title: Text('Exit'),
                leading: Icon(Icons.exit_to_app, color: Colors.black,)
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Toggle view details',
          onPressed: showDetails,
          child: Icon(Icons.remove_red_eye_outlined),
        ),
        body: Container(
          // scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(15),
          child: Center(
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
                          foregroundImage: AssetImage('assets/images/profile-photo000.jpg'),
                          child: Text('GD'),
                        ),
                        SizedBox(width: 25),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(fullName.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,),),
                              Text('$age years old',),
                              SizedBox(height: 12),
                              Text(bio, style: TextStyle(fontStyle: FontStyle.italic),),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: showDetails,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: visibleButtonLabel,
                      ),
                    ),
                    Visibility(
                      visible: visible,
                      child: Table(
                        defaultColumnWidth: IntrinsicColumnWidth(),
                        textBaseline: TextBaseline.alphabetic,
                        defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                        children: [
                          TableRow(
                            children: [
                              SizedBox(height: 10,),
                              SizedBox(height: 10,),
                              SizedBox(height: 10,),
                            ],
                          ),
                          TableRow(
                            children: [
                              Text('Course', style: TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(width: 10),
                              Text(course),
                            ],
                          ),
                          TableRow(
                            children: [
                              SizedBox(height: 10,),
                              SizedBox(height: 10,),
                              SizedBox(height: 10,),
                            ],
                          ),
                          TableRow(
                            children: [
                              Text('Class/Section', style: TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(width: 10),
                              Text(classSection),
                            ],
                          ),
                          TableRow(
                            children: [
                              SizedBox(height: 10,),
                              SizedBox(height: 10,),
                              SizedBox(height: 10,),
                            ],
                          ),
                          TableRow(
                            children: [
                              Text('Hobbies', style: TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(width: 10),
                              Text(hobbies),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showDetails() {
    setState(() {
      visible = !visible;

      visibleButtonLabel = <Widget>[
        Text('${visible ? 'Hide' : 'Show'} details', style: TextStyle(height: 1),),
        Icon((visible ? Icons.arrow_drop_up : Icons.arrow_drop_down), semanticLabel: '${visible ? 'Hide' : 'Show'} details',),
      ];
    });
  }
}
