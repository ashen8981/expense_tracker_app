/*
These are some helpful functions used across the app
*/

import 'package:intl/intl.dart';

//convert string to a double
double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

//format double value to dollars and cents
String formatAmount(double amount) {
  final format = NumberFormat.currency(locale: "en_us", symbol: "\$", decimalDigits: 2);
  return format.format(amount);
}

//calculate the number of months since the first start month
int calculateMonthCount(int startYear, startMonth, currentYear, currentMonth) {
  int monthCount = (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

//get current month name
String getCurrentMonthName() {
  DateTime now = DateTime.now();
  List<String> months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
  return months[now.month - 1]; // Get the current month by using the month index
}
