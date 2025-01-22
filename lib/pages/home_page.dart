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

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    super.initState();
  }

  //open new expenseBox
  void openNewExpenseBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
      return Scaffold(
        body: ListView.builder(
            itemCount: value.allExpense.length,
            itemBuilder: (context, index) {
              //get individual expense
              Expense individualExpense = value.allExpense[index];

              //return list title UI
              return MyListTile(
                title: individualExpense.name,
                trailing: formatAmount(individualExpense.amount),
                onEditPressed: (context) => openEditBox(individualExpense),
                onDeletePressed: (context) => openDeleteBox(individualExpense),
              );
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          child: Icon(Icons.add),
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
      },
      child: Text("Delete"),
    );
  }
}
