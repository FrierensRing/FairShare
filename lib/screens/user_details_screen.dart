// screens/user_details_screen.dart - Full-screen details for a user
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/data_manager.dart';
import '../utils/balance_calculator.dart';
import '../dialogs/delete_confirmation_dialog.dart';
import '../widgets/balance_summary_widget.dart';
import '../widgets/transaction_list_widget.dart';

class UserDetailsScreen extends StatefulWidget {
  final int index;
  final String userName;
  final List<String> userNames;
  final List<Transaction> transactions;

  const UserDetailsScreen({
    Key? key,
    required this.index,
    required this.userName,
    required this.userNames,
    required this.transactions,
  }) : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late List<Transaction> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = List.from(widget.transactions);
  }

  // Handle transaction deletion
  Future<void> _handleDeleteTransaction(Transaction transaction, int index) async {
    bool confirmed = await DeleteConfirmationDialogs.showDeleteTransactionDialog(
      context, 
      transaction
    );
    
    if (confirmed) {
      setState(() {
        _transactions.removeAt(index);

        // Also delete from the parent list to keep consistency
        final parentIndex = widget.transactions.indexOf(transaction);
        if (parentIndex != -1) {
          widget.transactions.removeAt(parentIndex);
        }
      });

      // Save updated transactions to persist the changes
      await DataManager.saveTransactions(widget.transactions);

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction deleted'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        )
      );
    }
  }

  // Handle user deletion
  Future<void> _handleDeleteUser() async {
    bool confirmed = await DeleteConfirmationDialogs.showDeleteUserDialog(
      context, 
      widget.userName
    );
    
    if (confirmed) {
      // Get the current user index to be removed
      final userIndex = widget.userNames.indexOf(widget.userName);

      if (userIndex != -1) {
        // Create a copy of the userNames list without the deleted user
        final updatedUserNames = List<String>.from(widget.userNames);
        updatedUserNames.removeAt(userIndex);

        // Always remove all transactions where this user is the payer or part of the split
        List<Transaction> updatedTransactions = widget.transactions.where((transaction) =>
          transaction.payerId != widget.userName &&
          !transaction.splitBetween.contains(widget.userName)
        ).toList();

        // Save the updated data
        await DataManager.saveUsers(updatedUserNames);
        await DataManager.saveTransactions(updatedTransactions);

        // Return to main page
        Navigator.pop(context); 

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User deleted along with their transactions'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter transactions related to this user
    List<Transaction> userTransactions = _transactions.where((transaction) =>
      transaction.payerId == widget.userName || transaction.splitBetween.contains(widget.userName)
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.userName}'s Balance"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Balance Summary",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Single Expanded widget containing both sections
          Expanded(
            child: Column(
              children: [
                // Balance section - takes 50% of space
                Expanded(
                  flex: 1,
                  child: BalanceSummaryWidget(
                    userName: widget.userName,
                    userIndex: widget.index,
                    userNames: widget.userNames,
                    transactions: _transactions,
                  ),
                ),

                // Transaction history header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Transaction History",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Transaction history section - takes 50% of space
                Expanded(
                  flex: 1,
                  child: TransactionListWidget(
                    userName: widget.userName,
                    transactions: userTransactions,
                    onDeleteTap: _handleDeleteTransaction,
                  ),
                ),

                // Delete user button at the bottom
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.person_remove_outlined, color: Colors.white),
                      label: Text("Delete ${widget.userName}", style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _handleDeleteUser,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}