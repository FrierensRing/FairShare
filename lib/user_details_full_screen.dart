import 'package:flutter/material.dart';
import 'transaction.dart';

// Full-screen details page
class UserDetailsFullScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Calculate balances for this user
    Map<String, Map<String, double>> balances =
    BalanceCalculator.calculateBalances(transactions, userNames);

    return Scaffold(
      appBar: AppBar(
        title: Text("${userName}'s Balance"),
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

          // User Owes Others
          Expanded(
            child: ListView.builder(
              itemCount: userNames.length,
              itemBuilder: (context, i) {
                if (i == index) return SizedBox.shrink(); // Skip self

                String otherUser = userNames[i];
                double amount = balances[userName]?[otherUser] ?? 0;
                bool isPositive = amount > 0;

                // Only show entries where there's a balance
                if (amount == 0) return SizedBox.shrink();

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isPositive ? Colors.red.shade300 : Colors.green.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isPositive ? Colors.red.shade100 : Colors.green.shade100,
                          child: Icon(
                            isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: isPositive ? Colors.red : Colors.green,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isPositive
                                    ? "You owe ${otherUser}"
                                    : "${otherUser} owes you",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                isPositive
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
                          "\$${amount.abs().toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isPositive ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Transaction history section
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

          Expanded(
            child: transactions.isEmpty
                ? Center(
              child: Text(
                "No transactions yet",
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, i) {
                Transaction transaction = transactions[i];
                bool isPayer = transaction.payerId == userName;
                bool isRecipient = transaction.splitBetween.contains(userName);

                // Skip transactions not related to this user
                if (!isPayer && !isRecipient) return SizedBox.shrink();

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 2,
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
                    subtitle: Text(
                      "Split between: ${transaction.splitBetween.join(', ')}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      "${transaction.dateTime.day}/${transaction.dateTime.month}/${transaction.dateTime.year}",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}