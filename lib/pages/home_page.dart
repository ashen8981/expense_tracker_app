import 'package:expense_track/barGrapgh/bar_graph.dart';
import 'package:expense_track/components/my_list_tile.dart';
import 'package:expense_track/database/expense_database.dart';
import 'package:expense_track/helpers/helper_functions.dart';
import 'package:expense_track/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //text controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  //futures to load graph data & month total
  Future<Map<String, double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    //read db in initial start up
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();

    //load futures
    refreshData();

    super.initState();
  }

  //refresh the graph data
  void refreshData() {
    //refresh the graph data
    _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context, listen: false).calculateMonthlyTotals();
    //calculate current month total
    _calculateCurrentMonthTotal = Provider.of<ExpenseDatabase>(context, listen: false).calculateCurrentMonthTotal();
  }

  //open new expenseBox
  void openNewExpenseBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)), // 8px curve on corners
              ),
              title: Text("New Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //user input -> expense name
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: "Expense name"),
                  ),
                  //user input -> expense amount
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(hintText: "Expense amount"),
                  )
                ],
              ),
              actions: [
                //cancel button
                _cancelButton(),
                //save button
                _createNewExpenseButton()
              ],
            ));
  }

  //open edit box
  void openEditBox(Expense expense) {
    //pre filled existing values to editfields
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Edit Expense"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //user input -> expense name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(hintText: existingName),
                  ),
                  //user input -> expense amount
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(hintText: existingAmount),
                  )
                ],
              ),
              actions: [
                //cancel button
                _cancelButton(),
                //save button
                _editExpenseButton(expense)
              ],
            ));
  }

  //open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Edit Expense"),
              actions: [
                //cancel button
                _cancelButton(),
                //delete button
                _deleteExpenseButton(expense.id)
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(builder: (context, value, child) {
      //get dates
      int startMonth = value.getStartMonth();
      int startYear = value.getStartYear();
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      //calculate the numbed of month since the first month
      int monthCount = calculateMonthCount(startYear, startMonth, currentYear, currentMonth);

      //only display the expenses for the current month
      List<Expense> currentMonthExpenses = value.allExpense.where((expense) {
        return expense.date.year == currentYear && expense.date.month == currentMonth;
      }).toList();

      //return UI
      return Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: FutureBuilder<double>(
            future: _calculateCurrentMonthTotal,
            builder: (context, snapshot) {
              //loaded
              if (snapshot.connectionState == ConnectionState.done) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("\$${snapshot.data!.toStringAsFixed(2)}"), Text(getCurrentMonthName())],
                );
              }
              //loading
              else {
                return Text("loading...");
              }
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              //Graph UI
              SizedBox(
                height: 250,
                child: FutureBuilder(
                  future: _monthlyTotalsFuture,
                  builder: (context, snapshot) {
                    //data is loaded
                    if (snapshot.connectionState == ConnectionState.done) {
                      Map<String, double> monthlyTotals = snapshot.data ?? {};

                      //create the list of monthly summary
                      List<double> monthlySummary = List.generate(monthCount, (index) {
                        //calculate the year and month considering start month & index
                        int year = startYear + (startMonth + index - 1) ~/ 12;
                        int month = (startMonth + index - 1) % 12 + 1;

                        //create the key in format year-month
                        String yearMonthKey = '$year-$month';

                        //return total for year-month or 0.0 if non exist
                        return monthlyTotals[yearMonthKey] ?? 0.0;
                      });

                      return MyBarGraph(monthlySummary: monthlySummary, startMonth: startMonth);
                    }
                    //loading
                    else {
                      return Center(child: Text("Loading..."));
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              //Expense List UI
              Expanded(
                child: ListView.builder(
                    itemCount: currentMonthExpenses.length,
                    itemBuilder: (context, index) {
                      //reverse the index to show latest item first
                      int reversedIndex = currentMonthExpenses.length - 1 - index;

                      //get individual expense
                      Expense individualExpense = currentMonthExpenses[reversedIndex];

                      //return list title UI
                      return MyListTile(
                        title: individualExpense.name,
                        trailing: formatAmount(individualExpense.amount),
                        onEditPressed: (context) => openEditBox(individualExpense),
                        onDeletePressed: (context) => openDeleteBox(individualExpense),
                      );
                    }),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.grey.shade200,
          onPressed: openNewExpenseBox,
          child: Icon(
            Icons.add,
            color: Colors.grey.shade800,
            size: 35,
          ),
        ),
      );
    });
  }

  //cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        //pop box
        Navigator.pop(context);

        //clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: Text("Cancel"),
    );
  }

  //save button-> create new expense
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        //only saves if there is something in the text field to save
        if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //create new expense
          Expense newExpense = Expense(
              name: nameController.text, amount: convertStringToDouble(amountController.text), date: DateTime.now());

          //save to db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);

          //refresh graph
          refreshData();

          //clear controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: Text("Save"),
    );
  }

  //save button-> edit existing expense
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        //save as lon as at least one text field has been changed
        if (nameController.text.isNotEmpty || amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);

          //create a new updated expense
          Expense updatedExpense = Expense(
              name: nameController.text.isNotEmpty ? nameController.text : expense.name,
              amount: amountController.text.isNotEmpty ? convertStringToDouble(amountController.text) : expense.amount,
              date: DateTime.now());

          //old expense id
          int expenseId = expense.id;

          //save to database
          await context.read<ExpenseDatabase>().updateExpense(expenseId, updatedExpense);

          //refresh graph
          refreshData();
        }
      },
      child: Text("Save"),
    );
  }

  //delete button
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        //pop box
        Navigator.pop(context);

        //delete expense from db
        await context.read<ExpenseDatabase>().deleteExpense(id);

        //refresh graph
        refreshData();
      },
      child: Text("Delete"),
    );
  }
}
