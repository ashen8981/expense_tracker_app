import 'package:expense_track/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

/*
  Setup
  */

//initialize db
  static Future<void> initialize() async {
    final dir = await getApplicationSupportDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

/*
  getters
  */

  List<Expense> get allExpense => _allExpenses;

/*
  operations
  */

//create - add a new expense
  Future<void> createNewExpense(Expense newExpense) async {
    //add to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    //re-read from db
    await readExpenses();
  }

//read - expense from db
  Future<void> readExpenses() async {
    //fetch all existing from db
    List<Expense> fetchExpenses = await isar.expenses.where().findAll();

    //give to local expenses to list
    _allExpenses.clear();
    _allExpenses.addAll(fetchExpenses);

    //update UI
    notifyListeners();
  }

  //update - edit an expense in db
  Future<void> updateExpense(int id, Expense updateExpense) async {
    //make sure new expense has same id as existing one
    updateExpense.id = id;

    ///check

    //update in db
    await isar.writeTxn(() => isar.expenses.put(updateExpense));

    //re-read from db
    await readExpenses();
  }

  //delete delete an expense
  Future<void> deleteExpense(int id) async {
    //delete from db
    await isar.writeTxn(() => isar.expenses.delete(id));

    //re-read from db
    await readExpenses();
  }

/*
 helper
  */

  //calculate total expenses for each month
  Future<Map<String, double>> calculateMonthlyTotals() async {
    //ensure the expenses are read from the database
    await readExpenses();

    //create a map to keep track of total expenses per month,year
    Map<String, double> monthlyTotals = {};

    //iterate over all expenses
    for (var expense in _allExpenses) {
      //extract the year & month from the date of the expense
      String yearMonth = '${expense.date.year}-${expense.date.month}';

      //if the year-month is not the amp yet initialize it to 0
      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }

      //add the expense for the total for the month
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }
    return monthlyTotals;
  }

  //calculate current month total
  Future<double> calculateCurrentMonthTotal() async {
    //ensure expenses are read from db first
    await readExpenses();

    //get current month , year
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    //filter the expenses to include only  those for this month this year
    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth && expense.date.year == currentYear;
    }).toList();

    //calculate the total for the current month
    double total = currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);

    return total;
  }

  //get start month
  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month; //default to current month if no expense is recorded
    }

    //sort expense by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );
    return _allExpenses.first.date.month;
  }

  //get start year
  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year; //default to current month if no expense is recorded
    }

    //sort expense by date to find the earliest
    _allExpenses.sort(
      (a, b) => a.date.compareTo(b.date),
    );
    return _allExpenses.first.date.year;
  }
}
