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
  static Future<void> initialize() async{
    final dir = await getApplicationSupportDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

/*
  getters
  */

  List<Expense> get allExpenses => _allExpenses;

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
    updateExpense.id = id;  ///check

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
}
