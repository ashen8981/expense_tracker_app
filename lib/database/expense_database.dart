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
  Future<Map<int, double>> calculateMonthlyTotals() async {
    //ensure the expenses are read from the database
    await readExpenses();

    //create a map to keep track of total expenses per month
    Map<int, double> monthlyTotals = {};

    //iterate over all expenses
    for (var expense in _allExpenses) {
      //extract the month from the date of the expense
      int month = expense.date.month;

      //if the month is not the amp yet initialize it to 0
      if (!monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = 0;
      }

      //add the expense for the total for the month
      monthlyTotals[month] = monthlyTotals[month]! + expense.amount;
    }
    return monthlyTotals;
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
