//==============================================================
// Program Name:  Personal Info Display
// Description:   Collects a user's name and age, then displays
//                a personalized greeting.
// Author:        Geovani P. Duqueza
//==============================================================

import 'dart:io';

void main(List<String> arguments) {
  String? name;
  int? age;

  // collect user data
  stdout.write('Enter your name: ');
  name = stdin.readLineSync();

  stdout.write('Enter your age: ');
  age = int.parse(stdin.readLineSync()!);

  // display greeting
  print('Hello, $name! You are $age years old.');
}
