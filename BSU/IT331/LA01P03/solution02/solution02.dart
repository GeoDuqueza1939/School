//==============================================================
// Program Name:  Appliance Class (Constructors and Getters)
// Description:   Creates an object and displays its properties
//                using a getter.
// Author:        Geovani P. Duqueza
//==============================================================

import 'dart:io';

void main(List<String> arguments) {
  // declare variables
  String? brandName;
  num? powerRating;
  Appliance app;

  // create appliance
  stdout.write('Enter brand name: ');
  brandName = stdin.readLineSync();

  stdout.write('Enter power rating: ');
  powerRating = num.parse(stdin.readLineSync()!);

  app = new Appliance(brandName, powerRating);

  print(''); // separator

  // display info using getter
  print(app.info);
}

class Appliance {
  // properties
  String? appBrand;
  num? appPower;

  // constructor
  Appliance(String? brand, num power) {
    appBrand = brand;
    appPower = power;
  }

  // methods
  String? get info {
    return 'Brand: $appBrand, Power: ${appPower}W';
  }
}