// widgets/balance_summary_widget.dart - Widget for displaying balance summaries
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/balance_calculator.dart';

class BalanceSummaryWidget extends StatelessWidget {
  final String userName;
  final int userIndex;
  final List<String> userNames;
  final List<Transaction> transactions;

  const BalanceSummaryWidget({
    Key? key,
    required this.userName,
    required this.userIndex,
    required this.userNames,
    required this.transactions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate balances for this user
    Map<String, Map<String, double>> balances =
        BalanceCalculator.calculateBalances(transactions, userNames);

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: userNames.length,
      itemBuilder: (context, i) {
        if (i == userIndex) return SizedBox.shrink(); // Skip self

        String otherUser = userNames[i];
        double youOweAmount = balances[userName]?[otherUser] ?? 0;
        double theyOweAmount = balances[otherUser]?[userName] ?? 0;

        // Skip if there's no debt in either direction
        if (youOweAmount == 0 && theyOweAmount == 0)
          return SizedBox.shrink();

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
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: youOwe ? Colors.red.shade300 : Colors.green.shade300,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      youOwe ? Colors.red.shade100 : Colors.green.shade100,
                  child: Icon(
                    youOwe ? Icons.arrow_upward : Icons.arrow_downward,
                    color: youOwe ? Colors.red : Colors.green,
                    size: 14,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          youOwe
                              ? "You owe ${otherUser}"
                              : "${otherUser} owes you",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  "\$${netAmount.abs().toStringAsFixed(2)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: youOwe ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}