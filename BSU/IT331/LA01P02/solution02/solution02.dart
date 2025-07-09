//==============================================================
// Program Name:  Simple Calculator
// Description:   Computes the sum, difference, product, and 
//                quotient on two numbers provided by the user.
// Author:        Geovani P. Duqueza
//==============================================================

import 'dart:io';

void main(List<String> arguments) {
  // declare variables
  num? num1, num2;

  // collect user input
  stdout.write('Enter first number: ');
  num1 = num.parse(stdin.readLineSync()!);

  stdout.write('Enter second number: ');
  num2 = num.parse(stdin.readLineSync()!);

  // display results
  print('Sum: ${num1 + num2}');
  print('Difference: ${num1 - num2}');
  print('Product: ${num1 * num2}');
  print('Quotient: ${num2 == 0 ? (num1 == 0 ? '\u221e' : 'undefined') : num1 / num2}');
}
