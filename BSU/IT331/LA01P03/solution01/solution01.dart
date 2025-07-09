//==============================================================
// Program Name:  Gadget Class (Classes and Methods)
// Description:   A Dart program with a Gadget class that
//                displays a gadget's name and type.
// Author:        Geovani P. Duqueza
//==============================================================

import 'dart:io';

void main(List<String> arguments) {
  // declare variables
  String? name, type;
  Gadget g;

  // create gadget using user input
  stdout.write('Enter gadget name: ');
  name = stdin.readLineSync();

  stdout.write('Enter gadget type: ');
  type = stdin.readLineSync();

  g = new Gadget(name, type);

  print(''); // separator

  // display gadget info
  g.displayInfo();
}

class Gadget {
  // properties
  String? name;
  String? type;

  // constructor
  Gadget(name, type) {
    this.name = name;
    this.type = type;
  }

  // methods
  void displayInfo() {
    print('Gadget Name: $name\nGadget Type: $type');
  }
}