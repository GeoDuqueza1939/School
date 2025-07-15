//==============================================================
// Program Name:  BasicApp (Basic Flutter Interface
//                with Functional UI)
// Description:   An app that shows a basic profile
// Author:        Geovani P. Duqueza
//==============================================================

import 'package:flutter/material.dart';

void main() {
  runApp(BasicApp());
}

class BasicApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Profile Banner')),
        body: Center(
          child: Container(
            width: 350,
            height: 200,
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))
              ]
            ),
            child: Column(
              children: <Widget>[
                Text(
                  'Juan Dela Cruz',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                Text('<SECTION>', style: TextStyle(fontSize: 16)),
                SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.call_rounded, color: Colors.red),
                    SizedBox(width: 8),
                    Text('09123456789'),
                    SizedBox(width: 25),
                    Icon(Icons.email, color: Colors.white),
                    SizedBox(width: 8),
                    Text('juan@email.com'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
