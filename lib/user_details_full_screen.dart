import 'package:flutter/material.dart';
import 'transaction.dart';

// Full-screen details page
class UserDetailsFullScreen extends StatefulWidget {
  final int index;
  final String userName;
  final List<String> userNames;
  final List<Transaction> transactions;

  const UserDetailsFullScreen({
    Key? key,
    required this.index,
    required this.userName,
    required this.userNames,
    required this.transactions,
  }) : super(key: key);

  @override
  _UserDetailsFullScreenState createState() => _UserDetailsFullScreenState();
}

class _UserDetailsFullScreenState extends State<UserDetailsFullScreen> {
  late List<Transaction> _transactions;

  @override
  void initState() {
    super.initState();
    _transactions = List.from(widget.transactions);
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, Transaction transaction, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Transaction"),
        content: Text(
            "Are you sure you want to delete this transaction?\n\n" +
                "${transaction.payerId} paid \$${transaction.amount.toStringAsFixed(2)}" +
                (transaction.description.isNotEmpty ? " for ${transaction.description}" : "")
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // Delete the transaction
              setState(() {
                _transactions.removeAt(index);

                // Also delete from the parent list to keep consistency
                final parentIndex = widget.transactions.indexOf(transaction);
                if (parentIndex != -1) {
                  widget.transactions.removeAt(parentIndex);
                }
              });

              Navigator.pop(context);

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transaction deleted'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  )
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate balances for this user
    Map<String, Map<String, double>> balances =
    BalanceCalculator.calculateBalances(_transactions, widget.userNames);

    // Filter transactions related to this user
    List<Transaction> userTransactions = _transactions.where((transaction) =>
    transaction.payerId == widget.userName || transaction.splitBetween.contains(widget.userName)
    ).toList();

    print("Displaying ${userTransactions.length} transactions for ${widget.userName}");

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
                  child: ListView.builder(
                    itemCount: widget.userNames.length,
                    itemBuilder: (context, i) {
                      if (i == widget.index) return SizedBox.shrink(); // Skip self

                      String otherUser = widget.userNames[i];
                      double youOweAmount = balances[widget.userName]?[otherUser] ?? 0;
                      double theyOweAmount = balances[otherUser]?[widget.userName] ?? 0;

                      // Skip if there's no debt in either direction
                      if (youOweAmount == 0 && theyOweAmount == 0) return SizedBox.shrink();

                      // Determine the net relationship
                      double netAmount;
                      bool youOwe;

                      if (youOweAmount > 0) {
                        netAmount = youOweAmount;
                        youOwe = true;
                      } else if (theyOweAmount > 0) {
                        netAmount = theyOweAmount;
                        youOwe = false;
                      } else {
                        return SizedBox.shrink(); // No debt
                      }

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: youOwe ? Colors.red.shade300 : Colors.green.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: youOwe ? Colors.red.shade100 : Colors.green.shade100,
                                child: Icon(
                                  youOwe
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: youOwe ? Colors.red : Colors.green,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      youOwe
                                          ? "You owe ${otherUser}"
                                          : "${otherUser} owes you",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      youOwe
                                          ? "You need to pay ${otherUser}"
                                          : "You need to receive from ${otherUser}",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "\$${netAmount.abs().toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: youOwe ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                  child: userTransactions.isEmpty
                      ? Center(
                    child: Text(
                      "No transactions yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    itemCount: userTransactions.length,
                    itemBuilder: (context, i) {
                      Transaction transaction = userTransactions[i];
                      bool isPayer = transaction.payerId == widget.userName;

                      // Debug print to verify transaction building
                      print("Building transaction card $i for ${transaction.payerId} amount: ${transaction.amount}");

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            _showDeleteConfirmationDialog(context, transaction, i);
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isPayer ? Colors.blue.shade100 : Colors.amber.shade100,
                              child: Icon(
                                isPayer ? Icons.payments : Icons.account_balance_wallet,
                                color: isPayer ? Colors.blue : Colors.amber,
                              ),
                            ),
                            title: Text(
                              isPayer
                                  ? "You paid \$${transaction.amount.toStringAsFixed(2)}"
                                  : "${transaction.payerId} paid \$${transaction.amount.toStringAsFixed(2)}",
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Split between: ${transaction.splitBetween.join(', ')}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (transaction.description.isNotEmpty)
                                  Text(
                                    "Description: ${transaction.description}",
                                    style: TextStyle(fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${transaction.dateTime.day}/${transaction.dateTime.month}/${transaction.dateTime.year}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                              ],
                            ),
                            isThreeLine: transaction.description.isNotEmpty,
                          ),
                        ),
                      );
                    },
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